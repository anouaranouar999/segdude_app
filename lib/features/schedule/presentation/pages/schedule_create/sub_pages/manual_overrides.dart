import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/manual_overrides_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/responsive_width_guard.dart';

// UI Color tokens
const _blue = Color(0xFF2A6FDB);
const _pageBg = Color(0xFFF4F7FB);
const _divider = Color(0xFFDDE3EC);
const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);
const _cardBorder = Color(0xFFE2E8F0);
const _breakColor = Color(0xFFF8FAFC);

/// A highly visual template-grid planner sub-page that allows pinning specific
/// subjects, teachers, and rooms to a specific class, day, and timeslot.
class ManualOverridesPage extends ConsumerStatefulWidget {
  const ManualOverridesPage({super.key});

  @override
  ConsumerState<ManualOverridesPage> createState() =>
      _ManualOverridesPageState();
}

class _ManualOverridesPageState extends ConsumerState<ManualOverridesPage> {
  ClassLevelEncoder? _selectedClass;

  List<String> _getDaysOfWeek(AppLocalizations l10n) => [
    l10n.dayMonday,
    l10n.dayTuesday,
    l10n.dayWednesday,
    l10n.dayThursday,
    l10n.dayFriday,
    l10n.daySaturday,
    l10n.daySunday,
  ];

