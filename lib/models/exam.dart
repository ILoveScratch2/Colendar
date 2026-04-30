enum ExamType { midterm, finalExam, quiz, makeup }

extension ExamTypeExtension on ExamType {
  String get label {
    switch (this) {
      case ExamType.midterm:
        return '期中考试';
      case ExamType.finalExam:
        return '期末考试';
      case ExamType.quiz:
        return '测验';
      case ExamType.makeup:
        return '补考';
    }
  }

  static ExamType fromString(String s) {
    switch (s) {
      case 'midterm':
        return ExamType.midterm;
      case 'final':
        return ExamType.finalExam;
      case 'quiz':
        return ExamType.quiz;
      case 'makeup':
        return ExamType.makeup;
      default:
        return ExamType.finalExam;
    }
  }
}

class Exam {
  final int? id;
  final int courseId;
  final String courseName;
  final ExamType examType;
  final int weekNumber;
  final int? dayOfWeek;
  final int? startSection;
  final int? sectionCount;
  final String examTime;
  final String location;
  final String seat;
  final bool reminderEnabled;
  final int reminderDays;
  final String note;
  final String createdAt;

  const Exam({
    this.id,
    required this.courseId,
    required this.courseName,
    this.examType = ExamType.finalExam,
    required this.weekNumber,
    this.dayOfWeek,
    this.startSection,
    this.sectionCount,
    this.examTime = '',
    this.location = '',
    this.seat = '',
    this.reminderEnabled = false,
    this.reminderDays = 1,
    this.note = '',
    this.createdAt = '',
  });

  Exam copyWith({
    int? id,
    int? courseId,
    String? courseName,
    ExamType? examType,
    int? weekNumber,
    int? dayOfWeek,
    int? startSection,
    int? sectionCount,
    String? examTime,
    String? location,
    String? seat,
    bool? reminderEnabled,
    int? reminderDays,
    String? note,
    String? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      examType: examType ?? this.examType,
      weekNumber: weekNumber ?? this.weekNumber,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startSection: startSection ?? this.startSection,
      sectionCount: sectionCount ?? this.sectionCount,
      examTime: examTime ?? this.examTime,
      location: location ?? this.location,
      seat: seat ?? this.seat,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'exam_type': examType.name,
      'week_number': weekNumber,
      'day_of_week': dayOfWeek,
      'start_section': startSection,
      'section_count': sectionCount,
      'exam_time': examTime,
      'location': location,
      'seat': seat,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_days': reminderDays,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'] as int?,
      courseId: map['course_id'] as int? ?? 0,
      courseName: map['course_name'] as String? ?? '',
      examType: ExamTypeExtension.fromString(map['exam_type'] as String? ?? 'final'),
      weekNumber: map['week_number'] as int? ?? 1,
      dayOfWeek: map['day_of_week'] as int?,
      startSection: map['start_section'] as int?,
      sectionCount: map['section_count'] as int?,
      examTime: map['exam_time'] as String? ?? '',
      location: map['location'] as String? ?? '',
      seat: map['seat'] as String? ?? '',
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderDays: map['reminder_days'] as int? ?? 1,
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }
}
