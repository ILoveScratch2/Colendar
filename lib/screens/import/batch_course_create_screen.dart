import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../models/course.dart';
import '../../utils/week_parser.dart';
import '../../utils/course_color_palette.dart';
import '../../utils/constants.dart';

/// Batch course creation (manual import) screen.
/// Users can input multiple courses at once in a table-like form.
class BatchCourseCreateScreen extends StatefulWidget {
  const BatchCourseCreateScreen({super.key});

  @override
  State<BatchCourseCreateScreen> createState() =>
      _BatchCourseCreateScreenState();
}

class _BatchCourseCreateScreenState extends State<BatchCourseCreateScreen> {
  final List<_CourseEntry> _entries = [_CourseEntry()];
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('批量添加课程'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveAll,
            child: const Text('全部保存'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _entries.length + 1,
        itemBuilder: (_, i) {
          if (i == _entries.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _entries.add(_CourseEntry())),
                icon: const Icon(Icons.add),
                label: const Text('添加一行'),
              ),
            );
          }
          return _CourseEntryRow(
            key: ValueKey(_entries[i].id),
            entry: _entries[i],
            index: i,
            onDelete: () => setState(() => _entries.removeAt(i)),
          );
        },
      ),
    );
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    final sp = context.read<ScheduleProvider>();
    final scheduleId = sp.current?.id;
    if (scheduleId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请先创建学期')));
      setState(() => _saving = false);
      return;
    }

    final usedColors = sp.courses.map((c) => c.color).toList();
    int saved = 0;
    for (final entry in _entries) {
      if (entry.name.trim().isEmpty) continue;
      final color = CourseColorPalette.getColorForCourse(entry.name, usedColors);
      usedColors.add(color);
      final course = Course(
        courseName: entry.name.trim(),
        teacher: entry.teacher.trim(),
        classroom: entry.classroom.trim(),
        dayOfWeek: entry.dayOfWeek,
        startSection: entry.startSection,
        sectionCount: entry.sectionCount,
        weeks: entry.weeks,
        scheduleId: scheduleId,
        color: color,
      );
      await sp.addCourse(course);
      saved++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已保存 $saved 门课程')));
      context.pop();
    }
  }
}

class _CourseEntry {
  static int _idCounter = 0;
  final int id = _idCounter++;
  String name = '';
  String teacher = '';
  String classroom = '';
  int dayOfWeek = 1;
  int startSection = 1;
  int sectionCount = 2;
  List<int> weeks = List.generate(20, (i) => i + 1);
}

class _CourseEntryRow extends StatefulWidget {
  final _CourseEntry entry;
  final int index;
  final VoidCallback onDelete;

  const _CourseEntryRow({
    super.key,
    required this.entry,
    required this.index,
    required this.onDelete,
  });

  @override
  State<_CourseEntryRow> createState() => _CourseEntryRowState();
}

class _CourseEntryRowState extends State<_CourseEntryRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _teacherCtrl;
  late final TextEditingController _roomCtrl;
  late final TextEditingController _weekCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.entry.name);
    _teacherCtrl = TextEditingController(text: widget.entry.teacher);
    _roomCtrl = TextEditingController(text: widget.entry.classroom);
    _weekCtrl = TextEditingController(
        text: WeekParser.format(widget.entry.weeks));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _teacherCtrl.dispose();
    _roomCtrl.dispose();
    _weekCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('课程 ${widget.index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: '课程名称 *',
                  isDense: true,
                  border: OutlineInputBorder()),
              onChanged: (v) => e.name = v,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teacherCtrl,
                    decoration: const InputDecoration(
                        labelText: '教师',
                        isDense: true,
                        border: OutlineInputBorder()),
                    onChanged: (v) => e.teacher = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _roomCtrl,
                    decoration: const InputDecoration(
                        labelText: '教室',
                        isDense: true,
                        border: OutlineInputBorder()),
                    onChanged: (v) => e.classroom = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('星期：', style: TextStyle(fontSize: 13)),
                ...List.generate(7, (i) {
                  final selected = e.dayOfWeek == i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => e.dayOfWeek = i + 1),
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(days[i],
                          style: TextStyle(
                              fontSize: 11,
                              color: selected ? Colors.white : null)),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('节次：', style: TextStyle(fontSize: 13)),
                DropdownButton<int>(
                  isDense: true,
                  value: e.startSection,
                  items: List.generate(AppConstants.maxSection, (i) => i + 1)
                      .map((v) => DropdownMenuItem(
                          value: v, child: Text('第$v节')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => e.startSection = v);
                  },
                ),
                const Text(' 共 ', style: TextStyle(fontSize: 13)),
                DropdownButton<int>(
                  isDense: true,
                  value: e.sectionCount,
                  items: List.generate(6, (i) => i + 1)
                      .map((v) => DropdownMenuItem(
                          value: v, child: Text('$v节')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => e.sectionCount = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weekCtrl,
                    decoration: const InputDecoration(
                        labelText: '周次（如 1-16）',
                        isDense: true,
                        border: OutlineInputBorder()),
                    onChanged: (v) {
                      e.weeks = WeekParser.parse(v);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
