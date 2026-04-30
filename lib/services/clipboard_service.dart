import 'package:flutter/services.dart';

import '../models/course.dart';

class ClipboardService {
  /// Copy course info as text to system clipboard
  static Future<void> copyCourseText(Course course) async {
    final buffer = StringBuffer();
    buffer.writeln(course.courseName);
    if (course.teacher.isNotEmpty) buffer.writeln('教师: ${course.teacher}');
    if (course.classroom.isNotEmpty) buffer.writeln('教室: ${course.classroom}');
    buffer.writeln(
        '时间: 周${["", "一", "二", "三", "四", "五", "六", "日"][course.dayOfWeek]} '
        '第${course.startSection}-${course.startSection + course.sectionCount - 1}节');
    buffer.writeln('周次: ${course.weeks.join(", ")}');
    if (course.courseCode.isNotEmpty) buffer.writeln('代码: ${course.courseCode}');
    if (course.note.isNotEmpty) buffer.writeln('备注: ${course.note}');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }
}
