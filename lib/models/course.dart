class Course {
  final int? id;
  final String courseName;
  final String teacher;
  final String classroom;
  final int dayOfWeek; // 1=Mon ... 7=Sun
  final int startSection;
  final int sectionCount;
  final List<int> weeks;
  final int scheduleId;
  final String color; // hex color string e.g. "#5B9BD5"
  final bool reminderEnabled;
  final int reminderMinutes;
  final String note;
  final String courseCode;
  final double credit;

  const Course({
    this.id,
    required this.courseName,
    this.teacher = '',
    this.classroom = '',
    required this.dayOfWeek,
    required this.startSection,
    this.sectionCount = 2,
    required this.weeks,
    required this.scheduleId,
    this.color = '#5B9BD5',
    this.reminderEnabled = false,
    this.reminderMinutes = 15,
    this.note = '',
    this.courseCode = '',
    this.credit = 0.0,
  });

  Course copyWith({
    int? id,
    String? courseName,
    String? teacher,
    String? classroom,
    int? dayOfWeek,
    int? startSection,
    int? sectionCount,
    List<int>? weeks,
    int? scheduleId,
    String? color,
    bool? reminderEnabled,
    int? reminderMinutes,
    String? note,
    String? courseCode,
    double? credit,
  }) {
    return Course(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      sectionCount: sectionCount ?? this.sectionCount,
      weeks: weeks ?? this.weeks,
      scheduleId: scheduleId ?? this.scheduleId,
      color: color ?? this.color,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      note: note ?? this.note,
      courseCode: courseCode ?? this.courseCode,
      credit: credit ?? this.credit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'course_name': courseName,
      'teacher': teacher,
      'classroom': classroom,
      'day_of_week': dayOfWeek,
      'start_section': startSection,
      'section_count': sectionCount,
      'weeks': weeks.join(','),
      'schedule_id': scheduleId,
      'color': color,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_minutes': reminderMinutes,
      'note': note,
      'course_code': courseCode,
      'credit': credit,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    final weeksStr = map['weeks'] as String? ?? '';
    final weeks = weeksStr.isEmpty
        ? <int>[]
        : weeksStr.split(',').map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
    return Course(
      id: map['id'] as int?,
      courseName: map['course_name'] as String? ?? '',
      teacher: map['teacher'] as String? ?? '',
      classroom: map['classroom'] as String? ?? '',
      dayOfWeek: map['day_of_week'] as int? ?? 1,
      startSection: map['start_section'] as int? ?? 1,
      sectionCount: map['section_count'] as int? ?? 2,
      weeks: weeks,
      scheduleId: map['schedule_id'] as int? ?? 0,
      color: map['color'] as String? ?? '#5B9BD5',
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderMinutes: map['reminder_minutes'] as int? ?? 15,
      note: map['note'] as String? ?? '',
      courseCode: map['course_code'] as String? ?? '',
      credit: (map['credit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
