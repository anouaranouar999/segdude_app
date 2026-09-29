import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/features/schedule/data/schedule_api.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/manual_overrides_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_result_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

/// Tracks whether a schedule is currently being generated.
final isGeneratingProvider = StateProvider<bool>((ref) => false);

/// Tracks the user's last "continue anyway" decision from the rooms warning
/// dialog. Other widgets may read this to react to the choice.
final continueAnyWayProvider = StateProvider<bool>((ref) => false);

/// Holds the midpoint of the estimated generation time in seconds.
/// Zero means no estimate is available (progress bar falls back to indeterminate
/// style). Set once before generation starts and cleared when it finishes.
final estimatedSecondsProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Generates a schedule based on the current settings and inputs.
void generateSchedule(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;

  ref.read(roomsProvider.notifier).reindexRooms();
  final classes = ref.read(levelsProvider).classes;
  final rooms = ref.read(roomsProvider).rooms;
  final teachers = ref.read(teachersProvider).teachers;
  final consecutiveHours = ref.read(subjectsProvider).consecutiveHours;
  final subjects = ref.read(subjectsProvider).subjects;
  final startTime = ref.read(settingsProvider).startTime;
  final settings = ref.read(settingsProvider);
  final levels = ref.read(levelsProvider).realID;
  final dayOverrides = ref.read(settingsProvider).dayOverrides;
  final manualOverrides = ref.read(manualOverridesProvider).overrides;
  final includeTeachersInPayload = settings.includeTeachersInPayload;
  final groups = ref.read(groupsProvider).groups;
  final mergedClasses = ref.read(groupsProvider).merges;
  final prioritizeStudentOrTeacher = settings.prioritizeStudentTeacher;
  // -------------------------------------------------------------------------
  // Basic presence checks
  // -------------------------------------------------------------------------

  if (subjects.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pleaseAddSubjects)));
    return;
  }
  if (teachers.isEmpty && includeTeachersInPayload) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pleaseAddTeachers)));
    return;
  }
  if (rooms.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pleaseAddRooms)));
    return;
  }

  // -------------------------------------------------------------------------
  // Check that all rooms are not "forced", leaving no free rooms for other
  // subjects that have no forced-room assignment.
  // -------------------------------------------------------------------------

  final allForcedRooms = subjects
      .expand((s) => s.forcedRoomsIds ?? <int>[])
      .toSet();
  final validFreeRooms = rooms
      .where((r) => !allForcedRooms.contains(r.roomId))
      .length;

  if (validFreeRooms == 0) {
    final hasSubjectWithoutForcedRooms = subjects.any(
      (s) => s.forcedRoomsIds == null || s.forcedRoomsIds!.isEmpty,
    );
    if (hasSubjectWithoutForcedRooms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(l10n.allRoomsForcedNoFreeRooms),
        ),
      );
      return;
    }
  }

  // -------------------------------------------------------------------------
  // Check that no forced subject appears in the allowed_subjects of other rooms
  // -------------------------------------------------------------------------

  final forcedSubjects = subjects.where(
    (s) => s.forcedRoomsIds != null && s.forcedRoomsIds!.isNotEmpty,
  );

  for (final subject in forcedSubjects) {
    for (final room in rooms) {
      if (!subject.forcedRoomsIds!.contains(room.roomId) &&
          room.allowedSubjects.contains(subject.subjectId)) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Text(l10n.warning),
              ],
            ),
            content: Text(
              l10n.forcedSubjectInAllowedRooms(
                subject.subjectName ?? '',
                room.roomName,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => dialogContext.pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  // Auto-fix: remove the subject from other rooms' allowedSubjects
                  for (final s in forcedSubjects) {
                    for (final r in rooms) {
                      if (!s.forcedRoomsIds!.contains(r.roomId)) {
                        r.allowedSubjects.remove(s.subjectId);
                      }
                    }
                  }
                  dialogContext.pop();
                  // Restart generation with the fixed data
                  generateSchedule(context, ref);
                },
                child: Text(l10n.continueBtn),
              ),
            ],
          ),
        );
        return;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Validate that every subject has at least one teacher and that each level's
  // hours are covered by a qualified teacher.
  // -------------------------------------------------------------------------

  if (includeTeachersInPayload) {
    for (final subject in subjects) {
      if (!teachers.any((t) => t.subjectId == subject.subjectId)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.insufficientTeachers),
              ],
            ),
            content: Text('${subject.subjectName} ${l10n.hasNoTeacher}'),
            actions: [
              TextButton(onPressed: () => context.pop(), child: Text(l10n.ok)),
            ],
          ),
        );
        return;
      }

      if (subject.weeklyHours == null) continue;

      for (final entry in subject.weeklyHours!.entries) {
        final levelId = int.parse(entry.key);
        final qualifiedForLevel = teachers
            .where((t) => t.subjectId == subject.subjectId)
            .map((t) => t.qualifiedLevels!.contains(levelId))
            .any((e) => e);

        if (!qualifiedForLevel) {
          if (entry.value == 0) continue;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.insufficientTeachers),
                ],
              ),
              content: Text(
                l10n.needHoursNoQualifiedTeacher(
                  entry.value,
                  subject.subjectName ?? '',
                  levels[levelId] ?? '',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
          return;
        }
      }

      // -----------------------------------------------------------------------
      // Check that total teacher capacity covers the required teaching hours.
      // -----------------------------------------------------------------------

      int requiredHours = 0;
      for (final entry in subject.weeklyHours!.entries) {
        final levelId = int.parse(entry.key);
        final hoursPerClass = entry.value;
        final classCount = classes.where((c) => c.levelId == levelId).length;
        requiredHours += classCount * hoursPerClass;
      }

      final int breaksPerDay = settings.breakHoursPerDay.length;
      final int defaultMaxHours =
          settings.daysPerWeek * (settings.timeslotsPerDay - breaksPerDay);

      int availableHours = 0;
      final subjectTeachers = teachers.where(
        (t) => t.subjectId == subject.subjectId,
      );
      for (final t in subjectTeachers) {
        availableHours += (t.maxHoursPerWeek ?? defaultMaxHours);
      }

      if (requiredHours > availableHours) {
        final deficit = requiredHours - availableHours;
        final int neededTeachers = (deficit / defaultMaxHours).ceil();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.insufficientTeachers),
              ],
            ),
            content: Text(
              l10n.notEnoughTeachersContent(
                subject.subjectName ?? '',
                requiredHours,
                availableHours,
                neededTeachers + 1,
              ),
            ),
            actions: [
              TextButton(onPressed: () => context.pop(), child: Text(l10n.ok)),
            ],
          ),
        );
        return;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Room prediction — formula-based (industry standard)
  //
  // Total class-hours per week (CHW):
  //   for each subject → for each level entry → hours × classes_in_level
  // Teaching capacity per room: D × (T − B)
  // Minimum rooms at 75 % utilisation: CHW / (capacity × 0.75)
  // -------------------------------------------------------------------------

  int totalClassHours = 0;
  for (final subject in subjects) {
    if (subject.weeklyHours == null) continue;
    for (final entry in subject.weeklyHours!.entries) {
      final levelId = int.parse(entry.key);
      final hoursPerClass = entry.value;
      final classesInLevel = classes.where((c) => c.levelId == levelId).length;
      totalClassHours += hoursPerClass * classesInLevel;
    }
  }

  final int breaksPerDay = settings.breakHoursPerDay.length;
  final int teachingHoursPerRoom =
      settings.daysPerWeek * (settings.timeslotsPerDay - breaksPerDay);

  const double utilizationRate = 0.75;
  final int predictedRooms = teachingHoursPerRoom > 0
      ? (totalClassHours / (teachingHoursPerRoom * utilizationRate)).ceil()
      : 0;

  // -------------------------------------------------------------------------
  // Build the request payload — reused for both /estimate and /schedule/create.
  // -------------------------------------------------------------------------

  consecutiveHours.where((t) => t.consecutiveHours == 0).forEach((t) {
    t.levelIds = [0];
  });

  final breaks = List<int>.from(settings.breakHoursPerDay);
  for (int i = 0; i < breaks.length; i++) {
    breaks[i] = breaks[i] - (startTime - 1);
  }

  // print(mergedClasses.map((e) => e.toJson()));

  /// ------------------------------------------------------------------------------- put inputs into solver
  final payload = ScheduleJsonEncoder(
    classes,
    subjects,
    teachers,
    rooms,
    manualOverrides,
    consecutiveHours,
    dayOverrides ?? [],
    groups, // SplitGroupEncoder
    mergedClasses: mergedClasses,
    daysPerWeek: settings.daysPerWeek,
    timeslotsPerDay: settings.timeslotsPerDay,
    maxHoursPerDay: settings.maxHoursPerDay,
    breakHoursPerDay: breaks,
    teachersEnabled: includeTeachersInPayload,
    prioritizeStudentOrTeacher: prioritizeStudentOrTeacher,
  ).toJson();

  // -------------------------------------------------------------------------
  // If room count is insufficient, warn the user and let them decide whether
  // to proceed. The dialog drives all further execution — nothing falls through
  // here. If room count is sufficient, go straight to estimate → generate.
  // -------------------------------------------------------------------------

  if (rooms.length < predictedRooms) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.deepOrange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.insufficientRoomsTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.roomCapacityMayBeInsufficient,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(l10n.currentRooms, '${rooms.length} room(s)'),
                const SizedBox(height: 8),
                _buildInfoRow(l10n.predictedNeeded, '~$predictedRooms room(s)'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  l10n.totalClassHoursWeek,
                  '$totalClassHours hours',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  l10n.ratioPerRoom,
                  '$teachingHoursPerRoom hours (at 75% utilization)',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    l10n.schedulerMayFail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(continueAnyWayProvider.notifier).state = false;
                dialogContext.pop();
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(continueAnyWayProvider.notifier).state = true;
                dialogContext.pop();
                // Use the outer page context — dialogContext is invalid after pop.
                _estimateThenGenerate(context, ref, payload, l10n.localeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.tryAnyway),
            ),
          ],
        );
      },
    );
    // Do NOT fall through — generation is driven from inside the dialog.
    return;
  }

  // Sufficient rooms: proceed directly to estimate → generate.
  _estimateThenGenerate(context, ref, payload, l10n.localeName);
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// Calls /schedule/estimate and shows the time-estimate dialog if successful,
/// otherwise falls through to generation immediately.
void _estimateThenGenerate(
  BuildContext context,
  WidgetRef ref,
  dynamic payload,
  String lang,
) {
  ref.read(isGeneratingProvider.notifier).state = true;

  ScheduleApi().estimateSchedule(payload, lang).then((estimate) {
    ref.read(isGeneratingProvider.notifier).state = false;
    if (context.mounted) {
      final int seconds = estimate?['recommended_time_limit_seconds'] ?? 0;
      _runGeneration(context, ref, payload, lang, estimatedSeconds: seconds);
    }
  });
}

