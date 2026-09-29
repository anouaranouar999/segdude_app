import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/core/providers/shared_prefs_provider.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/domain/schedule_span_utils.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_result/printer_page.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

// Single source of truth for the timetable grid lines, so that the
// outer border, the inner vertical dividers and the inner horizontal
// dividers are always painted with the exact same color/width -
// avoids any risk of one of them drifting (e.g. a default Divider
// color) and looking different from the others.
const Color _kGridLineColor = Colors.black;
const double _kGridLineWidth = 1.0;

class SchedulePrintSkeleton extends ConsumerWidget {
  const SchedulePrintSkeleton({super.key, required this.schedule});
  final ScheduleDecoder schedule;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scheduleSkeleton),
      ),
      body: ScheduleResult(payLoad: schedule),
    );
  }
}

/// ----------------------------------------------------------------------------Returns and Shows schedule table
class ScheduleResult extends ConsumerStatefulWidget {
  const ScheduleResult({super.key, required this.payLoad});
  final ScheduleDecoder payLoad;
  @override
  ConsumerState<ScheduleResult> createState() => _ScheduleResultState();
}

class _ScheduleResultState extends ConsumerState<ScheduleResult> {
  ScheduleDecoder get payLoad => widget.payLoad;
  final printer = PrintDemo();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timing = ref.read(settingsProvider);
    final classID =
        (ref.watch(levelsProvider.select((s) => s.classID)) ?? 0) - 1;
    final subjects = ref.read(subjectsProvider).subjects;
    final teachers = ref.read(teachersProvider).teachers;
    final rooms = ref.read(roomsProvider).rooms;
    final selectedDays = ref.read(settingsProvider).selectedDays;
    final startTime = ref.read(settingsProvider).startTime;

