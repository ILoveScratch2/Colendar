import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../models/exam.dart';

class AddExamScreen extends StatefulWidget {
  final int? courseId;
  const AddExamScreen({super.key, this.courseId});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedCourseId;
  ExamType _examType = ExamType.finalExam;
  int _weekNumber = 1;
  int? _dayOfWeek;
  int? _startSection;
  int? _sectionCount;
  DateTime? _examDateTime;
  final _locationCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  bool _reminderEnabled = false;
  int _reminderDays = 1;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
    final sp = context.read<ScheduleProvider>();
    _weekNumber = sp.currentWeek;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _seatCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final courses = sp.courses;

    return Scaffold(
      appBar: AppBar(title: const Text('添加考试')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.courseId == null)
              DropdownButtonFormField<int>(
                value: _selectedCourseId,
                decoration: const InputDecoration(
                  labelText: '选择课程',
                  border: OutlineInputBorder(),
                ),
                items: courses.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.courseName),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCourseId = v),
                validator: (v) => v == null ? '请选择课程' : null,
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExamType>(
              value: _examType,
              decoration: const InputDecoration(
                labelText: '考试类型',
                border: OutlineInputBorder(),
              ),
              items: ExamType.values.map((t) {
                return DropdownMenuItem(value: t, child: Text(t.label));
              }).toList(),
              onChanged: (v) => setState(() => _examType = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildIntField('周次', _weekNumber, (v) {
                    _weekNumber = v;
                    setState(() {});
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionalIntField('星期几', _dayOfWeek, 1, 7, (v) {
                    _dayOfWeek = v;
                    setState(() {});
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOptionalIntField(
                      '开始节次', _startSection, 1, 14, (v) {
                    _startSection = v;
                    setState(() {});
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionalIntField(
                      '节数', _sectionCount, 1, 6, (v) {
                    _sectionCount = v;
                    setState(() {});
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('考试时间'),
              subtitle: Text(_examDateTime != null
                  ? '${_examDateTime!.year}-${_examDateTime!.month.toString().padLeft(2, "0")}-${_examDateTime!.day.toString().padLeft(2, "0")} '
                      '${_examDateTime!.hour.toString().padLeft(2, "0")}:${_examDateTime!.minute.toString().padLeft(2, "0")}'
                  : '点击选择'),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (time != null) {
                    setState(() {
                      _examDateTime = DateTime(
                          date.year, date.month, date.day, time.hour, time.minute);
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: '考试地点',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seatCtrl,
              decoration: const InputDecoration(
                labelText: '座位号',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('考试提醒'),
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            if (_reminderEnabled)
              DropdownButtonFormField<int>(
                value: _reminderDays,
                decoration: const InputDecoration(
                  labelText: '提前几天提醒',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3, 5, 7, 14]
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text('提前 $d 天')))
                    .toList(),
                onChanged: (v) => setState(() => _reminderDays = v!),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('保存考试'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntField(
      String label, int value, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => onChanged(int.tryParse(v) ?? value),
    );
  }

  Widget _buildOptionalIntField(String label, int? value, int min, int max,
      ValueChanged<int?> onChanged) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: '$label (可选)',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed == null) {
          onChanged(null);
        } else if (parsed >= min && parsed <= max) {
          onChanged(parsed);
        }
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择课程')));
      return;
    }

    final sp = context.read<ScheduleProvider>();
    final course = sp.courses.firstWhere(
      (c) => c.id == _selectedCourseId,
      orElse: () => sp.courses.first,
    );

    final exam = Exam(
      courseId: _selectedCourseId!,
      courseName: course.courseName,
      examType: _examType,
      weekNumber: _weekNumber,
      dayOfWeek: _dayOfWeek,
      startSection: _startSection,
      sectionCount: _sectionCount,
      examTime: _examDateTime?.toIso8601String() ?? '',
      location: _locationCtrl.text,
      seat: _seatCtrl.text,
      reminderEnabled: _reminderEnabled,
      reminderDays: _reminderDays,
      note: _noteCtrl.text,
      createdAt: DateTime.now().toIso8601String(),
    );

    sp.addExam(exam);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('考试已添加')));
    context.pop();
  }
}
