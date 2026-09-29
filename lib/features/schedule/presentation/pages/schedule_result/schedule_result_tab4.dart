import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

const _blue = Color(0xFF2A6FDB);
const _headerBg = Color(0xFFEEF3FB);
const _headerText = Color(0xFF2A4A7F);
const _divider = Color(0xFFDDE3EC);
const _pageBg = Color(0xFFF4F7FB);
const _textPrimary = Color(0xFF1A2E4A);
const _textSecondary = Color(0xFF5A6A85);

class ScheduleResultTab4 extends ConsumerWidget {
  final ScheduleDecoder schedule;
  final Map<String, String> daysMap;

  const ScheduleResultTab4({
    super.key,
    required this.schedule,
    required this.daysMap,
  });

  bool _isFreeForClass(String cId, int dIndex, int tIndex) {
    final cSched = schedule.classes.firstWhere(
      (c) => c.classId == cId,
      orElse: () => const ClassSchedule(classId: '', days: []),
    );
    if (cSched.days.isEmpty || dIndex < 0 || dIndex >= cSched.days.length) {
      return true;
    }
    final day = cSched.days[dIndex];
    if (day.slots.isEmpty || tIndex < 0 || tIndex >= day.slots.length) {
      return true;
    }
    final slot = day.slots[tIndex];
    if (slot.slotId == 'lock') return false;
    if (slot.lesson?.subjectId != null) return false;
    return true;
  }

  bool _isTeacherFree(int tId, int dayIndex, int timeIndex) {
    for (final cSched in schedule.classes) {
      if (cSched.days.length > dayIndex) {
        final day = cSched.days[dayIndex];
        if (day.slots.length > timeIndex) {
          final slot = day.slots[timeIndex];
          if (slot.lesson?.teacherId == tId) return false;
        }
      }
    }
    return true;
  }