/// Shows the estimated generation time dialog and proceeds or cancels based
/// on the user's choice.

/// Performs the actual API call to /schedule/create and handles navigation
/// on success or shows a snack-bar on failure.
void _runGeneration(
  BuildContext context,
  WidgetRef ref,
  dynamic payload,
  String lang, {
  int estimatedSeconds = 0,
}) {
  // Store the estimate so WhileGenerating can drive its progress bar.
  ref.read(estimatedSecondsProvider.notifier).state = estimatedSeconds;
  ref.read(isGeneratingProvider.notifier).state = true;
  ScheduleApi()
      .fetchSchedule(payload, lang)
      .then((value) {
        // Provider writes are unconditional so isGeneratingProvider is never
        // left stuck as true if the widget unmounts mid-request.
        ref.read(isGeneratingProvider.notifier).state = false;
        ref.read(estimatedSecondsProvider.notifier).state = 0;
        ref.read(currentScheduleProvider.notifier).state = value["schedule"];
        if (context.mounted) {
          context.go(
            '/create/schedule_second_page/result',
            extra: value["schedule"],
          );
        }
      })
      .catchError((error) {
        ref.read(isGeneratingProvider.notifier).state = false;
        ref.read(estimatedSecondsProvider.notifier).state = 0;
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      });
}

/// Builds a label/value row used inside dialogs.
Widget _buildInfoRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
