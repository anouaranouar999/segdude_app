import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'printer_page.dart';

const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);
const _divider = Color(0xFFDDE3EC);
const _textPrimary = Color(0xFF1A2E4A);
const _textSecondary = Color(0xFF5A6A85);
// Matches the Student tab's FAB color (schedule_result_page.dart's `_blue`)
// so the Teacher print button reads as the same action, without importing
// a private constant across files.
const _printFabColor = Color(0xFF2A6FDB);

// Width of the collapsible Teacher navigation panel (subject filter, search,
// teacher list). Mirrors how the Student tab's sidebar
// (schedule_result_page.dart, _sidebarCollapsed) fixes a single width and
// animates it to zero on collapse via AnimatedSize, rather than introducing
// a different collapse mechanism for Teachers.
const _panelWidth = 260.0;

class TeacherSchedule extends ConsumerStatefulWidget {
  final ScheduleDecoder? schedule;

  const TeacherSchedule({super.key, this.schedule});

  @override
  ConsumerState<TeacherSchedule> createState() => _TeacherScheduleState();
}

class _TeacherScheduleState extends ConsumerState<TeacherSchedule>
    with AutomaticKeepAliveClientMixin {
  // null means "All subjects" — Subject is now a filter on the Teacher
  // list, not a required selection step.
  int? _selectedSubjectId;
  String? _selectedTeacherId;
  bool _panelCollapsed = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Without this, TabBarView disposes this tab's State (and these fields
  // with it) as soon as the user switches to another tab, which is why the
  // Teacher selection was being lost on tab switch rather than any bug in
  // the selection logic itself. No new/duplicate selection state is
  // introduced — this only keeps the existing fields above alive.
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Teachers from the generated schedule that match [subjectId].
  /// `subjectId == null` ("All subjects") returns every teacher in the
  /// schedule — there is no subject filter applied in that case. This is
  /// the single source of truth for which teachers are valid for a given
  /// subject, used both to build the displayed list and to decide whether
  /// the current teacher selection survives a subject change.
  List<TeacherScheduleEntry> _teachersForSubject(
    int? subjectId,
    List teachers,
  ) {
    final scheduleTeachers =
        widget.schedule?.teacherSchedule?.teachers ??
        const <TeacherScheduleEntry>[];
    if (subjectId == null) return scheduleTeachers;
    return scheduleTeachers.where((entry) {
      final teacherId = int.tryParse(entry.teacherId);
      final teacher = teacherId == null
          ? null
          : teachers.where((t) => t.teacherId == teacherId).firstOrNull;
      return teacher != null && teacher.subjectId == subjectId;
    }).toList();
  }

  void _onSubjectChanged(int? subjectId) {
    // Resolve validity against the *subject* filter only — the search
    // query never invalidates a selection, only the subject filter does
    // (a teacher found via search stays selected even after the search
    // text is cleared). See scenarios D/E in the spec.
    final teachers = ref.read(teachersProvider).teachers;
    final stillValidIds = _teachersForSubject(
      subjectId,
      teachers,
    ).map((t) => t.teacherId).toSet();

    setState(() {
      _selectedSubjectId = subjectId;
      if (_selectedTeacherId != null &&
          !stillValidIds.contains(_selectedTeacherId)) {
        _selectedTeacherId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final l10n = AppLocalizations.of(context)!;
    final teacherSchedule = widget.schedule?.teacherSchedule;
    final teachers = ref.watch(teachersProvider).teachers;
    final subjects = ref.watch(subjectsProvider).subjects;

    if (teacherSchedule == null || teacherSchedule.teachers.isEmpty) {
      return Center(child: Text(l10n.noTeacherScheduleAvailable));
    }

    // Teachers matching the active Subject filter (or all of them, when
    // the filter is "All subjects"). This is what decides teacher-selection
    // validity and the empty-state message on the schedule side.
    final subjectFilteredTeachers = _teachersForSubject(
      _selectedSubjectId,
      teachers,
    );

    // Subject filter + search query combined — what's actually rendered in
    // the Teacher list. Filtering an already-in-memory list of ~40-50
    // entries is cheap; no reload or reconstruction of the underlying
    // teacher data happens here.
    final query = _searchQuery.trim().toLowerCase();
    final displayedTeachers = query.isEmpty
        ? subjectFilteredTeachers
        : subjectFilteredTeachers
              .where(
                (teacher) => _teacherName(
                  teacher.teacherId,
                  teachers,
                  l10n,
                ).toLowerCase().contains(query),
              )
              .toList();

    // Selection is resolved against the subject-filtered list (not the
    // search-narrowed one), so a selected teacher stays selected while the
    // user types a search query that happens to hide them from the list.
    final selectedTeacher = subjectFilteredTeachers
        .where((teacher) => teacher.teacherId == _selectedTeacherId)
        .firstOrNull;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // ── Collapsible panel (subject filter + search + teacher list) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: SizedBox(
              width: _panelCollapsed ? 0 : _panelWidth,
              height: double.infinity,
              child: _teacherPanel(subjects, teachers, displayedTeachers, l10n),
            ),
          ),
          // ── Toggle button — same control as the Student tab's sidebar ──
          Container(width: 1, height: double.infinity, color: _divider),
          Tooltip(
            message: _panelCollapsed ? l10n.teacher : l10n.collapse,
            child: InkWell(
              onTap: () => setState(() => _panelCollapsed = !_panelCollapsed),
              child: Container(
                width: 20,
                height: double.infinity,
                color: _headerBg,
                child: Center(
                  child: AnimatedRotation(
                    turns: _panelCollapsed ? 0 : 0.5,
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
          Container(width: 1, height: double.infinity, color: _divider),
          // ── Schedule table ───────────────────────────────────────────
          Expanded(
            child: selectedTeacher == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _emptyStateMessage(
                          subjects: subjects,
                          subjectFilteredTeachers: subjectFilteredTeachers,
                          l10n: l10n,
                        ),
                        style: const TextStyle(color: _textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      // Unchanged from before: same Padding, same
                      // LayoutBuilder, same SizedBox/_TeacherTable — the
                      // badge below is a plain overlay on top, so it cannot
                      // affect the table's own constraints, dimensions, or
                      // positioning.
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // See _TeacherTable's outer Container note (kept
                            // as-is below): it forwards whatever width it's
                            // given rather than committing to one itself, so
                            // this SizedBox is what pins it to the panel's
                            // actual available width/height.
                            return SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              child: _TeacherTable(
                                teacher: selectedTeacher,
                                settings: ref.watch(settingsProvider),
                                subjects: subjects,
                                rooms: ref.watch(roomsProvider).rooms,
                                classes: ref.watch(levelsProvider).classes,
                              ),
                            );
                          },
                        ),
                      ),
                      // Makes the active selection unmistakable even when
                      // the panel is collapsed (where the highlighted
                      // ListTile — the only other selection indicator — is
                      // no longer visible at all).
                      // Print action, styled to match the Student tab's
                      // Scaffold-level FloatingActionButton.extended (same
                      // color, icon, label pattern) but kept as an overlay
                      // confined to this tab, rather than lifting the
                      // Teacher selection up into schedule_result_page.dart.
                      PositionedDirectional(
                        bottom: 16,
                        end: 16,
                        child: FloatingActionButton.extended(
                          heroTag: 'teacherPrintFab',
                          elevation: 4,
                          backgroundColor: _printFabColor,
                          icon: const Icon(Icons.print, color: Colors.white),
                          label: Text(
                            l10n.print,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => _printSelectedTeacher(
                            selectedTeacher,
                            teachers,
                            subjects,
                            l10n,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _emptyStateMessage({
    required List subjects,
    required List<TeacherScheduleEntry> subjectFilteredTeachers,
    required AppLocalizations l10n,
  }) {
    if (subjects.isEmpty) return l10n.noSubjectsDefinedYet;
    if (subjectFilteredTeachers.isEmpty) return l10n.noTeachersForSubject;
    return l10n.selectATeacherToViewSchedule;
  }

  String _teacherName(String id, List teachers, AppLocalizations l10n) {
    final teacherId = int.tryParse(id);
    return teachers
            .where((teacher) => teacher.teacherId == teacherId)
            .firstOrNull
            ?.teacherName ??
        l10n.teacherNumberFallback(id);
  }

  /// The panel itself: subject filter + search on a header band, then the
  /// scrollable teacher list beneath — same visual language (header bg,
  /// borders, list-item styling) as the Student tab's Levels/Classes
  /// sidebar, adapted to a single column since Teacher has one filter
  /// axis (Subject) instead of two navigation levels.
  Widget _teacherPanel(
    List subjects,
    List teachers,
    List<TeacherScheduleEntry> displayedTeachers,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Container(
          color: _headerBg,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.filterTeachersBySubject,
                style: const TextStyle(
                  color: _headerText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              _subjectFilterDropdown(subjects, l10n),
              const SizedBox(height: 10),
              _teacherSearchField(l10n),
            ],
          ),
        ),
        const Divider(height: 1, color: _divider),
        Expanded(
          child: displayedTeachers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noTeachersForSubject,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: displayedTeachers.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: _divider),
                  itemBuilder: (context, index) {
                    final entry = displayedTeachers[index];
                    final isSelected = entry.teacherId == _selectedTeacherId;
                    // Wrapped in its own Material so the ListTile's ink
                    // splash/hover paints locally instead of on whatever
                    // Material ancestor happens to be further up the tree —
                    // otherwise the tile's own opaque tileColor/
                    // selectedTileColor background paints over (hides) the
                    // splash. `color: Colors.transparent` keeps this purely
                    // structural: the tile's existing background/selection
                    // colors are unchanged.
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        selected: isSelected,
                        // Was Colors.white, same as this panel's own
                        // background (Container(color: Colors.white) at the
                        // top of this build method) — so the "selected"
                        // background was blending into the surroundings
                        // instead of standing out. Student/Class list uses
                        // the same Colors.white convention but pops because
                        // its backdrop is the page's _pageBg (a light grey),
                        // not white. _headerBg is this file's existing
                        // equivalent light highlight tone (already used for
                        // the header bar and the print button's badge), so
                        // this keeps the same "solid, distinct tile on
                        // selection" convention, just contrasted correctly
                        // against this panel's actual background.
                        selectedTileColor: _headerBg,
                        tileColor: isSelected ? _headerBg : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        hoverColor: const Color(0xFFE8F0FD),
                        onTap: () => setState(
                          () => _selectedTeacherId = entry.teacherId,
                        ),
                        title: Text(
                          _teacherName(entry.teacherId, teachers, l10n),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isSelected ? _headerText : _textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _subjectFilterDropdown(List subjects, AppLocalizations l10n) {
    // Falls back to "All subjects" (null) if the previously selected
    // subject no longer exists in the (possibly reloaded) subjects list.
    final currentValue = subjects.any((s) => s.subjectId == _selectedSubjectId)
        ? _selectedSubjectId
        : null;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: currentValue,
          isExpanded: true,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                l10n.allSubjects,
                style: const TextStyle(fontSize: 13, color: _textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...subjects.map<DropdownMenuItem<int?>>(
              (s) => DropdownMenuItem<int?>(
                value: s.subjectId,
                child: Text(
                  s.subjectName ?? l10n.subjectNumberFallback('${s.subjectId}'),
                  style: const TextStyle(fontSize: 13, color: _textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: subjects.isEmpty ? null : _onSubjectChanged,
        ),
      ),
    );
  }

  Widget _teacherSearchField(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 13, color: _textPrimary),
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 18, color: _textSecondary),
        hintText: l10n.searchForATeacher,
        hintStyle: const TextStyle(fontSize: 13, color: _textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _headerText),
        ),
      ),
      // Search operates on the already subject-filtered list only (see
      // displayedTeachers above) — never on the full teacher collection —
      // so results can never leak teachers excluded by the active filter.
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  // Resolves the printable payload from the exact same state already
  // backing the on-screen table — [teacher] here is the `selectedTeacher`
  // computed in build() from the current subject/teacher selection, so the
  // printed timetable can never lag behind or diverge from what's on
  // screen. Reuses the shared printing infrastructure (PrintDemo) rather
  // than a separate print-side schedule lookup.
  Future<void> _printSelectedTeacher(
    TeacherScheduleEntry teacher,
    List teachers,
    List subjects,
    AppLocalizations l10n,
  ) async {
    final dayNames = [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];
    await PrintDemo().printTeacherDocument(
      teacher,
      _teacherName(teacher.teacherId, teachers, l10n),
      ref.read(settingsProvider),
      subjects,
      ref.read(roomsProvider).rooms,
      ref.read(levelsProvider).classes,
      l10n,
      dayNames,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Teacher timetable grid geometry.
//
// Every dimension the grid needs is declared exactly once here, mirroring
// how the Student timetable (see ScheduleResult in schedule_result_page.dart)
// centralizes its own row height / column flex / border thickness instead
// of letting each cell compute its own numbers. A single source of truth
// is what keeps every row the same height and every column the same width
// all the way down the grid — no cumulative drift, no per-cell patches.
//
// Unlike the Student timetable, the Teacher timetable is mostly empty
// (a teacher only occupies a handful of slots), so it deliberately does
// NOT draw a full grid of cell borders — that would read as a dense wall
// of empty boxes. Instead only two structural lines are drawn: one
// horizontal line under the header row, and one vertical line after the
// day-name column ("L" frame). Occupied lessons are rendered as
// rectangular, square-cornered timetable cells (matching the Student
// timetable's own cell geometry); empty periods stay plain white with no
// border at all.
//
// Day rows no longer use a fixed height: the header keeps a fixed height
// ([_headerRowHeight]) but the day rows equally share whatever height the
// table is actually given (see _TeacherTable/_TimetableRow), which is how
// the whole table fits the page without ever needing to scroll.
const double _headerRowHeight = 44;
const double _borderThickness = 1;
const double _cellPadding = 8;
const int _timeColumnFlex = 12;
const int _timeSlotFlex = 10;

/// One row of the teacher timetable: a day/time label cell on one side and
/// the time-slot cells on the other, split by a single vertical divider.
///
/// Every row — the header and every day row — places that divider at the
/// exact same flex position ([_timeColumnFlex] vs the remaining space) and
/// rows are stacked with nothing in between, so the individual dividers
/// line up into what reads as one continuous vertical line rather than a
/// grid of separately-drawn segments.
///
/// Sizing comes from [height] when provided (the header row, whose height
/// is a known constant) — no [IntrinsicHeight] measurement needed since the
/// height is already known. When [height] is omitted (day
/// rows), the row instead relies on already being placed inside an
/// ambient bounded height by its caller (an [Expanded] — see
/// [_TeacherTable]), so [CrossAxisAlignment.stretch] alone is enough to
/// make every cell fill that height. This avoids running an
/// [IntrinsicHeight] measurement pass per day row, which matters once a
/// table has many day rows.
class _TimetableRow extends StatelessWidget {
  final Widget leading;
  final List<Widget> slots;
  final Color? rowBackground;
  final double? height;

  const _TimetableRow({
    required this.leading,
    required this.slots,
    this.rowBackground,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: _timeColumnFlex, child: leading),
        const VerticalDivider(
          width: 0,
          thickness: _borderThickness,
          color: _divider,
        ),
        // Each entry in `slots` is already an Expanded(flex:
        // _timeSlotFlex * span, ...) from _slotCell, so they're spread
        // directly as siblings of `leading` here — not re-wrapped in
        // another Expanded. That keeps `leading`'s flex ([_timeColumnFlex])
        // and each slot's flex ([_timeSlotFlex]) being compared directly
        // against each other in one flat Row, which is what the two
        // constants were sized relative to one another for in the first
        // place. Wrapping `slots` in its own Expanded here previously
        // gave that wrapper an unspecified (default flex: 1) share,
        // which made `leading` win ~12/13 of the row's width and
        // squeezed the entire time grid into a sliver on one side.
        ...slots,
      ],
    );

    return Container(color: rowBackground, height: height, child: row);
  }
}

class _TeacherTable extends StatelessWidget {
  final TeacherScheduleEntry teacher;
  final dynamic settings;
  final List subjects;
  final List rooms;
  final List classes;

  const _TeacherTable({
    required this.teacher,
    required this.settings,
    required this.subjects,
    required this.rooms,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final startTime = settings.startTime as int;
    final minutes = settings.minutesList as List<int>;
    final endMinutes = settings.endMinutesList as List<int>;
    final timeslots = settings.timeslotsPerDay as int;
    final daysPerWeek = settings.daysPerWeek as int;
    final breakHours = settings.breakHoursPerDay as List<int>;
    final showSubjectColors = settings.showSubjectColors as bool? ?? true;
    final visibleSlots = [
      for (var index = 0; index < timeslots; index++)
        if (!breakHours.contains(startTime + index)) index,
    ];
    final dayNames = [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];

    // Header slot cells (time labels). Same flex per visible slot as the
    // day rows below, so the header's slot boundaries line up exactly with
    // every day row's slot boundaries. A thin vertical divider is placed
    // between consecutive labels (never before the first or after the
    // last) purely to make the time-header boundaries readable — it takes
    // zero layout width (matching the existing leading/body divider
    // elsewhere in this table) so it cannot shift the flex-based column
    // geometry shared with the body, and it is not repeated in the body
    // itself, which must stay free of a full vertical grid.
    final headerTimeLabels = <Widget>[
      for (final slotIndex in visibleSlots)
        _slotCell(
          _timeSlotFlex,
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${startTime + slotIndex}:${minutes[slotIndex].toString().padLeft(2, '0')}'
                '–${startTime + slotIndex + 1}:${endMinutes[slotIndex].toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: _headerText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
    ];
    final headerSlotCells = <Widget>[
      for (var i = 0; i < headerTimeLabels.length; i++) ...[
        if (i > 0)
          const VerticalDivider(
            width: 0,
            thickness: _borderThickness,
            color: _divider,
          ),
        headerTimeLabels[i],
      ],
    ];

    // One row per day. The day-name cell always gets the same background
    // as the time header row, per spec — the two headers must read as one
    // header system rather than two differently-colored elements.
    final dayRows = <Widget>[];
    for (var dayIndex = 0; dayIndex < daysPerWeek; dayIndex++) {
      final dayId = '${dayIndex + 1}';
      final day = teacher.days.where((item) => item.dayId == dayId).firstOrNull;
      final slotsById = {
        for (final slot in day?.slots ?? const <TeacherLessonSlot>[])
          slot.slotId: slot,
      };

      final slotCells = <Widget>[];
      var visibleIndex = 0;
      while (visibleIndex < visibleSlots.length) {
        final slotIndex = visibleSlots[visibleIndex];
        final slot = slotsById['${slotIndex + 1}'];
        // Merge consecutive timeslots that share the same lesson into one
        // wider cell, exactly like the previous implementation — only the
        // rendering of the resulting cell changes below.
        var span = 1;
        while (visibleIndex + span < visibleSlots.length && slot != null) {
          final nextIndex = visibleSlots[visibleIndex + span];
          final next = slotsById['${nextIndex + 1}'];
          if (next == null || !_sameLesson(slot, next)) break;
          span++;
        }
        // Whether a different lesson immediately precedes this cell (an
        // identical, consecutive lesson would already have been merged
        // into this same cell by the loop above). When true, that
        // neighboring cell already draws a trailing border on its own
        // side, so this cell must skip its leading border — otherwise the
        // shared boundary between two different adjacent lessons would be
        // drawn twice and look twice as thick.
        final hasPrecedingLesson =
            slot != null &&
            visibleIndex > 0 &&
            slotsById['${visibleSlots[visibleIndex - 1] + 1}'] != null;
        slotCells.add(
          _slotCell(
            _timeSlotFlex * span,
            _lessonCell(
              slot,
              l10n,
              showSubjectColors,
              suppressLeadingBorder: hasPrecedingLesson,
            ),
          ),
        );
        visibleIndex += span;
      }

      dayRows.add(
        _TimetableRow(
          // The horizontal day separator is drawn as this cell's own
          // bottom border rather than a full-row Divider, so the line is
          // confined to the day-name column and never crosses into the
          // timetable body (no border on the last day, since nothing
          // follows it).
          leading: Container(
            decoration: BoxDecoration(
              color: _headerBg,
              border: dayIndex < daysPerWeek - 1
                  ? const Border(
                      bottom: BorderSide(
                        color: _divider,
                        width: _borderThickness,
                      ),
                    )
                  : null,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              dayIndex < dayNames.length
                  ? dayNames[dayIndex]
                  : l10n.dayNumberFallback(dayId),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _headerText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          slots: slotCells,
        ),
      );
    }

    return Container(
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
        child: Column(
          children: [
            // Header row: day/time-header background applied to the whole
            // row, so the blank corner cell matches the time labels beside
            // it — and, by extension, the day-name cells below (see
            // `leading` above), keeping all three header surfaces one
            // consistent color.
            _TimetableRow(
              rowBackground: _headerBg,
              height: _headerRowHeight,
              leading: const SizedBox.shrink(),
              slots: headerSlotCells,
            ),
            // The only horizontal rule in the whole grid: it separates the
            // header from the schedule body. Day rows are stacked directly
            // below it with no further horizontal lines, so empty periods
            // read as open white space rather than a dense lattice of
            // empty boxes.
            const Divider(
              height: _borderThickness,
              thickness: _borderThickness,
              color: _divider,
            ),
            // Day rows share the remaining height of the table equally —
            // there is no fixed per-row height any more. This, together
            // with the SizedBox in the LayoutBuilder above that hands this
            // whole table its available height, is what lets the table
            // always fit the page exactly with no scrolling regardless of
            // how many days are configured. The separator between one day
            // and the next is drawn by each day's own leading cell (its
            // bottom border — see above), not by a widget here, precisely
            // so it stays confined to the day-name column instead of
            // crossing the timetable body.
            Expanded(
              child: Column(
                children: [for (final row in dayRows) Expanded(child: row)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotCell(int flex, Widget child) =>
      Expanded(flex: flex, child: child);

  bool _sameLesson(TeacherLessonSlot first, TeacherLessonSlot second) {
    return first.classId == second.classId &&
        first.subjectId == second.subjectId &&
        first.roomId == second.roomId;
  }

  /// Renders a single Day × Time-slot area.
  ///
  /// The outer bounds always fill exactly the height given by the day
  /// row, whether the period is empty or occupied — that's what keeps
  /// every row in the grid the same height regardless of how much content
  /// any one slot happens to have.
  ///
  /// - Empty period: same bordered cell as an occupied one, just with a
  ///   plain white fill and no content — this is what makes the timetable
  ///   read as one complete grid (matching the Student timetable's
  ///   principle of always drawing every cell) instead of leaving large
  ///   unbordered white gaps wherever the teacher has no lesson.
  /// - Occupied period: a rectangular, square-cornered cell fills the slot
  ///   exactly (matching the Student timetable's own cell geometry) —
  ///   there is no inset gap and no rounded corner, so it reads as part of
  ///   the timetable grid rather than a floating card placed on top of it.
  ///   [suppressLeadingBorder] drops this cell's leading-edge border when a
  ///   different lesson immediately precedes it, so that shared boundary
  ///   is drawn once (by the preceding cell's trailing border) instead of
  ///   twice as thick.
  Widget _lessonCell(
    TeacherLessonSlot? slot,
    AppLocalizations l10n,
    bool showSubjectColors, {
    required bool suppressLeadingBorder,
  }) {
    const cellBorderSide = BorderSide(color: _divider, width: _borderThickness);

    if (slot == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: BorderDirectional(
            top: cellBorderSide,
            bottom: cellBorderSide,
            end: cellBorderSide,
            start: suppressLeadingBorder ? BorderSide.none : cellBorderSide,
          ),
        ),
      );
    }

    final subject = subjects
        .where((item) => item.subjectId == slot.subjectId)
        .firstOrNull;
    final room = rooms.where((item) => item.roomId == slot.roomId).firstOrNull;
    final classItem = classes
        .where((item) => item.classId == slot.classId)
        .firstOrNull;

    Color? cellColor;
    if (showSubjectColors && subject?.color != null) {
      cellColor = Color(subject!.color!).withValues(alpha: 0.15);
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor ?? Colors.white,
        border: BorderDirectional(
          top: cellBorderSide,
          bottom: cellBorderSide,
          end: cellBorderSide,
          start: suppressLeadingBorder ? BorderSide.none : cellBorderSide,
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(_cellPadding),
      // FittedBox scales the whole label block down to fit whatever space
      // this cell actually has — the same technique already used for the
      // time-header labels above — so a shorter or narrower cell shrinks
      // its text instead of overflowing.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subject?.subjectName ??
                  l10n.subjectNumberFallback(slot.subjectId.toString()),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              classItem?.className ??
                  l10n.classNumberFallback(slot.classId.toString()),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: _textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              room?.roomName ?? l10n.roomNumberFallback(slot.roomId.toString()),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
