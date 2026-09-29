import 'package:flutter_test/flutter_test.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';

void main() {
  test('teacher qualified classes round-trip through JSON', () {
    final teacher = TeacherEncoder(
      1,
      'Alice',
      7,
      [10],
      maxHoursPerWeek: 12,
      requireConsecutiveHours: true,
      qualifiedClasses: {
        10: [101, 102],
      },
    );

    final json = teacher.toJson();
    expect(json['qualified_classes'], {
      '10': [101, 102],
    });

    final decoded = TeacherEncoder.fromJson(json);
    expect(decoded.qualifiedClasses, {
      10: [101, 102],
    });
    expect(decoded.teacherName, 'Alice');
  });
}
