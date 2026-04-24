import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../models/course.dart';
import '../../utils/course_color_palette.dart';
import '../../utils/week_parser.dart';
import '../../utils/constants.dart';

/// Screen for creating or editing a course.
class CourseEditScreen extends StatefulWidget {
  final int? courseId; // null = create new
  final int? scheduleId; // required when creating new

  const CourseEditScreen({super.key, this.courseId, this.scheduleId});

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _teacherCtrl = TextEditingController();
  final _classroomCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _weekExprCtrl = TextEditingController();

  int _dayOfWeek = 1;
  int _startSection = 1;
  int _sectionCount = 2;
  List<int> _weeks = [];
  String _color = '#5B9BD5';
  bool _reminderEnabled = false;
  int _reminderMinutes = 15;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourse());
  }

  Future<void> _loadCourse() async {
    if (widget.courseId != null) {
      final sp = context.read<ScheduleProvider>();
      final course =
          sp.courses.firstWhere((c) => c.id == widget.courseId, orElse: () => _blankCourse());
      _populateFromCourse(course);
    } else {
      // New course defaults
      final sp = context.read<ScheduleProvider>();
      final totalWeeks = sp.current?.totalWeeks ?? 20;
      _weeks = List.generate(totalWeeks, (i) => i + 1);
      _weekExprCtrl.text = WeekParser.format(_weeks);
    }
    setState(() => _loading = false);
  }

  Course _blankCourse() => Course(
        courseName: '',
        dayOfWeek: 1,
        startSection: 1,
        weeks: [],
        scheduleId: widget.scheduleId ?? 0,
      );

  void _populateFromCourse(Course c) {
    _nameCtrl.text = c.courseName;
    _teacherCtrl.text = c.teacher;
    _classroomCtrl.text = c.classroom;
    _noteCtrl.text = c.note;
    _dayOfWeek = c.dayOfWeek;
    _startSection = c.startSection;
    _sectionCount = c.sectionCount;
    _weeks = List.from(c.weeks);
    _color = c.color;
    _reminderEnabled = c.reminderEnabled;
    _reminderMinutes = c.reminderMinutes;
    _weekExprCtrl.text = WeekParser.format(_weeks);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_weeks.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请设置上课周次')));
      return;
    }
    setState(() => _saving = true);
    final sp = context.read<ScheduleProvider>();
    final scheduleId = widget.courseId != null
        ? sp.courses
            .firstWhere((c) => c.id == widget.courseId)
            .scheduleId
        : (widget.scheduleId ?? sp.current!.id!);

    final course = Course(
      id: widget.courseId,
      courseName: _nameCtrl.text.trim(),
      teacher: _teacherCtrl.text.trim(),
      classroom: _classroomCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
      dayOfWeek: _dayOfWeek,
      startSection: _startSection,
      sectionCount: _sectionCount,
      weeks: _weeks,
      scheduleId: scheduleId,
      color: _color,
      reminderEnabled: _reminderEnabled,
      reminderMinutes: _reminderMinutes,
    );

    if (widget.courseId == null) {
      await sp.addCourse(course);
    } else {
      await sp.updateCourse(course);
    }
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _teacherCtrl.dispose();
    _classroomCtrl.dispose();
    _noteCtrl.dispose();
    _weekExprCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseId == null ? '新建课程' : '编辑课程'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ColorBar(color: _color, onTap: _pickColor),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: '课程名称 *', border: OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入课程名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _teacherCtrl,
              decoration: const InputDecoration(
                  labelText: '教师', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _classroomCtrl,
              decoration: const InputDecoration(
                  labelText: '教室', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _SectionTitle('上课时间'),
            const SizedBox(height: 8),
            _DayPicker(
              value: _dayOfWeek,
              onChange: (v) => setState(() => _dayOfWeek = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _IntDropdown(
                    label: '开始节次',
                    value: _startSection,
                    min: AppConstants.minSection,
                    max: AppConstants.maxSection,
                    onChanged: (v) => setState(() => _startSection = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntDropdown(
                    label: '节次数',
                    value: _sectionCount,
                    min: 1,
                    max: 6,
                    onChanged: (v) => setState(() => _sectionCount = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionTitle('上课周次'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weekExprCtrl,
              decoration: InputDecoration(
                labelText: '周次（如 1-16 或 1-8,10-16）',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _applyWeekExpr,
                ),
              ),
              onFieldSubmitted: (_) => _applyWeekExpr(),
            ),
            const SizedBox(height: 4),
            if (_weeks.isNotEmpty)
              Wrap(
                spacing: 4,
                children: _weeks
                    .map((w) => Chip(
                          label: Text('$w', style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            _SectionTitle('提醒'),
            SwitchListTile(
              title: const Text('开启提醒'),
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            if (_reminderEnabled)
              _IntDropdown(
                label: '提前提醒（分钟）',
                value: _reminderMinutes,
                options: const [5, 10, 15, 20, 30, 45, 60],
                onChanged: (v) => setState(() => _reminderMinutes = v),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                  labelText: '备注', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _applyWeekExpr() {
    setState(() {
      _weeks = WeekParser.parse(_weekExprCtrl.text);
    });
  }

  void _pickColor() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _ColorPicker(
        currentColor: _color,
        onSelect: (c) {
          setState(() => _color = c);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ColorBar extends StatelessWidget {
  final String color;
  final VoidCallback onTap;
  const _ColorBar({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: CourseColorPalette.colorFromHex(color),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text('点击选择颜色',
            style: TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String currentColor;
  final ValueChanged<String> onSelect;
  const _ColorPicker({required this.currentColor, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: CourseColorPalette.colors.map((hex) {
          final selected = hex == currentColor;
          return GestureDetector(
            onTap: () => onSelect(hex),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CourseColorPalette.colorFromHex(hex),
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600));
  }
}

class _DayPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChange;
  const _DayPicker({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: List.generate(7, (i) {
        final selected = value == i + 1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(i + 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  days[i],
                  style: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _IntDropdown extends StatelessWidget {
  final String label;
  final int value;
  final int? min;
  final int? max;
  final List<int>? options;
  final ValueChanged<int> onChanged;

  const _IntDropdown({
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = options ??
        List.generate((max! - min! + 1), (i) => min! + i);
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
      items: items
          .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
