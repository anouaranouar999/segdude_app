import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/domain/schedule_span_utils.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Bundles the header image + display-preference + font assets shared by
// every print flow (currently Student and Teacher), so each print method
// loads them the exact same way instead of duplicating the
// SharedPreferences/font-loading boilerplate.
class _PrintAssets {
  final Uint8List? imageBytes;
  final bool showSubjectColors;
  final bool showClassName;
  final pw.Font arabicFont;
  final pw.Font arabicFontBold;

  const _PrintAssets({
    required this.imageBytes,
    required this.showSubjectColors,
    required this.showClassName,
    required this.arabicFont,
    required this.arabicFontBold,
  });
}

class PrintDemo {
  Future<_PrintAssets> _loadPrintAssets() async {
    // Load the saved header image bytes and settings
    Uint8List? imageBytes;
    bool showSubjectColors = true;
    bool showClassName = true;
    try {
      final prefs = SharedPreferencesAsync();
      final bytesStr = await prefs.getString('header_image_bytes');
      if (bytesStr != null) {
        imageBytes = base64Decode(bytesStr);
      }
      final savedColors = await prefs.getBool('show_subject_colors');
      if (savedColors != null) {
        showSubjectColors = savedColors;
      }
      final savedName = await prefs.getBool('show_class_name');
      if (savedName != null) {
        showClassName = savedName;
      }
    } catch (e) {
      debugPrint('Error loading header image/settings: $e');
    }

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    return _PrintAssets(
      imageBytes: imageBytes,
      showSubjectColors: showSubjectColors,
      showClassName: showClassName,
      arabicFont: arabicFont,
      arabicFontBold: arabicFontBold,
    );
  }

