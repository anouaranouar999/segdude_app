import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

/// State representing the configured manual overrides.
class ManualOverridesState {
  final List<ManualOverrideEncoder> overrides;

  ManualOverridesState({required this.overrides});

  ManualOverridesState copyWith({List<ManualOverrideEncoder>? overrides}) {
    return ManualOverridesState(overrides: overrides ?? this.overrides);
  }
}

/// Notifier that manages manual override constraints.
class ManualOverridesNotifier extends Notifier<ManualOverridesState> {
  @override
  ManualOverridesState build() {
    return ManualOverridesState(overrides: []);
  }

  /// Adds a new override constraint, removing any existing override for the same class, day, and timeslot.
  void addOverride(ManualOverrideEncoder override) {
    final newOverrides = List<ManualOverrideEncoder>.from(state.overrides);
    newOverrides.removeWhere(
      (o) =>
          o.classId == override.classId &&
          o.day == override.day &&
          o.timeslot == override.timeslot,
    );
    newOverrides.add(override);
    state = state.copyWith(overrides: newOverrides);
  }

  /// Removes an override constraint for a specific class, day, and timeslot.
  void removeOverride(int classId, int day, int timeslot) {
    final newOverrides = List<ManualOverrideEncoder>.from(state.overrides);
    newOverrides.removeWhere(
      (o) => o.classId == classId && o.day == day && o.timeslot == timeslot,
    );
    state = state.copyWith(overrides: newOverrides);
  }

  /// overrides the default state setter to also save the state to SharedPreferences
  @override
  set state(ManualOverridesState value) {
    super.state = value;
    final jsonString = jsonEncode(
      value.overrides.map((o) => o.toJson()).toList(),
    );
    SharedPreferencesService().saveString('manual_overrides_data', jsonString);
  }

  /// load state from SharedPreferences
  void loadState(List<ManualOverrideEncoder> overrides) {
    state = state.copyWith(overrides: overrides);
  }

  /// Clears all manual overrides.
  void clearOverrides() {
    state = state.copyWith(overrides: []);
  }
}

/// Provider that exposes the manual overrides state and modifier methods.
final manualOverridesProvider =
    NotifierProvider<ManualOverridesNotifier, ManualOverridesState>(
      ManualOverridesNotifier.new,
    );
