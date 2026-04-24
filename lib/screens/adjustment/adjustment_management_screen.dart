import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/course.dart';
import '../../models/course_adjustment.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/course_color_palette.dart';

class AdjustmentManagementScreen extends StatelessWidget {
  const AdjustmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final adjustments = sp.adjustments;

    return Scaffold(
      appBar: AppBar(title: const Text('调课管理')),
      body: adjustments.isEmpty
          ? const Center(child: Text('暂无调课记录'))
          : ListView.builder(
              itemCount: adjustments.length,
              itemBuilder: (_, i) {
                final adj = adjustments[i];
                final course = sp.courses
                    .where((c) => c.id == adj.originalCourseId)
                    .firstOrNull;
                if (course == null) return const SizedBox.shrink();
                return _AdjustmentTile(
                    adj: adj, course: course, sp: sp);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, sp),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, ScheduleProvider sp) {
    showDialog(
      context: context,
      builder: (_) => _AddAdjustmentDialog(sp: sp),
    );
  }
}

class _AdjustmentTile extends StatelessWidget {
  final CourseAdjustment adj;
  final Course course;
  final ScheduleProvider sp;
  const _AdjustmentTile(
      {required this.adj, required this.course, required this.sp});

  @override
  Widget build(BuildContext context) {
    final color = CourseColorPalette.colorFromHex(course.color);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            course.courseName.isNotEmpty
                ? course.courseName.substring(0, 1)
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(course.courseName),
        subtitle: Text(
          adj.newWeekNumber != null
              ? '第${adj.originalWeekNumber}周 → 第${adj.newWeekNumber}周 ${du.DateUtils.dayName(adj.newDayOfWeek ?? course.dayOfWeek)}'
              : '第${adj.originalWeekNumber}周 已取消',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            await sp.deleteAdjustment(adj.id!);
          },
        ),
      ),
    );
  }
}

class _AddAdjustmentDialog extends StatefulWidget {
  final ScheduleProvider sp;
  const _AddAdjustmentDialog({required this.sp});

  @override
  State<_AddAdjustmentDialog> createState() => _AddAdjustmentDialogState();
}

class _AddAdjustmentDialogState extends State<_AddAdjustmentDialog> {
  Course? _selectedCourse;
  int _originalWeek = 1;
  bool _isCancelled = false;
  int? _newWeek;
  int? _newDay;
  int? _newStartSection;
  String _reason = '';

  @override
  Widget build(BuildContext context) {
    final sp = widget.sp;
    final courses = sp.courses;
    final totalWeeks = sp.current?.totalWeeks ?? 20;

    return AlertDialog(
      title: const Text('添加调课'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Course>(
              decoration: const InputDecoration(labelText: '课程'),
              items: courses
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.courseName)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCourse = v),
            ),
            const SizedBox(height: 8),
            _WeekDrop(
              label: '原始周次',
              value: _originalWeek,
              max: totalWeeks,
              onChanged: (v) => setState(() => _originalWeek = v),
            ),
            SwitchListTile(
              title: const Text('取消该次课'),
              value: _isCancelled,
              onChanged: (v) => setState(() => _isCancelled = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isCancelled) ...[
              _WeekDrop(
                label: '调至周次',
                value: _newWeek ?? _originalWeek,
                max: totalWeeks,
                onChanged: (v) => setState(() => _newWeek = v),
              ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: '调至星期'),
                initialValue: _newDay,
                items: List.generate(7, (i) => i + 1)
                    .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(du.DateUtils.dayName(d))))
                    .toList(),
                onChanged: (v) => setState(() => _newDay = v),
              ),
            ],
            TextField(
              decoration: const InputDecoration(labelText: '原因（可选）'),
              onChanged: (v) => _reason = v,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消')),
        FilledButton(
          onPressed: _selectedCourse == null
              ? null
              : () async {
                  final adj = CourseAdjustment(
                    originalCourseId: _selectedCourse!.id!,
                    scheduleId: sp.current!.id!,
                    originalWeekNumber: _originalWeek,
                    newWeekNumber: _isCancelled ? null : (_newWeek ?? _originalWeek),
                    newDayOfWeek: _isCancelled ? null : _newDay,
                    newStartSection: _isCancelled ? null : _newStartSection,
                    reason: _reason,
                  );
                  await sp.addAdjustment(adj);
                  if (context.mounted) Navigator.pop(context);
                },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _WeekDrop extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  const _WeekDrop(
      {required this.label,
      required this.value,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label),
      initialValue: value.clamp(1, max),
      items: List.generate(max, (i) => i + 1)
          .map((w) => DropdownMenuItem(value: w, child: Text('第$w周')))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
