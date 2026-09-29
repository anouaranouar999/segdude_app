class ScheduleJsonEncoder {
  final int daysPerWeek;
  final int timeslotsPerDay;
  final int maxHoursPerDay;
  final List<int> breakHoursPerDay;
  final List<ClassLevelEncoder> classes;
  final List<SubjectEncoder> subjects;
  final List<TeacherEncoder> teachers;
  final List<RoomEncoder> rooms;
  final List<ManualOverrideEncoder>? manualOverrides;
  final List<ConsecutiveHoursEncoder>? consecutiveHours;
  final List<DayOverrideEncoder>? daysOverrides;
  final List<SplitGroupEncoder>? splitGroups;
  final List<ClassesMergeEncoder>? mergedClasses;
  final bool teachersEnabled;
  final bool prioritizeStudentOrTeacher;

  ScheduleJsonEncoder(
    this.classes,
    this.subjects,
    this.teachers,
    this.rooms,
    this.manualOverrides,
    this.consecutiveHours,
    this.daysOverrides,
    this.splitGroups, {
    this.mergedClasses,
    required this.daysPerWeek,
    required this.timeslotsPerDay,
    required this.maxHoursPerDay,
    required this.breakHoursPerDay,
    this.teachersEnabled = true,
    this.prioritizeStudentOrTeacher = true,
  });

  /// return json with keys days_per_week, timeslots_perDay, max_hours_per_day, break_hours_per_day
  /// and lists classes, subjects, teachers, rooms, manual_overrides
  Map<String, dynamic> toJson() => <String, dynamic>{
    'days_per_week': daysPerWeek,
    'time_slots_per_day': timeslotsPerDay,
    'max_hours_per_day': maxHoursPerDay,
    'break_hours_per_day': breakHoursPerDay,
    'classes': classes.map((x) => x.toJson()).toList(),
    'subjects': subjects.map((x) => x.toJson()).toList(),
    'teachers': teachers.map((x) => x.toJson()).toList(),
    'rooms': rooms.map((x) => x.toJson()).toList(),
    'manual_overrides': manualOverrides?.map((x) => x.toJson()).toList(),
    'consecutive_requirements': consecutiveHours
        ?.map((x) => x.toJson())
        .toList(),
    'days_overrides': daysOverrides?.map((x) => x.toJson()).toList(),
    'group_split_requirements': splitGroups?.map((x) => x.toJson()).toList(),
    'class_merge_requirements': mergedClasses?.map((x) => x.toJson()).toList(),
    'teachers_enabled': teachersEnabled,
    'prioritize_student_gaps': prioritizeStudentOrTeacher,
  };
}

/*  classes=[ClassGroup(id=1, level_id=1, name='class1', num_students=11)] 
      subjects=[Subject(id=1, name='string', weekly_hours={1: 1}, forced_room_id=1)]
      teachers=[Teacher(id=1, name='string', subject_id=1, qualified_levels=[1], max_hours_per_week=11)]
      rooms=[Room(id=1, name='string', capacity=40, allowed_subjects=[1, 2])]
      manual_overrides=[ManualOverride(class_id=0, day=0, timeslot=0, subject_id=0, teacher_id=0, room_id=0)] */

class ClassLevelEncoder {
  final int? classId;
  final int? levelId;
  final String? className;
  final int? studentsNumber;

  /// e.g. class_id = 1, level_id = 1, name = 'class1', num_students = 11
  ClassLevelEncoder(
    this.classId,
    this.levelId,
    this.className,
    this.studentsNumber,
  );

  factory ClassLevelEncoder.fromJson(Map<String, dynamic> json) {
    return ClassLevelEncoder(
      json['id'] as int?,
      json['level_id'] as int?,
      json['name'] as String?,
      json['num_students'] as int?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': classId,
    'level_id': levelId,
    'name': className,
    'num_students': studentsNumber,
  };
}

/// {"weekly_hours": {'level': hours} , "forced_room_id": room_id or null}
class SubjectEncoder {
  final int subjectId;
  final String? subjectName;
  final Map<String, int>? weeklyHours;
  List<int>? forcedRoomsIds;

  /// Subject display color stored as an ARGB integer (e.g. Color.value).
  /// Null means no color has been chosen (use default).
  final int? color;
  final bool requiresRoom;
  final int? minRestHours;
  final List<int>? avoidHours;

  /// e.g. subject_id = 1, subject_name = 'Math', weekly_hours = {1: 2, 2: 3}, forced_rooms_ids = [1, 2]
  SubjectEncoder(
    this.subjectId,
    this.subjectName,
    this.weeklyHours, {
    this.forcedRoomsIds,
    this.color,
    this.requiresRoom = true,
    this.minRestHours,
    this.avoidHours,
  });

