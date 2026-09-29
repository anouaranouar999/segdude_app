import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/manual_overrides_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_result_provider.dart';
import 'package:go_router/go_router.dart';

class ScheduleSerialization {
  static Future<void> exportSchedule(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final levelsState = ref.read(levelsProvider);
    final teachersState = ref.read(teachersProvider);
    final roomsState = ref.read(roomsProvider);
    final subjectsState = ref.read(subjectsProvider);
    final settingsState = ref.read(settingsProvider);
    final overridesState = ref.read(manualOverridesProvider);
    final groupsState = ref.read(groupsProvider);
    final currentResult = ref.read(currentScheduleProvider);

    final data = {
      'version': 1,
      'levels_data': levelsState.levels,
      'level_ids_data': levelsState.levelIds,
      'real_id_data': levelsState.realID.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'next_level_id_data': levelsState.nextLevelId,
      'classes_data': levelsState.classes.map((c) => c.toJson()).toList(),

      'teachers_data': teachersState.teachers.map((t) => t.toJson()).toList(),

      'rooms_data': roomsState.rooms.map((r) => r.toJson()).toList(),
      'next_room_id_data': roomsState.nextRoomID,

      'subjects_data': subjectsState.subjects.map((s) => s.toJson()).toList(),
      'consecutive_hours_data': subjectsState.consecutiveHours
          .map((c) => c.toJson())
          .toList(),

      'groups_data': groupsState.groups.map((g) => g.toJson()).toList(),
      'merges_data': groupsState.merges.map((m) => m.toJson()).toList(),

      'manual_overrides_data': overridesState.overrides
          .map((o) => o.toJson())
          .toList(),

      'selected_days': settingsState.selectedDays,
      'days_per_week': settingsState.daysPerWeek,
      'timeslots_per_day': settingsState.timeslotsPerDay,
      'max_hours_per_day': settingsState.maxHoursPerDay,
      'break_hours_per_day': settingsState.breakHoursPerDay,
      'start_time': settingsState.startTime,
      'selected_day_id': settingsState.selectedDayId,
      'day_overrides': settingsState.dayOverrides
          ?.map((o) => o.toJson())
          .toList(),
      'minutes_list': settingsState.minutesList,
      'end_minutes_list': settingsState.endMinutesList,
      'include_teachers_in_payload': settingsState.includeTeachersInPayload,

      'last_generated_schedule': currentResult?.toJson(),
    };

    try {
      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);

      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Schedule Data',
        fileName: 'timetable_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(bytes),
      );

      if (outputFile != null && !kIsWeb) {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settingsState.selectedDays.isEmpty &&
                      settingsState.daysPerWeek == 0
                  ? 'Schedule successfully saved.'
                  : 'Schedule and configuration inputs successfully saved.',
            ),
            backgroundColor: const Color(0xFF2A6FDB),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> importSchedule(
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) throw Exception('Could not read file data');

      final jsonString = utf8.decode(fileBytes);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final prefsService = SharedPreferencesService();

      // 1. Load Levels
      if (data.containsKey('levels_data')) {
        final Map<String, dynamic> levelsDecoded = data['levels_data'];
        final Map<String, int> levels = levelsDecoded.map(
          (k, v) => MapEntry(k, v as int),
        );

        final Map<String, dynamic> levelIdsDecoded =
            data['level_ids_data'] ?? {};
        final Map<String, int> levelIds = levelIdsDecoded.map(
          (k, v) => MapEntry(k, v as int),
        );

        final Map<String, dynamic> realIDDecoded = data['real_id_data'] ?? {};
        final Map<int, String> realID = realIDDecoded.map(
          (k, v) => MapEntry(int.parse(k), v as String),
        );

        final int nextLevelId = data['next_level_id_data'] ?? 1;

        final List classesDecoded = data['classes_data'] ?? [];
        final classes = classesDecoded
            .map((e) => ClassLevelEncoder.fromJson(e))
            .toList();

        ref
            .read(levelsProvider.notifier)
            .loadState(levels, levelIds, realID, nextLevelId, classes);
      }

