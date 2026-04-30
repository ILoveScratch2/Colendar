import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/course.dart';

class ExportService {
  static const formats = ['json', 'ics', 'csv', 'txt'];

  static String formatName(String f) {
    switch (f) {
      case 'json':
        return 'JSON';
      case 'ics':
        return 'ICS (日历)';
      case 'csv':
        return 'CSV (表格)';
      case 'txt':
        return 'TXT (文本)';
      default:
        return f.toUpperCase();
    }
  }

  Future<void> exportCourses(
      List<Course> courses, String scheduleName, String format) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final filename =
        '${scheduleName}_export_$timestamp.$format';
    final file = File('${exportDir.path}/$filename');

    String content;
    switch (format) {
      case 'json':
        content = _exportJson(courses, scheduleName);
        break;
      case 'ics':
        content = _exportIcs(courses, scheduleName);
        break;
      case 'csv':
        content = _exportCsv(courses);
        break;
      case 'txt':
        content = _exportTxt(courses, scheduleName);
        break;
      default:
        content = _exportJson(courses, scheduleName);
    }

    await file.writeAsString(content, encoding: utf8);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  String _exportJson(List<Course> courses, String scheduleName) {
    final data = {
      'scheduleName': scheduleName,
      'exportDate': DateTime.now().toIso8601String(),
      'courseCount': courses.length,
      'courses': courses.map((c) => {
            'courseName': c.courseName,
            'teacher': c.teacher,
            'classroom': c.classroom,
            'dayOfWeek': c.dayOfWeek,
            'startSection': c.startSection,
            'sectionCount': c.sectionCount,
            'weeks': c.weeks,
            'color': c.color,
            'courseCode': c.courseCode,
            'credit': c.credit,
            'note': c.note,
          }).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _exportIcs(List<Course> courses, String scheduleName) {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCALENDAR');
    buf.writeln('VERSION:2.0');
    buf.writeln('PRODID:-//Colendar//CN');
    buf.writeln('X-WR-CALNAME:$scheduleName');

    for (final c in courses) {
      for (final week in c.weeks) {
        buf.writeln('BEGIN:VEVENT');
        buf.writeln('SUMMARY:${c.courseName}');
        if (c.classroom.isNotEmpty) {
          buf.writeln('LOCATION:${c.classroom}');
        }
        buf.writeln(
            'DESCRIPTION:教师: ${c.teacher}\\n节次: 第${c.startSection}-${c.startSection + c.sectionCount - 1}节');
        buf.writeln(
            'DTSTART:20240101T${(8 + (c.startSection - 1)).toString().padLeft(2, "0")}0000');
        buf.writeln(
            'DTEND:20240101T${(8 + c.startSection + c.sectionCount - 1).toString().padLeft(2, "0")}0000');
        buf.writeln('RRULE:FREQ=WEEKLY;COUNT=$week');
        buf.writeln('END:VEVENT');
      }
    }

    buf.writeln('END:VCALENDAR');
    return buf.toString();
  }

  String _exportCsv(List<Course> courses) {
    final buf = StringBuffer();
    buf.writeln('课程名称,教师,教室,星期,开始节次,节数,周次,课程代码,学分,备注');
    for (final c in courses) {
      buf.writeln(
          '"${c.courseName}","${c.teacher}","${c.classroom}",${c.dayOfWeek},${c.startSection},${c.sectionCount},"${c.weeks.join(",")}","${c.courseCode}",${c.credit},"${c.note}"');
    }
    return buf.toString();
  }

  String _exportTxt(List<Course> courses, String scheduleName) {
    final buf = StringBuffer();
    buf.writeln('课程表: $scheduleName');
    buf.writeln('导出时间: ${DateTime.now().toIso8601String()}');
    buf.writeln('共 ${courses.length} 门课程');
    buf.writeln('=' * 40);

    final dayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final sorted =
        List<Course>.from(courses)..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    for (final c in sorted) {
      buf.writeln('${dayNames[c.dayOfWeek]} 第${c.startSection}-${c.startSection + c.sectionCount - 1}节: ${c.courseName}');
      if (c.teacher.isNotEmpty) buf.writeln('  教师: ${c.teacher}');
      if (c.classroom.isNotEmpty) buf.writeln('  教室: ${c.classroom}');
      buf.writeln('  周次: ${c.weeks.join(", ")}');
      buf.writeln();
    }
    return buf.toString();
  }
}
