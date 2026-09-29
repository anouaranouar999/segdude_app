import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';

class RoomsState {
  final List<RoomEncoder> rooms;
  final int? nextRoomID;
  RoomsState({required this.rooms, required this.nextRoomID});

  RoomsState copyWith({List<RoomEncoder>? rooms, int? nextRoomID}) {
    return RoomsState(
      rooms: rooms ?? this.rooms,
      nextRoomID: nextRoomID ?? this.nextRoomID,
    );
  }
}

class RoomsNotifier extends Notifier<RoomsState> {
  @override
  RoomsState build() {
    return RoomsState(rooms: [], nextRoomID: 0);
  }

  /// overrides the default state setter to also save the state to SharedPreferences
  @override
  set state(RoomsState value) {
    super.state = value;
    final jsonString = jsonEncode(value.rooms.map((r) => r.toJson()).toList());
    SharedPreferencesService().saveString('rooms_data', jsonString);
    SharedPreferencesService().setInt(
      'next_room_id_data',
      value.nextRoomID ?? 1,
    );
  }

  void loadState(List<RoomEncoder> rooms, int nextRoomID) {
    state = state.copyWith(rooms: rooms, nextRoomID: nextRoomID);
  }

  /// adds a new room to the list and returns the id
  int addRoom(
    String name,
    int capacity,
    List<int> allowedLevels,
    List<int> allowedSubjects,
    Map<int, List<int>>? allowedClasses,
  ) {
    final newRooms = List<RoomEncoder>.from(state.rooms);
    final roomID = state.nextRoomID;
    newRooms.add(
      RoomEncoder(
        roomID! + 1,
        name,
        capacity,
        allowedLevels,
        allowedSubjects,
        allowedClasses ?? {},
      ),
    );
    state = state.copyWith(rooms: newRooms, nextRoomID: roomID + 1);
    return newRooms.last.roomId;
  }

  /// edit room to given params
  void editRoom(
    int roomId,
    String name,
    int capacity,
    List<int> allowedLevels,
    List<int> allowedSubjects,
    Map<int, List<int>>? allowedClasses,
    bool requiresRoom,
  ) {
    final newRooms = List<RoomEncoder>.from(state.rooms);
    final index = newRooms.indexWhere((room) => room.roomId == roomId);
    if (index == -1) return;
    newRooms[index] = RoomEncoder(
      roomId,
      name,
      capacity,
      allowedLevels,
      allowedSubjects,
      allowedClasses ?? {},
    );
    state = state.copyWith(rooms: newRooms);
  }

  /// make RoomsIDs consecutive
  void reindexRooms() {
    final newRooms = List<RoomEncoder>.from(state.rooms);

    for (var i = 0; i < newRooms.length; i++) {
      ref // replace old ID
          .read(subjectsProvider.notifier)
          .removeEditForcedRoom(newRooms[i].roomId, newRoomId: i + 1);
      newRooms[i].roomId = i + 1;
    }

    state = state.copyWith(rooms: newRooms, nextRoomID: newRooms.length + 1);
  }

  /// Generate a list og rooms
  void generateRooms(int numRooms, String namePattern) {
    final newRooms = List<RoomEncoder>.from(state.rooms);
    var newId = state.nextRoomID;
    for (int i = 0; i < numRooms; i++) {
      newId = newId! + 1;
      final name = namePattern.replaceFirst('#', (i + 1).toString());
      newRooms.add(RoomEncoder(newId, name, 40, [], [], {}));
    }
    state = state.copyWith(rooms: newRooms, nextRoomID: newId);
  }

  /// remove deleted level
  /// delete also classes that belong to the subject from the allowedClasses of the room
  void removeLevelFromRooms(int levelId, {List<int> classes = const []}) {
    final newRooms = List<RoomEncoder>.from(state.rooms);
    for (var i = 0; i < newRooms.length; i++) {
      if (newRooms[i].allowedLevels.contains(levelId)) {
        newRooms[i].allowedLevels.remove(levelId);
        newRooms[i].allowedClasses?.remove(levelId);
      }
    }
    state = state.copyWith(rooms: newRooms);
  }

  /// remove deleted subject and also remove it from the forced room if it was set

  void removeSubjectFromRooms(int subjectId) {
    final newRooms = List<RoomEncoder>.from(state.rooms);
    for (var i = 0; i < newRooms.length; i++) {
      if (newRooms[i].allowedSubjects.contains(subjectId)) {
        newRooms[i].allowedSubjects.remove(subjectId);
      }
    }
    state = state.copyWith(rooms: newRooms);
  }

  /// Added to support UI delete action — minimal, safe, no logic change
  void removeRoom(int roomId) {
    final newRooms = List<RoomEncoder>.from(state.rooms)
      ..removeWhere((r) => r.roomId == roomId);
    state = state.copyWith(rooms: newRooms);
  }
}

final roomsProvider = NotifierProvider<RoomsNotifier, RoomsState>(
  RoomsNotifier.new,
);
