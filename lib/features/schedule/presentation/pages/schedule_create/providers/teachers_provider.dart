import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

class TeachersState {
  final List<TeacherEncoder> teachers;

  TeachersState({required this.teachers});

  TeachersState copyWith({List<TeacherEncoder>? teachers}) {
    return TeachersState(teachers: teachers ?? this.teachers);
  }
}

class TeachersNotifier extends Notifier<TeachersState> {
  @override
  TeachersState build() {
    return TeachersState(teachers: []);
  }

  @override
  set state(TeachersState value) {
    super.state = value;
    final jsonString = jsonEncode(
      value.teachers.map((t) => t.toJson()).toList(),
    );
    SharedPreferencesService().saveString('teachers_data', jsonString);
  }

  void loadState(List<TeacherEncoder> teachers) {
    state = state.copyWith(teachers: teachers);
  }

  void addTeacher(
    String name, {
    required int subjectId,
    required List<int> qualifiedLevels,
    int? maxHoursPerWeek,
    bool? isbackToback,
    Map<int, List<int>>? qualifiedClasses,
  }) {
    final newTeachers = List<TeacherEncoder>.from(state.teachers);
    if (newTeachers.any((t) => t.teacherName == name)) return;

    final newId =
        newTeachers.fold<int>(0, (maxId, t) {
          final id = t.teacherId;
          return id > maxId ? id : maxId;
        }) +
        1;

    newTeachers.add(
      TeacherEncoder(
        newId,
        name,
        subjectId,
        qualifiedLevels,
        maxHoursPerWeek: maxHoursPerWeek,
        requireConsecutiveHours: isbackToback,
        qualifiedClasses: qualifiedClasses,
      ),
    );
    state = state.copyWith(teachers: newTeachers);
  }

  void editTeacher(
    int teacherId,
    String name, {
    required int subjectId,
    required List<int> qualifiedLevels,
    int? maxHoursPerWeek,
    bool? isbackToback,
    Map<int, List<int>>? qualifiedClasses,
  }) {
    final newTeachers = List<TeacherEncoder>.from(state.teachers);
    final index = newTeachers.indexWhere((t) => t.teacherId == teacherId);
    if (index == -1) return;
    if (newTeachers.any(
      (t) => t.teacherName == name && t.teacherId != teacherId,
    )) {
      return;
    }

    newTeachers[index] = TeacherEncoder(
      teacherId,
      name,
      subjectId,
      qualifiedLevels,
      maxHoursPerWeek: maxHoursPerWeek,
      requireConsecutiveHours: isbackToback,
      qualifiedClasses: qualifiedClasses,
    );
    state = state.copyWith(teachers: newTeachers);
  }

  void removeTeacher(int teacherId) {
    final newTeachers = List<TeacherEncoder>.from(state.teachers)
      ..removeWhere((t) => t.teacherId == teacherId);
    state = state.copyWith(teachers: newTeachers);
  }

  // Helper method for cascading level delete
  void removeQualifiedLevel(int removeLevelId) {
    final newTeachers = state.teachers.map((t) {
      final newQualifiedLevels = t.qualifiedLevels
          ?.where((id) => id != removeLevelId)
          .toList();
      final newQualifiedClasses = <int, List<int>>{};
      if (t.qualifiedClasses != null) {
        for (final entry in t.qualifiedClasses!.entries) {
          if (entry.key == removeLevelId) continue;
          newQualifiedClasses[entry.key] = entry.value;
        }
      }
      return TeacherEncoder(
        t.teacherId,
        t.teacherName,
        t.subjectId,
        newQualifiedLevels,
        maxHoursPerWeek: t.maxHoursPerWeek,
        requireConsecutiveHours: t.requireConsecutiveHours,
        qualifiedClasses: newQualifiedClasses.isEmpty
            ? null
            : newQualifiedClasses,
      );
    }).toList();
    state = state.copyWith(teachers: newTeachers);
  }
}

final teachersProvider = NotifierProvider<TeachersNotifier, TeachersState>(
  TeachersNotifier.new,
);
