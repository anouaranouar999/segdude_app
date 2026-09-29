class ScheduleDecoder {
  final List<ClassSchedule> classes;
  final Map<String, dynamic>? error;
  final TeacherScheduleDecoder? teacherSchedule;
  final TeacherShiftGroups? teacherShiftGroups;

  const ScheduleDecoder({
    required this.classes,
    this.error,
    this.teacherSchedule,
    this.teacherShiftGroups,
  });

  /// Accepts the full server response map which may contain:
  ///   { "schedule": {...}, "teacherSchedule": {...}, "teacherShiftGroups": {...} }
  /// or a bare schedule map (e.g. when loaded from cache).
  factory ScheduleDecoder.fromJson(Map<String, dynamic> json) {
    final isFullResponse = json['schedule'] is Map;
    final scheduleJson = isFullResponse
        ? Map<String, dynamic>.from(json['schedule'] as Map)
        : json;

    final rawTeacherSchedule = json['teacherSchedule'] is Map
        ? Map<String, dynamic>.from(json['teacherSchedule'] as Map)
        : null;

    final rawTeacherShiftGroups = json['teacherShiftGroups'] is Map
        ? Map<String, dynamic>.from(json['teacherShiftGroups'] as Map)
        : null;

    if (scheduleJson['error'] != null) {
      return ScheduleDecoder(error: scheduleJson, classes: []);
    }

    return ScheduleDecoder(
      error: null,
      classes: scheduleJson.entries
          .map((e) => ClassSchedule.fromEntry(e))
          .toList(),
      teacherSchedule: rawTeacherSchedule == null
          ? null
          : TeacherScheduleDecoder.fromJson(rawTeacherSchedule),
      teacherShiftGroups: rawTeacherShiftGroups == null
          ? null
          : TeacherShiftGroups.fromJson(rawTeacherShiftGroups),
    );
  }

  /// Serializes back to the full server response shape so that
  /// [ScheduleSerialization] round-trips all tab data.
  Map<String, dynamic> toJson() {
    if (error != null) return error!;
    return {
      'schedule': {for (final cs in classes) cs.classId: cs.toJson()},
      if (teacherSchedule != null) 'teacherSchedule': teacherSchedule!.toJson(),
      if (teacherShiftGroups != null)
        'teacherShiftGroups': teacherShiftGroups!.toJson(),
    };
  }
}

class TeacherScheduleDecoder {
  final List<TeacherScheduleEntry> teachers;

  const TeacherScheduleDecoder({required this.teachers});

  factory TeacherScheduleDecoder.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleDecoder(
      teachers: json.entries
          .map((entry) => TeacherScheduleEntry.fromEntry(entry))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    for (final t in teachers) t.teacherId: t.toJson(),
  };
}

class TeacherScheduleEntry {
  final String teacherId;
  final List<TeacherDaySchedule> days;

  const TeacherScheduleEntry({required this.teacherId, required this.days});

