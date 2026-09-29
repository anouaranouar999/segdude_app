import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_result_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

const _blue = Color(0xFF2A6FDB);
const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);
const _divider = Color(0xFFDDE3EC);
const _pageBg = Color(0xFFF4F7FB);
const _textPrimary = Color(0xFF1A2E4A);
const _textSecondary = Color(0xFF5A6A85);

/// A fixed palette of 10 visually distinct group colours.
/// Groups are assigned colours in order of appearance.
const _groupPalette = [
  Color(0xFF3B82F6), // blue
  Color(0xFFEF4444), // red
  Color(0xFF10B981), // emerald
  Color(0xFFF59E0B), // amber
  Color(0xFF8B5CF6), // violet
  Color(0xFFEC4899), // pink
  Color(0xFF14B8A6), // teal
  Color(0xFFF97316), // orange
  Color(0xFF6366F1), // indigo
  Color(0xFF84CC16), // lime
];

class ScheduleResultTab2 extends ConsumerStatefulWidget {
  final ScheduleDecoder? schedule;
  const ScheduleResultTab2({super.key, this.schedule});

  @override
  ConsumerState<ScheduleResultTab2> createState() => _ScheduleResultTab2State();
}

class _ScheduleResultTab2State extends ConsumerState<ScheduleResultTab2> {
  String _searchQuery = '';
  int? _selectedSubjectId;
  int _activeViewIndex =
      0; // 0: Teachers Matrix, 1: Rooms Summary, 2: Subjects & Slots

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userLicenseProvider.notifier).checkLicense();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheduleData = widget.schedule ?? ref.watch(currentScheduleProvider);
    final teachersState = ref.watch(teachersProvider);
    final subjectsState = ref.watch(subjectsProvider);
    final roomsState = ref.watch(roomsProvider);
    final levelsState = ref.watch(levelsProvider);
    final licenseState = ref.watch(userLicenseProvider);

    final user = ref.watch(userProvider);
    final showWarning = user == null || !licenseState.isPremium;
    // print(user!.userMetadata?['full_name']);
    if (scheduleData == null || scheduleData.classes.isEmpty) {
      return Expanded(
        child: Container(
          color: _pageBg,
          child: Column(
            children: [
              if (showWarning)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.red.shade200, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.licenseWarning} ${l10n.licenseWarningDesc}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: _textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.localeName == 'ar'
                            ? 'لا توجد بيانات جدول متاحة للعرض'
                            : 'No schedule summary available',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
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

    // 1. Levels Info Map
    final levelsList = levelsState.levelIds.keys.toList();
    final levelClassCounts = levelsState.levels; // Map<String, int>

    // 2. Aggregate Teacher Rows
    final teacherRows = _aggregateTeacherData(
      schedule: scheduleData,
      teachers: teachersState.teachers,
      subjects: subjectsState.subjects,
      rooms: roomsState.rooms,
      classes: levelsState.classes,
      levelRealId: levelsState.realID,
      levelIds: levelsState.levelIds,
    );

    // 3. Filter Teacher Rows
    final filteredTeacherRows = teacherRows.where((row) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          row.teacherName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          row.subjectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          row.assignedRooms.any(
            (r) => r.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      final matchesSubject =
          _selectedSubjectId == null || row.subjectId == _selectedSubjectId;
      return matchesSearch && matchesSubject;
    }).toList();

    // 4. Aggregate Room Rows
    final roomRows = _aggregateRoomData(
      schedule: scheduleData,
      rooms: roomsState.rooms,
      subjects: subjectsState.subjects,
      teachers: teachersState.teachers,
      classes: levelsState.classes,
    );

    // 5. Calculate Metrics
    final totalTeachers = teacherRows.length;
    final totalClassesCount = levelsState.classes.length;
    final totalScheduledHours = teacherRows.fold<int>(
      0,
      (sum, r) => sum + r.totalHours,
    );
    final activeRoomsCount = roomRows
        .where((r) => r.totalScheduledHours > 0)
        .length;

    return Container(
      color: _pageBg,
      child: Column(
        children: [
          if (showWarning)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.red.shade200, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.licenseWarning} ${l10n.licenseWarningDesc}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Top Institution Header & Summary Metrics Card
          _buildHeaderCard(
            l10n: l10n,
            levelsList: levelsList,
            levelClassCounts: levelClassCounts,
            totalTeachers: totalTeachers,
            totalClassesCount: totalClassesCount,
            totalScheduledHours: totalScheduledHours,
            activeRoomsCount: activeRoomsCount,
          ),

          // Toolbar: Search, Subject Filter, View Switcher & Export Button
          _buildToolbar(
            l10n: l10n,
            subjects: subjectsState.subjects,
            onPrint: () => _printSummaryPdf(
              scheduleData: scheduleData,
              teacherRows: teacherRows,
              levelsList: levelsList,
              levelClassCounts: levelClassCounts,
              l10n: l10n,
              l10ncontext: context,
            ),
          ),

          // Main Table View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: _divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  child: _activeViewIndex == 0
                      ? _buildTeachersMatrixTable(
                          filteredTeacherRows,
                          levelsList,
                          l10n,
                          teacherShiftGroups: scheduleData.teacherShiftGroups,
                        )
                      : _activeViewIndex == 1
                      ? _buildRoomsSummaryTable(roomRows, l10n)
                      : _buildSubjectsSummaryTable(
                          scheduleData,
                          subjectsState.subjects,
                          teachersState.teachers,
                          l10n,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Banner Card
  Widget _buildHeaderCard({
    required AppLocalizations l10n,
    required List<String> levelsList,
    required Map<String, int> levelClassCounts,
    required int totalTeachers,
    required int totalClassesCount,
    required int totalScheduledHours,
    required int activeRoomsCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1E3A8A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --------------------------------------- Institution Header
          Text(
            ref.watch(userProvider)?.institution ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Levels Class Breakdown Chips
          if (levelClassCounts.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                ...levelClassCounts.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '${e.key} : ${e.value.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${l10n.classes}  : $totalClassesCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Key Summary Metrics Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(Icons.people, l10n.teachers, '$totalTeachers'),
              _buildStatChip(Icons.class_, l10n.classes, '$totalClassesCount'),
              _buildStatChip(
                Icons.meeting_room,
                l10n.rooms,
                '$activeRoomsCount',
              ),
              _buildStatChip(
                Icons.access_time,
                l10n.hours,
                '$totalScheduledHours',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Toolbar View
  Widget _buildToolbar({
    required AppLocalizations l10n,
    required List<SubjectEncoder> subjects,
    required VoidCallback onPrint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Search Input
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: l10n.localeName == 'ar'
                      ? 'بحث عن أستاذ أو مادة...'
                      : 'Search teacher or subject...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: _textSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _divider),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Subject Filter Dropdown
          SizedBox(
            height: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedSubjectId,
                  hint: Text(
                    l10n.localeName == 'ar' ? 'كل المواد' : 'All Subjects',
                    style: const TextStyle(fontSize: 13, color: _textSecondary),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        l10n.localeName == 'ar' ? 'كل المواد' : 'All Subjects',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    ...subjects.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.subjectId,
                        child: Text(
                          s.subjectName ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedSubjectId = val),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // View Selector Switcher (Segmented Control)
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _divider),
            ),
            child: Row(
              children: [
                _buildViewTab(
                  0,
                  l10n.localeName == 'ar' ? 'جدول الأساتذة' : 'Teachers Matrix',
                  Icons.table_chart_outlined,
                ),
                _buildViewTab(
                  1,
                  l10n.localeName == 'ar' ? 'توزيع القاعات' : 'Rooms Summary',
                  Icons.meeting_room_outlined,
                ),
                _buildViewTab(
                  2,
                  l10n.localeName == 'ar' ? 'إحصائيات الحصص' : 'Slots Stats',
                  Icons.bar_chart,
                ),
              ],
            ),
          ),
          const Spacer(),

          // Print PDF Button
          ElevatedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print, size: 20),
            label: Text(
              l10n.print,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab(int index, String label, IconData icon) {
    final isSelected = _activeViewIndex == index;
    return InkWell(
      onTap: () => setState(() => _activeViewIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : _textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // View 1: Main Teacher Assignment Matrix
  // ---------------------------------------------------------------------------
  Widget _buildTeachersMatrixTable(
    List<_TeacherRowData> rows,
    List<String> levelsList,
    AppLocalizations l10n, {
    TeacherShiftGroups? teacherShiftGroups,
  }) {
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noMatchingRecordsFound,
            style: const TextStyle(color: _textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    // Build group → color and teacher → group maps.
    final groupColorMap = <String, Color>{};
    final teacherGroupMap = <int, TeacherShiftGroup>{};
    if (teacherShiftGroups != null) {
      for (var i = 0; i < teacherShiftGroups.groups.length; i++) {
        final group = teacherShiftGroups.groups[i];
        final color = _groupPalette[i % _groupPalette.length];
        groupColorMap[group.groupId] = color;
        for (final teacherId in group.teacherIds) {
          teacherGroupMap[teacherId] = group;
        }
      }
    }

    // Build a legend row if we have shift groups.
    // Widget? legend;
    // if (groupColorMap.isNotEmpty) {
    //   legend = Container(
    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    //     color: _pageBg,
    //     child: Wrap(
    //       spacing: 12,
    //       runSpacing: 4,
    //       children: teacherShiftGroups!.groups.asMap().entries.map((e) {
    //         final group = e.value;
    //         final color =
    //             groupColorMap[group.groupId] ??
    //             _groupPalette[e.key % _groupPalette.length];
    //         return Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Container(
    //               width: 12,
    //               height: 12,
    //               decoration: BoxDecoration(
    //                 color: color,
    //                 shape: BoxShape.circle,
    //               ),
    //             ),
    //             const SizedBox(width: 4),
    //             Text(
    //               'Group ${group.groupId}',
    //               style: const TextStyle(
    //                 fontSize: 12,
    //                 color: _textSecondary,
    //                 fontWeight: FontWeight.w500,
    //               ),
    //             ),
    //             if (group.pattern.isNotEmpty) ...[
    //               const SizedBox(width: 4),
    //               Text(
    //                 '(${group.pattern.join(' › ')})',
    //                 style: const TextStyle(fontSize: 11, color: _textSecondary),
    //               ),
    //             ],
    //           ],
    //         );
    //       }).toList(),
    //     ),
    //   );
    // }

    final table = Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: _divider, width: 1),
            children: [
              // Header Row
              TableRow(
                decoration: const BoxDecoration(color: _headerBg),
                children: [
                  _headerCell('#'),
                  _headerCell('${l10n.lastName}/${l10n.firstName}'),
                  _headerCell(l10n.id),
                  _headerCell(l10n.subjectsTaught),
                  // Level columns
                  ...List.generate(
                    levelsList.isEmpty ? 3 : levelsList.length,
                    (i) => _headerCell(
                      levelsList.isNotEmpty
                          ? '(${i + 1}) ${levelsList[i]}'
                          : '(${i + 1}) ${l10n.levels} ${i + 1}',
                    ),
                  ),
                  _headerCell(l10n.classes),
                  _headerCell(l10n.rooms),
                  _headerCell(l10n.hours),
                  if (groupColorMap.isNotEmpty) _headerCell(l10n.grouping),
                  // _headerCell(l10n.grouping),
                  _headerCell(l10n.notes),
                ],
              ),

              // Data Rows
              ...rows.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final r = entry.value;
                final isEven = idx % 2 == 0;

                // Look up which shift group this teacher belongs to.
                final shiftGroup = teacherGroupMap[r.teacherId];
                final groupColor = shiftGroup != null
                    ? groupColorMap[shiftGroup.groupId]
                    : null;

                return TableRow(
                  decoration: BoxDecoration(
                    color: groupColor != null
                        ? groupColor.withValues(alpha: 0.07)
                        : (isEven ? const Color(0xFFF9FAFB) : Colors.white),
                  ),
                  children: [
                    _dataCellWithAccent(
                      '$idx',
                      align: Alignment.center,
                      isBold: true,
                      accentColor: groupColor,
                    ),
                    _teacherNameCell(
                      r.teacherName,
                      shiftGroup: shiftGroup,
                      groupColor: groupColor,
                    ),
                    _dataCell('   ', align: Alignment.center),
                    _dataCell(r.subjectName, isBold: true, color: _headerText),

                    // Class list cells per level
                    ...List.generate(
                      levelsList.isEmpty ? 3 : levelsList.length,
                      (lIdx) {
                        final levelName = levelsList.isNotEmpty
                            ? levelsList[lIdx]
                            : 'Level ${lIdx + 1}';
                        final assigned =
                            r.assignedClassesByLevel[levelName] ?? [];
                        final formatted = _formatClassDisplayList(assigned);
                        return _dataCell(
                          formatted,
                          align: Alignment.center,
                          isBold: assigned.isNotEmpty,
                          color: assigned.isNotEmpty ? _blue : _textSecondary,
                        );
                      },
                    ),

                    _dataCell(
                      '${r.totalClasses}',
                      align: Alignment.center,
                      isBold: true,
                    ),
                    _dataCell(
                      r.assignedRooms.isEmpty
                          ? '-'
                          : r.assignedRooms.join(' - '),
                      align: Alignment.center,
                    ),
                    _dataCell(
                      '${r.totalHours}',
                      align: Alignment.center,
                      isBold: true,
                      color: Colors.blue.shade900,
                    ),
                    if (groupColorMap.isNotEmpty)
                      _groupChipCell(shiftGroup, groupColor),
                    // _dataCell(r.fouj, align: Alignment.center),
                    _dataCell(r.notes, align: Alignment.center),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
    return table;
    // if (legend == null) return table;
    // return Column(
    //   children: [
    //     // legend,
    //     const Divider(height: 1, color: _divider),
    //     Expanded(child: table),
    //   ],
    // );
  }

  /// Teacher name cell with an optional left-border accent and group chip.
  Widget _teacherNameCell(
    String name, {
    TeacherShiftGroup? shiftGroup,
    Color? groupColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: groupColor != null
          ? BoxDecoration(
              border: Border(left: BorderSide(color: groupColor, width: 3)),
            )
          : null,
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    );
  }

  /// Small coloured chip showing the group ID.
  Widget _groupChipCell(TeacherShiftGroup? group, Color? color) {
    if (group == null || color == null) {
      return const SizedBox(height: 36);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          group.groupId,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  /// Data cell with an optional coloured left-border accent.
  Widget _dataCellWithAccent(
    String content, {
    Alignment align = Alignment.centerLeft,
    bool isBold = false,
    Color? color,
    Color? accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: align,
      decoration: accentColor != null
          ? BoxDecoration(
              border: Border(left: BorderSide(color: accentColor, width: 3)),
            )
          : null,
      child: Text(
        content.isEmpty ? '-' : content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          color: color ?? _textPrimary,
        ),
      ),
    );
  }

  Widget _headerCell(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      alignment: Alignment.center,
      color: _headerBg,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: _headerText,
        ),
      ),
    );
  }

  Widget _dataCell(
    String content, {
    Alignment align = Alignment.centerLeft,
    bool isBold = false,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: align,
      child: Text(
        content.isEmpty ? '-' : content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          color: color ?? _textPrimary,
        ),
      ),
    );
  }

  // Format assigned classes nicely like reference PDF: e.g., "3/4 - 5 - 6" or "1/1 - 2 - 3"
  String _formatClassDisplayList(List<String> classNames) {
    if (classNames.isEmpty) return '-';
    if (classNames.length == 1) return classNames.first;

    final formattedItems = <String>[];
    for (final name in classNames) {
      final parts = name.split('_');
      if (parts.length > 1) {
        formattedItems.add(parts.last);
      } else {
        formattedItems.add(name);
      }
    }
    return formattedItems.join(' - ');
  }

  // ---------------------------------------------------------------------------
  // View 2: Rooms Summary View
  // ---------------------------------------------------------------------------
  Widget _buildRoomsSummaryTable(
    List<_RoomRowData> roomRows,
    AppLocalizations l10n,
  ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        itemCount: roomRows.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: _divider),
        itemBuilder: (context, idx) {
          final room = roomRows[idx];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: room.totalScheduledHours > 0
                  ? _blue
                  : Colors.grey.shade300,
              child: Icon(
                Icons.meeting_room,
                color: room.totalScheduledHours > 0
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
            ),
            title: Text(
              room.roomName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _textPrimary,
              ),
            ),
            subtitle: Text(
              'السعة: ${room.capacity} طالب | المواد: ${room.subjectsTaught.isEmpty ? 'الكل' : room.subjectsTaught.join(', ')}',
              style: const TextStyle(fontSize: 12, color: _textSecondary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${room.totalScheduledHours} ساعة أسبوعياً',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _blue,
                  ),
                ),
                Text(
                  '${room.classesUsing.length} فصول تستعمل القاعة',
                  style: const TextStyle(fontSize: 11, color: _textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // View 3: Subjects & Slots Summary View
  // ---------------------------------------------------------------------------
  Widget _buildSubjectsSummaryTable(
    ScheduleDecoder schedule,
    List<SubjectEncoder> subjects,
    List<TeacherEncoder> teachers,
    AppLocalizations l10n,
  ) {
    // Aggregate subject statistics
    final subjectHours = <int, int>{};
    final subjectClasses = <int, Set<String>>{};
    final subjectTeachers = <int, Set<String>>{};

    for (final cs in schedule.classes) {
      for (final day in cs.days) {
        for (final slot in day.slots) {
          if (slot.lesson != null) {
            final sId = slot.lesson!.subjectId;
            final tId = slot.lesson!.teacherId;

            subjectHours[sId] = (subjectHours[sId] ?? 0) + 1;
            subjectClasses.putIfAbsent(sId, () => {}).add(cs.classId);

            if (tId > 0 && tId <= teachers.length) {
              final tName = teachers[tId - 1].teacherName ?? 'أستاذ $tId';
              subjectTeachers.putIfAbsent(sId, () => {}).add(tName);
            }
          }
        }
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        itemCount: subjects.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: _divider),
        itemBuilder: (context, idx) {
          final subj = subjects[idx];
          final hours = subjectHours[subj.subjectId] ?? 0;
          final classesCount = subjectClasses[subj.subjectId]?.length ?? 0;
          final tList = subjectTeachers[subj.subjectId]?.toList() ?? [];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: subj.color != null ? Color(subj.color!) : _blue,
              child: Text(
                '${subj.subjectId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              subj.subjectName ?? l10n.unknownSubject,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _textPrimary,
              ),
            ),
            subtitle: Text(
              'الأساتذة: ${tList.isEmpty ? 'غير معين' : tList.join(' - ')}',
              style: const TextStyle(fontSize: 12, color: _textSecondary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$hours ساعة أسبوعياً',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _blue,
                  ),
                ),
                Text(
                  'المسند لـ $classesCount فصل',
                  style: const TextStyle(fontSize: 11, color: _textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Data Aggregation Helper
  // ---------------------------------------------------------------------------
  List<_TeacherRowData> _aggregateTeacherData({
    required ScheduleDecoder schedule,
    required List<TeacherEncoder> teachers,
    required List<SubjectEncoder> subjects,
    required List<RoomEncoder> rooms,
    required List<ClassLevelEncoder> classes,
    required Map<int, String> levelRealId,
    required Map<String, int> levelIds,
  }) {
    // Map classId to ClassLevelEncoder
    final classMap = <String, ClassLevelEncoder>{};
    for (final c in classes) {
      if (c.classId != null) {
        classMap[c.classId.toString()] = c;
      }
    }

    final teacherMap = <int, _TeacherRowData>{};

    // Initialize map from teachers list
    for (final t in teachers) {
      final sName =
          t.subjectId != null &&
              t.subjectId! > 0 &&
              t.subjectId! <= subjects.length
          ? (subjects[t.subjectId! - 1].subjectName ?? 'مادة ${t.subjectId}')
          : 'مادة غير محددة';

      teacherMap[t.teacherId] = _TeacherRowData(
        teacherId: t.teacherId,
        teacherName: t.teacherName ?? 'أستاذ ${t.teacherId}',
        subjectId: t.subjectId ?? 0,
        subjectName: sName,
        // gender: 'أنثى/ذكر',
        payrollNo: '${2150000 + t.teacherId * 1357}',
        assignedClassesByLevel: {},
        totalClasses: 0,
        assignedRooms: [],
        totalHours: 0,
        // fouj: 'A',
        notes: '',
      );
    }

    // Traverse schedule slots
    for (final cs in schedule.classes) {
      final clsEncoder = classMap[cs.classId];
      final levelName = clsEncoder?.levelId != null
          ? (levelRealId[clsEncoder!.levelId] ??
                'المستوى ${clsEncoder.levelId}')
          : 'المستوى 1';
      final className = clsEncoder?.className ?? 'فصل ${cs.classId}';

      for (final day in cs.days) {
        for (final slot in day.slots) {
          if (slot.lesson != null) {
            final tId = slot.lesson!.teacherId;
            final rId = slot.lesson!.roomId;

            // Ensure teacher row exists (including unassigned slots where tId might be 0)
            if (tId > 0 && !teacherMap.containsKey(tId)) {
              final sId = slot.lesson!.subjectId;
              final sName = sId > 0 && sId <= subjects.length
                  ? (subjects[sId - 1].subjectName ?? 'مادة $sId')
                  : 'مادة $sId';
              teacherMap[tId] = _TeacherRowData(
                teacherId: tId,
                teacherName: tId <= teachers.length
                    ? (teachers[tId - 1].teacherName ?? 'أستاذ $tId')
                    : 'أستاذ $tId',
                subjectId: sId,
                subjectName: sName,
                // gender: 'أنثى/ذكر',
                payrollNo: '${2150000 + tId * 1357}',
                assignedClassesByLevel: {},
                totalClasses: 0,
                assignedRooms: [],
                totalHours: 0,
                // fouj: 'A',
                notes: '',
              );
            }

            if (tId > 0) {
              final tRow = teacherMap[tId]!;
              tRow.totalHours += 1;

              // Add room name
              if (rId > 0 && rId <= rooms.length) {
                final rName = rooms[rId - 1].roomName;
                if (!tRow.assignedRooms.contains(rName)) {
                  tRow.assignedRooms.add(rName);
                }
              }

              // Add class to level assigned list
              final levelClasses = tRow.assignedClassesByLevel.putIfAbsent(
                levelName,
                () => [],
              );
              if (!levelClasses.contains(className)) {
                levelClasses.add(className);
              }
            }
          }
        }
      }
    }

    // Calculate total distinct classes count per teacher
    for (final r in teacherMap.values) {
      final uniqueClasses = <String>{};
      for (final list in r.assignedClassesByLevel.values) {
        uniqueClasses.addAll(list);
      }
      r.totalClasses = uniqueClasses.length;
    }

    return teacherMap.values.toList();
  }

  // Rooms Data Aggregator
  List<_RoomRowData> _aggregateRoomData({
    required ScheduleDecoder schedule,
    required List<RoomEncoder> rooms,
    required List<SubjectEncoder> subjects,
    required List<TeacherEncoder> teachers,
    required List<ClassLevelEncoder> classes,
  }) {
    final roomMap = <int, _RoomRowData>{};

    for (final r in rooms) {
      roomMap[r.roomId] = _RoomRowData(
        roomId: r.roomId,
        roomName: r.roomName,
        capacity: r.capacity,
        subjectsTaught: [],
        teachersUsing: [],
        classesUsing: {},
        totalScheduledHours: 0,
      );
    }

    for (final cs in schedule.classes) {
      for (final day in cs.days) {
        for (final slot in day.slots) {
          if (slot.lesson != null && slot.lesson!.roomId > 0) {
            final rId = slot.lesson!.roomId;
            if (roomMap.containsKey(rId)) {
              final roomRow = roomMap[rId]!;
              roomRow.totalScheduledHours += 1;
              roomRow.classesUsing.add(cs.classId);

              final sId = slot.lesson!.subjectId;
              if (sId > 0 && sId <= subjects.length) {
                final sName = subjects[sId - 1].subjectName ?? '';
                if (!roomRow.subjectsTaught.contains(sName)) {
                  roomRow.subjectsTaught.add(sName);
                }
              }
            }
          }
        }
      }
    }

    return roomMap.values.toList();
  }

  // ---------------------------------------------------------------------------
  // PDF Export Engine (Reference Document Reproducer)
  // ---------------------------------------------------------------------------
  Future<void> _printSummaryPdf({
    required ScheduleDecoder scheduleData,
    required List<_TeacherRowData> teacherRows,
    required List<String> levelsList,
    required Map<String, int> levelClassCounts,
    required AppLocalizations l10n,
    required BuildContext l10ncontext,
  }) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    final totalClassesCount = levelClassCounts.values.fold<int>(
      0,
      (sum, v) => sum + v,
    );

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        margin: const pw.EdgeInsets.only(left: 15, top: 5),
        orientation: pw.PageOrientation.portrait,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: AppLocalizations.of(l10ncontext)!.localeName == 'ar'
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // PDF Top Title Box (Reference Document Header)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1.5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            ref.read(userProvider)?.institution ?? '',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.Text(
                            '${l10n.schoolSeason} : ${DateTime.now().year}/${DateTime.now().year + 1}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 1,
                          ),
                        ),
                        child: pw.Text(
                          '$totalClassesCount',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // Main PDF Data Table
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.black,
                      width: 0.8,
                    ),
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _pdfHeaderCell('#'),
                          _pdfHeaderCell('${l10n.firstName}/${l10n.lastName}'),
                          _pdfHeaderCell(l10n.id),
                          _pdfHeaderCell(l10n.subject),
                          ...List.generate(
                            levelsList.isEmpty ? 3 : levelsList.length,
                            (i) => _pdfHeaderCell(
                              levelsList.isNotEmpty
                                  ? '(${i + 1}) ${levelsList[i]}'
                                  : '(${i + 1}) ${l10n.levels} ${i + 1}',
                            ),
                          ),
                          _pdfHeaderCell('${l10n.number} ${l10n.classes}'),
                          _pdfHeaderCell(l10n.room),
                          _pdfHeaderCell('${l10n.number} ${l10n.hours}'),
                          _pdfHeaderCell(l10n.notes),
                        ],
                      ),

                      // Data Rows
                      ...teacherRows.asMap().entries.map((e) {
                        final idx = e.key + 1;
                        final r = e.value;

                        return pw.TableRow(
                          children: [
                            _pdfDataCell('$idx'),
                            _pdfDataCell(r.teacherName, isBold: true),
                            _pdfDataCell(r.payrollNo),
                            _pdfDataCell(r.subjectName, isBold: true),
                            ...List.generate(
                              levelsList.isEmpty ? 3 : levelsList.length,
                              (lIdx) {
                                final lName = levelsList.isNotEmpty
                                    ? levelsList[lIdx]
                                    : 'Level ${lIdx + 1}';
                                final assigned =
                                    r.assignedClassesByLevel[lName] ?? [];
                                return _pdfDataCell(
                                  _formatClassDisplayList(assigned),
                                );
                              },
                            ),
                            _pdfDataCell('${r.totalClasses}', isBold: true),
                            _pdfDataCell(r.assignedRooms.join(' - ')),
                            _pdfDataCell('${r.totalHours}', isBold: true),
                            _pdfDataCell(r.notes),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Teacher_Summary_List',
    );
  }

  pw.Widget _pdfHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _pdfDataCell(String text, {bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text.isEmpty ? '-' : text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

// Data Holding Classes
class _TeacherRowData {
  final int teacherId;
  final String teacherName;
  final int subjectId;
  final String subjectName;
  // final String gender;
  final String payrollNo;
  final Map<String, List<String>> assignedClassesByLevel;
  int totalClasses;
  final List<String> assignedRooms;
  int totalHours;
  // final String fouj;
  final String notes;

  _TeacherRowData({
    required this.teacherId,
    required this.teacherName,
    required this.subjectId,
    required this.subjectName,
    // required this.gender,
    required this.payrollNo,
    required this.assignedClassesByLevel,
    required this.totalClasses,
    required this.assignedRooms,
    required this.totalHours,
    // required this.fouj,
    required this.notes,
  });
}

class _RoomRowData {
  final int roomId;
  final String roomName;
  final int capacity;
  final List<String> subjectsTaught;
  final List<String> teachersUsing;
  final Set<String> classesUsing;
  int totalScheduledHours;

  _RoomRowData({
    required this.roomId,
    required this.roomName,
    required this.capacity,
    required this.subjectsTaught,
    required this.teachersUsing,
    required this.classesUsing,
    required this.totalScheduledHours,
  });
}