    final showSubjectColors = ref.watch(
      settingsProvider.select((s) => s.showSubjectColors),
    );
    final showClassName = ref.watch(
      settingsProvider.select((s) => s.showClassName),
    );
    final showTeachersNames = ref.watch(
      settingsProvider.select((s) => s.showTeachersNames),
    );
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _HeaderImagePicker(
                      showClassName: showClassName ?? true,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
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

                        return Container(
                          // Replicates the outer edge of the previous
                          // TableBorder.all(). Uses the same shared
                          // grid-line constants as the inner dividers
                          // below so the outer edge is guaranteed to
                          // match them exactly instead of relying on
                          // Border.all()'s implicit default color/width.
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _kGridLineColor,
                              width: _kGridLineWidth,
                            ),
                          ),
                          child: Column(
                            children: List.generate(timing.daysPerWeek + 1, (
                              rowIndex,
                            ) {
                              final dayIndex = rowIndex == timing.daysPerWeek
                                  ? timing.daysPerWeek - 1
                                  : rowIndex - 1;

                              // rowIndex == 0 is the header row and has no
                              // corresponding day (dayIndex would be -1),
                              // so only look up slots for real day rows.
                              final slots = rowIndex == 0
                                  ? null
                                  : payLoad
                                        .classes[classID]
                                        .days[dayIndex]
                                        .slots;
                              final isLocked =
                                  slots != null && slots[0].slotId == 'lock';

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
                                        color: const Color(0xFFEFF6FF),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(''),
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
                                      Container(
                                        //-----------------------------------------------Slots Container
                                        alignment: Alignment.center,
                                        // The vertical column boundary is
                                        // painted as this cell's own left
                                        // border (inside its flex-allotted
                                        // width) rather than as a separate
                                        // fixed-width sibling widget, so
                                        // every row divides the exact same
                                        // total width by the exact same
                                        // flex ratios - see the comment
                                        // above `rowCells` for why a
                                        // sibling divider caused drift.
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEFF6FF),
                                          border: Border(
                                            left: BorderSide(
                                              color: _kGridLineColor,
                                              width: _kGridLineWidth,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(1),
                                        child: Text(
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          '${(startTime + timeIndex).toString().padLeft(2, '0')}:00'
                                          '–'
                                          '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:00',
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
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F5F9),
                                          border: Border(
                                            top: BorderSide(
                                              color: _kGridLineColor,
                                              width: _kGridLineWidth,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(1),
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          _localizedDayName(
                                            l10n,
                                            selectedDays[dayIndex],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  colIndex += 1;
                                  continue;
                                }

                                // By this point rowIndex != 0 (handled by
                                // the branches above), so slots is
                                // guaranteed non-null.
                                final daySlots = slots!;

                                // Determine how many consecutive timeslots
                                // (starting at timeIndex) share the same
                                // subjectId, teacherId and roomId, so they
                                // can be rendered as a single merged cell.
                                var span = 1;
                                if (!isLocked &&
                                    daySlots[timeIndex].lesson?.subjectId !=
                                        null) {
                                  final lesson = daySlots[timeIndex].lesson!;
                                  span = mergedLessonSpan(
                                    index: timeIndex,
                                    length: timing.timeslotsPerDay,
                                    matchesAnchor: (i) {
                                      final candidate = daySlots[i].lesson;
                                      return candidate != null &&
                                          candidate.subjectId ==
                                              lesson.subjectId &&
                                          candidate.teacherId ==
                                              lesson.teacherId &&
                                          candidate.roomId == lesson.roomId;
                                    },
                                  );
                                }

                                Color cellColor = dayIndex.isEven
                                    ? const Color(0xFFFAFAFA)
                                    : Colors.white;

                                if ((showSubjectColors ?? true) &&
                                    !isLocked &&
                                    daySlots[timeIndex].lesson?.subjectId !=
                                        null) {
                                  final sId =
                                      daySlots[timeIndex].lesson!.subjectId;
                                  if (sId > 0 && sId <= subjects.length) {
                                    final subject = subjects[sId - 1];
                                    if (subject.color != null) {
                                      cellColor = Color(
                                        subject.color!,
                                      ).withValues(alpha: 0.35);
                                    }
                                  }
                                }

                                rowCells.add(
                                  flexCell(
                                    10 * span,
                                    Container(
                                      height: 65,
                                      alignment: Alignment.center,
                                      // padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: cellColor,
                                        border: const Border(
                                          left: BorderSide(
                                            color: _kGridLineColor,
                                            width: _kGridLineWidth,
                                          ),
                                          top: BorderSide(
                                            color: _kGridLineColor,
                                            width: _kGridLineWidth,
                                          ),
                                        ),
                                      ),
                                      child: isLocked
                                          ? Tooltip(
                                              message: l10n.pdfLockedSlot,
                                              child: const Icon(
                                                Icons.lock,
                                                color: Colors.red,
                                              ),
                                            )
                                          : daySlots[timeIndex]
                                                    .lesson
                                                    ?.subjectId !=
                                                null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  '${subjects[daySlots[timeIndex].lesson!.subjectId - 1].subjectName}',
                                                ),
                                                const SizedBox(height: 2),
                                                // if roomId is -1 it means that subject doesn't need a room
                                                if (daySlots[timeIndex]
                                                        .lesson!
                                                        .roomId !=
                                                    -1)
                                                  Text(
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    rooms[daySlots[timeIndex]
                                                                .lesson!
                                                                .roomId -
                                                            1]
                                                        .roomName,
                                                  ),
                                                if (daySlots[timeIndex]
                                                            .lesson!
                                                            .teacherId >
                                                        0 &&
                                                    daySlots[timeIndex]
                                                            .lesson!
                                                            .teacherId <=
                                                        teachers.length)
                                                  if (showTeachersNames ??
                                                      false) ...[
                                                    Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                      '${teachers[daySlots[timeIndex].lesson!.teacherId - 1].teacherName}',
                                                    ),
                                                  ],
                                              ],
                                            )
                                          : Text(
                                              '—',
                                              style: TextStyle(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                                colIndex += span;
                              }

                              // The vertical (column) and horizontal
                              // (row) grid lines are now painted as
                              // each cell's own left/top border (see
                              // the cell-building branches above)
                              // instead of interleaved
                              // VerticalDivider/Divider sibling
                              // widgets. Those siblings had their own
                              // fixed width/height that came out of
                              // the Row's available space *before*
                              // the flex (Expanded) distribution ran,
                              // and the number of siblings changes
                              // from row to row (a merged lesson has
                              // fewer, wider cells and so fewer
                              // dividers) - so two rows with the
                              // exact same total flex could still end
                              // up with a very slightly different
                              // flexible width budget, and therefore
                              // sub-pixel-different column boundary
                              // positions. Painting the boundary
                              // inside each cell's own already-sized
                              // box removes that variable entirely:
                              // every row is now a plain Row of only
                              // Expanded children, so the same flex
                              // ratios always divide the exact same
                              // total width, and corresponding column
                              // boundaries land on identical
                              // coordinates in every row.
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: rowCells,
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        //----------------------------------------------------------------Left Container For settings
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          alignment: .center,
          padding: const EdgeInsets.all(12.0),
          width: 200,
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
          child: Column(
            mainAxisAlignment: .spaceBetween,
            children: [
              Column(
                crossAxisAlignment: .center,
                children: [
                  Text(
                    l10n.settings,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: .bold,

                      color: Color(0xFF1A2E4A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'A5',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                      Semantics(
                        label: 'A5',
                        child: Checkbox(value: false, onChanged: (val) {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                      Semantics(
                        label: l10n.name,
                        child: Checkbox(
                          value: showClassName ?? true,
                          onChanged: (val) async {
                            if (val != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setShowClassName(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getColorsLabel(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                      Semantics(
                        label: _getColorsLabel(context),
                        child: Checkbox(
                          value: showSubjectColors ?? true,
                          onChanged: (val) async {
                            if (val != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setShowSubjectColors(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Teachers names',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                      Semantics(
                        label: 'Teachers names',
                        child: Checkbox(
                          value: showTeachersNames ?? false,
                          onChanged: (val) async {
                            if (val != null) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setShowTeachersNames(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 45,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                  //----------------------------------------- Save and Exit button
                  child: Text(
                    l10n.saveExit,
                    style: TextStyle(
                      color: Color(0xFF1A2E4A),
                      fontSize: 14,
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Resolves a raw weekday number (as stored in settingsProvider's
  // selectedDays, e.g. "1".."7" for Monday..Sunday - see
  // DaysPortalOverlay's `selectedDays.contains('${dayId + 1}')` and
  // `DayOverrideEncoder(dayId + 1, ...)` for the same 1-based
  // convention) to the localized day name, using the existing
  // dayMonday..daySunday ARB keys already generated by
  // AppLocalizations. Falls back to the raw value if it's ever
  // something unexpected, instead of throwing.
  String _localizedDayName(AppLocalizations l10n, String dayNumber) {
    switch (dayNumber) {
      case '1':
        return l10n.dayMonday;
      case '2':
        return l10n.dayTuesday;
      case '3':
        return l10n.dayWednesday;
      case '4':
        return l10n.dayThursday;
      case '5':
        return l10n.dayFriday;
      case '6':
        return l10n.daySaturday;
      case '7':
        return l10n.daySunday;
      default:
        return dayNumber;
    }
  }

  String _getColorsLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fr') {
      return 'Couleurs';
    } else if (locale == 'ar') {
      return 'الألوان';
    }
    return 'Colors';
  }
}

class _HeaderImagePicker extends ConsumerStatefulWidget {
  const _HeaderImagePicker({required this.showClassName});
  final bool showClassName;

  @override
  ConsumerState<_HeaderImagePicker> createState() => _HeaderImagePickerState();
}

class _HeaderImagePickerState extends ConsumerState<_HeaderImagePicker> {
  Uint8List? _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // Load image bytes from SharedPreferences on startup
  Future<void> _loadImage() async {
    try {
      final prefs = ref.read(sharedPrefsProvider);
      final bytesStr = await prefs.getString('header_image_bytes');
      if (bytesStr != null) {
        setState(() {
          _imageBytes = base64Decode(bytesStr);
        });
      }
    } catch (e) {
      debugPrint('Error loading header image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      setState(() {
        _imageBytes = bytes;
      });

      try {
        final prefs = ref.read(sharedPrefsProvider);

        // Save the image path to SharedPreferences as requested
        if (result.files.single.path != null) {
          await prefs.saveString(
            'header_image_path',
            result.files.single.path!,
          );
        }

        // Save base64 encoded bytes to SharedPreferences for cross-platform/web persistent loading
        await prefs.saveString('header_image_bytes', base64Encode(bytes));
      } catch (e) {
        debugPrint('Error saving header image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.clickToAddHeaderImage,
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
          child: Stack(
            children: [
              if (widget.showClassName)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      // class name
                      ref.watch(levelsProvider).selectedLevel,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isLoading
                    ? const Center(
                        key: ValueKey('loading'),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : _imageBytes != null
                    ? ClipRRect(
                        key: const ValueKey('image'),
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        ),
                      )
                    : FittedBox(
                        key: const ValueKey('placeholder'),
                        fit: BoxFit.scaleDown,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.clickToAddHeaderImage,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
