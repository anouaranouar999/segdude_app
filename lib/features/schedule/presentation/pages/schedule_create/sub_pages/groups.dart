import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/widgets/add_dialogs.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/responsive_width_guard.dart';

// UI Color tokens
const _blue = Color(0xFF2A6FDB);
const _pageBg = Color(0xFFF4F7FB);
const _divider = Color(0xFFDDE3EC);
const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);

/// Looks up a teacher's display name by id. Returns the localized
/// "no teacher assigned" label when `teacherId` is null (the merge
/// exception), or a localized "Teacher {id}" placeholder if a teacher id
/// is set but that teacher was removed after the merge was created.
String _teacherLabel(
  List<TeacherEncoder> teachers,
  int? teacherId,
  AppLocalizations l10n,
) {
  if (teacherId == null) return l10n.groupsNoTeacherAssignedShort;
  for (final teacher in teachers) {
    if (teacher.teacherId == teacherId) {
      return teacher.teacherName ?? l10n.teacherNumberFallback('$teacherId');
    }
  }
  return l10n.teacherNumberFallback('$teacherId');
}

class Groups extends ConsumerStatefulWidget {
  const Groups({super.key});

  @override
  ConsumerState<Groups> createState() => _GroupsState();
}

class _GroupsState extends ConsumerState<Groups> {
  ClassLevelEncoder? _selectedClass;

