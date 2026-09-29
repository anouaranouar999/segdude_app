import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_serialization.dart';
import 'package:segdude_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/widgets/add_dialogs.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'printer_page.dart';
import 'schedule_result_tab2.dart';
import 'schedule_result_tab3.dart';
import 'schedule_result_tab4.dart';

const _blue = Color(0xFF2A6FDB);
const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);
const _divider = Color(0xFFDDE3EC);
const _pageBg = Color(0xFFF4F7FB);
const _textPrimary = Color(0xFF1A2E4A);
const _textSecondary = Color(0xFF5A6A85);

class ScheduleResultPage extends ConsumerStatefulWidget {
  final ScheduleDecoder? schedule;
  const ScheduleResultPage({super.key, this.schedule});

  @override
  ConsumerState<ScheduleResultPage> createState() => _ScheduleResultPageState();
}

class _ScheduleResultPageState extends ConsumerState<ScheduleResultPage> {
  final prefs = SharedPreferencesService();
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final daysMap = <String, String>{
      AppLocalizations.of(context)?.dayMonday ?? 'Monday': '1',
      AppLocalizations.of(context)?.dayTuesday ?? 'Tuesday': '2',
      AppLocalizations.of(context)?.dayWednesday ?? 'Wednesday': '3',
      AppLocalizations.of(context)?.dayThursday ?? 'Thursday': '4',
      AppLocalizations.of(context)?.dayFriday ?? 'Friday': '5',
      AppLocalizations.of(context)?.daySaturday ?? 'Saturday': '6',
      AppLocalizations.of(context)?.daySunday ?? 'Sunday': '7',
    };

