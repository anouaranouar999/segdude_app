import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

class SubjectsState {
  final List<SubjectEncoder> subjects;
  final List<ConsecutiveHoursEncoder> consecutiveHours;
  final String selectedSubject;
  final prefs = SharedPreferencesService();

  SubjectsState({
    required this.subjects,
    required this.consecutiveHours,
    required this.selectedSubject,
  });

  SubjectsState copyWith({
    List<SubjectEncoder>? subjects,
    List<ConsecutiveHoursEncoder>? consecutiveHours,
    String? selectedSubject,
  }) {
    return SubjectsState(
      subjects: subjects ?? this.subjects,
      consecutiveHours: consecutiveHours ?? this.consecutiveHours,
      selectedSubject: selectedSubject ?? this.selectedSubject,
    );
  }
}

class SubjectsNotifier extends Notifier<SubjectsState> {
  @override
  SubjectsState build() {
    return SubjectsState(
      subjects: [],
      consecutiveHours: [],
      selectedSubject: 'None',
    );
  }

  @override
  set state(SubjectsState value) {
    super.state = value;
    final subjectsJson = jsonEncode(
      value.subjects.map((s) => s.toJson()).toList(),
    );
    SharedPreferencesService().saveString('subjects_data', subjectsJson);

    final consecutiveJson = jsonEncode(
      value.consecutiveHours.map((c) => c.toJson()).toList(),
    );
    SharedPreferencesService().saveString(
      'consecutive_hours_data',
      consecutiveJson,
    );
  }

  void loadState(
    List<SubjectEncoder> subjects,
    List<ConsecutiveHoursEncoder> consecutiveHours,
  ) {
    state = state.copyWith(
      subjects: subjects,
      consecutiveHours: consecutiveHours,
    );
  }

  /// addSubject method
  void addSubject(
    String name,
    Map<String, int> weeklyHours, {
    List<int>? forcedRoomsIds,
    int? color,
    bool requiresRoom = true,
    int? minRestHours,
    List<int>? avoidHours,
  }) {
    final newSubjects = List<SubjectEncoder>.from(state.subjects);
    final newConsecutiveHours = List<ConsecutiveHoursEncoder>.from(
      state.consecutiveHours,
    );

    if (newSubjects.any((s) => s.subjectName == name)) return;
    newSubjects.add(
      SubjectEncoder(
        newSubjects.length + 1,
        name,
        weeklyHours,
        forcedRoomsIds: forcedRoomsIds,
        color: color,
        requiresRoom: requiresRoom,
        minRestHours: minRestHours,
        avoidHours: avoidHours,
      ),
    );
    newConsecutiveHours.add(
      ConsecutiveHoursEncoder(newSubjects.length, 0, levelIds: [0]),
    );
    state = state.copyWith(
      subjects: newSubjects,
      consecutiveHours: newConsecutiveHours,
    );
  }

  /// editSubject method
  void editSubject(
    int subjectId, {
    String? name,
    Map<String, int>? weeklyHours,
    List<int>? forcedRoomsIds,
    int? color,
    bool? requiresRoom,
    int? minRestHours,
    List<int>? avoidHours,
  }) {
    final newSubjects = List<SubjectEncoder>.from(state.subjects);
    final tempWeeklyHours = Map<String, int>.from(
      newSubjects[subjectId - 1].weeklyHours ?? {},
    );
    if (weeklyHours != null) {
      for (final entry in weeklyHours.entries) {
        tempWeeklyHours[entry.key] = entry.value;
      }
    }

    newSubjects[subjectId - 1] = SubjectEncoder(
      subjectId,
      name ?? newSubjects[subjectId - 1].subjectName,
      tempWeeklyHours,
      forcedRoomsIds:
          forcedRoomsIds ?? newSubjects[subjectId - 1].forcedRoomsIds,
      color: color ?? newSubjects[subjectId - 1].color,
      requiresRoom: requiresRoom ?? newSubjects[subjectId - 1].requiresRoom,
      minRestHours: minRestHours ?? newSubjects[subjectId - 1].minRestHours,
      avoidHours: avoidHours ?? newSubjects[subjectId - 1].avoidHours,
    );
    state = state.copyWith(subjects: newSubjects);
  }

  void removeSubject(int subjectId) {
    final newSubjects = List<SubjectEncoder>.from(state.subjects);
    final newConsecutiveHours = List<ConsecutiveHoursEncoder>.from(
      state.consecutiveHours,
    );
    newSubjects.removeWhere((s) => s.subjectId == subjectId);
    newConsecutiveHours.removeWhere((ch) => ch.subjectId == subjectId);

    final List<SubjectEncoder> reindexedSubjects = [];
    final List<ConsecutiveHoursEncoder> reindexedCH = [];

    for (int i = 0; i < newSubjects.length; i++) {
      final oldId = newSubjects[i].subjectId;
      final newId = i + 1;

      reindexedSubjects.add(
        SubjectEncoder(
          newId,
          newSubjects[i].subjectName,
          newSubjects[i].weeklyHours,
          forcedRoomsIds: newSubjects[i].forcedRoomsIds,
          color: newSubjects[i].color,
          requiresRoom: newSubjects[i].requiresRoom,
          minRestHours: newSubjects[i].minRestHours,
          avoidHours: newSubjects[i].avoidHours,
        ),
      );

      for (var ch in newConsecutiveHours) {
        if (ch.subjectId == oldId) {
          reindexedCH.add(
            ConsecutiveHoursEncoder(
              newId,
              ch.consecutiveHours,
              levelIds: ch.levelIds,
              classId: ch.classId,
            ),
          );
        }
      }
    }

    state = state.copyWith(
      subjects: reindexedSubjects,
      consecutiveHours: reindexedCH,
    );
  }

