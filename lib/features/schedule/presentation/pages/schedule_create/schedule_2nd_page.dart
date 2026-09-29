import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/shared/widgets/navigation_guard.dart';
import 'package:segdude_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/sub_pages/while_generating.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/widgets/add_dialogs.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/responsive_width_guard.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_service.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/manual_overrides_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'schedule_generator.dart';

const _blue = Color(0xFF2A6FDB);
const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);
const _divider = Color(0xFFDDE3EC);
const _pageBg = Color(0xFFF4F7FB);

// ── File-level pure functions — stateless helpers, no memory concern ──────────

/// Measures the single-line width a piece of text needs for a given style,
/// used below to derive real minimum-width numbers instead of guessing them.
double _textWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width;
}

/// Minimum width `_LevelsListColumn` needs. Its widest fixed-size elements
/// are the header label and the "Add level" button — neither can wrap, so
/// squeezing the column below this width is what would overflow.
double _minLevelsListColumnWidth(AppLocalizations l10n) {
  const headerStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  const addLevelStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

  final headerWidth = _textWidth(l10n.levelsColumnHeader, headerStyle);
  final addLevelWidth = _textWidth(l10n.addLevel, addLevelStyle);

  const addLevelButtonChrome = 18 + 8 + 32; // icon + gap + button padding
  const listTileMinContent =
      160.0; // room for a short title/subtitle/delete icon

  return [
    headerWidth + 32,
    addLevelWidth + addLevelButtonChrome,
    listTileMinContent,
  ].reduce((a, b) => a > b ? a : b);
}

/// Minimum width `_LevelDetailsColumn` needs. Every `_SectionHeader` is a
/// Row of an icon, a title, a `Spacer`, and an "Add/Edit" button — none of
/// those can wrap, so the widest section header sets the real floor.
double _minLevelDetailsColumnWidth(AppLocalizations l10n) {
  const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  const buttonStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

  final widestTitleWidth = [
    l10n.subjectsTaught,
    l10n.assignedTeachers,
    l10n.availableRooms,
    l10n.manualOverridesSection,
  ].map((t) => _textWidth(t, titleStyle)).reduce((a, b) => a > b ? a : b);

  final addEditWidth = _textWidth(l10n.addEdit, buttonStyle);

  const sectionIconAndGap = 20 + 8;
  const addEditButtonChrome = 18 + 8 + 32 + 2; // icon + gap + padding + border
  const columnPadding = 24 * 2; // SingleChildScrollView padding, both sides
  const minSpacerGap = 24; // breathing room the Spacer must keep

  return columnPadding +
      sectionIconAndGap +
      widestTitleWidth +
      minSpacerGap +
      addEditButtonChrome +
      addEditWidth;
}

/// Renders `_LevelsListColumn` and `_LevelDetailsColumn` side by side, and
/// lets that Row shrink fluidly like any other flexible layout — but only
/// down to the combined minimum width both columns actually need (computed
/// above from their real content, not a hardcoded page-1-style breakpoint).
///
/// `_ScheduleCreatePageState` now wraps the whole page in a
/// `ResponsiveWidthGuard` using that exact same combined minimum width, so
/// in practice this widget is never asked to render below `minTotalWidth`
/// — the enlarge-window message takes over first. The stacked branch below
/// is kept as a defensive fallback only (e.g. if the Scaffold body is ever
/// narrower than the raw viewport width), so the layout still degrades
/// gracefully instead of overflowing if that assumption is ever violated.
class _ResponsiveLevelsBody extends StatelessWidget {
  const _ResponsiveLevelsBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final minListWidth = _minLevelsListColumnWidth(l10n);
    final minDetailsWidth = _minLevelDetailsColumnWidth(l10n);
    const dividerWidth = 1.0;
    final minTotalWidth = minListWidth + dividerWidth + minDetailsWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minTotalWidth) {
          return const Row(
            children: [
              Expanded(child: _LevelsListColumn()),
              VerticalDivider(thickness: 1, width: 1, color: _divider),
              Expanded(flex: 3, child: _LevelDetailsColumn()),
            ],
          );
        }

        return const Column(
          children: [
            Expanded(flex: 2, child: _LevelsListColumn()),
            Divider(height: 1, color: _divider),
            Expanded(flex: 3, child: _LevelDetailsColumn()),
          ],
        );
      },
    );
  }
}

class ScheduleCreatePage extends ConsumerStatefulWidget {
  const ScheduleCreatePage({super.key});

  @override
  ConsumerState<ScheduleCreatePage> createState() => _ScheduleCreatePageState();
}

class _ScheduleCreatePageState extends ConsumerState<ScheduleCreatePage> {
  @override
  void initState() {
    super.initState();
  }

