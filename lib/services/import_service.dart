import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/course.dart';
import '../utils/course_color_palette.dart';

class ParsedCourse {
  final String courseName;
  final String teacher;
  final String classroom;
  final int dayOfWeek;
  final int startSection;
  final int sectionCount;
  final List<int> weeks;
  final String courseCode;
  final double credit;
  final String note;

  const ParsedCourse({
    required this.courseName,
    this.teacher = '',
    this.classroom = '',
    required this.dayOfWeek,
    required this.startSection,
    this.sectionCount = 2,
    required this.weeks,
    this.courseCode = '',
    this.credit = 0,
    this.note = '',
  });
}

class ImportService {
  Future<List<ParsedCourse>?> pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'ics'],
    );
    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);
    final content = await file.readAsString(encoding: utf8);
    final ext = result.files.first.extension?.toLowerCase() ?? 'json';

    switch (ext) {
      case 'json':
        return _parseJson(content);
      case 'ics':
        return _parseIcs(content);
      default:
        return _parseJson(content);
    }
  }

  List<ParsedCourse> _parseJson(String content) {
    final data = json.decode(content) as Map<String, dynamic>;
    final courses = data['courses'] as List<dynamic>?;
    if (courses == null) return [];

    return courses.map((c) {
      final weeksRaw = c['weeks'];
      List<int> weeks;
      if (weeksRaw is List) {
        weeks = weeksRaw.map<int>((e) => e as int).toList();
      } else if (weeksRaw is String) {
        weeks = weeksRaw
            .split(',')
            .map((s) => int.tryParse(s.trim()) ?? 1)
            .toList();
      } else {
        weeks = [1];
      }

      return ParsedCourse(
        courseName: c['courseName'] as String? ?? '',
        teacher: c['teacher'] as String? ?? '',
        classroom: c['classroom'] as String? ?? '',
        dayOfWeek: c['dayOfWeek'] as int? ?? 1,
        startSection: c['startSection'] as int? ?? 1,
        sectionCount: c['sectionCount'] as int? ?? 2,
        weeks: weeks,
        courseCode: c['courseCode'] as String? ?? '',
        credit: (c['credit'] as num?)?.toDouble() ?? 0,
        note: c['note'] as String? ?? '',
      );
    }).toList();
  }

  List<ParsedCourse> _parseIcs(String content) {
    final results = <ParsedCourse>[];
    final lines = content.split('\n');

    String? summary;
    String? location;
    String? description;
    String? rrule;

    for (final line in lines) {
      if (line.startsWith('SUMMARY:')) {
        summary = line.substring(8).trim();
      } else if (line.startsWith('LOCATION:')) {
        location = line.substring(9).trim();
      } else if (line.startsWith('DESCRIPTION:')) {
        description = line.substring(12).trim();
      } else if (line.startsWith('RRULE:')) {
        rrule = line.substring(6).trim();
      } else if (line.startsWith('END:VEVENT')) {
        if (summary != null && summary.isNotEmpty) {
          int weekCount = 18;
          if (rrule != null) {
            final match =
                RegExp(r'COUNT=(\d+)').firstMatch(rrule);
            if (match != null) {
              weekCount = int.tryParse(match.group(1)!) ?? 18;
            }
          }
          results.add(ParsedCourse(
            courseName: summary,
            classroom: location ?? '',
            teacher: description ?? '',
            dayOfWeek: 1,
            startSection: 1,
            sectionCount: 2,
            weeks: List.generate(weekCount, (i) => i + 1),
          ));
        }
        summary = null;
        location = null;
        description = null;
        rrule = null;
      }
    }

    return results;
  }

  List<Course> convertToCourses(
      List<ParsedCourse> parsed, int scheduleId, List<String> usedColors) {
    final result = <Course>[];

    for (final p in parsed) {
      final color = CourseColorPalette.getColorForCourse(
          p.courseName, usedColors);
      usedColors.add(color);

      result.add(Course(
        courseName: p.courseName,
        teacher: p.teacher,
        classroom: p.classroom,
        dayOfWeek: p.dayOfWeek,
        startSection: p.startSection,
        sectionCount: p.sectionCount,
        weeks: p.weeks,
        scheduleId: scheduleId,
        color: color,
        courseCode: p.courseCode,
        credit: p.credit,
        note: p.note,
      ));
    }

    return result;
  }
}