  void setSelectedSubject(String subjectName) {
    state = state.copyWith(selectedSubject: subjectName);
  }

  void editConsecutiveHours(
    int subjectId,
    int hours,
    int levelId, {
    bool remove = false,
  }) {
    final newConsecutiveHours = List<ConsecutiveHoursEncoder>.from(
      state.consecutiveHours,
    );

    // Find an existing rule that exactly matches subjectId and contains levelId
    final exactIndex = newConsecutiveHours.indexWhere(
      (ch) =>
          ch.subjectId == subjectId &&
          (ch.levelIds?.contains(levelId) ?? false),
    );

    if (remove) {
      if (exactIndex != -1) {
        final existing = newConsecutiveHours[exactIndex];
        final updatedLevelIds = List<int>.from(existing.levelIds ?? []);
        updatedLevelIds.remove(levelId);
        if (updatedLevelIds.isEmpty) {
          newConsecutiveHours.removeAt(exactIndex);
        } else {
          newConsecutiveHours[exactIndex] = ConsecutiveHoursEncoder(
            existing.subjectId,
            existing.consecutiveHours,
            levelIds: updatedLevelIds,
            classId: existing.classId,
          );
        }
      }
    } else {
      if (exactIndex != -1) {
        // Update only the specific level. If the existing entry targets multiple
        // levels, split it so other levels keep their original value.
        final existing = newConsecutiveHours[exactIndex];
        final existingLevels = List<int>.from(existing.levelIds ?? []);
        if (existingLevels.length > 1) {
          // Remove the level from the existing entry
          final remaining = existingLevels
              .where((id) => id != levelId)
              .toList();
          if (remaining.isEmpty) {
            newConsecutiveHours.removeAt(exactIndex);
          } else {
            newConsecutiveHours[exactIndex] = ConsecutiveHoursEncoder(
              existing.subjectId,
              existing.consecutiveHours,
              levelIds: remaining,
              classId: existing.classId,
            );
          }
          // Add a new entry for the updated level
          newConsecutiveHours.add(
            ConsecutiveHoursEncoder(subjectId, hours, levelIds: [levelId]),
          );
        } else {
          // Single-level entry: update in-place
          newConsecutiveHours[exactIndex] = ConsecutiveHoursEncoder(
            existing.subjectId,
            hours,
            levelIds: existing.levelIds,
            classId: existing.classId,
          );
        }
      } else {
        // Create a new rule specific to this subject+level
        newConsecutiveHours.add(
          ConsecutiveHoursEncoder(subjectId, hours, levelIds: [levelId]),
        );
      }
    }

    // Normalize: ensure levelIds lists are sorted for readability
    for (var ch in newConsecutiveHours) {
      ch.levelIds?.sort();
    }

    state = state.copyWith(consecutiveHours: newConsecutiveHours);
  }

  ///------------------ Remove Forced Room for Subject or Edit Forced Room -
  void removeEditForcedRoom(int roomID, {int? newRoomId}) {
    final newSubjects = List<SubjectEncoder>.from(state.subjects);
    final index = newSubjects.indexWhere(
      (subject) => subject.forcedRoomsIds?.contains(roomID) ?? false,
    );
    if (index == -1) return;

    final updatedRoomsIds = List<int>.from(
      newSubjects[index].forcedRoomsIds ?? [],
    );
    updatedRoomsIds.remove(roomID);
    if (newRoomId != null) {
      updatedRoomsIds.add(newRoomId);
    }

    newSubjects[index] = SubjectEncoder(
      newSubjects[index].subjectId,
      newSubjects[index].subjectName,
      newSubjects[index].weeklyHours,
      forcedRoomsIds: updatedRoomsIds.isEmpty ? null : updatedRoomsIds,
      color: newSubjects[index].color,
    );
    state = state.copyWith(subjects: newSubjects);
  }

  /// load subjects from shared preferences
  Future<void> loadSubjects() async {}

  // Helper method for cascading level delete
  void removeLevelReferences(String levelName, int removeLevelId) {
    final newSubjects = state.subjects.map((s) {
      final newWeeklyHours = Map<String, int>.from(s.weeklyHours ?? {});
      newWeeklyHours.remove('$removeLevelId');
      return SubjectEncoder(
        s.subjectId,
        s.subjectName,
        newWeeklyHours,
        forcedRoomsIds: s.forcedRoomsIds,
        color: s.color,
        requiresRoom: s.requiresRoom,
      );
    }).toList();

    final newConsecutiveHours = <ConsecutiveHoursEncoder>[];
    for (var ch in state.consecutiveHours) {
      if (ch.levelIds == null) {
        newConsecutiveHours.add(ch);
      } else {
        final mappedIds = List<int>.from(ch.levelIds!);
        mappedIds.remove(removeLevelId);
        newConsecutiveHours.add(
          ConsecutiveHoursEncoder(
            ch.subjectId,
            ch.consecutiveHours,
            levelIds: mappedIds.isEmpty ? null : mappedIds,
            classId: ch.classId,
          ),
        );
      }
    }

    state = state.copyWith(
      subjects: newSubjects,
      consecutiveHours: newConsecutiveHours,
    );
  }
}

final subjectsProvider = NotifierProvider<SubjectsNotifier, SubjectsState>(
  SubjectsNotifier.new,
);
