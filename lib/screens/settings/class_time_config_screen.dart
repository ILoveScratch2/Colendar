import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/schedule_provider.dart';
import '../../models/class_time.dart';

class ClassTimeConfigScreen extends StatefulWidget {
  const ClassTimeConfigScreen({super.key});

  @override
  State<ClassTimeConfigScreen> createState() => _ClassTimeConfigScreenState();
}

class _ClassTimeConfigScreenState extends State<ClassTimeConfigScreen> {
  late List<ClassTimeEntry> _entries;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final sp = context.read<ScheduleProvider>();
    _entries = List.from(sp.classTimes);
  }

  Future<void> _save() async {
    final sp = context.read<ScheduleProvider>();
    final configName = sp.current?.classTimeConfigName ?? 'default';
    await sp.saveClassTimes(_entries, configName);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已保存')));
      setState(() => _dirty = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作息时间设置'),
        actions: [
          if (_dirty)
            TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (_, i) {
          final e = _entries[i];
          return ListTile(
            leading: CircleAvatar(
              radius: 14,
              child: Text('${e.sectionNumber}',
                  style: const TextStyle(fontSize: 12)),
            ),
            title: Text('第${e.sectionNumber}节'),
            subtitle: Text('${e.startTime} — ${e.endTime}'),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: () => _editEntry(i, e),
          );
        },
      ),
    );
  }

  void _editEntry(int index, ClassTimeEntry entry) {
    showDialog(
      context: context,
      builder: (_) => _TimeEditDialog(
        entry: entry,
        onSave: (updated) {
          setState(() {
            _entries[index] = updated;
            _dirty = true;
          });
        },
      ),
    );
  }
}

class _TimeEditDialog extends StatefulWidget {
  final ClassTimeEntry entry;
  final ValueChanged<ClassTimeEntry> onSave;
  const _TimeEditDialog({required this.entry, required this.onSave});

  @override
  State<_TimeEditDialog> createState() => _TimeEditDialogState();
}

class _TimeEditDialogState extends State<_TimeEditDialog> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    _start = _parseTime(widget.entry.startTime);
    _end = _parseTime(widget.entry.endTime);
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('第${widget.entry.sectionNumber}节时间'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('开始时间'),
            trailing: Text(_fmt(_start)),
            onTap: () async {
              final t = await showTimePicker(
                  context: context, initialTime: _start);
              if (t != null) setState(() => _start = t);
            },
          ),
          ListTile(
            title: const Text('结束时间'),
            trailing: Text(_fmt(_end)),
            onTap: () async {
              final t =
                  await showTimePicker(context: context, initialTime: _end);
              if (t != null) setState(() => _end = t);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消')),
        FilledButton(
          onPressed: () {
            widget.onSave(widget.entry.copyWith(
              startTime: _fmt(_start),
              endTime: _fmt(_end),
            ));
            Navigator.pop(context);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