  // Below this width the 200px sidebar + per-day/per-timeslot calendar
  // grid (see `build` below) starts producing RenderFlex overflows, so the
  // page isn't built at all.
  static const double _kMinPageWidth = 800;
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidthGuard(minWidth: _kMinPageWidth, builder: _buildPage);
  }

  Widget _buildPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levelsState = ref.watch(levelsProvider);
    final settings = ref.watch(settingsProvider);
    final subjects = ref.watch(subjectsProvider).subjects;
    final teachers = ref.watch(teachersProvider).teachers;
    final groupsState = ref.watch(groupsProvider);
    final groups = groupsState.groups;
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

    /// list used to check uncheck

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
        title: Text(l10n.groups),
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

                                  return Material(
                                    type: MaterialType.transparency,
                                    child: ListTile(
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

                                      onTap: () {
                                        setState(() {
                                          _selectedClass = itemClass;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // ------------------ List of Groups ------------------
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
                                    Icons.groups,
                                    color: _blue,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.groupsSplitClsIntoGroups,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A2E4A),
                                          ),
                                        ),
                                        Text(
                                          overflow: TextOverflow.ellipsis,
                                          l10n.groupsSelectClassToSplit,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: subjects.isEmpty
                                        ? null
                                        : () => addGroupsDialog(
                                            context,
                                            ref,
                                            subjects,
                                            _selectedClass?.className ?? '',
                                            _selectedClass!.classId!,
                                            filteredClasses
                                                .map((e) => e.classId)
                                                .cast<int>()
                                                .toList(),
                                          ),
                                    icon: const Icon(Icons.add),
                                    label: Text(l10n.groupsAdd),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _showMergeDialog(
                                      context,
                                      ref,
                                      filteredClasses,
                                      subjects,
                                      teachers,
                                    ),
                                    icon: const Icon(Icons.merge_type),
                                    label: Text(l10n.groupsMerge),
                                  ),
                                ],
                              ),
                            ),

                            // ----------------------------------------------Interactive Groups-----------------------------------------------------------
                            subjects.isEmpty
                                ? _EmptyState(
                                    message: l10n.groupsAddSubjectFirst,
                                  )
                                : Expanded(
                                    child: ListView(
                                      children: [
                                        ...groups
                                            .where(
                                              (g) =>
                                                  g.classId ==
                                                      _selectedClass!
                                                          .classId! &&
                                                  g.subjectId > 0 &&
                                                  g.subjectId <=
                                                      subjects.length,
                                            )
                                            .map(
                                              (g) => Material(
                                                type: MaterialType.transparency,
                                                child: ListTile(
                                                  onTap: () {
                                                    debugPrint("${g.toJson()}");
                                                  },
                                                  leading: Icon(Icons.groups),
                                                  title: Text(
                                                    subjects[g.subjectId - 1]
                                                            .subjectName ??
                                                        '',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: _blue,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    '${_selectedClass?.className ?? 'Unknown'} / ${g.numGroups} > ${subjects[g.subjectId - 1].subjectName ?? 'Unknown'}',
                                                  ),
                                                  trailing: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    //  ---------------------------Delete Group
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                            groupsProvider
                                                                .notifier,
                                                          )
                                                          .removeGroup(
                                                            g.classId,
                                                            g.subjectId,
                                                            g.numGroups,
                                                          );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ...groupsState.merges
                                            .where(
                                              (merge) =>
                                                  merge.subjectId > 0 &&
                                                  merge.subjectId <=
                                                      subjects.length &&
                                                  merge.classIds.contains(
                                                    _selectedClass!.classId,
                                                  ) &&
                                                  merge.classIds.every(
                                                    (id) =>
                                                        levelsState.classes.any(
                                                          (item) =>
                                                              item.classId ==
                                                              id,
                                                        ),
                                                  ),
                                            )
                                            .map(
                                              (merge) => ListTile(
                                                onTap: () {
                                                  debugPrint(
                                                    "${merge.toJson()}",
                                                  );
                                                },
                                                leading: const Icon(
                                                  Icons.merge_type,
                                                  color: _blue,
                                                ),
                                                title: Text(
                                                  '${l10n.groupsMerge}: ${subjects[merge.subjectId - 1].subjectName ?? ''}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _blue,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  '${merge.classIds.map((id) => levelsState.classes.firstWhere((item) => item.classId == id).className).join(' + ')}'
                                                  ' • ${_teacherLabel(teachers, merge.teacherId, l10n)}',
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  onPressed: () => ref
                                                      .read(
                                                        groupsProvider.notifier,
                                                      )
                                                      .removeMerge(merge),
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  /// A teacher is eligible for a class when the class's level is among the
  /// teacher's qualified levels, and — when `qualifiedClasses` narrows that
  /// level down to a specific subset — the class id is in that subset.
  /// An absent or empty entry for the level means "all classes in that
  /// level qualify" (mirrors the optional-refinement pattern already used
  /// by `RoomEncoder.allowedClasses`).
  static bool _classEligibleForTeacher(
    ClassLevelEncoder itemClass,
    TeacherEncoder teacher,
  ) {
    final levels = teacher.qualifiedLevels;
    if (levels == null || !levels.contains(itemClass.levelId)) return false;
    final restriction = teacher.qualifiedClasses?[itemClass.levelId];
    if (restriction == null || restriction.isEmpty) return true;
    return restriction.contains(itemClass.classId);
  }

  Future<void> _showMergeDialog(
    BuildContext pageContext,
    WidgetRef ref,
    List<ClassLevelEncoder> classes,
    List<SubjectEncoder> subjects,
    List<TeacherEncoder> teachers,
  ) async {
    final selectedIds = <int>{};
    int? subjectId;
    int? teacherId;
    bool isSubmitting = false;
    final l10n = AppLocalizations.of(pageContext)!;

    TextStyle sectionLabelStyle(Color color) => TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: color,
    );
    final helperTextStyle = TextStyle(fontSize: 12.5, color: Colors.grey[600]);

    await showDialog<void>(
      context: pageContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // A teacher is offered for the current Subject only when they are
          // also qualified for at least one class of the current Level —
          // `classes` is already scoped to the current level by the caller,
          // and `_classEligibleForTeacher` is the same qualification check
          // already used to filter classes after a teacher is picked, so a
          // teacher who clears this filter is guaranteed to have eligible
          // classes below (no more "0 eligible classes" dead end).
          final eligibleTeachers = subjectId == null
              ? const <TeacherEncoder>[]
              : teachers
                    .where((t) => t.subjectId == subjectId)
                    .where(
                      (t) => classes.any((c) => _classEligibleForTeacher(c, t)),
                    )
                    .toList();

          TeacherEncoder? selectedTeacher;
          for (final t in eligibleTeachers) {
            if (t.teacherId == teacherId) selectedTeacher = t;
          }
          // Selected teacher is no longer valid for the current subject
          // (subject changed underneath it) — drop it.
          if (teacherId != null && selectedTeacher == null) {
            teacherId = null;
          }

          // A qualified teacher must exist for the selected Subject +
          // current Level, or merge creation is blocked entirely (no
          // teacher-less exception). Within that, picking a specific
          // Teacher is still optional — see the eligibleClasses comment.
          final teacherRequired = eligibleTeachers.isNotEmpty;

          // No specific Teacher selected (teacherId == null) only ever
          // means one thing now: qualified teachers exist for this Subject
          // + Level (teacherRequired), but the Admin intentionally left the
          // Teacher selector empty. The merge is sent with teacherId = null
          // so the solver can distribute the resulting hours among all
          // teachers qualified for this Subject + Level. `classes` is
          // already scoped to the current level by the caller.
          // When teacherRequired is false, there is nobody to fall back to
          // — eligibleClasses stays empty and canMerge (below) blocks
          // submission, so this list is never presented as selectable.
          final eligibleClasses = selectedTeacher != null
              ? classes
                    .where((c) => _classEligibleForTeacher(c, selectedTeacher!))
                    .toList()
              : (subjectId != null && teacherRequired)
              ? classes
              : const <ClassLevelEncoder>[];

          // Drop any previously selected classes that are no longer valid
          // for the current subject + teacher.
          selectedIds.removeWhere(
            (id) => !eligibleClasses.any((c) => c.classId == id),
          );

          // A specific Teacher is optional, but at least one qualified
          // Teacher must exist for the Subject + current Level — merge
          // creation is blocked otherwise (no teacher-less exception).
          final canMerge =
              subjectId != null && teacherRequired && selectedIds.length >= 2;

          final subjectState = subjectId != null
              ? _StepState.done
              : _StepState.active;
          final teacherState = teacherId != null
              ? _StepState.done
              : (subjectId == null
                    ? _StepState.pending
                    // No teacher is qualified for this subject + level:
                    // this is now a blocking dead end (merge creation is
                    // disabled), so the step must not read as "done" —
                    // pending communicates "not available" without looking
                    // like a completed/bypassed step.
                    : (teacherRequired
                          ? _StepState.active
                          : _StepState.pending));
          final classesState = selectedIds.length >= 2
              ? _StepState.done
              : ((subjectId != null && teacherRequired)
                    ? _StepState.active
                    : _StepState.pending);
          // Classes unlock only once at least one qualified Teacher exists
          // for the Subject + current Level — picking a specific Teacher
          // remains optional (see the eligibleClasses comment above), but
          // the teacher-less merge exception no longer applies.
          final classesUnlocked = subjectId != null && teacherRequired;

          Color stepColor(_StepState state) => switch (state) {
            _StepState.done => _blue,
            _StepState.active => _headerText,
            _StepState.pending => Colors.grey[500]!,
          };

          Future<void> confirmMerge() async {
            if (!canMerge || isSubmitting) return;
            final hasSplits = ref
                .read(groupsProvider)
                .groups
                .any(
                  (group) =>
                      group.subjectId == subjectId &&
                      selectedIds.contains(group.classId),
                );
            final hasOverlappingMerge = ref
                .read(groupsProvider.notifier)
                .hasOverlappingMerge(selectedIds.toList(), subjectId!);
            if (hasSplits || hasOverlappingMerge) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (warningContext) => AlertDialog(
                  title: Text(l10n.groupsMergeWarningTitle),
                  content: Text(l10n.groupsMergeWarning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(warningContext, false),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(warningContext, true),
                      child: Text(l10n.groupsMerge),
                    ),
                  ],
                ),
              );
              if (!dialogContext.mounted) return;
              if (confirmed != true) return;
            }
            setDialogState(() => isSubmitting = true);
            ref
                .read(groupsProvider.notifier)
                .mergeClasses(
                  selectedIds.toList(),
                  subjectId!,
                  teacherId: teacherId,
                  replaceOverlappingMerges: true,
                );
            Navigator.pop(dialogContext);
            if (pageContext.mounted) {
              ScaffoldMessenger.of(pageContext).showSnackBar(
                SnackBar(content: Text(l10n.groupsMergeSuccessMessage)),
              );
            }
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 460,
                // Generous cap so the normal Subject → Teacher → Classes →
                // Summary content fits without triggering the inner
                // scroll view below. Still bounded by the viewport (minus
                // a small margin) so it can never overflow the screen —
                // that inner scroll remains as a safety net for the edge
                // case of an unusually large number of classes.
                maxHeight: (MediaQuery.of(pageContext).size.height - 48).clamp(
                  360.0,
                  double.infinity,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header banner ────────────────────────────────
                  // Same white surface as the rest of the dialog — only
                  // the icon badge below carries the accent tint, so the
                  // header doesn't read as a visually separate panel.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      border: Border(bottom: BorderSide(color: _divider)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _headerBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.merge_type,
                            color: _blue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.groupsMerge,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2E4A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.groupsMergeClasses,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFF5A6A85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable body ──────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Step 1: Subject ──────────────────────
                          Row(
                            children: [
                              _StepBadge(number: 1, state: subjectState),
                              const SizedBox(width: 8),
                              Text(
                                l10n.subject.toUpperCase(),
                                style: sectionLabelStyle(
                                  stepColor(subjectState),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.groupsSelectSubjectToMerge,
                            style: helperTextStyle,
                          ),
                          const SizedBox(height: 8),
                          _SelectorTile<int>(
                            hintText: l10n.subject,
                            selectedLabel: subjectId == null
                                ? null
                                : subjects
                                      .firstWhere(
                                        (s) => s.subjectId == subjectId,
                                      )
                                      .subjectName,
                            enabled: subjects.isNotEmpty,
                            selectedIcon: Icons.menu_book_rounded,
                            items: subjects
                                .map(
                                  (s) => _SelectorItem<int>(
                                    value: s.subjectId,
                                    label: s.subjectName ?? '',
                                    isSelected: s.subjectId == subjectId,
                                  ),
                                )
                                .toList(),
                            onSelected: (value) => setDialogState(() {
                              subjectId = value;
                              teacherId = null;
                              selectedIds.clear();
                            }),
                          ),
                          const SizedBox(height: 18),

                          // ── Step 2: Teacher (filtered by subject) ─
                          Row(
                            children: [
                              _StepBadge(number: 2, state: teacherState),
                              const SizedBox(width: 8),
                              Text(
                                l10n.teacher.toUpperCase(),
                                style: sectionLabelStyle(
                                  stepColor(teacherState),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.groupsSelectTeacherToMerge,
                            style: helperTextStyle,
                          ),
                          const SizedBox(height: 8),
                          if (subjectId == null)
                            _InlineHint(
                              text: l10n.selectSubjectFirst,
                              icon: Icons.info_outline,
                            )
                          else if (eligibleTeachers.isEmpty)
                            _InlineHint(
                              text: l10n.groupsNoQualifiedTeacherMergeBlocked,
                              icon: Icons.person_off_rounded,
                            )
                          else
                            _SelectorTile<int>(
                              hintText: l10n.teacher,
                              selectedLabel: teacherId == null
                                  ? null
                                  : selectedTeacher?.teacherName,
                              enabled: true,
                              selectedIcon: Icons.person_rounded,
                              items: eligibleTeachers
                                  .map(
                                    (t) => _SelectorItem<int>(
                                      value: t.teacherId,
                                      label: t.teacherName ?? '',
                                      isSelected: t.teacherId == teacherId,
                                    ),
                                  )
                                  .toList(),
                              onSelected: (value) => setDialogState(() {
                                teacherId = value;
                                selectedIds.clear();
                              }),
                            ),
                          const SizedBox(height: 18),

                          // ── Step 3: Classes (filtered by subject+teacher)
                          Row(
                            children: [
                              _StepBadge(number: 3, state: classesState),
                              const SizedBox(width: 8),
                              Text(
                                l10n.classes.toUpperCase(),
                                style: sectionLabelStyle(
                                  stepColor(classesState),
                                ),
                              ),
                              const Spacer(),
                              if (classesUnlocked && eligibleClasses.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedIds.length >= 2
                                        ? _headerBg
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    l10n.groupsClassesSelectedCount(
                                      selectedIds.length,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: selectedIds.length >= 2
                                          ? _headerText
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.groupsSelectClassesToMerge,
                            style: helperTextStyle,
                          ),
                          const SizedBox(height: 8),
                          if (!classesUnlocked)
                            // classesUnlocked requires both a Subject and
                            // at least one qualified Teacher for the
                            // current Level (a *specific* Teacher is still
                            // optional — see the eligibleClasses comment
                            // above). Mirror the same two causes shown for
                            // Step 2 so the messaging stays consistent.
                            _InlineHint(
                              text: subjectId == null
                                  ? l10n.selectSubjectFirst
                                  : l10n.groupsNoQualifiedTeacherMergeBlocked,
                              icon: Icons.info_outline,
                            )
                          else if (eligibleClasses.isEmpty)
                            _InlineHint(
                              text: l10n.groupsNoClassesForTeacherSubject,
                              icon: Icons.search_off_rounded,
                            )
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: eligibleClasses
                                      .map(
                                        (itemClass) => _ClassChip(
                                          label: itemClass.className ?? '',
                                          selected: selectedIds.contains(
                                            itemClass.classId,
                                          ),
                                          onTap: () => setDialogState(() {
                                            if (selectedIds.contains(
                                              itemClass.classId,
                                            )) {
                                              selectedIds.remove(
                                                itemClass.classId,
                                              );
                                            } else {
                                              selectedIds.add(
                                                itemClass.classId!,
                                              );
                                            }
                                          }),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),

                          // ── Review summary, once mergeable ────────
                          if (canMerge) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _headerBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.fact_check_rounded,
                                        size: 16,
                                        color: _headerText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.groupsMergeSummary,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _headerText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _SummaryTable(
                                    entries: [
                                      _SummaryEntry(
                                        icon: Icons.menu_book_rounded,
                                        label: l10n.subject,
                                        value:
                                            subjects
                                                .firstWhere(
                                                  (s) =>
                                                      s.subjectId == subjectId,
                                                )
                                                .subjectName ??
                                            '',
                                      ),
                                      _SummaryEntry(
                                        icon: selectedTeacher != null
                                            ? Icons.person_rounded
                                            : Icons.person_off_rounded,
                                        label: l10n.teacher,
                                        value:
                                            selectedTeacher?.teacherName ??
                                            l10n.groupsNoTeacherAssignedShort,
                                      ),
                                      _SummaryEntry(
                                        icon: Icons.groups_rounded,
                                        label: l10n.classes,
                                        value: eligibleClasses
                                            .where(
                                              (c) => selectedIds.contains(
                                                c.classId,
                                              ),
                                            )
                                            .map((c) => c.className ?? '')
                                            .join(' + '),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),

                  // ── Actions ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: _divider)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: canMerge && !isSubmitting
                              ? confirmMerge
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.merge_type, size: 18),
                          label: Text(l10n.groupsMerge),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------ Generic page empty state warning.
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

/// ------------------------------------------------------ Merge dialog building blocks.
/// Progress state of a merge-dialog step (Subject / Teacher / Classes).
enum _StepState { pending, active, done }

/// Small numbered/checked circular badge shown next to a step's section
/// label, so the user can see at a glance which steps are complete.
class _StepBadge extends StatelessWidget {
  final int number;
  final _StepState state;

  const _StepBadge({required this.number, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color background = switch (state) {
      _StepState.done => _blue,
      _StepState.active => Colors.white,
      _StepState.pending => _pageBg,
    };
    final Color border = switch (state) {
      _StepState.done => _blue,
      _StepState.active => _blue,
      _StepState.pending => _divider,
    };
    final Color foreground = switch (state) {
      _StepState.done => Colors.white,
      _StepState.active => _blue,
      _StepState.pending => const Color(0xFFADC8FF),
    };
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.4),
      ),
      child: state == _StepState.done
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : Text(
              '$number',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
            ),
    );
  }
}

/// A single option shown inside a [_SelectorTile]'s menu.
class _SelectorItem<T> {
  final T value;
  final String label;
  final bool isSelected;

  const _SelectorItem({
    required this.value,
    required this.label,
    this.isSelected = false,
  });
}

/// A tappable bordered "selector" card that opens a positioned menu of
/// options below it — used in place of the default Material dropdown so
/// the Subject/Teacher pickers match the app's card-based visual language.
/// Behaves like a single-select dropdown: same interaction, different skin.
class _SelectorTile<T> extends StatelessWidget {
  final String hintText;
  final String? selectedLabel;
  final bool enabled;
  final List<_SelectorItem<T>> items;
  final ValueChanged<T> onSelected;
  final IconData? selectedIcon;

  const _SelectorTile({
    required this.hintText,
    required this.selectedLabel,
    required this.enabled,
    required this.items,
    required this.onSelected,
    this.selectedIcon,
  });

  Future<void> _openMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(
      Offset(0, box.size.height + 4),
      ancestor: overlay,
    );
    final bottomRight = box.localToGlobal(
      box.size.bottomRight(Offset(0, box.size.height + 4)),
      ancestor: overlay,
    );
    final position = RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<T>(
      context: context,
      position: position,
      constraints: BoxConstraints(
        minWidth: box.size.width,
        maxWidth: box.size.width,
        maxHeight: 280,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: item.isSelected
                            ? _blue
                            : const Color(0xFF1A2E4A),
                        fontWeight: item.isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (item.isSelected)
                    const Icon(Icons.check, size: 16, color: _blue),
                ],
              ),
            ),
          )
          .toList(),
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (builderContext) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? () => _openMenu(builderContext) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : _pageBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedLabel != null ? _blue : _divider,
                width: selectedLabel != null ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                if (selectedIcon != null) ...[
                  Icon(
                    selectedIcon,
                    size: 18,
                    color: selectedLabel != null
                        ? _blue
                        : const Color(0xFFADC8FF),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selectedLabel ?? hintText,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selectedLabel != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: !enabled
                          ? const Color(0xFFADC8FF)
                          : selectedLabel != null
                          ? const Color(0xFF1A2E4A)
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: enabled
                      ? const Color(0xFF5A6A85)
                      : const Color(0xFFADC8FF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A muted inline banner used for "waiting on a previous step" and
/// "nothing found" states inside the merge dialog — visually distinct
/// from an actionable control so the user doesn't mistake it for one.
class _InlineHint extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InlineHint({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _pageBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8A9BB5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

/// A selectable chip used for the Classes multi-select grid.
class _ClassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ClassChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? _blue : _divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 14, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.white : const Color(0xFF1A2E4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry ("Subject" → "Math") to render inside a [_SummaryTable].
class _SummaryEntry {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryEntry({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Renders the merge review summary as a two-column table: the label
/// column sizes itself to whatever the widest localized label actually
/// needs ([IntrinsicColumnWidth]), instead of a guessed fixed pixel width
/// that can wrap mid-word in some languages. The value column flexes and
/// is free to wrap onto multiple lines (e.g. many merged class names)
/// without ever disturbing the label.
class _SummaryTable extends StatelessWidget {
  final List<_SummaryEntry> entries;

  const _SummaryTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        for (int i = 0; i < entries.length; i++)
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: 14,
                  bottom: i == entries.length - 1 ? 0 : 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entries[i].icon,
                      size: 15,
                      color: const Color(0xFF5A6A85),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entries[i].label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == entries.length - 1 ? 0 : 8,
                ),
                child: Text(
                  entries[i].value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2E4A),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
