import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class SemesterManagementScreen extends StatelessWidget {
  const SemesterManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('学期管理')),
      body: sp.schedules.isEmpty
          ? const Center(child: Text('还没有学期，点击下方添加'))
          : ListView(
              children: sp.schedules.map((s) {
                final isCurrent = s.id == sp.current?.id;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text(s.name),
                    subtitle: Text(
                        '${_fmt(s.startDate)} — ${_fmt(s.endDate)}  共${s.totalWeeks}周'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent)
                          const Chip(
                              label: Text('当前',
                                  style: TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _showEditDialog(context, sp, schedule: s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _confirmDelete(context, sp, s),
                        ),
                      ],
                    ),
                    onTap: isCurrent
                        ? null
                        : () async {
                            await sp.switchSchedule(s.id!);
                            if (context.mounted) context.pop();
                          },
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, sp),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  void _confirmDelete(
      BuildContext context, ScheduleProvider sp, Schedule s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除学期'),
        content: Text('删除「${s.name}」及其所有课程？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await sp.deleteSchedule(s.id!);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ScheduleProvider sp,
      {Schedule? schedule}) {
    showDialog(
      context: context,
      builder: (_) => _ScheduleEditDialog(schedule: schedule, sp: sp),
    );
  }
}

class _ScheduleEditDialog extends StatefulWidget {
  final Schedule? schedule;
  final ScheduleProvider sp;
  const _ScheduleEditDialog({this.schedule, required this.sp});

  @override
  State<_ScheduleEditDialog> createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<_ScheduleEditDialog> {
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  int _totalWeeks = 20;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nameCtrl.text = s?.name ?? '';
    _schoolCtrl.text = s?.schoolName ?? '';
    _startDate = s?.startDate ?? DateTime.now();
    _endDate = s?.endDate ??
        DateTime.now().add(const Duration(days: 140));
    _totalWeeks = s?.totalWeeks ?? 20;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule == null ? '新建学期' : '编辑学期'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: '学期名称', hintText: '如：2024春季学期'),
            ),
            TextField(
              controller: _schoolCtrl,
              decoration: const InputDecoration(labelText: '学校（可选）'),
            ),
            const SizedBox(height: 12),
            _DateRow(
              label: '开学日期',
              date: _startDate,
              onPick: (d) => setState(() {
                _startDate = d;
                // Auto-calculate end date
                _endDate = d.add(Duration(days: _totalWeeks * 7));
              }),
            ),
            _DateRow(
              label: '结束日期',
              date: _endDate,
              onPick: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('总周数')),
                DropdownButton<int>(
                  value: _totalWeeks,
                  items: List.generate(25, (i) => i + 8)
                      .map((v) =>
                          DropdownMenuItem(value: v, child: Text('$v 周')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _totalWeeks = v;
                        _endDate = _startDate.add(Duration(days: v * 7));
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消')),
        FilledButton(
          onPressed: () async {
            if (_nameCtrl.text.trim().isEmpty) return;
            final schedule = Schedule(
              id: widget.schedule?.id,
              name: _nameCtrl.text.trim(),
              schoolName: _schoolCtrl.text.trim(),
              startDate: _startDate,
              endDate: _endDate,
              totalWeeks: _totalWeeks,
              isCurrent: widget.schedule?.isCurrent ?? false,
            );
            if (widget.schedule == null) {
              await widget.sp.addSchedule(schedule);
            } else {
              await widget.sp.updateSchedule(schedule);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;
  const _DateRow(
      {required this.label, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final text =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(child: Text(label)),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null) onPick(picked);
          },
          child: Text(text),
        ),
      ],
    );
  }
}
