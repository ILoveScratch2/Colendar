import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../models/course.dart';
import '../../utils/course_color_palette.dart';
import '../../utils/week_parser.dart';
import '../../utils/date_utils.dart' as du;

class CourseDetailScreen extends StatelessWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final courseList = sp.courses.where((c) => c.id == courseId).toList();

    if (courseList.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('课程不存在')),
      );
    }

    final course = courseList.first;
    final color = CourseColorPalette.colorFromHex(course.color);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(course.courseName,
                  style: const TextStyle(color: Colors.white)),
              background: Container(color: color),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/course/${course.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, sp, course),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _InfoTile(Icons.person_outline, '教师', course.teacher),
              _InfoTile(Icons.room_outlined, '教室', course.classroom),
              _InfoTile(
                  Icons.calendar_today_outlined,
                  '上课时间',
                  '${du.DateUtils.dayName(course.dayOfWeek)} '
                      '第${course.startSection}-${course.startSection + course.sectionCount - 1}节'),
              _InfoTile(
                Icons.date_range_outlined,
                '上课周次',
                WeekParser.format(course.weeks),
              ),
              if (course.note.isNotEmpty)
                _InfoTile(Icons.notes_outlined, '备注', course.note),
              _ReminderTile(course: course),
              const SizedBox(height: 24),
              // Adjustments for this course
              _AdjustmentsSection(courseId: courseId),
            ]),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ScheduleProvider sp, Course course) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除课程'),
        content: Text('确定要删除「${course.courseName}」吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await sp.deleteCourse(course.id!);
              if (context.mounted) context.pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Course course;
  const _ReminderTile({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: const Text('提醒', style: TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        course.reminderEnabled
            ? '上课前 ${course.reminderMinutes} 分钟'
            : '未开启',
      ),
    );
  }
}

class _AdjustmentsSection extends StatelessWidget {
  final int courseId;
  const _AdjustmentsSection({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final adjs =
        sp.adjustments.where((a) => a.originalCourseId == courseId).toList();

    if (adjs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('调课记录',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary)),
        ),
        ...adjs.map((adj) => ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(adj.reason.isNotEmpty ? adj.reason : '调课'),
              subtitle: Text(
                adj.newWeekNumber != null
                    ? '第${adj.originalWeekNumber}周 → 第${adj.newWeekNumber}周'
                    : '第${adj.originalWeekNumber}周 已取消',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => sp.deleteAdjustment(adj.id!),
              ),
            )),
      ],
    );
  }
}
