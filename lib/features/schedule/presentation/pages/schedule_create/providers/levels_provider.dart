import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';

class LevelsState {
  final Map<String, int> levels;
  final Map<String, int> levelIds;
  final Map<int, String> realID;
  final int nextLevelId;
  final List<ClassLevelEncoder> classes;
  final String selectedLevel;
  final int? selectedLevelId;
  final int? classesGroupID;
  final int? classID;
  LevelsState({
    required this.levels,
    required this.levelIds,
    required this.nextLevelId,
    required this.classes,
    required this.selectedLevel,
    required this.realID,
    required this.selectedLevelId,
    required this.classesGroupID,
    required this.classID,
  });

  LevelsState copyWith({
    Map<String, int>? levels,
    Map<String, int>? levelIds,
    int? nextLevelId,
    List<ClassLevelEncoder>? classes,
    String? selectedLevel,
    int? selectedLevelId,
    int? classesGroupID,
    Map<int, String>? realID,
    int? classID,
  }) {
    return LevelsState(
      levels: levels ?? this.levels,
      levelIds: levelIds ?? this.levelIds,
      nextLevelId: nextLevelId ?? this.nextLevelId,
      classes: classes ?? this.classes,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedLevelId: selectedLevelId,
      realID: realID ?? this.realID,
      classesGroupID: classesGroupID ?? this.classesGroupID,
      classID: classID ?? this.classID,
    );
  }
}

class LevelsNotifier extends Notifier<LevelsState> {
  @override
  LevelsState build() {
    return LevelsState(
      levels: {},
      levelIds: {},
      nextLevelId: 1,
      classes: [],
      selectedLevel: 'None',
      selectedLevelId: null,
      realID: {},
      classesGroupID: 1,
      classID: 1,
    );
  }

  @override
  set state(LevelsState value) {
    super.state = value;
    final levelsJson = jsonEncode(value.levels);
    SharedPreferencesService().saveString('levels_data', levelsJson);

    final levelIdsJson = jsonEncode(value.levelIds);
    SharedPreferencesService().saveString('level_ids_data', levelIdsJson);

    final realIDJson = jsonEncode(
      value.realID.map((k, v) => MapEntry(k.toString(), v)),
    );
    SharedPreferencesService().saveString('real_id_data', realIDJson);

    SharedPreferencesService().setInt('next_level_id_data', value.nextLevelId);

    final classesJson = jsonEncode(
      value.classes.map((c) => c.toJson()).toList(),
    );
    SharedPreferencesService().saveString('classes_data', classesJson);
  }

  void loadState(
    Map<String, int> levels,
    Map<String, int> levelIds,
    Map<int, String> realID,
    int nextLevelId,
    List<ClassLevelEncoder> classes,
  ) {
    state = state.copyWith(
      levels: levels,
      levelIds: levelIds,
      realID: realID,
      nextLevelId: nextLevelId,
      classes: classes,
      selectedLevel: state.selectedLevel == 'None' && levels.isNotEmpty
          ? levels.keys.first
          : state.selectedLevel,
      selectedLevelId: state.selectedLevelId == null && levelIds.isNotEmpty
          ? levelIds.values.first
          : state.selectedLevelId,
      classesGroupID: state.classesGroupID == 1 && levelIds.isNotEmpty
          ? levelIds.values.first
          : state.classesGroupID,
      classID: state.classID == 1 && classes.isNotEmpty
          ? classes.first.classId
          : state.classID,
    );
  }

  void addLevel(String name, int numClasses) {
    if (state.levels.containsKey(name)) return;

    final newLevels = Map<String, int>.from(state.levels);
    final newLevelIds = Map<String, int>.from(state.levelIds);
    final newRealID = Map<int, String>.from(state.realID);
    final levelId = state.nextLevelId;

    newLevels[name] = numClasses;
    newLevelIds[name] = levelId;
    newRealID[levelId] = name;

    final newClasses = List<ClassLevelEncoder>.from(state.classes);
    for (int i = 0; i < numClasses; i++) {
      newClasses.add(
        ClassLevelEncoder(
          newClasses.length + 1,
          levelId,
          '${name}_${i + 1}',
          30,
        ),
      );
    }
    final isFirstLevel = state.levels.isEmpty;
    state = state.copyWith(
      levels: newLevels,
      levelIds: newLevelIds,
      nextLevelId: levelId + 1,
      classes: newClasses,
      realID: newRealID,
      selectedLevel: isFirstLevel ? name : state.selectedLevel,
      selectedLevelId: isFirstLevel ? levelId : state.selectedLevelId,
      classesGroupID: isFirstLevel ? levelId : state.classesGroupID,
    );
  }

  /// set selected level to tapped element
  void setSelectedLevel(String name) {
    state = state.copyWith(selectedLevel: name);
  }

  /// set selected levelId to tapped element
  void setSelectedLevelId(int id) {
    state = state.copyWith(selectedLevelId: id);
  }

  /// since no {levelId: { id : classes}}, use this index to refer all classes of a level
  void setClassesGroupId(int id) {
    state = state.copyWith(classesGroupID: id);
  }

  /// set selected classId to tapped element
  void setClassID(int id) {
    state = state.copyWith(classID: id);
  }

  // Purely updates the state of levels and classes.
  // The schedule service should call this while simultaneously reindexing subjects/teachers.
  void removeLevelCore(String name, int removeLevelId) {
    final newLevels = Map<String, int>.from(state.levels);
    newLevels.remove(name);

    final newLevelIds = Map<String, int>.from(state.levelIds);
    newLevelIds.remove(name);

    // remove level id from realIDs
    final newRealID = Map<int, String>.from(state.realID);
    newRealID.remove(removeLevelId);

    // ----------------------------------------------------- remove level id from classes
    final newClasses = state.classes
        .where((classLevel) => classLevel.levelId != removeLevelId)
        .toList();
    // ----------------------------------------------------- remove level id from teachers qualified levels
    ref.read(teachersProvider.notifier).removeQualifiedLevel(removeLevelId);
    // ----------------------------------------------------- remove level from subjects
    ref
        .read(subjectsProvider.notifier)
        .removeLevelReferences(name, removeLevelId);

    state = state.copyWith(
      levels: newLevels,
      levelIds: newLevelIds,
      classes: newClasses,
      realID: newRealID,
      selectedLevel: state.selectedLevel == name
          ? (newLevels.isNotEmpty ? newLevels.keys.first : 'None')
          : state.selectedLevel,
      selectedLevelId: state.selectedLevel == name
          ? (newLevelIds.isNotEmpty ? newLevelIds.values.first : null)
          : state.selectedLevelId,
      classesGroupID: state.selectedLevel == name
          ? (newLevelIds.isNotEmpty ? newLevelIds.values.first : null)
          : state.classesGroupID,
    );
  }
}

final levelsProvider = NotifierProvider<LevelsNotifier, LevelsState>(
  LevelsNotifier.new,
);