  // This function builds the PDF and triggers the print dialog
  Future<void> printDocument(
    ScheduleDecoder payLoad,
    int classId,
    SettingsState timing,
    List<SubjectEncoder> subjects,
    List<TeacherEncoder> teachers,
    List<RoomEncoder> rooms,
    List<String> selectedDays,
    int startTime,
    List<int> minutes,
    String className,
    AppLocalizations l10n,
    Map<String, String> daysMap,
    bool showTeachersNames,
  ) async {
    final pdf = pw.Document();

    final assets = await _loadPrintAssets();
    final imageBytes = assets.imageBytes;
    final showSubjectColors = assets.showSubjectColors;
    final showClassName = assets.showClassName;
    final arabicFont = assets.arabicFont;
    final arabicFontBold = assets.arabicFontBold;

    // Build the PDF page
    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        margin: pw.EdgeInsets.only(left: 5, right: 55, top: 0, bottom: 10),
        orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: l10n.localeName == 'ar'
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            child: pw.Column(
              //-----------------------------------------------------Show header image if exists
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                if (imageBytes != null) ...[
                  pw.Expanded(
                    child: pw.Stack(
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Image(
                              pw.MemoryImage(imageBytes),
                              fit: pw.BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        if (showClassName)
                          pw.Text(
                            className,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                // -----------------------------------------
                pw.Expanded(
                  flex: timing.daysPerWeek,
                  //----------------------------------------- Container surounding the table
                  child: pw.Container(
                    // Replicates the outer edge of the previous
                    // pw.TableBorder.all().
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: pw.Column(
                      children: List.generate(timing.daysPerWeek + 1, (
                        rowIndex,
                      ) {
                        final dayIndex = rowIndex == timing.daysPerWeek
                            ? timing.daysPerWeek - 1
                            : rowIndex - 1;

                        // rowIndex == 0 is the header row and has no
                        // corresponding day (dayIndex would be -1), so
                        // only look up slots for real day rows.
                        final slots = rowIndex == 0
                            ? null
                            : payLoad.classes[classId].days[dayIndex].slots;
                        final isLocked =
                            slots != null && slots[0].slotId == 'lock';

                        final rowCells = <pw.Widget>[];
                        var colIndex = 0;
                        while (colIndex <= timing.timeslotsPerDay) {
                          final timeIndex = colIndex == timing.timeslotsPerDay
                              ? timing.timeslotsPerDay - 1
                              : colIndex - 1;

                          if (colIndex == 0 && rowIndex == 0) {
                            rowCells.add(
                              pw.Expanded(
                                flex: 12,
                                child: pw.Container(
                                  margin: const pw.EdgeInsets.all(1.5),
                                  alignment: pw.Alignment.center,
                                  color: PdfColors.grey200,
                                  child: pw.Text(''),
                                ),
                              ),
                            );
                            colIndex += 1;
                            continue;
                          }
                          if (rowIndex == 0) {
                            rowCells.add(
                              pw.Expanded(
                                flex: 10,
                                //-----------------------------------------------Timing Slots Container
                                child: pw.Container(
                                  margin: const pw.EdgeInsets.all(1.5),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                  ),
                                  alignment: pw.Alignment.center,
                                  // color: PdfColors.grey200,
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: pw.FittedBox(
                                    fit: pw.BoxFit.fitHeight,
                                    child: pw.Text(
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                      l10n.localeName == 'ar'
                                          ? '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:${timing.endMinutesList[timeIndex].toString().padLeft(2, '0')}'
                                                '-'
                                                '${(startTime + timeIndex).toString().padLeft(2, '0')}:${minutes[timeIndex].toString().padLeft(2, '0')}'
                                          : '${(startTime + timeIndex).toString().padLeft(2, '0')}:${minutes[timeIndex].toString().padLeft(2, '0')}'
                                                '-'
                                                '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:${timing.endMinutesList[timeIndex].toString().padLeft(2, '0')}',
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
                              pw.Expanded(
                                flex: 12,
                                child: pw.Container(
                                  height: 65,
                                  alignment: pw.Alignment.center,
                                  margin: const pw.EdgeInsets.all(2),
                                  color: PdfColors.grey100,
                                  padding: const pw.EdgeInsets.all(2),
                                  child: pw.Text(
                                    textAlign: pw.TextAlign.center,
                                    maxLines: 1,
                                    overflow: pw.TextOverflow.visible,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    // ------------------------------------Days Name
                                    daysMap.entries
                                        .elementAt(
                                          int.parse(selectedDays[dayIndex]) - 1,
                                        )
                                        .key,
                                  ),
                                ),
                              ),
                            );
                            colIndex += 1;
                            continue;
                          }

                          // By this point rowIndex != 0 (handled by the
                          // branches above), so slots is guaranteed
                          // non-null.
                          final daySlots = slots!;

                          // Determine how many consecutive timeslots
                          // (starting at timeIndex) share the same
                          // subjectId, teacherId and roomId, so they can
                          // be rendered as a single merged cell.
                          var span = 1;
                          if (!isLocked &&
                              daySlots[timeIndex].lesson?.subjectId != null) {
                            final lesson = daySlots[timeIndex].lesson!;
                            span = mergedLessonSpan(
                              index: timeIndex,
                              length: timing.timeslotsPerDay,
                              matchesAnchor: (i) {
                                final candidate = daySlots[i].lesson;
                                return candidate != null &&
                                    candidate.subjectId == lesson.subjectId &&
                                    candidate.teacherId == lesson.teacherId &&
                                    candidate.roomId == lesson.roomId;
                              },
                            );
                          }

                          PdfColor? cellColor;
                          if (showSubjectColors &&
                              !isLocked &&
                              daySlots[timeIndex].lesson?.subjectId != null) {
                            final sId = daySlots[timeIndex].lesson!.subjectId;
                            if (sId > 0 && sId <= subjects.length) {
                              final subject = subjects[sId - 1];
                              if (subject.color != null) {
                                final c = PdfColor.fromInt(subject.color!);
                                cellColor = PdfColor(
                                  c.red,
                                  c.green,
                                  c.blue,
                                  0.35,
                                );
                              }
                            }
                          }

                          rowCells.add(
                            pw.Expanded(
                              flex: 10 * span,
                              child: pw.Container(
                                margin: const pw.EdgeInsets.all(3),
                                color: cellColor,
                                alignment: pw.Alignment.center,
                                padding: const pw.EdgeInsets.all(1),
                                child: isLocked
                                    // ------------------------------------Locked Slot Container
                                    ? pw.Container(
                                        height: 70,
                                        alignment: pw.Alignment.center,
                                        child: pw.Text(
                                          ' ${l10n.pdfLockedSlot}',
                                        ),
                                      )
                                    : daySlots[timeIndex].lesson?.subjectId !=
                                          null
                                    ? pw.Expanded(
                                        child: pw.Stack(
                                          children: [
                                            pw.Positioned.fill(
                                              child: pw.Column(
                                                mainAxisAlignment:
                                                    pw.MainAxisAlignment.center,
                                                children: [
                                                  pw.Text(
                                                    textAlign:
                                                        pw.TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        pw.TextOverflow.visible,
                                                    style: pw.TextStyle(
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    '${subjects[daySlots[timeIndex].lesson!.subjectId - 1].subjectName}',
                                                  ),
                                                  // if roomId is -1 it means that subject doesn't need a room
                                                  if (daySlots[timeIndex]
                                                          .lesson!
                                                          .roomId !=
                                                      -1)
                                                    pw.Text(
                                                      textAlign:
                                                          pw.TextAlign.center,
                                                      maxLines: 1,
                                                      overflow: pw
                                                          .TextOverflow
                                                          .visible,
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
                                                          teachers.length) ...[
                                                    // only show teacher name if showTeachersNames is true
                                                    if (showTeachersNames)
                                                      pw.Text(
                                                        textAlign:
                                                            pw.TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: pw
                                                            .TextOverflow
                                                            .visible,
                                                        style: pw.TextStyle(
                                                          fontSize: 11,
                                                        ),

                                                        '${teachers[daySlots[timeIndex].lesson!.teacherId - 1].teacherName}',
                                                      ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            //---------------------- Show Group number in circle if exists
                                            if (daySlots[timeIndex]
                                                    .lesson!
                                                    .group !=
                                                null)
                                              pw.Positioned(
                                                top: 0,
                                                right: 0,
                                                child: pw.Container(
                                                  margin: pw.EdgeInsets.only(
                                                    top: 1,
                                                    right: 1,
                                                  ),
                                                  height: 20,
                                                  width: 20,
                                                  alignment:
                                                      pw.Alignment.center,
                                                  decoration: pw.BoxDecoration(
                                                    shape: pw.BoxShape.circle,
                                                    color: PdfColors.black,
                                                  ),
                                                  child: pw.Text(
                                                    style: pw.TextStyle(
                                                      color: PdfColors.white,
                                                      fontWeight:
                                                          pw.FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                    "${daySlots[timeIndex].lesson!.group}",
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    : pw.Text(''),
                              ),
                            ),
                          );
                          colIndex += span;
                        }

                        // Insert thin dividers between cells to replicate
                        // the previous pw.TableBorder.all() inside
                        // -------------------------------------------------- vertical borders.
                        final spacedRowCells = <pw.Widget>[];
                        for (var i = 0; i < rowCells.length; i++) {
                          if (i > 0) {
                            spacedRowCells.add(
                              pw.Container(width: 0, color: PdfColors.black),
                            );
                          }
                          spacedRowCells.add(rowCells[i]);
                        }

                        final rowHeight = rowIndex == 0
                            ? 25.0
                            : (isLocked ? 70.0 : 65.0);

                        return pw.Column(
                          children: [
                            // Replicates the previous
                            // pw.TableBorder.all() inside horizontal
                            // borders (skipped above the first row).
                            // if (rowIndex > 0)
                            pw.Container(height: 0.1, color: PdfColors.black),
                            pw.Container(
                              height: rowHeight,
                              child: pw.Row(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: spacedRowCells,
                              ),
                            ),
                            pw.Container(height: 0.1, color: PdfColors.black),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Trigger the browser's print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          l10n.pdfDocumentName, // The name of the file if the user saves as PDF
    );
  }

  // Builds and triggers printing for a single Teacher's timetable.
  //
  // Mirrors [printDocument]'s visual/technical conventions (fonts, header
  // image, orientation, page size, RTL/LTR handling, and the
  // [Printing.layoutPdf] trigger) but is driven by a [TeacherScheduleEntry]
  // instead of a class-indexed [ScheduleDecoder], and — matching the
  // on-screen Teacher timetable's sparse semantics — skips break-hour
  // columns entirely and merges consecutive slots that share the same
  // subject/class/room into a single cell via [mergedLessonSpan], the same
  // utility already used above for the Student grid.
  Future<void> printTeacherDocument(
    TeacherScheduleEntry teacher,
    String teacherName,
    SettingsState timing,
    // Left as `List` (dynamic), not `List<SubjectEncoder>` — matching how
    // schedule_result_tab3.dart already treats subjects/rooms/classes
    // throughout (see `_TeacherTable`, `_lessonCell`): the Teacher tab's
    // `subjectsProvider` exposes this as `List<dynamic>`, unlike the
    // Student print path's source, so a typed param here would reject the
    // exact same list the on-screen table already renders from.
    List subjects,
    List rooms,
    List classes,
    AppLocalizations l10n,
    List<String> dayNames,
  ) async {
    final pdf = pw.Document();

    final assets = await _loadPrintAssets();
    final imageBytes = assets.imageBytes;
    final showClassName = assets.showClassName;
    final showSubjectColors = assets.showSubjectColors;
    final arabicFont = assets.arabicFont;
    final arabicFontBold = assets.arabicFontBold;

    final startTime = timing.startTime;
    final minutes = timing.minutesList;
    final endMinutes = timing.endMinutesList;
    final timeslotsPerDay = timing.timeslotsPerDay;
    final daysPerWeek = timing.daysPerWeek;
    final breakHours = timing.breakHoursPerDay;
    final visibleSlots = [
      for (var index = 0; index < timeslotsPerDay; index++)
        if (!breakHours.contains(startTime + index)) index,
    ];

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        margin: pw.EdgeInsets.only(left: 5, right: 55, top: 0, bottom: 10),
        orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: l10n.localeName == 'ar'
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                if (imageBytes != null) ...[
                  pw.Expanded(
                    child: pw.Stack(
                      children: [
                        pw.Expanded(
                          child: pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Image(
                              pw.MemoryImage(imageBytes),
                              fit: pw.BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        if (showClassName)
                          pw.Text(
                            teacherName,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                pw.Expanded(
                  flex: daysPerWeek,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: pw.Column(
                      children: List.generate(daysPerWeek + 1, (rowIndex) {
                        final isHeaderRow = rowIndex == 0;
                        final dayIndex = isHeaderRow ? -1 : rowIndex - 1;
                        final daySlots = isHeaderRow
                            ? null
                            : {
                                for (final slot
                                    in teacher.days
                                            .where(
                                              (d) =>
                                                  d.dayId == '${dayIndex + 1}',
                                            )
                                            .firstOrNull
                                            ?.slots ??
                                        const <TeacherLessonSlot>[])
                                  slot.slotId: slot,
                              };

                        final rowCells = <pw.Widget>[
                          pw.Expanded(
                            flex: 12,
                            child: pw.Container(
                              margin: const pw.EdgeInsets.all(1.5),
                              alignment: pw.Alignment.center,
                              color: isHeaderRow
                                  ? PdfColors.grey200
                                  : PdfColors.grey100,
                              padding: isHeaderRow
                                  ? pw.EdgeInsets.zero
                                  : const pw.EdgeInsets.all(2),
                              child: pw.Text(
                                isHeaderRow
                                    ? ''
                                    : (dayIndex < dayNames.length
                                          ? dayNames[dayIndex]
                                          : '${dayIndex + 1}'),
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                overflow: pw.TextOverflow.visible,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: isHeaderRow ? 12 : 16,
                                ),
                              ),
                            ),
                          ),
                        ];

                        var visibleIndex = 0;
                        while (visibleIndex < visibleSlots.length) {
                          final timeIndex = visibleSlots[visibleIndex];

                          if (isHeaderRow) {
                            rowCells.add(
                              pw.Expanded(
                                flex: 10,
                                child: pw.Container(
                                  margin: const pw.EdgeInsets.all(1.5),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey200,
                                  ),
                                  alignment: pw.Alignment.center,
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: pw.FittedBox(
                                    fit: pw.BoxFit.fitHeight,
                                    child: pw.Text(
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                      l10n.localeName == 'ar'
                                          ? '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:${endMinutes[timeIndex].toString().padLeft(2, '0')}'
                                                '-'
                                                '${(startTime + timeIndex).toString().padLeft(2, '0')}:${minutes[timeIndex].toString().padLeft(2, '0')}'
                                          : '${(startTime + timeIndex).toString().padLeft(2, '0')}:${minutes[timeIndex].toString().padLeft(2, '0')}'
                                                '-'
                                                '${(startTime + timeIndex + 1).toString().padLeft(2, '0')}:${endMinutes[timeIndex].toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                ),
                              ),
                            );
                            visibleIndex += 1;
                            continue;
                          }

                          final slot = daySlots!['${timeIndex + 1}'];

                          // Merge consecutive visible slots that share the
                          // same subject/class/room into one wider cell —
                          // same semantics as the on-screen Teacher table's
                          // _sameLesson check, expressed via the same
                          // mergedLessonSpan utility the Student print
                          // already relies on.
                          var span = 1;
                          if (slot != null) {
                            span = mergedLessonSpan(
                              index: visibleIndex,
                              length: visibleSlots.length,
                              matchesAnchor: (i) {
                                final candidateIndex = visibleSlots[i];
                                final candidate =
                                    daySlots['${candidateIndex + 1}'];
                                return candidate != null &&
                                    candidate.subjectId == slot.subjectId &&
                                    candidate.classId == slot.classId &&
                                    candidate.roomId == slot.roomId;
                              },
                            );
                          }

                          PdfColor? cellColor;
                          if (showSubjectColors && slot != null) {
                            final sId = slot.subjectId;
                            if (sId > 0 && sId <= subjects.length) {
                              final subject = subjects[sId - 1];
                              if (subject.color != null) {
                                final c = PdfColor.fromInt(subject.color!);
                                cellColor = PdfColor(
                                  c.red,
                                  c.green,
                                  c.blue,
                                  0.35,
                                );
                              }
                            }
                          }

                          final subject = slot == null
                              ? null
                              : subjects
                                    .where((s) => s.subjectId == slot.subjectId)
                                    .firstOrNull;
                          final room = slot == null
                              ? null
                              : rooms
                                    .where((r) => r.roomId == slot.roomId)
                                    .firstOrNull;
                          final classItem = slot == null
                              ? null
                              : classes
                                    .where((c) => c.classId == slot.classId)
                                    .firstOrNull;

                          rowCells.add(
                            pw.Expanded(
                              flex: 10 * span,
                              child: pw.Container(
                                margin: const pw.EdgeInsets.all(3),
                                color: cellColor,
                                alignment: pw.Alignment.center,
                                padding: const pw.EdgeInsets.all(1),
                                child: slot == null
                                    ? pw.Text('')
                                    : pw.Column(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        children: [
                                          pw.Text(
                                            textAlign: pw.TextAlign.center,
                                            maxLines: 1,
                                            overflow: pw.TextOverflow.visible,
                                            style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            subject?.subjectName ?? '',
                                          ),
                                          if (classItem != null)
                                            pw.Text(
                                              textAlign: pw.TextAlign.center,
                                              maxLines: 1,
                                              overflow: pw.TextOverflow.visible,
                                              style: const pw.TextStyle(
                                                fontSize: 11,
                                              ),
                                              classItem.className ?? '',
                                            ),
                                          // roomId == -1 means the subject
                                          // doesn't need a room, matching
                                          // the Student print's convention.
                                          if (slot.roomId != -1 && room != null)
                                            pw.Text(
                                              textAlign: pw.TextAlign.center,
                                              maxLines: 1,
                                              overflow: pw.TextOverflow.visible,
                                              room.roomName,
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                          visibleIndex += span;
                        }

                        // Thin vertical dividers between cells, replicating
                        // the Student print's pw.TableBorder.all() effect.
                        final spacedRowCells = <pw.Widget>[];
                        for (var i = 0; i < rowCells.length; i++) {
                          if (i > 0) {
                            spacedRowCells.add(
                              pw.Container(width: 0, color: PdfColors.black),
                            );
                          }
                          spacedRowCells.add(rowCells[i]);
                        }

                        final rowHeight = isHeaderRow ? 25.0 : 65.0;

                        return pw.Column(
                          children: [
                            pw.Container(height: 0.1, color: PdfColors.black),
                            pw.Container(
                              height: rowHeight,
                              child: pw.Row(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: spacedRowCells,
                              ),
                            ),
                            pw.Container(height: 0.1, color: PdfColors.black),
                          ],
                        );
                      }),
                    ),
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
      name: l10n.pdfDocumentName,
    );
  }
}