      // 2. Load Teachers
      if (data.containsKey('teachers_data')) {
        final List decoded = data['teachers_data'];
        final teachers = decoded
            .map((e) => TeacherEncoder.fromJson(e))
            .toList();
        ref.read(teachersProvider.notifier).loadState(teachers);
      }

      // 3. Load Rooms
      if (data.containsKey('rooms_data')) {
        final List decoded = data['rooms_data'];
        final rooms = decoded.map((e) => RoomEncoder.fromJson(e)).toList();
        final int nextRoomId = data['next_room_id_data'] ?? 1;
        ref.read(roomsProvider.notifier).loadState(rooms, nextRoomId);
      }

      // 4. Load Subjects and Consecutive Hours
      if (data.containsKey('subjects_data')) {
        final List decodedSubjects = data['subjects_data'];
        final subjects = decodedSubjects
            .map((e) => SubjectEncoder.fromJson(e))
            .toList();

        final List decodedConsecutive = data['consecutive_hours_data'] ?? [];
        final consecutiveHours = decodedConsecutive
            .map((e) => ConsecutiveHoursEncoder.fromJson(e))
            .toList();
        ref
            .read(subjectsProvider.notifier)
            .loadState(subjects, consecutiveHours);
      }

      // 5. Load Groups
      if (data.containsKey('groups_data')) {
        final List decoded = data['groups_data'];
        final groups = decoded
            .map((e) => SplitGroupEncoder.fromJson(e))
            .toList();
        final merges = (data['merges_data'] as List? ?? [])
            .map((e) => ClassesMergeEncoder.fromJson(e))
            .toList();
        ref.read(groupsProvider.notifier).loadState(groups, merges);
      }

      // 6. Load Manual Overrides
      if (data.containsKey('manual_overrides_data')) {
        final List decoded = data['manual_overrides_data'];
        final manualOverrides = decoded
            .map((e) => ManualOverrideEncoder.fromJson(e))
            .toList();
        ref.read(manualOverridesProvider.notifier).loadState(manualOverrides);
      }

      // 7. Load Settings
      if (data.containsKey('selected_days')) {
        final List decodedDays = data['selected_days'] ?? [];
        final selectedDays = decodedDays.map((e) => e.toString()).toList();
        final int daysPerWeek = data['days_per_week'] ?? 0;
        final int timeslotsPerDay = data['timeslots_per_day'] ?? 0;
        final int maxHoursPerDay = data['max_hours_per_day'] ?? 0;
        final int startTime = data['start_time'] ?? 0;
        final int? selectedDayId = data['selected_day_id'];

        final List decodedBreaks = data['break_hours_per_day'] ?? [];
        final breakHoursPerDay = decodedBreaks.map((e) => e as int).toList();

        final List decodedOverrides = data['day_overrides'] ?? [];
        final dayOverrides = decodedOverrides
            .map((e) => DayOverrideEncoder.fromJson(e))
            .toList();

        final List decodedMinutes = data['minutes_list'] ?? [];
        final minutesList = decodedMinutes.map((e) => e as int).toList();

        final List decodedEndMinutes = data['end_minutes_list'] ?? [];
        final endMinutesList = decodedEndMinutes.map((e) => e as int).toList();

        final bool includeTeachersInPayload =
            data['include_teachers_in_payload'] ?? true;

        ref
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
              endMinutesList: endMinutesList,
              includeTeachersInPayload: includeTeachersInPayload,
            );
      }

      // 8. Load Result
      ScheduleDecoder? importedResult;
      if (data.containsKey('last_generated_schedule') &&
          data['last_generated_schedule'] != null) {
        importedResult = ScheduleDecoder.fromJson(
          data['last_generated_schedule'],
        );
        ref.read(currentScheduleProvider.notifier).state = importedResult;
        await prefsService.saveString(
          'last_generated_schedule',
          jsonEncode(data['last_generated_schedule']),
        );
      } else {
        ref.read(currentScheduleProvider.notifier).state = null;
        await prefsService.remove('last_generated_schedule');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule and configuration loaded successfully.'),
            backgroundColor: Color(0xFF2A6FDB),
          ),
        );
        if (importedResult != null) {
          context.go(
            '/create/schedule_second_page/result',
            extra: importedResult,
          );
        } else {
          context.go('/create/schedule_second_page');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