  factory SubjectEncoder.fromJson(Map<String, dynamic> json) {
    return SubjectEncoder(
      json['id'] as int,
      json['name'] as String?,
      (json['weekly_hours'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as int),
      ),
      forcedRoomsIds: (json['forced_room_ids'] as List<dynamic>?)?.cast<int>(),
      color: json['color'] as int?,
      requiresRoom: json['requires_room'] as bool? ?? true,
      minRestHours: json['min_rest_hours'] as int?,
      avoidHours: (json['avoid_hours'] as List<dynamic>?)?.cast<int>(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': subjectId,
    'name': subjectName,
    'weekly_hours': weeklyHours,
    'forced_room_ids': forcedRoomsIds,
    'color': color,
    'requires_room': requiresRoom,
    'min_rest_hours': minRestHours,
    'avoid_hours': avoidHours,
  };
}

class TeacherEncoder {
  final int teacherId;
  final String? teacherName;
  final int? subjectId;
  final List<int>? qualifiedLevels;
  final int? maxHoursPerWeek;
  bool? requireConsecutiveHours = true;
  Map<int, List<int>>? qualifiedClasses;

  /// e.g. teacher_id = 1, teacher_name = 'Teacher1', subject_id = 1, qualified_levels = [1, 2], max_hours_per_week = 10  \
  /// require_consecutive_hours = true by default
  TeacherEncoder(
    this.teacherId,
    this.teacherName,
    this.subjectId,
    // set default to empty list
    this.qualifiedLevels, {
    this.maxHoursPerWeek,
    this.requireConsecutiveHours,
    this.qualifiedClasses,
  });

  factory TeacherEncoder.fromJson(Map<String, dynamic> json) {
    final rawQualifiedClasses = json['qualified_classes'];
    Map<int, List<int>>? parsedQualifiedClasses;

    if (rawQualifiedClasses is Map) {
      parsedQualifiedClasses = <int, List<int>>{};
      for (final entry in rawQualifiedClasses.entries) {
        final levelId = int.tryParse(entry.key.toString());
        if (levelId == null) continue;

        final classIds = (entry.value is List)
            ? (entry.value as List)
                  .map((value) => int.tryParse(value.toString()))
                  .whereType<int>()
                  .toList()
            : <int>[];

        parsedQualifiedClasses[levelId] = classIds;
      }
      if (parsedQualifiedClasses.isEmpty) {
        parsedQualifiedClasses = null;
      }
    }

    return TeacherEncoder(
      json['id'] as int,
      json['name'] as String?,
      json['subject_id'] as int?,
      (json['qualified_levels'] as List<dynamic>?)?.cast<int>(),
      maxHoursPerWeek: json['max_hours_per_week'] as int?,
      requireConsecutiveHours: json['require_consecutive_hours'] as bool?,
      qualifiedClasses: parsedQualifiedClasses,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': teacherId,
    'name': teacherName,
    'subject_id': subjectId,
    'qualified_levels': qualifiedLevels,
    'max_hours_per_week': maxHoursPerWeek,
    'require_consecutive_hours': requireConsecutiveHours,
    'qualified_classes': qualifiedClasses == null
        ? null
        : {
            for (final entry in qualifiedClasses!.entries)
              entry.key.toString(): entry.value,
          },
  };
}

class RoomEncoder {
  int roomId;
  final String roomName;
  final int capacity;
  final List<int> allowedLevels;
  final List<int> allowedSubjects;
  Map<int, List<int>>? allowedClasses;

  /// e.g. room_id = 1, room_name = 'Room1', capacity = 40, allowed_levels = [1, 2], allowed_subjects = [1, 2, 3]
  RoomEncoder(
    this.roomId,
    this.roomName,
    this.capacity,
    this.allowedSubjects,
    this.allowedLevels,
    this.allowedClasses,
  );

  factory RoomEncoder.fromJson(Map<String, dynamic> json) {
    final rawAllowedClasses = json['allowed_classes'];
    Map<int, List<int>>? parsedAllowedClasses;

    if (rawAllowedClasses is Map) {
      parsedAllowedClasses = <int, List<int>>{};
      for (final entry in rawAllowedClasses.entries) {
        final levelId = int.tryParse(entry.key.toString());
        if (levelId == null) continue;

        final classIds = (entry.value is List)
            ? (entry.value as List)
                  .map((value) => int.tryParse(value.toString()))
                  .whereType<int>()
                  .toList()
            : <int>[];

        parsedAllowedClasses[levelId] = classIds;
      }
    } else if (rawAllowedClasses is List) {
      // Backward compatibility: if it was a List, map to an empty map
      parsedAllowedClasses = {};
    }

    return RoomEncoder(
      json['id'] as int,
      json['name'] as String,
      json['capacity'] as int,
      (json['allowed_subjects'] as List<dynamic>?)?.cast<int>() ?? [],
      (json['allowed_levels'] as List<dynamic>?)?.cast<int>() ?? [],
      parsedAllowedClasses,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': roomId,
    'name': roomName,
    'capacity': capacity,
    'allowed_subjects': allowedSubjects,
    'allowed_levels': allowedLevels,
    'allowed_classes': allowedClasses == null
        ? null
        : {
            for (final entry in allowedClasses!.entries)
              entry.key.toString(): entry.value,
          },
  };
}

class ConsecutiveHoursEncoder {
  final int subjectId;
  List<int>? levelIds;
  int? classId;
  int? consecutiveHours;

  /// 1 if levelId is null, and classId is null, and consecutiveHours is provided, then rules are applied to all classes\
  /// 2 if levelId is provided, classId is ignored, rule is applied to all classes in that level\
  /// 3 Create new instance for each rule to be applied , unless first Case
  ConsecutiveHoursEncoder(
    this.subjectId,
    this.consecutiveHours, {
    this.levelIds,
    this.classId,
  });

  factory ConsecutiveHoursEncoder.fromJson(Map<String, dynamic> json) {
    return ConsecutiveHoursEncoder(
      json['subject_id'] as int,
      json['num_consecutive'] as int?,
      levelIds: (json['level_ids'] as List<dynamic>?)?.cast<int>(),
      classId: json['class_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'subject_id': subjectId,
    'level_ids': levelIds,
    'class_id': classId,
    'num_consecutive': consecutiveHours,
  };
}

class DayOverrideEncoder {
  int dayId;
  List<int>? timeslots;
  List<int>? breaks;

  /// Override day default timing
  /// e.g. day_id = 1, timeslots = [1, 2, 3], breaks = [1, 2]
  /// use global timeslots and breaks if timeslots and breaks are empty
  DayOverrideEncoder(this.dayId, this.timeslots, this.breaks);

  factory DayOverrideEncoder.fromJson(Map<String, dynamic> json) {
    return DayOverrideEncoder(
      json['day'] as int,
      (json['available_timeslots'] as List<dynamic>?)?.cast<int>(),
      (json['breaks_timeslots'] as List<dynamic>?)?.cast<int>(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'day': dayId,
    'available_timeslots': timeslots,
    'breaks_timeslots': breaks,
  };
}

class ManualOverrideEncoder {
  final int classId;
  final int day;
  final int timeslot;
  final int subjectId;
  final int teacherId;
  final int roomId;

  ManualOverrideEncoder(
    this.classId,
    this.day,
    this.timeslot,
    this.subjectId,
    this.teacherId,
    this.roomId,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'class_id': classId - 1,
    'day': day,
    'timeslot': timeslot,
    'subject_id': subjectId,
    'teacher_id': teacherId,
    'room_id': roomId,
  };

  factory ManualOverrideEncoder.fromJson(Map<String, dynamic> json) {
    return ManualOverrideEncoder(
      (json['class_id'] as int) + 1,
      json['day'] as int,
      json['timeslot'] as int,
      json['subject_id'] as int,
      json['teacher_id'] as int,
      json['room_id'] as int,
    );
  }
}

class SplitGroupEncoder {
  final int classId;
  final int subjectId;
  final int numGroups;

  SplitGroupEncoder(this.classId, this.subjectId, this.numGroups);

  factory SplitGroupEncoder.fromJson(Map<String, dynamic> json) {
    return SplitGroupEncoder(
      json['class_id'] as int,
      json['subject_id'] as int,
      json['num_groups'] as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'class_id': classId,
    'subject_id': subjectId,
    'num_groups': numGroups,
  };
}

class ClassesMergeEncoder {
  final List<int> classIds;
  final int subjectId;

  /// The teacher responsible for the merged group, or `null`. `null` here
  /// is a real, meaningful value, not a placeholder: it is serialized as
  /// JSON `null` (key always present), matching how every other optional
  /// identifier in this file (SubjectEncoder.color,
  /// TeacherEncoder.maxHoursPerWeek, ...) already represents "no value" —
  /// no sentinel such as 0/-1 is used.
  ///
  /// `null` means: at least one teacher is qualified for this
  /// subject/level (the UI blocks merge creation entirely otherwise, so an
  /// encoder is never built for a subject/level with zero qualified
  /// teachers), but the admin intentionally left the Teacher selector
  /// empty. The solver should distribute the resulting hours among all
  /// teachers qualified for this subject/level, resolved using
  /// [subjectId] and the merged classes' levels.
  final int? teacherId;

  ClassesMergeEncoder(this.classIds, this.subjectId, this.teacherId);

  factory ClassesMergeEncoder.fromJson(Map<String, dynamic> json) {
    return ClassesMergeEncoder(
      (json['class_ids'] as List<dynamic>).cast<int>(),
      json['subject_id'] as int,
      json['teacher_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'class_ids': classIds,
    'subject_id': subjectId,
    'teacher_id': teacherId,
  };
}