  factory TeacherScheduleEntry.fromEntry(MapEntry<String, dynamic> entry) {
    final dayMap = _asStringMap(entry.value);
    return TeacherScheduleEntry(
      teacherId: entry.key,
      days: dayMap.entries
          .map((day) => TeacherDaySchedule.fromEntry(day))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {for (final d in days) d.dayId: d.toJson()};
}

class TeacherDaySchedule {
  final String dayId;
  final List<TeacherLessonSlot> slots;

  const TeacherDaySchedule({required this.dayId, required this.slots});

  factory TeacherDaySchedule.fromEntry(MapEntry<String, dynamic> entry) {
    final slotMap = _asStringMap(entry.value);
    return TeacherDaySchedule(
      dayId: entry.key,
      slots: slotMap.entries
          .map((slot) => TeacherLessonSlot.fromEntry(slot))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    for (final s in slots) s.slotId: s.toJson(),
  };
}

class TeacherLessonSlot {
  final String slotId;
  final int classId;
  final int subjectId;
  final int roomId;

  const TeacherLessonSlot({
    required this.slotId,
    required this.classId,
    required this.subjectId,
    required this.roomId,
  });

  factory TeacherLessonSlot.fromEntry(MapEntry<String, dynamic> entry) {
    final lesson = _asStringMap(entry.value);
    return TeacherLessonSlot(
      slotId: entry.key,
      classId: _asInt(lesson['class_id']),
      subjectId: _asInt(lesson['subject_id']),
      roomId: _asInt(lesson['room_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'class_id': classId,
    'subject_id': subjectId,
    'room_id': roomId,
  };
}

// ---------------------------------------------------------------------------
// TeacherShiftGroups — parsed from the "teacherShiftGroups" key in the
// server response.  Each group has a name (e.g. "A"), a shift pattern list
// (e.g. ["AM","PM","AM"]) and the teacher IDs that belong to the group.
// ---------------------------------------------------------------------------

class TeacherShiftGroups {
  final List<TeacherShiftGroup> groups;

  const TeacherShiftGroups({required this.groups});

  factory TeacherShiftGroups.fromJson(Map<String, dynamic> json) {
    return TeacherShiftGroups(
      groups: json.entries.map((e) => TeacherShiftGroup.fromEntry(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    for (final g in groups) g.groupId: g.toJson(),
  };

  /// Returns a map from teacher-id (int) → group color for quick look-up.
  Map<int, TeacherShiftGroup> get teacherGroupMap {
    final map = <int, TeacherShiftGroup>{};
    for (final group in groups) {
      for (final id in group.teacherIds) {
        map[id] = group;
      }
    }
    return map;
  }
}

class TeacherShiftGroup {
  final String groupId;
  final List<String> pattern;
  final List<int> teacherIds;

  const TeacherShiftGroup({
    required this.groupId,
    required this.pattern,
    required this.teacherIds,
  });

  factory TeacherShiftGroup.fromEntry(MapEntry<String, dynamic> entry) {
    final map = _asStringMap(entry.value);
    final rawPattern = map['pattern'];
    final rawIds = map['teacher_ids'];
    return TeacherShiftGroup(
      groupId: entry.key,
      pattern: rawPattern is List
          ? rawPattern.map((e) => e.toString()).toList()
          : const [],
      teacherIds: rawIds is List
          ? rawIds.map((e) => _asInt(e)).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'pattern': pattern,
    'teacher_ids': teacherIds,
  };
}

Map<String, dynamic> _asStringMap(dynamic value) {
  if (value is! Map) return const {};
  return value.map((key, value) => MapEntry(key.toString(), value));
}

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

class ClassSchedule {
  final String classId;
  final List<DaySchedule> days;

  const ClassSchedule({required this.classId, required this.days});

  factory ClassSchedule.fromEntry(MapEntry<String, dynamic> entry) {
    final dayMap = entry.value as Map<String, dynamic>;
    return ClassSchedule(
      classId: entry.key,
      days: dayMap.entries.map((e) => DaySchedule.fromEntry(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    for (final day in days) day.dayId: day.toJson(),
  };
}

class DaySchedule {
  final String dayId;
  final List<LessonSlot> slots;

  const DaySchedule({required this.dayId, required this.slots});

  factory DaySchedule.fromEntry(MapEntry<String, dynamic> entry) {
    final slotMap = entry.value as Map<String, dynamic>;

    return DaySchedule(
      dayId: entry.key,
      slots: slotMap.entries.map((e) => LessonSlot.fromEntry(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    for (final slot in slots) slot.slotId: slot.toJson(),
  };
}

class LessonSlot {
  final String slotId;
  final Lesson? lesson;

  const LessonSlot({required this.slotId, this.lesson});

  factory LessonSlot.fromEntry(MapEntry<String, dynamic> entry) {
    return LessonSlot(
      slotId: entry.key,
      lesson: entry.value != null
          ? Lesson.fromJson(entry.value as Map<String, dynamic>)
          : null,
    );
  }

  dynamic toJson() => lesson?.toJson();
}

class Lesson {
  final int subjectId;
  final int teacherId;
  final int roomId;
  final int? group;
  final List<dynamic>? mergeWith;
  const Lesson({
    required this.subjectId,
    required this.teacherId,
    required this.roomId,
    this.group,
    this.mergeWith,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      subjectId: json['subject_id'] as int? ?? 0,
      teacherId: json['teacher_id'] as int? ?? 0,
      roomId: json['room_id'] as int? ?? 0,
      group: json['group'] as int?,
      mergeWith: json['merged_with'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'subject_id': subjectId,
    'teacher_id': teacherId,
    'room_id': roomId,
    if (group != null) 'group': group,
    if (mergeWith != null) 'merged_with': mergeWith,
  };
}
