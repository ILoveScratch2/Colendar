class CourseAdjustment {
  final int? id;
  final int originalCourseId;
  final int scheduleId;
  final int originalWeekNumber;
  final int originalDayOfWeek;
  final int originalStartSection;
  final int originalSectionCount;
  final int? newWeekNumber;
  final int? newDayOfWeek;
  final int? newStartSection;
  final int? newSectionCount;
  final String? newClassroom;
  final String reason;

  const CourseAdjustment({
    this.id,
    required this.originalCourseId,
    required this.scheduleId,
    required this.originalWeekNumber,
    this.originalDayOfWeek = 1,
    this.originalStartSection = 1,
    this.originalSectionCount = 2,
    this.newWeekNumber,
    this.newDayOfWeek,
    this.newStartSection,
    this.newSectionCount,
    this.newClassroom,
    this.reason = '',
  });

  bool get isCancelled => newWeekNumber == null && newDayOfWeek == null;

  CourseAdjustment copyWith({
    int? id,
    int? originalCourseId,
    int? scheduleId,
    int? originalWeekNumber,
    int? originalDayOfWeek,
    int? originalStartSection,
    int? originalSectionCount,
    int? newWeekNumber,
    int? newDayOfWeek,
    int? newStartSection,
    int? newSectionCount,
    String? newClassroom,
    String? reason,
  }) {
    return CourseAdjustment(
      id: id ?? this.id,
      originalCourseId: originalCourseId ?? this.originalCourseId,
      scheduleId: scheduleId ?? this.scheduleId,
      originalWeekNumber: originalWeekNumber ?? this.originalWeekNumber,
      originalDayOfWeek: originalDayOfWeek ?? this.originalDayOfWeek,
      originalStartSection: originalStartSection ?? this.originalStartSection,
      originalSectionCount: originalSectionCount ?? this.originalSectionCount,
      newWeekNumber: newWeekNumber ?? this.newWeekNumber,
      newDayOfWeek: newDayOfWeek ?? this.newDayOfWeek,
      newStartSection: newStartSection ?? this.newStartSection,
      newSectionCount: newSectionCount ?? this.newSectionCount,
      newClassroom: newClassroom ?? this.newClassroom,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'original_course_id': originalCourseId,
      'schedule_id': scheduleId,
      'original_week_number': originalWeekNumber,
      'original_day_of_week': originalDayOfWeek,
      'original_start_section': originalStartSection,
      'original_section_count': originalSectionCount,
      'new_week_number': newWeekNumber,
      'new_day_of_week': newDayOfWeek,
      'new_start_section': newStartSection,
      'new_section_count': newSectionCount,
      'new_classroom': newClassroom,
      'reason': reason,
    };
  }

  factory CourseAdjustment.fromMap(Map<String, dynamic> map) {
    return CourseAdjustment(
      id: map['id'] as int?,
      originalCourseId: map['original_course_id'] as int? ?? 0,
      scheduleId: map['schedule_id'] as int? ?? 0,
      originalWeekNumber: map['original_week_number'] as int? ?? 1,
      originalDayOfWeek: map['original_day_of_week'] as int? ?? 1,
      originalStartSection: map['original_start_section'] as int? ?? 1,
      originalSectionCount: map['original_section_count'] as int? ?? 2,
      newWeekNumber: map['new_week_number'] as int?,
      newDayOfWeek: map['new_day_of_week'] as int?,
      newStartSection: map['new_start_section'] as int?,
      newSectionCount: map['new_section_count'] as int?,
      newClassroom: map['new_classroom'] as String?,
      reason: map['reason'] as String? ?? '',
    );
  }
}
