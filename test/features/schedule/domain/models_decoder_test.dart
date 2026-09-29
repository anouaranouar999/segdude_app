import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';

void main() {
  test('Schedule.fromJson should decode nested maps correctly', () {
    final jsonStr = '''
    {
      "Class 1": {
        "day_1": {
          "1": null,
          "2": null,
          "3": null,
          "4": null,
          "5": null,
          "6": null,
          "7": null,
          "8": null,
          "9": null,
          "10": null
        },
        "day_6": {
          "1": null,
          "2": null,
          "3": null,
          "4": null,
          "5": null,
          "6": null,
          "7": {
            "subject_id": 1,
            "teacher_id": 1,
            "room_id": 2
          },
          "8": null,
          "9": null,
          "10": null
        }
      }
    }
    ''';

    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final schedule = ScheduleDecoder.fromJson(json);

    expect(schedule.classes.length, 1);
    // expect(schedule.classes[0].className, 'Class 1');
    expect(schedule.classes[0].days.length, 2);

    final day1 = schedule.classes[0].days.firstWhere((d) => d.dayId == 'day_1');
    expect(day1.slots.length, 10);
    expect(day1.slots[0].lesson, isNull);

    final day6 = schedule.classes[0].days.firstWhere((d) => d.dayId == 'day_6');
    expect(day6.slots.length, 10);
    expect(day6.slots.firstWhere((s) => s.slotId == '7').lesson, isNotNull);
    expect(day6.slots.firstWhere((s) => s.slotId == '7').lesson?.subjectId, 1);
    expect(day6.slots.firstWhere((s) => s.slotId == '7').lesson?.teacherId, 1);
    expect(day6.slots.firstWhere((s) => s.slotId == '7').lesson?.roomId, 2);
  });
}
