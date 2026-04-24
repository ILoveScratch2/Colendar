class Schedule {
  final int? id;
  final String name;
  final String schoolName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalWeeks;
  final bool isCurrent;
  final String classTimeConfigName;

  const Schedule({
    this.id,
    required this.name,
    this.schoolName = '',
    required this.startDate,
    required this.endDate,
    this.totalWeeks = 20,
    this.isCurrent = false,
    this.classTimeConfigName = 'default',
  });

  Schedule copyWith({
    int? id,
    String? name,
    String? schoolName,
    DateTime? startDate,
    DateTime? endDate,
    int? totalWeeks,
    bool? isCurrent,
    String? classTimeConfigName,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolName: schoolName ?? this.schoolName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      isCurrent: isCurrent ?? this.isCurrent,
      classTimeConfigName: classTimeConfigName ?? this.classTimeConfigName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'school_name': schoolName,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
      'total_weeks': totalWeeks,
      'is_current': isCurrent ? 1 : 0,
      'class_time_config_name': classTimeConfigName,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      schoolName: map['school_name'] as String? ?? '',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      totalWeeks: map['total_weeks'] as int? ?? 20,
      isCurrent: (map['is_current'] as int? ?? 0) == 1,
      classTimeConfigName: map['class_time_config_name'] as String? ?? 'default',
    );
  }
}
