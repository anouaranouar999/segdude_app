import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/core/providers/locale_provider.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';

Future<void> loadSavedScheduleAndNavigate(
  BuildContext context,
  SharedPreferencesService prefsService,
) async {
  final container = ProviderContainer();

  // ---------------------------------------------------------------------- Load Locale Settings
  final selectedLocale = await prefsService.getString('locale');
  if (selectedLocale != null) {
    container.read(localeProvider.notifier).setLocale(Locale(selectedLocale));
  }
  // ---------------------------------------------------------------------- Load Settings
  final selectedDaysJson = await prefsService.getString('selected_days');
  if (selectedDaysJson != null) {
    final List decodedDays = jsonDecode(selectedDaysJson);
    final selectedDays = decodedDays.map((e) => e.toString()).toList();
    final daysPerWeek = await prefsService.getInt('days_per_week') ?? 0;
    final timeslotsPerDay = await prefsService.getInt('timeslots_per_day') ?? 0;
    final maxHoursPerDay = await prefsService.getInt('max_hours_per_day') ?? 0;
    final startTime = await prefsService.getInt('start_time') ?? 0;
    final selectedDayId = await prefsService.getInt('selected_day_id');

    final breakHoursJson = await prefsService.getString('break_hours_per_day');
    List<int> breakHoursPerDay = [];
    if (breakHoursJson != null) {
      final List decodedBreaks = jsonDecode(breakHoursJson);
      breakHoursPerDay = decodedBreaks.map((e) => e as int).toList();
    }

    final dayOverridesJson = await prefsService.getString('day_overrides');
    List<DayOverrideEncoder> dayOverrides = [];
    if (dayOverridesJson != null) {
      final List decodedOverrides = jsonDecode(dayOverridesJson);
      dayOverrides = decodedOverrides
          .map((e) => DayOverrideEncoder.fromJson(e))
          .toList();
    }

    final minutesListJson = await prefsService.getString('minutes_list');
    List<int> minutesList = [];
    if (minutesListJson != null) {
      final List decodedMinutes = jsonDecode(minutesListJson);
      minutesList = decodedMinutes.map((e) => e as int).toList();
    }

    container
        .read(settingsProvider.notifier)
        .loadState(
          selectedDays: selectedDays,
          daysPerWeek: daysPerWeek,
          timeslotsPerDay: timeslotsPerDay,
          maxHoursPerDay: maxHoursPerDay,
          breakHoursPerDay: breakHoursPerDay,
          startTime: startTime,
          selectedDayId: selectedDayId,
          dayOverrides: dayOverrides,
          minutesList: minutesList,
        );
  }
  // ---------------------------------------------------------------------- Load Teachers
  final teachersJson = await prefsService.getString('teachers_data');
  if (teachersJson != null) {
    final List decoded = jsonDecode(teachersJson);
    final teachers = decoded.map((e) => TeacherEncoder.fromJson(e)).toList();
    container.read(teachersProvider.notifier).loadState(teachers);
  }

  // ---------------------------------------------------------------------- Load Rooms
  final roomsJson = await prefsService.getString('rooms_data');
  final nextRoomID = await prefsService.getInt('next_room_id_data') ?? 1;
  if (roomsJson != null) {
    final List decoded = jsonDecode(roomsJson);
    final rooms = decoded.map((e) => RoomEncoder.fromJson(e)).toList();
    container.read(roomsProvider.notifier).loadState(rooms, nextRoomID);
  }

  // ---------------------------------------------------------------------- Load Subjects and Consecutive Hours
  final subjectsJson = await prefsService.getString('subjects_data');
  final consecutiveHoursJson = await prefsService.getString(
    'consecutive_hours_data',
  );

  List<SubjectEncoder> subjects = [];
  List<ConsecutiveHoursEncoder> consecutiveHours = [];

  if (subjectsJson != null) {
    final List decoded = jsonDecode(subjectsJson);
    subjects = decoded.map((e) => SubjectEncoder.fromJson(e)).toList();
  }

  if (consecutiveHoursJson != null) {
    final List decoded = jsonDecode(consecutiveHoursJson);
    consecutiveHours = decoded
        .map((e) => ConsecutiveHoursEncoder.fromJson(e))
        .toList();
  }

  if (subjects.isNotEmpty || consecutiveHours.isNotEmpty) {
    container
        .read(subjectsProvider.notifier)
        .loadState(subjects, consecutiveHours);
  }

  // Load Levels
  final levelsJson = await prefsService.getString('levels_data');
  final levelIdsJson = await prefsService.getString('level_ids_data');
  final realIDJson = await prefsService.getString('real_id_data');
  final classesJson = await prefsService.getString('classes_data');
  final nextLevelId = await prefsService.getInt('next_level_id_data') ?? 1;

  if (levelsJson != null &&
      levelIdsJson != null &&
      realIDJson != null &&
      classesJson != null) {
    final Map<String, dynamic> levelsDecoded = jsonDecode(levelsJson);
    final Map<String, int> levels = levelsDecoded.map(
      (k, v) => MapEntry(k, v as int),
    );

    final Map<String, dynamic> levelIdsDecoded = jsonDecode(levelIdsJson);
    final Map<String, int> levelIds = levelIdsDecoded.map(
      (k, v) => MapEntry(k, v as int),
    );

    final Map<String, dynamic> realIDDecoded = jsonDecode(realIDJson);
    final Map<int, String> realID = realIDDecoded.map(
      (k, v) => MapEntry(int.parse(k), v as String),
    );

    final List classesDecoded = jsonDecode(classesJson);
    final classes = classesDecoded
        .map((e) => ClassLevelEncoder.fromJson(e))
        .toList();

    container
        .read(levelsProvider.notifier)
        .loadState(levels, levelIds, realID, nextLevelId, classes);
  }
  // ------------------------------- Get last generated schedule from shared preferences
  final lastGeneratedScheduleJson = await prefsService.getString(
    'last_generated_schedule',
  );
  final encodedSchedule = lastGeneratedScheduleJson != null
      ? ScheduleDecoder.fromJson(jsonDecode(lastGeneratedScheduleJson))
      : ScheduleDecoder.fromJson({'error': 'No saved schedule'});

  if (context.mounted) {
    context.go('/create/schedule_second_page/result', extra: encodedSchedule);
  }
}