  bool _isRoomFree(int rId, int dayIndex, int timeIndex) {
    for (final cSched in schedule.classes) {
      if (cSched.days.length > dayIndex) {
        final day = cSched.days[dayIndex];
        if (day.slots.length > timeIndex) {
          final slot = day.slots[timeIndex];
          if (slot.lesson?.roomId == rId) return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final classes = ref.watch(levelsProvider.select((s) => s.classes));
    final timing = ref.read(settingsProvider);
    final teachers = ref.read(teachersProvider).teachers;
    final rooms = ref.read(roomsProvider).rooms;
    final selectedDays = timing.selectedDays;
    final startTime = timing.startTime;
    final minutes = timing.minutesList;
    final endMinutes = timing.endMinutesList;
    final days = <String>[...daysMap.keys];

    // Group levels
    final levelIds = classes.map((c) => c.levelId).toSet().toList();

    // Pre-compute each day's rendered rows once, so we can tell up front
    // whether the whole tab has nothing free anywhere (global empty state)
    // vs. only some days being empty (per-day empty state).
    final dayRows = <int, List<_FreeSlotRow>>{};

    for (var dayIndex = 0; dayIndex < selectedDays.length; dayIndex++) {
      final rows = <_FreeSlotRow>[];

      for (var timeIndex = 0; timeIndex < timing.timeslotsPerDay; timeIndex++) {
        if (timing.breakHoursPerDay.contains(startTime + timeIndex)) continue;

        int allLevelFreeCount = 0;
        for (final c in classes) {
          if (_isFreeForClass(c.classId.toString(), dayIndex, timeIndex)) {
            allLevelFreeCount++;
          }
        }
        final emptyForAllLevels =
            allLevelFreeCount == classes.length && classes.isNotEmpty;

        final indicators = <_LevelIndicator>[];

        for (final levelId in levelIds) {
          final sameLevelClasses = classes
              .where((c) => c.levelId == levelId)
              .toList();
          int sameLevelFreeCount = 0;
          final sameLevelFreeClassNames = <String>[];

          for (final c in sameLevelClasses) {
            if (_isFreeForClass(c.classId.toString(), dayIndex, timeIndex)) {
              sameLevelFreeCount++;
              sameLevelFreeClassNames.add(c.className ?? '');
            }
          }

          final freeForAllSameLevel =
              sameLevelFreeCount == sameLevelClasses.length &&
              sameLevelClasses.isNotEmpty;
          final freeForMoreThan2SameLevel = sameLevelFreeCount > 2;

          Color? dotColor;
          if (emptyForAllLevels) {
            dotColor = Colors.green;
          } else if (freeForAllSameLevel) {
            dotColor = Colors.orange;
          } else if (freeForMoreThan2SameLevel) {
            dotColor = _blue;
          }

          if (dotColor != null) {
            indicators.add(
              _LevelIndicator(
                levelId: levelId,
                color: dotColor,
                freeClassNames: sameLevelFreeClassNames,
              ),
            );
          }
        }

        if (indicators.isEmpty) continue;

        final timeString =
            '${(startTime + timeIndex).toString().padLeft(2, '0')}:${minutes[timeIndex].toString().padLeft(2, '0')} - '
            '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:${endMinutes[timeIndex].toString().padLeft(2, '0')}';

        rows.add(
          _FreeSlotRow(
            dayIndex: dayIndex,
            timeIndex: timeIndex,
            timeString: timeString,
            indicators: indicators,
          ),
        );
      }

      dayRows[dayIndex] = rows;
    }

    final hasAnyFreeSlot = dayRows.values.any((rows) => rows.isNotEmpty);

    return Container(
      color: _pageBg,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            color: _headerBg,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  l10n.freeResourcesTabTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _headerText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    _LegendEntry(
                      color: Colors.green,
                      label: l10n.freeForAllClasses,
                    ),
                    _LegendEntry(
                      color: Colors.orange,
                      label: l10n.freeForLevelClasses,
                    ),
                    _LegendEntry(color: _blue, label: l10n.freeForSomeClasses),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 13,
                      color: _textSecondary.withAlpha(180),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.tapLevelForDetailsHint,
                      style: TextStyle(
                        fontSize: 11,
                        color: _textSecondary.withAlpha(200),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: !hasAnyFreeSlot
                ? _EmptyState(message: l10n.noFreeSlotsAvailable)
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: selectedDays.length,
                    itemBuilder: (context, dayIndex) {
                      final dayName =
                          days[int.parse(selectedDays[dayIndex]) - 1];
                      final rows = dayRows[dayIndex] ?? const <_FreeSlotRow>[];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: _headerText,
                              collapsedIconColor: _textSecondary,
                              title: Text(
                                dayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: _textPrimary,
                                ),
                              ),
                              initiallyExpanded: dayIndex == 0,
                              children: rows.isEmpty
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: Text(
                                          l10n.noFreeSlotsThisDay,
                                          style: const TextStyle(
                                            color: _textSecondary,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      for (var i = 0; i < rows.length; i++) ...[
                                        if (i > 0)
                                          const Divider(
                                            height: 1,
                                            color: _divider,
                                          ),
                                        _FreeSlotTile(
                                          row: rows[i],
                                          l10n: l10n,
                                          teachers: teachers,
                                          rooms: rooms,
                                          isTeacherFree: _isTeacherFree,
                                          isRoomFree: _isRoomFree,
                                        ),
                                      ],
                                    ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// One computed row: a timeslot with the level indicators that apply to it.
class _FreeSlotRow {
  final int dayIndex;
  final int timeIndex;
  final String timeString;
  final List<_LevelIndicator> indicators;

  _FreeSlotRow({
    required this.dayIndex,
    required this.timeIndex,
    required this.timeString,
    required this.indicators,
  });
}

class _LevelIndicator {
  final dynamic levelId;
  final Color color;
  final List<String> freeClassNames;

  _LevelIndicator({
    required this.levelId,
    required this.color,
    required this.freeClassNames,
  });
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendEntry({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    // Mirrors the _LevelChip pill styling (same alpha values) so the legend
    // visually reads as "this is what the chip looks like", not just a dot.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // ~0.1 opacity
        border: Border.all(color: color.withAlpha(153)), // ~0.6 opacity
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withAlpha(230),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: _textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeSlotTile extends StatelessWidget {
  final _FreeSlotRow row;
  final AppLocalizations l10n;
  final List<dynamic> teachers;
  final List<dynamic> rooms;
  final bool Function(int tId, int dayIndex, int timeIndex) isTeacherFree;
  final bool Function(int rId, int dayIndex, int timeIndex) isRoomFree;

  const _FreeSlotTile({
    required this.row,
    required this.l10n,
    required this.teachers,
    required this.rooms,
    required this.isTeacherFree,
    required this.isRoomFree,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              row.timeString,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: row.indicators.map((indicator) {
                return _LevelChip(
                  indicator: indicator,
                  onTap: () => _showFreeResourcesDialog(context, indicator),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFreeResourcesDialog(
    BuildContext context,
    _LevelIndicator indicator,
  ) {
    final freeTeachersList = teachers
        .where((t) {
          if (indicator.levelId != null &&
              !(t.qualifiedLevels?.contains(indicator.levelId) ?? false)) {
            return false;
          }
          return isTeacherFree(t.teacherId, row.dayIndex, row.timeIndex);
        })
        .map((t) => t.teacherName as String)
        .toList();

    final freeRoomsList = rooms
        .where((r) {
          if (indicator.levelId != null &&
              r.allowedLevels.isNotEmpty &&
              !r.allowedLevels.contains(indicator.levelId)) {
            return false;
          }
          return isRoomFree(r.roomId, row.dayIndex, row.timeIndex);
        })
        .map((r) => r.roomName as String)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          l10n.freeResourcesForLevel('${indicator.levelId}'),
          style: const TextStyle(
            color: _headerText,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogSection(
                label: l10n.freeClassesLabel,
                value: indicator.freeClassNames.join(", "),
                fallback: l10n.noneLabel,
              ),
              const Divider(height: 20, color: _divider),
              _DialogSection(
                label: l10n.freeQualifiedTeachersLabel,
                value: freeTeachersList.join(", "),
                fallback: l10n.noneLabel,
              ),
              const Divider(height: 20, color: _divider),
              _DialogSection(
                label: l10n.freeRoomsLabel,
                value: freeRoomsList.join(", "),
                fallback: l10n.noneLabel,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.ok,
              style: const TextStyle(color: _blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  final String label;
  final String value;
  final String fallback;

  const _DialogSection({
    required this.label,
    required this.value,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? fallback : value,
          style: const TextStyle(
            fontSize: 13,
            color: _textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  final _LevelIndicator indicator;
  final VoidCallback onTap;

  const _LevelChip({required this.indicator, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Tooltip surfaces the "tap for details" hint on hover (desktop/web) and
    // long-press (touch), and doubles as the chip's accessibility hint.
    return Tooltip(
      message: l10n.tapLevelForDetailsHint,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        mouseCursor: SystemMouseCursors.click,
        hoverColor: indicator.color.withAlpha(38), // ~0.15 opacity
        splashColor: indicator.color.withAlpha(51), // ~0.2 opacity
        highlightColor: indicator.color.withAlpha(31), // ~0.12 opacity
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: indicator.color.withAlpha(26), // ~0.1 opacity
            border: Border.all(
              color: indicator.color.withAlpha(153),
            ), // ~0.6 opacity
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicator.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.levelNumberFallback('${indicator.levelId}'),
                style: TextStyle(
                  color: indicator.color.withAlpha(230),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: indicator.color.withAlpha(210), // ~0.82 opacity
              ),
            ],
          ),
        ),
      ),
    );
  }
}
