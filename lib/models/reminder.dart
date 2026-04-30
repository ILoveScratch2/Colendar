class Reminder {
  final int? id;
  final int courseId;
  final int minutesBefore;
  final bool isEnabled;
  final int weekNumber;
  final int dayOfWeek;
  final int triggerTime;
  final String createdAt;

  const Reminder({
    this.id,
    required this.courseId,
    this.minutesBefore = 15,
    this.isEnabled = true,
    required this.weekNumber,
    required this.dayOfWeek,
    this.triggerTime = 0,
    this.createdAt = '',
  });

  Reminder copyWith({
    int? id,
    int? courseId,
    int? minutesBefore,
    bool? isEnabled,
    int? weekNumber,
    int? dayOfWeek,
    int? triggerTime,
    String? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      isEnabled: isEnabled ?? this.isEnabled,
      weekNumber: weekNumber ?? this.weekNumber,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      triggerTime: triggerTime ?? this.triggerTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'course_id': courseId,
      'minutes_before': minutesBefore,
      'is_enabled': isEnabled ? 1 : 0,
      'week_number': weekNumber,
      'day_of_week': dayOfWeek,
      'trigger_time': triggerTime,
      'created_at': createdAt,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      courseId: map['course_id'] as int? ?? 0,
      minutesBefore: map['minutes_before'] as int? ?? 15,
      isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
      weekNumber: map['week_number'] as int? ?? 1,
      dayOfWeek: map['day_of_week'] as int? ?? 1,
      triggerTime: map['trigger_time'] as int? ?? 0,
      createdAt: map['created_at'] as String? ?? '',
    );
  }
}