    final l10n = AppLocalizations.of(context)!;
    final scheduleData = widget.schedule;
    final classId = ref.watch(levelsProvider.select((s) => s.classID));
    if (scheduleData == null) {
      Future.delayed(Duration(seconds: 5), () {
        if (context.mounted) context.go('/');
      });
      return Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(title: Text(l10n.scheduleResult)),
        body: Center(
          child: Text(
            l10n.noScheduleDataGoHome,
            style: TextStyle(color: _textSecondary),
          ),
        ),
      );
    }
    final scheduleValue = scheduleData;
        return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          title: Text(l10n.scheduleResult),
          bottom: TabBar(
            // isScrollable: true,
            tabs: [
              Tab(text: l10n.roleStudent), //Tab 1
              Tab(text: l10n.teacher), // Tab 2
              Tab(text: l10n.supervisor), //Tab 3
              Tab(text: "Free Resources"), //Tab 4
            ],
            labelColor: _blue,
            unselectedLabelColor: _textSecondary,
            indicatorColor: _blue,
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                context.go('/');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.goHome,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            if (scheduleData.error == null) ...[
              OutlinedButton.icon(
                onPressed: () {
                  ScheduleSerialization.exportSchedule(ref, context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  l10n.localeName == 'ar'
                      ? 'تنزيل / حفظ'
                      : l10n.localeName == 'fr'
                      ? 'Enregistrer'
                      : 'Save / Download',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  context.go(
                    '/create/schedule_second_page/result/schedule_skeleton',
                    extra: scheduleValue,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.settings,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Current Schedule Result
            scheduleValue.error != null
                ? ErrorViewer(schedule: scheduleValue)
                : Row(
                    children: [
                      // ── Collapsible sidebar (levels + classes) ──────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: SizedBox(
                          width: _sidebarCollapsed ? 0 : 320,
                          height: double.infinity,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 150,
                                height: double.infinity,
                                child: Column(
                                  children: [
                                    _SidebarHeader(title: l10n.levels),
                                    Expanded(child: LevelsList()),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                thickness: 1,
                                width: 1,
                                color: _divider,
                              ),
                              SizedBox(
                                width: 169,
                                height: double.infinity,
                                child: Column(
                                  children: [
                                    _SidebarHeader(title: l10n.classes),
                                    Expanded(child: ClassesList()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ── Toggle button ───────────────────────────────────
                      Container(
                        width: 1,
                        height: double.infinity,
                        color: _divider,
                      ),
                      Tooltip(
                        message: _sidebarCollapsed
                            ? l10n.levels
                            : l10n.collapse,
                        child: InkWell(
                          onTap: () => setState(
                            () => _sidebarCollapsed = !_sidebarCollapsed,
                          ),
                          child: Container(
                            width: 20,
                            height: double.infinity,
                            color: _headerBg,
                            child: Center(
                              child: AnimatedRotation(
                                turns: _sidebarCollapsed ? 0 : 0.5,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: _headerText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: double.infinity,
                        color: _divider,
                      ),
                      // ── Schedule table ──────────────────────────────────
                      ScheduleResult(payLoad: scheduleValue, daysMap: daysMap),
                    ],
                  ),
            // Tab 2: Summary of slots, rooms, teachers
            TeacherSchedule(schedule: scheduleValue),
            ScheduleResultTab2(schedule: scheduleValue),
            ScheduleResultTab4(schedule: scheduleValue, daysMap: daysMap),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return ListenableBuilder(
              listenable: tabController,
              builder: (context, _) {
                if (tabController.index == 1) {
                  return const SizedBox.shrink();
                }
                if (tabController.index == 2) {
                  return const SizedBox.shrink();
                }
                return scheduleData.error != null
                    ? FloatingActionButton.extended(
                        elevation: 4,
                        label: Text(
                          l10n.tryAgain,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _blue,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          context.pop();
                        },
                      )
                    : FloatingActionButton.extended(
                        elevation: 4,
                        label: Text(
                          l10n.print,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _blue,
                        icon: const Icon(Icons.print, color: Colors.white),
                        onPressed: () {
                          if (classId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.pleaseSelectAClassFirst),
                                backgroundColor: const Color(0xFFE6A23C),
                              ),
                            );
                            return;
                          }
                          final subjects = ref.read(subjectsProvider).subjects;
                          final teachers = ref.read(teachersProvider).teachers;
                          final rooms = ref.read(roomsProvider).rooms;
                          final settings = ref.read(settingsProvider);
                          final selectedClass = ref
                              .read(levelsProvider.select((s) => s.classes))
                              .where((c) => c.classId == classId)
                              .firstOrNull;
                          final showTeachersNames = ref.watch(
                            settingsProvider.select((s) => s.showTeachersNames),
                          );
                          PrintDemo().printDocument(
                            scheduleData,
                            classId - 1,
                            settings,
                            subjects,
                            teachers,
                            rooms,
                            settings.selectedDays,
                            settings.startTime,
                            settings.minutesList,
                            selectedClass!.className ?? '',
                            l10n,
                            daysMap,
                            showTeachersNames ?? true,
                          );
                        },
                      );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String title;
  const _SidebarHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: _headerBg,
      height: 44,
      width: double.infinity,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _headerText,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------- Returns a list of levels
class LevelsList extends ConsumerWidget {
  const LevelsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final levels = ref.watch(levelsProvider.select((s) => s.levels));
    final levelsIds = ref.watch(levelsProvider.select((s) => s.levelIds));
    final selectedLevel = ref.watch(
      levelsProvider.select((s) => s.selectedLevel),
    );
    final levelEntries = levelsIds.entries.toList();
    return ListView.separated(
      itemCount: levels.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: _divider),
      itemBuilder: (context, index) {
        final level = levelEntries[index];
        final isSelected = selectedLevel == level.key;

        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.white,
          tileColor: isSelected ? Colors.white : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            level.key,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: _textPrimary,
            ),
          ),
          trailing: Text(
            levelsIds[level.key].toString(),
            style: const TextStyle(color: _textSecondary),
          ),
          subtitle: Text(
            l10n.clsCount(levels[level.key] ?? 0),
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
          hoverColor: const Color(0xFFE8F0FD),
          onTap: () {
            ref.read(levelsProvider.notifier).setClassesGroupId(level.value);
            ref.read(levelsProvider.notifier).setSelectedLevelId(level.value);
            ref.read(levelsProvider.notifier).setSelectedLevel(level.key);

            // Auto-select first class of this level
            final levelClasses = ref
                .read(levelsProvider)
                .classes
                .where((c) => c.levelId == level.value)
                .toList();
            if (levelClasses.isNotEmpty) {
              ref
                  .read(levelsProvider.notifier)
                  .setClassID(levelClasses.first.classId!);
            }
          },
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------- Returns a list of classes
class ClassesList extends ConsumerWidget {
  const ClassesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final classesGroupID = ref.watch(
      levelsProvider.select((s) => s.classesGroupID),
    );
    final classes = ref.watch(levelsProvider.select((s) => s.classes));
    final filteredClasses = classesGroupID != null
        ? classes.where((cls) => cls.levelId == classesGroupID).toList()
        : [];

    if (classes.isEmpty || classesGroupID == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            l10n.selectLevel,
            style: TextStyle(
              color: _textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredClasses.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: _divider),
      itemBuilder: (context, index) {
        final cls = filteredClasses[index];
        final isSelected =
            cls.classId == ref.watch(levelsProvider.select((s) => s.classID));

        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.white,
          tileColor: isSelected ? Colors.white : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          onTap: () {
            ref.read(levelsProvider.notifier).setClassID(cls.classId!);
          },
          title: Text(
            cls.className.toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: _textPrimary,
            ),
          ),
          hoverColor: const Color(0xFFE8F0FD),
        );
      },
    );
  }
}

/// ----------------------------------------------------------------------------Returns and Shows schedule table
class ScheduleResult extends ConsumerStatefulWidget {
  const ScheduleResult({
    super.key,
    required this.payLoad,
    required this.daysMap,
  });
  final ScheduleDecoder payLoad;
  final Map<String, String> daysMap;

  @override
  ConsumerState<ScheduleResult> createState() => _ScheduleResultState();
}

class _ScheduleResultState extends ConsumerState<ScheduleResult> {
  ScheduleDecoder get payLoad => widget.payLoad;
  Map<String, String> get daysMap => widget.daysMap;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider);
    final classes = ref.watch(levelsProvider.select((s) => s.classes));
    final timing = ref.read(settingsProvider);
    final classID = ref.watch(levelsProvider.select((s) => s.classID));
    final subjects = ref.read(subjectsProvider).subjects;
    final teachers = ref.read(teachersProvider).teachers;
    final rooms = ref.read(roomsProvider).rooms;
    final selectedDays = ref.read(settingsProvider).selectedDays;
    final startTime = ref.read(settingsProvider).startTime;
    final minutes = ref.watch(settingsProvider).minutesList;
    final endMinutes = ref.watch(settingsProvider).endMinutesList;
    final activeClassSchedule = payLoad.classes.isEmpty
        ? const ClassSchedule(classId: '', days: [])
        : payLoad.classes.firstWhere(
            (c) => classID != null ? c.classId == classID.toString() : true,
            orElse: () => payLoad.classes.first,
          );

    final selectedClass = classes
        .where((c) => c.classId == classID)
        .firstOrNull;
    final days = <String>[...daysMap.keys];
    final showSubjectColors = ref.watch(settingsProvider).showSubjectColors;
    final showTeachersNames = ref.watch(settingsProvider).showTeachersNames;

    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              color: _headerBg,
              height: 44,
              width: double.infinity,
              child: Text(
                selectedClass != null
                    ? '${selectedClass.className}'
                    : l10n.selectAClass,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _headerText,
                ),
              ),
            ),
            const Divider(height: 1, color: _divider),
            if (selectedClass != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _divider),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Builder(
                        builder: (_) {
                          // Wraps a cell in an Expanded with the given flex,
                          // so that merged lesson cells (flex = span * 10)
                          // render wider than normal cells (flex = 10),
                          // matching the previous FlexColumnWidth ratios
                          // (day column 1.2 -> flex 12, other columns 1.0
                          // -> flex 10 per timeslot).
                          Widget flexCell(int flex, Widget child) {
                            return Expanded(flex: flex, child: child);
                          }

                          return Column(
                            children: List.generate(timing.daysPerWeek + 1, (
                              rowIndex,
                            ) {
                              final dayIndex = rowIndex == timing.daysPerWeek
                                  ? timing.daysPerWeek - 1
                                  : rowIndex - 1;

                              final hasSlots =
                                  activeClassSchedule.days.isNotEmpty &&
                                  dayIndex >= 0 &&
                                  dayIndex < activeClassSchedule.days.length &&
                                  activeClassSchedule
                                      .days[dayIndex]
                                      .slots
                                      .isNotEmpty;
                              final isLocked =
                                  hasSlots &&
                                  activeClassSchedule
                                          .days[dayIndex]
                                          .slots[0]
                                          .slotId ==
                                      'lock';

                              final rowCells = <Widget>[];
                              var colIndex = 0;
                              while (colIndex <= timing.timeslotsPerDay) {
                                final timeIndex =
                                    colIndex == timing.timeslotsPerDay
                                    ? timing.timeslotsPerDay - 1
                                    : colIndex - 1;

                                // Break periods never contain lessons, so
                                // hide their column entirely instead of
                                // wasting horizontal space on an empty cell.
                                if (colIndex != 0 &&
                                    timing.breakHoursPerDay.contains(
                                      startTime + timeIndex,
                                    )) {
                                  colIndex += 1;
                                  continue;
                                }

                                if (colIndex == 0 && rowIndex == 0) {
                                  rowCells.add(
                                    flexCell(
                                      12,
                                      Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(0),
                                        child: const Text('  '),
                                      ),
                                    ),
                                  );
                                  colIndex += 1;
                                  continue;
                                }
                                if (rowIndex == 0) {
                                  rowCells.add(
                                    flexCell(
                                      10,
                                      Material(
                                        color: Colors.transparent,
                                        child: MaterialButton(
                                          hoverColor: Colors.blue.shade200,
                                          // The default MaterialButton
                                          // padding (16px horizontal) and
                                          // minWidth (88px) were eating most
                                          // of the narrow column's width,
                                          // which is what forced the label
                                          // into an ellipsis.
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          minWidth: 0,
                                          onPressed: () async {
                                            // print(
                                            //   activeClassSchedule
                                            //           .days[0]
                                            //           .slots[0]
                                            //           .lesson
                                            //           ?.mergeWith ??
                                            //       'no merge',
                                            // );
                                            updateMinuteDialog(
                                              context,
                                              ref,
                                              timeIndex,
                                            );
                                          },
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${(startTime + timeIndex).toString().padLeft(2, '0')}:${minutes[timeIndex].toString().padLeft(2, '0')}'
                                              '–'
                                              '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:${endMinutes[timeIndex].toString().padLeft(2, '0')}',
                                              maxLines: 1,
                                              softWrap: false,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _headerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  colIndex += 1;
                                  continue;
                                }
                                if (colIndex == 0) {
                                  rowCells.add(
                                    flexCell(
                                      12,
                                      Container(
                                        height: 80,
                                        alignment: Alignment.center,
                                        color: _headerBg,
                                        padding: const EdgeInsets.all(2),
                                        child: Text(
                                          days[int.parse(
                                                selectedDays[dayIndex],
                                              ) -
                                              1],
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: _headerText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  colIndex += 1;
                                  continue;
                                }

                                // Determine how many consecutive timeslots
                                // (starting at timeIndex) share the same
                                // subjectId, teacherId and roomId, so they
                                // can be rendered as a single merged cell.
                                var span = 1;
                                if (hasSlots &&
                                    !isLocked &&
                                    timeIndex >= 0 &&
                                    timeIndex <
                                        activeClassSchedule
                                            .days[dayIndex]
                                            .slots
                                            .length &&
                                    activeClassSchedule
                                            .days[dayIndex]
                                            .slots[timeIndex]
                                            .lesson
                                            ?.subjectId !=
                                        null) {
                                  final lesson = activeClassSchedule
                                      .days[dayIndex]
                                      .slots[timeIndex]
                                      .lesson!;
                                  while (timeIndex + span <
                                          timing.timeslotsPerDay &&
                                      timeIndex + span <
                                          activeClassSchedule
                                              .days[dayIndex]
                                              .slots
                                              .length) {
                                    final nextLesson = activeClassSchedule
                                        .days[dayIndex]
                                        .slots[timeIndex + span]
                                        .lesson;
                                    if (nextLesson == null ||
                                        nextLesson.subjectId !=
                                            lesson.subjectId ||
                                        nextLesson.teacherId !=
                                            lesson.teacherId ||
                                        nextLesson.roomId != lesson.roomId ||
                                        nextLesson.group != lesson.group) {
                                      break;
                                    }
                                    span++;
                                  }
                                }

                                Color? cellColor;
                                if ((showSubjectColors ?? true) &&
                                    hasSlots &&
                                    !isLocked &&
                                    timeIndex >= 0 &&
                                    timeIndex <
                                        activeClassSchedule
                                            .days[dayIndex]
                                            .slots
                                            .length &&
                                    activeClassSchedule
                                            .days[dayIndex]
                                            .slots[timeIndex]
                                            .lesson
                                            ?.subjectId !=
                                        null) {
                                  final sId = activeClassSchedule
                                      .days[dayIndex]
                                      .slots[timeIndex]
                                      .lesson!
                                      .subjectId;
                                  if (sId > 0 && sId <= subjects.length) {
                                    final subject = subjects[sId - 1];
                                    if (subject.color != null) {
                                      cellColor = Color(
                                        subject.color!,
                                      ).withValues(alpha: 0.15);
                                    }
                                  }
                                }

                                rowCells.add(
                                  flexCell(
                                    10 * span,
                                    Container(
                                      height: 80,
                                      alignment: Alignment.center,
                                      color: cellColor,
                                      padding: const EdgeInsets.all(8.0),
                                      child: !hasSlots
                                          ? const SizedBox()
                                          : isLocked
                                          ? IconButton(
                                              onPressed: () {
                                                if (user != null) {
                                                  context.go(
                                                    '/create/schedule_second_page/result/buy_page',
                                                  );
                                                } else {
                                                  context.push(
                                                    '/login',
                                                    extra: payLoad,
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.lock,
                                                color: Colors.red,
                                              ),
                                            )
                                          : timeIndex >= 0 &&
                                                timeIndex <
                                                    activeClassSchedule
                                                        .days[dayIndex]
                                                        .slots
                                                        .length &&
                                                activeClassSchedule
                                                        .days[dayIndex]
                                                        .slots[timeIndex]
                                                        .lesson
                                                        ?.subjectId !=
                                                    null
                                          ? Stack(
                                              alignment: Alignment.topLeft,
                                              children: [
                                                Positioned.fill(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${subjects[activeClassSchedule.days[dayIndex].slots[timeIndex].lesson!.subjectId - 1].subjectName}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                          color: _textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      // if subject has no room roomId = -1 show empty Text widget instead of 'no room'
                                                      if (activeClassSchedule
                                                              .days[dayIndex]
                                                              .slots[timeIndex]
                                                              .lesson!
                                                              .roomId !=
                                                          -1)
                                                        Text(
                                                          rooms[activeClassSchedule
                                                                      .days[dayIndex]
                                                                      .slots[timeIndex]
                                                                      .lesson!
                                                                      .roomId -
                                                                  1]
                                                              .roomName,
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                _textSecondary,
                                                          ),
                                                        ),
                                                      if (activeClassSchedule
                                                                  .days[dayIndex]
                                                                  .slots[timeIndex]
                                                                  .lesson!
                                                                  .teacherId >
                                                              0 &&
                                                          activeClassSchedule
                                                                  .days[dayIndex]
                                                                  .slots[timeIndex]
                                                                  .lesson!
                                                                  .teacherId <=
                                                              teachers
                                                                  .length) ...[
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        if (showTeachersNames ??
                                                            false)
                                                          Text(
                                                            '${teachers[activeClassSchedule.days[dayIndex].slots[timeIndex].lesson!.teacherId - 1].teacherName}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  _textSecondary,
                                                            ),
                                                          ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                // ----------------------------- If this class is split show group number
                                                if (activeClassSchedule
                                                        .days[dayIndex]
                                                        .slots[timeIndex]
                                                        .lesson!
                                                        .group !=
                                                    null)
                                                  Container(
                                                    alignment: .topRight,
                                                    child: CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor:
                                                          Colors.black,
                                                      child: Text(
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: .bold,
                                                          fontSize: 10,
                                                        ),
                                                        "${activeClassSchedule.days[dayIndex].slots[timeIndex].lesson!.group}",
                                                      ),
                                                    ),
                                                  ),
                                                // --------------------------- if this class belongs is merged with other class(s)
                                                if (activeClassSchedule
                                                        .days[dayIndex]
                                                        .slots[timeIndex]
                                                        .lesson!
                                                        .mergeWith !=
                                                    null)
                                                  Container(
                                                    alignment: .topRight,
                                                    child: Text(
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: .bold,
                                                        fontSize: 10,
                                                      ),
                                                      "${activeClassSchedule.days[dayIndex].slots[timeIndex].lesson!.mergeWith}",
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : const Text(' '),
                                    ),
                                  ),
                                );
                                colIndex += span;
                              }

                              // Insert thin dividers between cells to
                              // replicate the previous Table's inside
                              // vertical borders.
                              final spacedRowCells = <Widget>[];
                              for (var i = 0; i < rowCells.length; i++) {
                                if (i > 0) {
                                  spacedRowCells.add(
                                    const VerticalDivider(
                                      width: 0,
                                      thickness: 1,
                                      color: _divider,
                                    ),
                                  );
                                }
                                spacedRowCells.add(rowCells[i]);
                              }

                              return Column(
                                children: [
                                  // Replicates the previous Table's inside
                                  // horizontal borders (skipped above the
                                  // first row).
                                  if (rowIndex > 0)
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: _divider,
                                    ),
                                  Container(
                                    color: rowIndex == 0
                                        ? _headerBg
                                        : Colors.white,
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: spacedRowCells,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.table_chart_outlined,
                        size: 48,
                        color: _divider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.selectClassToViewSchedule,
                        style: const TextStyle(
                          color: _textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ErrorViewer extends ConsumerWidget {
  const ErrorViewer({super.key, required this.schedule});
  final ScheduleDecoder? schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Extract error data securely
    final errorData = schedule?.error;
    if (errorData == null) return const SizedBox.shrink();

    final errorMessage = errorData['error'] ?? l10n.scheduleGenerationFailed;
    final diagnostics =
        errorData['diagnostics']?['issues'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.red.shade100),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        errorMessage.toString(),
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              if (diagnostics.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20),
                    itemCount: diagnostics.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final issue = diagnostics[index];
                      final category =
                          issue['category']?.toString() ?? l10n.generalCategory;
                      final message =
                          issue['message']?.toString() ??
                          l10n.noDetailsProvided;
                      final hint = issue['hint']?.toString();

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: category == "License Error"
                                  ? Text(
                                      l10n.licenseError,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange.shade900,
                                      ),
                                    )
                                  : Text(
                                      category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            // Error Message
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFFD32F2F),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (hint != null && hint.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              // Hint/Solution
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade100,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 18,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.solutionHint(hint),
                                        style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (category == "License Error")
                              const SizedBox(height: 8),
                            if (category == "License Error")
                              ElevatedButton(
                                onPressed: () {
                                  context.push('/pricing');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l10n.getALicense),
                              ),

                            if (category == "License Error")
                              const SizedBox(height: 8),
                            if (category == "License Error")
                              ElevatedButton(
                                onPressed: () {
                                  context.go('/');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l10n.goHome),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      l10n.noFurtherDiagnostics,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
