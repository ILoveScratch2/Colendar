class ClassTimeEntry {
  final int? id;
  final int sectionNumber;
  final String startTime; // "08:00"
  final String endTime; // "08:45"
  final String configName;

  const ClassTimeEntry({
    this.id,
    required this.sectionNumber,
    required this.startTime,
    required this.endTime,
    this.configName = 'default',
  });

  ClassTimeEntry copyWith({
    int? id,
    int? sectionNumber,
    String? startTime,
    String? endTime,
    String? configName,
  }) {
    return ClassTimeEntry(
      id: id ?? this.id,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      configName: configName ?? this.configName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'section_number': sectionNumber,
      'start_time': startTime,
      'end_time': endTime,
      'config_name': configName,
    };
  }

  factory ClassTimeEntry.fromMap(Map<String, dynamic> map) {
    return ClassTimeEntry(
      id: map['id'] as int?,
      sectionNumber: map['section_number'] as int? ?? 1,
      startTime: map['start_time'] as String? ?? '08:00',
      endTime: map['end_time'] as String? ?? '08:45',
      configName: map['config_name'] as String? ?? 'default',
    );
  }
}
