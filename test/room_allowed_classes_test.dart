import 'package:flutter_test/flutter_test.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

void main() {
  test('RoomEncoder allowedClasses round-trip through JSON', () {
    final room = RoomEncoder(
      1,
      'Room 101',
      30,
      [10, 20],
      [1, 2],
      {
        1: [101, 102],
        2: [201, 202],
      },
    );

    final json = room.toJson();
    expect(json['allowed_classes'], {
      '1': [101, 102],
      '2': [201, 202],
    });

    final decoded = RoomEncoder.fromJson(json);
    expect(decoded.allowedClasses, {
      1: [101, 102],
      2: [201, 202],
    });
    expect(decoded.roomName, 'Room 101');
  });

  test('RoomEncoder allowedClasses backward compatibility with List JSON', () {
    final json = {
      'id': 1,
      'name': 'Room 101',
      'capacity': 30,
      'allowed_subjects': [10, 20],
      'allowed_levels': [1, 2],
      'allowed_classes': [101, 102, 201, 202],
    };

    final decoded = RoomEncoder.fromJson(json);
    expect(decoded.allowedClasses, {});
    expect(decoded.roomName, 'Room 101');
  });
}