  // This page's minimum usable width is not an arbitrary breakpoint: it's
  // the exact width at which `_ResponsiveLevelsBody` would otherwise switch
  // from the clean side-by-side layout to a stacked one (see
  // `_minLevelsListColumnWidth` / `_minLevelDetailsColumnWidth` above). That
  // stacking point is precisely where the page stops looking like a
  // polished desktop layout — cards lose their side-by-side alignment and
  // sections like Manual Overrides get compressed into a narrow column —
  // so instead of letting the page degrade into the stacked layout, we stop
  // rendering it there and ask the user to widen the window instead.
  double _minPageWidth(AppLocalizations l10n) {
    const dividerWidth = 1.0;
    return _minLevelsListColumnWidth(l10n) +
        dividerWidth +
        _minLevelDetailsColumnWidth(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveWidthGuard(
      minWidth: _minPageWidth(l10n),
      builder: _buildPage,
    );
  }

  Widget _buildPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levels = ref.watch(levelsProvider.select((s) => s.levels));
    final isGenerating = ref.watch(isGeneratingProvider);
    final teachers = ref.watch(teachersProvider.select((s) => s.teachers));
    final haveTeachers = teachers.isNotEmpty;
    final prefsService = SharedPreferencesService();
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(userProvider);
    if (settings.selectedDays.isEmpty || settings.maxHoursPerDay == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        title: Text(l10n.createSchedule),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: !haveTeachers,
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    bool checked = ref.watch(
                      settingsProvider.select(
                        (s) => s.includeTeachersInPayload,
                      ),
                    );
                    return Row(
                      children: [
                        Checkbox(
                          value: checked,
                          onChanged: haveTeachers
                              ? null
                              : (value) {
                                  final newValue = value ?? false;
                                  menuSetState(() {
                                    checked = newValue;
                                  });

                                  ref
                                      .read(settingsProvider.notifier)
                                      .setIncludeTeachersInPayload(newValue);

                                  ref
                                      .read(manualOverridesProvider.notifier)
                                      .clearOverrides();
                                },
                        ),
                        Expanded(
                          child: Text(
                            l10n.includeTeachersInPayload,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: user == null
                    ? Text(l10n.login)
                    : Text(l10n.logout),
                onTap: () async {
                  if (user == null) {
                    context.push('/login?from=/create/schedule_second_page');
                  } else {
                    await ref.read(authRepositoryProvider).signOut();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body:
          // if generating show while generating, else show levels if not empty , else show empty Add Levels
          isGenerating
          ? const WhileGenerating()
          : levels.isEmpty
          ? const _EmptyLevelsState()
          : const _ResponsiveLevelsBody(),
      //----------------------------------------------------- Check Data and generate Schedule
      floatingActionButton: levels.isEmpty
          ? null
          : Builder(
              builder: (context) {
                return FloatingActionButton.extended(
                  heroTag: null,
                  // Disable button while generating
                  onPressed: isGenerating
                      ? null
                      : () {
                          NavigationGuard.run(context, () async {
                            final lastGeneratedScheduleJson = await prefsService
                                .getString('last_generated_schedule');

                            if (lastGeneratedScheduleJson != null &&
                                context.mounted) {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: Text(l10n.warning),
                                    content: SizedBox(
                                      width: 400,
                                      height: 150,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Color(0xFFD94040),
                                            size: 70,
                                          ),
                                          Text(l10n.eraseSavedScheduleWarning),
                                          Text(l10n.impossibleToRecreate),
                                          Text(
                                            l10n.sureToContinue,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD94040),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                          generateSchedule(context, ref);
                                        },
                                        child: Text(l10n.continueBtn),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (context.mounted) {
                              generateSchedule(context, ref);
                            }
                          });
                        },
                  label: isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.generate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  icon: isGenerating ? null : const Icon(Icons.auto_awesome),
                );
              },
            ),
    );
  }
}

class _EmptyLevelsState extends ConsumerWidget {
  const _EmptyLevelsState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 56,
              color: Color(0xFF9DB5D8),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.startByAddingLevels,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2E4A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addLevelsInstructions,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5A6A85),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => addLevelDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(
                l10n.addLevels,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelsListColumn extends ConsumerWidget {
  const _LevelsListColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final levels = ref.watch(levelsProvider.select((s) => s.levels));
    final levelIds = ref.watch(levelsProvider.select((s) => s.levelIds));
    final classes = ref.watch(levelsProvider.select((s) => s.classes));
    final levelsList = levels.keys.toList();
    final selectedLevel = ref.watch(
      levelsProvider.select((s) => s.selectedLevel),
    );

    // NOTE: no longer wraps itself in `Expanded` — the parent
    // (`ScheduleCreatePage`) now decides how to size this column, since it is
    // reused both in the side-by-side Row layout and in the stacked Column
    // layout that kicks in below the minimum usable width.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          color: _headerBg,
          height: 44,
          child: Text(
            l10n.levelsColumnHeader,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _headerText,
            ),
          ),
        ),
        const Divider(height: 1, color: _divider),
        if (levels.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var level in levelsList) ...[
                    ListTile(
                      selected: level == selectedLevel,
                      selectedTileColor: Colors.white,
                      tileColor: level == selectedLevel ? Colors.white : null,
                      onTap: () {
                        ref
                            .read(levelsProvider.notifier)
                            .setSelectedLevel(level);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        level,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                      hoverColor: const Color(0xFFE8F0FD),
                      subtitle: Text(
                        l10n.classesCount(levels[level] ?? 0),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A6A85),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: l10n.removeLevelTooltip,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFD94040),
                          size: 20,
                        ),
                        //------------------------------------------------------ Delete level plus Dialog
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.removeLevelTooltip),
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 45,
                                    ),
                                  ],
                                ),
                                content: Text(l10n.confirmQuestion),
                                actions: [
                                  TextButton(
                                    child: Text(l10n.cancel),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text(l10n.removeLevelTooltip),
                                    onPressed: () {
                                      // remove level from rooms and schedule service and classes list
                                      ref
                                          .read(roomsProvider.notifier)
                                          .removeLevelFromRooms(
                                            levelIds[level] ?? 0,
                                            classes: classes
                                                .where(
                                                  (c) =>
                                                      c.levelId ==
                                                      levelIds[level],
                                                )
                                                .map((c) => c.classId)
                                                .whereType<int>()
                                                .toList(),
                                          );

                                      ref
                                          .read(scheduleServiceProvider)
                                          .removeLevel(level);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, color: _divider),
                  ],
                ],
              ),
            ),
          ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => addLevelDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              l10n.addLevel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelDetailsColumn extends ConsumerWidget {
  const _LevelDetailsColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedLevel = ref.watch(
      levelsProvider.select((s) => s.selectedLevel),
    );
    final groups = ref.watch(groupsProvider.select((s) => s.groups));
    final levelsList = ref.watch(
      levelsProvider.select((s) => s.levels.keys.toList()),
    );

    final levelIds = ref.watch(levelsProvider.select((s) => s.levelIds));
    final levelKey =
        selectedLevel != 'None' && levelsList.contains(selectedLevel)
        ? (levelIds[selectedLevel]).toString()
        : null;

    final subjects = ref.watch(subjectsProvider.select((s) => s.subjects));
    final filteredSubjects = levelKey != null
        ? subjects
              .where(
                (s) =>
                    s.weeklyHours?.containsKey(levelKey) == true &&
                    (s.weeklyHours![levelKey] ?? 0) > 0,
              )
              .toList()
        : [];

    final settings = ref.watch(settingsProvider);

    // Also correctly map real rooms and teachers

    final allTeachers = ref.watch(teachersProvider.select((s) => s.teachers));

    final filteredTeachers =
        levelKey != null && settings.includeTeachersInPayload
        ? allTeachers
              .where(
                (t) => t.qualifiedLevels?.contains(int.parse(levelKey)) == true,
              )
              .toList()
        : [];
    // ----------------------------------- Get Rooms Related to Selected Level
    final rooms = ref.watch(roomsProvider.select((s) => s.rooms));
    final filteredRooms = levelKey != null
        ? rooms
              .where(
                (room) =>
                    room.allowedLevels.isEmpty ||
                    room.allowedLevels.contains(int.parse(levelKey)) == true,
              )
              .toList()
        : [];
    // NOTE: no longer wraps itself in `Expanded(flex: 3)` — sizing is now
    // decided by the parent (`ScheduleCreatePage`), just like
    // `_LevelsListColumn`, so this column works both in the side-by-side Row
    // layout and in the stacked Column layout below the minimum usable width.
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            color: _headerBg,
            height: 44,
            child: Text(
              selectedLevel == 'None'
                  ? l10n.selectLevelToViewDetailsHeader
                  : l10n.detailsForLevel(selectedLevel),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _headerText,
              ),
            ),
          ),
          const Divider(height: 1, color: _divider),
          if (selectedLevel != 'None')
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subjects Section
                    _SectionHeader(
                      title: l10n.subjectsTaught,
                      icon: Icons.menu_book_rounded,
                      onAdd: () => context.go(
                        '/create/schedule_second_page/create_subject',
                      ),
                    ),
                    const SizedBox(height: 16),
                    filteredSubjects.isEmpty
                        ? _EmptyStateText(l10n.noSubjectsAddedYet)
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var subject in filteredSubjects)
                                _CustomChip(
                                  label: subject.subjectName ?? '',
                                  hours: subject.weeklyHours?[levelKey]
                                      .toString(),
                                  backgroundColor: const Color(0xFFE8F0FD),
                                  textColor: _blue,
                                  iconColor: const Color(0xFF9DB5D8),
                                ),
                            ],
                          ),
                    const SizedBox(height: 40),
                    if (settings.includeTeachersInPayload) ...[
                      Divider(height: 1, color: _divider),
                      const SizedBox(height: 5),
                      // Teachers Section
                      _SectionHeader(
                        title: l10n.assignedTeachers,
                        icon: Icons.person_outline_rounded,
                        onAdd: () => context.go(
                          '/create/schedule_second_page/add_teacher',
                        ),
                      ),
                      const SizedBox(height: 16),
                      filteredTeachers.isEmpty
                          ? _EmptyStateText(l10n.noTeachersAssignedYet)
                          : Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: filteredTeachers
                                  .map(
                                    (t) => _CustomChip(
                                      label: t.teacherName ?? '',
                                      backgroundColor: const Color(0xFFF4EBFF),
                                      textColor: const Color(0xFF7A2EDB),
                                      iconColor: const Color(0xFFD4B1F8),
                                    ),
                                  )
                                  .toList(),
                            ),
                      const SizedBox(height: 40),
                    ],
                    // --------------------------------
                    Divider(height: 1, color: _divider),
                    const SizedBox(height: 5),
                    // Resources (Rooms)
                    _SectionHeader(
                      title: l10n.availableRooms,
                      icon: Icons.meeting_room_outlined,
                      onAdd: () =>
                          context.go('/create/schedule_second_page/add_room'),
                    ),
                    filteredRooms.isEmpty
                        ? _EmptyStateText(l10n.noRoomsConfiguredYet)
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: filteredRooms
                                .map(
                                  (r) => _CustomChip(
                                    label: r.roomName,
                                    backgroundColor: const Color(0xFFE6F7F4),
                                    textColor: const Color(0xFF148570),
                                    iconColor: const Color(0xFF9AD3C9),
                                  ),
                                )
                                .toList(),
                          ),
                    const SizedBox(height: 40),
                    // -------------------------------- Divider --------------------------------
                    Divider(height: 1, color: _divider),
                    SizedBox(height: 5),
                    //split groups
                    _SectionHeader(
                      title: l10n.groups,
                      icon: Icons.groups,
                      onAdd: () =>
                          context.go('/create/schedule_second_page/groups'),
                    ),

                    groups.isEmpty
                        ? _EmptyStateText(l10n.groupsNotConf)
                        : Text(
                            l10n.groupsAreAssignedToAClass,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF148570),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    SizedBox(height: 20),
                    // -------------------------------- Divider --------------------------------
                    Divider(height: 1, color: _divider),
                    const SizedBox(height: 5),
                    // Manual Overrides Section
                    _SectionHeader(
                      title: l10n.manualOverridesSection,
                      icon: Icons.edit_calendar_outlined,
                      onAdd: () => context.push(
                        '/create/schedule_second_page/manual_overrides',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final overrides = ref
                            .watch(manualOverridesProvider)
                            .overrides;
                        final levelKeyInt = levelKey != null
                            ? int.tryParse(levelKey)
                            : null;
                        final classes = ref.watch(
                          levelsProvider.select((s) => s.classes),
                        );

                        // Count overrides for classes belonging to this level
                        final levelClassIds = classes
                            .where((c) => c.levelId == levelKeyInt)
                            .map((c) => c.classId)
                            .toSet();
                        final levelOverridesCount = overrides
                            .where((o) => levelClassIds.contains(o.classId))
                            .length;

                        if (levelOverridesCount == 0) {
                          return _EmptyStateText(
                            l10n.noManualOverridesForLevel,
                          );
                        }
                        return Text(
                          l10n.activeOverrideConstraints(levelOverridesCount),
                          style: const TextStyle(
                            color: Color(0xFF148570),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 48, color: _divider),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pleaseSelectLevelFromLeft,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF5A6A85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5A6A85)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E4A),
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: Text(AppLocalizations.of(context)!.addEdit),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2A6FDB),
            side: const BorderSide(color: Color(0xFF2A6FDB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateText extends StatelessWidget {
  final String text;
  const _EmptyStateText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Color(0xFF9DB5D8),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final String? hours;

  const _CustomChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      deleteIconColor: iconColor,
      onDeleted: () {},
      deleteIcon: hours != null ? Text('$hours') : null,
    );
  }
}
