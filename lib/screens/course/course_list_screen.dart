import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../utils/course_color_palette.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/week_parser.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final courses = sp.courses;

    // Group by day
    final Map<int, List<dynamic>> byDay = {};
    for (final c in courses) {
      byDay.putIfAbsent(c.dayOfWeek, () => []).add(c);
    }
    final sortedDays = byDay.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('全部课程（${courses.length}门）'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.push('/course/new?scheduleId=${sp.current?.id}'),
          ),
        ],
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text('还没有课程，点击右上角添加'),
            )
          : ListView(
              children: sortedDays.expand((day) {
                final dayCourses = byDay[day]!;
                return [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      du.DateUtils.dayName(day),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  ...dayCourses.map((c) => _CourseListTile(course: c)),
                ];
              }).toList(),
            ),
    );
  }
}

class _CourseListTile extends StatelessWidget {
  final dynamic course;
  const _CourseListTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final color = CourseColorPalette.colorFromHex(course.color as String);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            (course.courseName as String).isNotEmpty
                ? (course.courseName as String).substring(0, 1)
                : '?',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        title: Text(course.courseName as String),
        subtitle: Text(
          '${du.DateUtils.dayName(course.dayOfWeek as int)} '
          '第${course.startSection}-${(course.startSection as int) + (course.sectionCount as int) - 1}节  '
          '${WeekParser.format(course.weeks as List<int>)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: course.classroom != null && (course.classroom as String).isNotEmpty
            ? Text(course.classroom as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey))
            : null,
        onTap: () => context.push('/course/${course.id}'),
      ),
    );
  }
}