  // Below this width the 200px sidebar + per-day/per-timeslot calendar
  // grid (see `build` below) starts producing RenderFlex overflows, so the
  // page isn't built at all.
  static const double _kMinPageWidth = 1100;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidthGuard(minWidth: _kMinPageWidth, builder: _buildPage);
  }

  Widget _buildPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levelsState = ref.watch(levelsProvider);
    final settings = ref.watch(settingsProvider);
    final allOverrides = ref.watch(manualOverridesProvider).overrides;

    final daysOfWeek = _getDaysOfWeek(l10n);

    // Get current levels & selected level
    final levelsList = levelsState.levels.keys.toList();
    final selectedLevelName = levelsState.selectedLevel;
    final selectedLevelId = selectedLevelName != 'None'
        ? levelsState.levelIds[selectedLevelName]
        : null;

    // Filter classes to only show classes belonging to the selected level
    final filteredClasses = selectedLevelId != null
        ? levelsState.classes
              .where((c) => c.levelId == selectedLevelId)
              .toList()
        : <ClassLevelEncoder>[];

    // Auto-select first class if none selected or if selected class doesn't belong to current level
    if (_selectedClass == null && filteredClasses.isNotEmpty) {
      _selectedClass = filteredClasses.first;
    } else if (_selectedClass != null &&
        !filteredClasses.any((c) => c.classId == _selectedClass!.classId)) {
      _selectedClass = filteredClasses.isNotEmpty
          ? filteredClasses.first
          : null;
    }

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        title: Text(l10n.manualOverridesPlanner),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: levelsList.isEmpty
          ? _EmptyState(message: l10n.pleaseAddLevelsFirst)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left Sidebar: Level & Class Selector ──────────────────────
                Container(
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: _divider)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Level Selector Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: _headerBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectLevel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _headerText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: selectedLevelName == 'None'
                                  ? null
                                  : selectedLevelName,
                              hint: Text(l10n.chooseLevel),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: levelsList.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                      .read(levelsProvider.notifier)
                                      .setSelectedLevel(val);
                                  setState(() {
                                    _selectedClass =
                                        null; // reset class to auto-select
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: _divider),
                      // Classes List Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          selectedLevelName == 'None'
                              ? l10n.classes
                              : l10n.classesInLevel(selectedLevelName),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2E4A),
                          ),
                        ),
                      ),
                      // Classes List Scrollable
                      Expanded(
                        child: filteredClasses.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.selectLevelToViewClasses,
                                  style: const TextStyle(
                                    color: Color(0xFF8A9BB5),
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredClasses.length,
                                itemBuilder: (context, idx) {
                                  final itemClass = filteredClasses[idx];
                                  final isSel =
                                      _selectedClass?.classId ==
                                      itemClass.classId;
                                  final classOverrideCount = allOverrides
                                      .where(
                                        (o) => o.classId == itemClass.classId,
                                      )
                                      .length;

                                  return ListTile(
                                    selected: isSel,
                                    title: Text(
                                      itemClass.className ?? '',
                                      style: TextStyle(
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSel
                                            ? _blue
                                            : const Color(0xFF1A2E4A),
                                      ),
                                    ),
                                    trailing: classOverrideCount > 0
                                        ? Chip(
                                            labelPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            backgroundColor: const Color(
                                              0xFFE6F7F4,
                                            ),
                                            side: BorderSide.none,
                                            label: Text(
                                              l10n.nPinned(classOverrideCount),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF148570),
                                              ),
                                            ),
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedClass = itemClass;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // ── Right Work Area: Calendar Grid ───────────────────────────
                Expanded(
                  child: _selectedClass == null
                      ? _EmptyState(message: l10n.selectClassToStartPinning)
                      : settings.selectedDays.isEmpty ||
                            settings.timeslotsPerDay == 0
                      ? _EmptyState(
                          message: l10n.pleaseCompleteWorkingDaysConfig,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Class Header Summary Banner
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),

                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(color: _divider),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    color: _blue,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.templatePlannerTitle(
                                          _selectedClass!.className ?? '',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A2E4A),
                                        ),
                                      ),
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        l10n.templatePlannerSubtitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (allOverrides.any(
                                    (o) => o.classId == _selectedClass!.classId,
                                  ))
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFD94040,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFD94040),
                                        ),
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(
                                              manualOverridesProvider.notifier,
                                            )
                                            .clearOverrides();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              overflow: TextOverflow.ellipsis,
                                              l10n.clearedOverridesForClass,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.clear_all,
                                        size: 18,
                                      ),
                                      label: Text(l10n.clearOverrides),
                                    ),
                                ],
                              ),
                            ),

                            // Interactive Weekly Planner Grid
                            Expanded(
                              child: _CalendarGrid(
                                selectedClass: _selectedClass!,
                                selectedLevelId: selectedLevelId!,
                                days: settings.selectedDays,
                                timeslotsPerDay: settings.timeslotsPerDay,
                                startTime: settings.startTime,
                                breakHours: settings.breakHoursPerDay,
                                allDays: daysOfWeek,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

/// Renders a beautiful weekly schedule grid, columns are days, rows are hours.
class _CalendarGrid extends ConsumerWidget {
  final ClassLevelEncoder selectedClass;
  final int selectedLevelId;
  final List<String> days;
  final int timeslotsPerDay;
  final int startTime;
  final List<int> breakHours;
  final List<String> allDays;

  const _CalendarGrid({
    required this.selectedClass,
    required this.selectedLevelId,
    required this.days,
    required this.timeslotsPerDay,
    required this.startTime,
    required this.breakHours,
    required this.allDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overrides = ref.watch(manualOverridesProvider).overrides;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Row (Timeslots columns)
          Row(
            children: [
              // Days corner spacing cell
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    l10n.daySlotHeader,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF8A9BB5),
                    ),
                  ),
                ),
              ),
              // Slot columns
              ...List.generate(timeslotsPerDay, (slotIdx) {
                final slotNum = slotIdx + 1;
                final hourStart = startTime + slotIdx;
                final timeLabel = '$hourStart:00 - ${hourStart + 1}:00';
                final isBreak = breakHours.contains(hourStart);

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isBreak ? _breakColor : _headerBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _divider),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.slotNumber(slotNum),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isBreak
                                ? const Color(0xFF8A9BB5)
                                : _headerText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: isBreak
                                ? const Color(0xFFADC0D9)
                                : const Color(0xFF8A9BB5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),

          // Scrollable Grid Rows (Each row is a Day)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: days.map((dayName) {
                  // Get 1-based day index from the standard list
                  final dayId = days.indexOf(dayName) + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      height: 85,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Day Left Label
                          Container(
                            width: 100,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: _divider),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              allDays[int.parse(dayName) - 1],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2E4A),
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Timeslot Cells for this Day
                          ...List.generate(timeslotsPerDay, (slotIdx) {
                            final slotNum = slotIdx + 1;
                            final hourStart = startTime + slotIdx;
                            final isBreak = breakHours.contains(hourStart);

                            // Find matching override for this day and slot
                            final matchOverride = overrides.firstWhere(
                              (o) =>
                                  o.classId == selectedClass.classId &&
                                  o.day == dayId &&
                                  o.timeslot == slotNum,
                              orElse: () =>
                                  ManualOverrideEncoder(-1, -1, -1, -1, -1, -1),
                            );

                            final hasOverride = matchOverride.classId != -1;

                            if (isBreak) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _breakColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _divider,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.breakTime,
                                      style: const TextStyle(
                                        color: Color(0xFF8A9BB5),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: hasOverride
                                    ? _OverrideCard(
                                        manualOverride: matchOverride,
                                        onDelete: () {
                                          ref
                                              .read(
                                                manualOverridesProvider
                                                    .notifier,
                                              )
                                              .removeOverride(
                                                selectedClass.classId!,
                                                dayId,
                                                slotNum,
                                              );
                                        },
                                      )
                                    : _EmptyCell(
                                        onTap: () => _showAddOverrideDialog(
                                          context,
                                          ref,
                                          selectedClass,
                                          selectedLevelId,
                                          dayId,
                                          slotNum,
                                          dayName,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOverrideDialog(
    BuildContext context,
    WidgetRef ref,
    ClassLevelEncoder selectedClass,
    int levelId,
    int dayId,
    int timeslot,
    String dayName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddOverrideDialog(
          selectedClass: selectedClass,
          levelId: levelId,
          dayId: dayId,
          timeslot: timeslot,
          dayName: dayName,
        );
      },
    );
  }
}

/// A card displaying the active override details with a hover delete button.
class _OverrideCard extends ConsumerWidget {
  final ManualOverrideEncoder manualOverride;
  final VoidCallback onDelete;

  const _OverrideCard({required this.manualOverride, required this.onDelete});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final includeTeachers = settings.includeTeachersInPayload;
    final subjects = ref.watch(subjectsProvider).subjects;
    final teachers = ref.watch(teachersProvider).teachers;
    final rooms = ref.watch(roomsProvider).rooms;

    final subjectName = subjects
        .firstWhere(
          (s) => s.subjectId == manualOverride.subjectId,
          orElse: () => SubjectEncoder(-1, l10n.unknownSubject, null),
        )
        .subjectName;

    final displayTeacherName =
        teachers
            .firstWhere(
              (t) => t.teacherId == manualOverride.teacherId,
              orElse: () => TeacherEncoder(-1, null, -1, []),
            )
            .teacherName ??
        l10n.unknownTeacher;

    final roomName = rooms
        .firstWhere(
          (r) => r.roomId == manualOverride.roomId,
          orElse: () => RoomEncoder(-1, l10n.unknownRoom, 0, [], [], {}),
        )
        .roomName;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subjectName ?? l10n.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD94040),
                  size: 16,
                ),
              ),
            ],
          ),
          if (includeTeachers) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, size: 12, color: Color(0xFF047857)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    displayTeacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.meeting_room,
                size: 12,
                color: Color(0xFF047857),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dotted cell ready to be tapped to override a timeslot constraint.
