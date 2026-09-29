import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

class SettingsState {
  final int daysPerWeek;
  final int timeslotsPerDay;
  final int maxHoursPerDay;
  final List<int> breakHoursPerDay;
  final List<String> selectedDays;
  final int? selectedDayId;
  final int startTime;
  final List<DayOverrideEncoder>? dayOverrides;
  final List<int> minutesList;
  final List<int> endMinutesList;
  final bool includeTeachersInPayload;
  final bool prioritizeStudentTeacher;
  final bool? showSubjectColors;
  final bool? showClassName;
  final bool? showTeachersNames;
  SettingsState({
    required this.daysPerWeek,
    required this.timeslotsPerDay,
    required this.maxHoursPerDay,
    required this.breakHoursPerDay,
    required this.selectedDays,
    this.showSubjectColors,
    this.showClassName,
    this.showTeachersNames,
    this.selectedDayId,
    required this.startTime,
    this.dayOverrides,
    required this.minutesList,
    List<int>? endMinutesList,
    required this.includeTeachersInPayload,
    required this.prioritizeStudentTeacher,
  }) : endMinutesList = endMinutesList ?? minutesList;

  SettingsState copyWith({
    int? daysPerWeek,
    int? timeslotsPerDay,
    int? maxHoursPerDay,
    List<int>? breakHoursPerDay,
    List<String>? selectedDays,
    int? startTime,
    int? selectedDayId,
    List<DayOverrideEncoder>? dayOverrides,
    List<int>? minutesList,
    List<int>? endMinutesList,
    bool? includeTeachersInPayload,
    bool? prioritizeStudentTeacher,
    bool? showSubjectColors,
    bool? showClassName,
    bool? showTeachersNames,
  }) {
    return SettingsState(
      selectedDayId: selectedDayId ?? this.selectedDayId,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      timeslotsPerDay: timeslotsPerDay ?? this.timeslotsPerDay,
      maxHoursPerDay: maxHoursPerDay ?? this.maxHoursPerDay,
      breakHoursPerDay: breakHoursPerDay ?? this.breakHoursPerDay,
      selectedDays: selectedDays ?? this.selectedDays,
      startTime: startTime ?? this.startTime,
      dayOverrides: dayOverrides ?? this.dayOverrides,
      minutesList: minutesList ?? this.minutesList,
      endMinutesList: endMinutesList ?? this.endMinutesList,
      includeTeachersInPayload:
          includeTeachersInPayload ?? this.includeTeachersInPayload,
      prioritizeStudentTeacher:
          prioritizeStudentTeacher ?? this.prioritizeStudentTeacher,
      showSubjectColors: showSubjectColors ?? this.showSubjectColors,
      showClassName: showClassName ?? this.showClassName,
      showTeachersNames: showTeachersNames ?? this.showTeachersNames,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState(
      selectedDays: [],
      daysPerWeek: 0,
      timeslotsPerDay: 0,
      maxHoursPerDay: 0,
      breakHoursPerDay: [],
      startTime: 0,
      minutesList: [],
      endMinutesList: [],
      includeTeachersInPayload: true,
      prioritizeStudentTeacher: true,
      showSubjectColors: true,
      showClassName: true,
      showTeachersNames: false,
    );
  }

  @override
  set state(SettingsState value) {
    super.state = value;

    // Save selected days as a JSON string
    final selectedDaysJson = jsonEncode(value.selectedDays);
    SharedPreferencesService().saveString('selected_days', selectedDaysJson);

    // Save days per week
    SharedPreferencesService().setInt('days_per_week', value.daysPerWeek);

    // Save timeslots per day
    SharedPreferencesService().setInt(
      'timeslots_per_day',
      value.timeslotsPerDay,
    );

    // Save max hours per day
    SharedPreferencesService().setInt(
      'max_hours_per_day',
      value.maxHoursPerDay,
    );

    // Save break hours per day as a JSON string
    final breakHoursJson = jsonEncode(value.breakHoursPerDay);
    SharedPreferencesService().saveString(
      'break_hours_per_day',
      breakHoursJson,
    );

    // Save start time
    SharedPreferencesService().setInt('start_time', value.startTime);

    // Save selected day ID if present, otherwise remove it from preferences
    if (value.selectedDayId != null) {
      SharedPreferencesService().setInt(
        'selected_day_id',
        value.selectedDayId!,
      );
    } else {
      SharedPreferencesService().remove('selected_day_id');
    }

    // Save day overrides list as a JSON string, or remove if null
    if (value.dayOverrides != null) {
      final dayOverridesJson = jsonEncode(
        value.dayOverrides!.map((e) => e.toJson()).toList(),
      );
      SharedPreferencesService().saveString('day_overrides', dayOverridesJson);
    } else {
      SharedPreferencesService().remove('day_overrides');
    }

    // Save minutes list as a JSON string
    final minutesListJson = jsonEncode(value.minutesList);
    SharedPreferencesService().saveString('minutes_list', minutesListJson);

    // Save end minutes list as a JSON string
    final endMinutesListJson = jsonEncode(value.endMinutesList);
    SharedPreferencesService().saveString(
      'end_minutes_list',
      endMinutesListJson,
    );

    SharedPreferencesService().saveString(
      'include_teachers_in_payload',
      value.includeTeachersInPayload.toString(),
    );
    SharedPreferencesService().saveBool(
      'prioritize_student_teacher',
      value.prioritizeStudentTeacher,
    );
    SharedPreferencesService().saveBool(
      'show_subject_colors',
      value.showSubjectColors!,
    );
    SharedPreferencesService().saveBool(
      'show_class_name',
      value.showClassName!,
    );
  }

  /// Loads the saved settings state from SharedPreferences values passed in.
  void loadState({
    required List<String> selectedDays,
    required int daysPerWeek,
    required int timeslotsPerDay,
    required int maxHoursPerDay,
    required List<int> breakHoursPerDay,
    required int startTime,
    int? selectedDayId,
    required List<DayOverrideEncoder> dayOverrides,
    required List<int> minutesList,
    List<int>? endMinutesList,
    bool includeTeachersInPayload = true,
    bool prioritizeStudentTeacher = true,
    bool showSubjectColors = true,
    bool showClassName = true,
  }) {
    state = SettingsState(
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
      prioritizeStudentTeacher: prioritizeStudentTeacher,
      showSubjectColors: showSubjectColors,
      showClassName: showClassName,
    );
  }

  void setTimeslotsPerDay(int timeslots) {
    state = state.copyWith(timeslotsPerDay: timeslots);
  }

  /// set start time
  void setStartTime(int startTime) {
    state = state.copyWith(startTime: startTime);
  }

  void addBreakHour(int hour) {
    final newBreakHours = List<int>.from(state.breakHoursPerDay);
    if (!newBreakHours.contains(hour)) {
      newBreakHours.add(hour);
      newBreakHours.sort();

      // Unselect this slot from existing day overrides
      final currentOverrides = List<DayOverrideEncoder>.from(
        state.dayOverrides ?? [],
      );
      final slotId = hour - state.startTime + 1;
      for (int i = 0; i < currentOverrides.length; i++) {
        final override = currentOverrides[i];
        final newTimeslots = List<int>.from(override.timeslots ?? []);
        if (newTimeslots.contains(slotId)) {
          newTimeslots.remove(slotId);
          currentOverrides[i] = DayOverrideEncoder(
            override.dayId,
            newTimeslots,
            override.breaks,
          );
        }
      }

      state = state.copyWith(
        breakHoursPerDay: newBreakHours,
        dayOverrides: currentOverrides,
      );
    }
  }

  void removeBreakHour(int hour) {
    final newBreakHours = List<int>.from(state.breakHoursPerDay);
    newBreakHours.remove(hour);
    state = state.copyWith(breakHoursPerDay: newBreakHours);
  }

  void toggleDay(String day) {
    const days = ['1', '2', '3', '4', '5', '6', '7'];
    final dayOverrideId = days.indexOf(day) + 1;

    final newSelectedDays = List<String>.from(state.selectedDays);
    final currentOverrides = List<DayOverrideEncoder>.from(
      state.dayOverrides ?? [],
    );

    if (newSelectedDays.contains(day)) {
      newSelectedDays.remove(day);
      currentOverrides.removeWhere((o) => o.dayId == dayOverrideId);
    } else {
      newSelectedDays.add(day);
    }
    state = state.copyWith(
      selectedDays: newSelectedDays,
      daysPerWeek: newSelectedDays.length,
      dayOverrides: currentOverrides,
    );
  }

  void setMaxHoursPerDay(int hours) {
    state = state.copyWith(maxHoursPerDay: hours);
  }

  void setIncludeTeachersInPayload(bool includeTeachers) {
    state = state.copyWith(includeTeachersInPayload: includeTeachers);
  }

  /// set minutes list
  void setMinutesList(int slotsMinutes) {
    //
    state = state.copyWith(
      minutesList: List<int>.generate(slotsMinutes, (i) => 0),
      endMinutesList: List<int>.generate(slotsMinutes, (i) => 0),
    );
  }

  /// update minute of a specific index
  void updateMinute(int index, int minute) {
    final newMinutesList = List<int>.from(state.minutesList);
    newMinutesList[index] = minute;
    state = state.copyWith(minutesList: newMinutesList);
  }

  /// update the end minute of a specific index, independently from the
  /// start minute handled by [updateMinute].
  void updateEndMinute(int index, int minute) {
    final newEndMinutesList = List<int>.from(state.endMinutesList);
    newEndMinutesList[index] = minute;
    state = state.copyWith(endMinutesList: newEndMinutesList);
  }

  /// Resets all settings back to their initial defaults.
  void reset() {
    state = SettingsState(
      selectedDays: [],
      daysPerWeek: 0,
      timeslotsPerDay: 0,
      maxHoursPerDay: 0,
      breakHoursPerDay: [],
      startTime: 0,
      dayOverrides: [],
      minutesList: [],
      endMinutesList: [],
      includeTeachersInPayload: true,
      prioritizeStudentTeacher: true,
      showSubjectColors: true,
      showClassName: true,
    );
  }

  /// update multiple settings at once to avoid multiple rebuilds
  void updateDaySettings({
    required int startTime,
    required int timeslotsPerDay,
    required int selectedDayId,
  }) {
    final currentOverrides = List<DayOverrideEncoder>.from(
      state.dayOverrides ?? [],
    );

    // Check if override for this day already exists (1-indexed)
    final dayOverrideId = selectedDayId + 1;
    final index = currentOverrides.indexWhere((o) => o.dayId == dayOverrideId);

    if (index == -1) {
      // Add new override if it doesn't exist
      // Default to all slots being available (1 to timeslotsPerDay), EXCEPT break hours
      final defaultSlots = List.generate(timeslotsPerDay, (i) => i + 1).where((
        slot,
      ) {
        final absoluteHour = startTime + slot - 1;
        return !state.breakHoursPerDay.contains(absoluteHour);
      }).toList();

      currentOverrides.add(DayOverrideEncoder(dayOverrideId, defaultSlots, []));
    }

    state = state.copyWith(
      startTime: startTime,
      timeslotsPerDay: timeslotsPerDay,
      selectedDayId: selectedDayId,
      dayOverrides: currentOverrides,
    );
  }

  /// Toggle a slot in a specific day's override
  void toggleSlot(int dayId, int slotId) {
    final dayOverrideId = dayId + 1;
    final currentOverrides = List<DayOverrideEncoder>.from(
      state.dayOverrides ?? [],
    );
    final index = currentOverrides.indexWhere((o) => o.dayId == dayOverrideId);

    if (index != -1) {
      final override = currentOverrides[index];
      final newTimeslots = List<int>.from(override.timeslots ?? []);

      if (newTimeslots.contains(slotId)) {
        newTimeslots.remove(slotId);
      } else {
        newTimeslots.add(slotId);
        newTimeslots.sort();
      }

      currentOverrides[index] = DayOverrideEncoder(
        dayOverrideId,
        newTimeslots,
        override.breaks,
      );
      state = state.copyWith(dayOverrides: currentOverrides);
    }
  }

  /// either the solver will prioritize student or teacher
  void setPrioritizeStudentTeacher(bool prioritizeStudentTeacher) {
    state = state.copyWith(prioritizeStudentTeacher: prioritizeStudentTeacher);
  }

  /// show subject colors or subject class name
  void setShowSubjectColors(bool showSubjectColors) {
    state = state.copyWith(showSubjectColors: showSubjectColors);
  }

  /// show subject name or class name
  void setShowClassName(bool showClassName) {
    state = state.copyWith(showClassName: showClassName);
  }

  /// show teachers names on the schedule
  void setShowTeachersNames(bool showTeachersNames) {
    state = state.copyWith(showTeachersNames: showTeachersNames);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
