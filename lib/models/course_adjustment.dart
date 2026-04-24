class CourseAdjustment {
  final int? id;
  final int originalCourseId;
  final int scheduleId;
  final int originalWeekNumber;
  final int? newWeekNumber;
  final int? newDayOfWeek;
  final int? newStartSection;
  final String reason;

  const CourseAdjustment({
    this.id,
    required this.originalCourseId,
    required this.scheduleId,
    required this.originalWeekNumber,
    this.newWeekNumber,
    this.newDayOfWeek,
    this.newStartSection,
    this.reason = '',
  });

  bool get isCancelled => newWeekNumber == null && newDayOfWeek == null;

  CourseAdjustment copyWith({
    int? id,
    int? originalCourseId,
    int? scheduleId,
    int? originalWeekNumber,
    int? newWeekNumber,
    int? newDayOfWeek,
    int? newStartSection,
    String? reason,
  }) {
    return CourseAdjustment(
      id: id ?? this.id,
      originalCourseId: originalCourseId ?? this.originalCourseId,
      scheduleId: scheduleId ?? this.scheduleId,
      originalWeekNumber: originalWeekNumber ?? this.originalWeekNumber,
      newWeekNumber: newWeekNumber ?? this.newWeekNumber,
      newDayOfWeek: newDayOfWeek ?? this.newDayOfWeek,
      newStartSection: newStartSection ?? this.newStartSection,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'original_course_id': originalCourseId,
      'schedule_id': scheduleId,
      'original_week_number': originalWeekNumber,
      'new_week_number': newWeekNumber,
      'new_day_of_week': newDayOfWeek,
      'new_start_section': newStartSection,
      'reason': reason,
    };
  }

  factory CourseAdjustment.fromMap(Map<String, dynamic> map) {
    return CourseAdjustment(
      id: map['id'] as int?,
      originalCourseId: map['original_course_id'] as int? ?? 0,
      scheduleId: map['schedule_id'] as int? ?? 0,
      originalWeekNumber: map['original_week_number'] as int? ?? 1,
      newWeekNumber: map['new_week_number'] as int?,
      newDayOfWeek: map['new_day_of_week'] as int?,
      newStartSection: map['new_start_section'] as int?,
      reason: map['reason'] as String? ?? '',
    );
  }
}
