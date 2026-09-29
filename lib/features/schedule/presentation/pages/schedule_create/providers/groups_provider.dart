import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

class GroupsState {
  final List<SplitGroupEncoder> groups;
  final List<ClassesMergeEncoder> merges;
  GroupsState({required this.groups, this.merges = const []});

  GroupsState copyWith({
    List<SplitGroupEncoder>? groups,
    List<ClassesMergeEncoder>? merges,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      merges: merges ?? this.merges,
    );
  }
}

/// ------------------------------------------------- Notifier -------------------------------------------------
class GroupsNotifier extends Notifier<GroupsState> {
  @override
  GroupsState build() {
    return GroupsState(groups: []);
  }

  /// overrides the default state setter to also save the state to SharedPreferences
  @override
  set state(GroupsState value) {
    super.state = value;
    SharedPreferencesService().saveString(
      'groups_data',
      jsonEncode(value.groups.map((g) => g.toJson()).toList()),
    );
    SharedPreferencesService().saveString(
      'merges_data',
      jsonEncode(value.merges.map((m) => m.toJson()).toList()),
    );
  }

  /// load state from SharedPreferences
  void loadState(
    List<SplitGroupEncoder> groups, [
    List<ClassesMergeEncoder> merges = const [],
  ]) {
    state = state.copyWith(groups: groups, merges: merges);
  }

  /// Adds a new group to the list of groups.
  void addNewGroup(int classId, int subjectId, int numGroups) {
    final newGroups = List<SplitGroupEncoder>.from(state.groups);
    newGroups.removeWhere(
      (g) => g.classId == classId && g.subjectId == subjectId,
      // &&
      // g.numGroups == numGroups,
    );
    newGroups.add(SplitGroupEncoder(classId, subjectId, numGroups));
    final newMerges = List<ClassesMergeEncoder>.from(state.merges)
      ..removeWhere(
        (merge) =>
            merge.subjectId == subjectId && merge.classIds.contains(classId),
      );
    state = state.copyWith(groups: newGroups, merges: newMerges);
  }

  /// apply same rule to all classes in the same level
  void applySameRuleToAllClasses(
    List<int> classIds,
    int subjectId,
    int numGroups,
  ) {
    final newGroups = List<SplitGroupEncoder>.from(state.groups);
    for (int classId in classIds) {
      newGroups.removeWhere(
        (g) => g.classId == classId && g.subjectId == subjectId,
        // &&
        // g.numGroups == numGroups,
      );
      newGroups.add(SplitGroupEncoder(classId, subjectId, numGroups));
    }
    final newMerges = List<ClassesMergeEncoder>.from(state.merges)
      ..removeWhere(
        (merge) =>
            merge.subjectId == subjectId &&
            merge.classIds.any(classIds.contains),
      );
    state = state.copyWith(groups: newGroups, merges: newMerges);
  }

  /// Removes an existing group from the list of groups based on its group ID.
  void removeGroup(int classId, int subjectId, int numGroups) {
    final newGroups = List<SplitGroupEncoder>.from(state.groups);
    newGroups.removeWhere(
      (g) =>
          g.classId == classId &&
          g.subjectId == subjectId &&
          g.numGroups == numGroups,
    );
    state = state.copyWith(groups: newGroups);
  }

  /// Merges classes for one subject and removes conflicting split constraints.
  bool hasOverlappingMerge(List<int> classIds, int subjectId) {
    return state.merges.any(
      (merge) =>
          merge.subjectId == subjectId && merge.classIds.any(classIds.contains),
    );
  }

  void mergeClasses(
    List<int> classIds,
    int subjectId, {
    required int? teacherId,
    bool replaceOverlappingMerges = false,
  }) {
    final selectedIds = classIds.toSet().toList();
    if (selectedIds.length < 2) return;
    if (!replaceOverlappingMerges &&
        hasOverlappingMerge(selectedIds, subjectId)) {
      return;
    }

    final newGroups = List<SplitGroupEncoder>.from(state.groups)
      ..removeWhere(
        (group) =>
            group.subjectId == subjectId && selectedIds.contains(group.classId),
      );
    final newMerges = List<ClassesMergeEncoder>.from(state.merges)
      ..removeWhere(
        (merge) =>
            merge.subjectId == subjectId &&
            merge.classIds.any(selectedIds.contains),
      );
    newMerges.add(ClassesMergeEncoder(selectedIds, subjectId, teacherId));
    state = state.copyWith(groups: newGroups, merges: newMerges);
  }

  void removeMerge(ClassesMergeEncoder merge) {
    final newMerges = List<ClassesMergeEncoder>.from(state.merges)
      ..remove(merge);
    state = state.copyWith(merges: newMerges);
  }

  /// reindex subjetcIds when a subject is removed.
  void reindexSubjectIds(int removedSubjectId) {
    final newGroups = List<SplitGroupEncoder>.from(state.groups);
    newGroups.sort((a, b) => a.subjectId.compareTo(b.subjectId));
    for (int i = 0; i < newGroups.length; i++) {
      if (newGroups[i].subjectId > removedSubjectId) {
        newGroups[i] = SplitGroupEncoder(
          newGroups[i].classId,
          newGroups[i].subjectId - 1,
          newGroups[i].numGroups,
        );
      }
    }
    final newMerges = state.merges
        .where((merge) => merge.subjectId != removedSubjectId)
        .map(
          (merge) => ClassesMergeEncoder(
            merge.classIds,
            merge.subjectId > removedSubjectId
                ? merge.subjectId - 1
                : merge.subjectId,
            merge.teacherId,
          ),
        )
        .toList();
    state = state.copyWith(groups: newGroups, merges: newMerges);
  }

  /// Removes groups of a specific subject.
  void removeGroupsOfSubject(int subjectId) {
    final newGroups = List<SplitGroupEncoder>.from(state.groups);
    newGroups.removeWhere((g) => g.subjectId == subjectId);
    final newMerges = List<ClassesMergeEncoder>.from(state.merges)
      ..removeWhere((merge) => merge.subjectId == subjectId);
    state = state.copyWith(groups: newGroups, merges: newMerges);
  }

  /// Clears all groups.
  void clearGroups() {
    state = state.copyWith(groups: [], merges: []);
  }
}

final groupsProvider = NotifierProvider<GroupsNotifier, GroupsState>(
  GroupsNotifier.new,
);