class _EmptyCell extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyCell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: const Color(0xFFF1F5F9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _cardBorder, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 20, color: Color(0xFF9DB5D8)),
        ),
      ),
    );
  }
}

/// A dialog containing dropdowns to configure the override. Filtering is applied
/// so that only qualified teachers for the selected subject and level can be picked.
class _AddOverrideDialog extends ConsumerStatefulWidget {
  final ClassLevelEncoder selectedClass;
  final int levelId;
  final int dayId;
  final int timeslot;
  final String dayName;

  const _AddOverrideDialog({
    required this.selectedClass,
    required this.levelId,
    required this.dayId,
    required this.timeslot,
    required this.dayName,
  });

  @override
  ConsumerState<_AddOverrideDialog> createState() => _AddOverrideDialogState();
}

class _AddOverrideDialogState extends ConsumerState<_AddOverrideDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedSubjectId;
  int? _selectedTeacherId;
  int? _selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final includeTeachers = settings.includeTeachersInPayload;
    final subjects = ref.watch(subjectsProvider).subjects;
    final allTeachers = ref.watch(teachersProvider).teachers;
    final rooms = ref.watch(roomsProvider).rooms;
    // 1. Filter subjects to only show those taught to this level with hours > 0
    final levelKeyStr = widget.levelId.toString();
    final levelSubjects = subjects.where((s) {
      if (s.weeklyHours == null) return false;
      return (s.weeklyHours![levelKeyStr] ?? 0) > 0;
    }).toList();

    // 2. Filter teachers based on chosen subject & qualified levels.
    // If real teachers are not included, return an empty list so manual overrides
    // cannot pin a teacher ID.
    final filteredTeachers = _selectedSubjectId == null || !includeTeachers
        ? <TeacherEncoder>[]
        : allTeachers.where((t) {
            final teachesSubject = t.subjectId == _selectedSubjectId;
            final isQualifiedForLevel =
                t.qualifiedLevels?.contains(widget.levelId) ?? false;
            return teachesSubject && isQualifiedForLevel;
          }).toList();

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.pinLessonForClass(widget.selectedClass.className ?? ''),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dayAndSlot(widget.dayName, widget.timeslot),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subject Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedSubjectId,
                decoration: InputDecoration(
                  labelText: l10n.subject,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (val) =>
                    val == null ? l10n.validationSelectSubject : null,
                items: levelSubjects.map((s) {
                  return DropdownMenuItem(
                    value: s.subjectId,
                    child: Text(s.subjectName ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSubjectId = val;
                    _selectedTeacherId =
                        null; // Reset teacher on subject change
                  });
                },
              ),
              if (includeTeachers) ...[
                const SizedBox(height: 16),

                // Teacher Dropdown (Only enabled once subject is chosen)
                DropdownButtonFormField<int>(
                  initialValue: _selectedTeacherId,
                  decoration: InputDecoration(
                    labelText: l10n.teacher,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    helperText: _selectedSubjectId == null
                        ? l10n.selectSubjectFirst
                        : filteredTeachers.isEmpty
                        ? l10n.noQualifiedTeachersForLevelSubject
                        : null,
                    helperStyle: TextStyle(
                      color:
                          filteredTeachers.isEmpty && _selectedSubjectId != null
                          ? Colors.red
                          : null,
                    ),
                  ),
                  validator: (val) =>
                      val == null ? l10n.validationSelectTeacher : null,
                  items: filteredTeachers.map((t) {
                    return DropdownMenuItem(
                      value: t.teacherId,
                      child: Text(t.teacherName ?? ''),
                    );
                  }).toList(),
                  onChanged:
                      _selectedSubjectId == null || filteredTeachers.isEmpty
                      ? null
                      : (val) {
                          setState(() {
                            _selectedTeacherId = val;
                          });
                        },
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),

              // Room Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedRoomId,
                decoration: InputDecoration(
                  labelText: l10n.room,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (val) =>
                    val == null ? l10n.validationSelectRoom : null,
                items: rooms.map((r) {
                  return DropdownMenuItem(
                    value: r.roomId,
                    child: Text(r.roomName),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRoomId = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _blue),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final override = ManualOverrideEncoder(
                widget.selectedClass.classId!,
                widget.dayId,
                widget.timeslot,
                _selectedSubjectId!,
                includeTeachers ? _selectedTeacherId! : 0,
                _selectedRoomId!,
              );

              ref.read(manualOverridesProvider.notifier).addOverride(override);
              context.pop();
            }
          },
          child: Text(l10n.pinSlot),
        ),
      ],
    );
  }
}

/// Generic page empty state warning.
class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Color(0xFFADC8FF),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5A6A85),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
