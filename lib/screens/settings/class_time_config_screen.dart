import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/schedule_provider.dart';
import '../../providers/settings_provider.dart';
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
    final sp = context.watch<ScheduleProvider>();
    final settings = context.watch<SettingsProvider>();
    final entries = sp.classTimes;
    _entries = List.from(entries);

    final morning = entries
        .where((e) => e.sectionNumber <= settings.morningSections)
        .toList()
      ..sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
    final afternoon = entries
        .where((e) =>
            e.sectionNumber > settings.morningSections &&
            e.sectionNumber <= settings.totalSections)
        .toList()
      ..sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));

    final maxCourseSection = sp.getMaxCourseSection();
    final totalSections = settings.totalSections;
    final hasWarning = maxCourseSection > 0 && totalSections < maxCourseSection;

    return Scaffold(
      appBar: AppBar(
        title: const Text('作息时间设置'),
        actions: [
          if (_dirty)
            TextButton(onPressed: _save, child: const Text('保存')),
          PopupMenuButton<String>(
            tooltip: '更多',
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'reset', child: Text('重置为默认')),
            ],
            onSelected: (v) {
              if (v == 'reset') _resetToDefault();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _ConfigTile(
                    icon: Icons.timer_outlined,
                    title: '课程时长',
                    subtitle: '设置每节课的上课时间长度',
                    value: '${settings.classDuration}分钟',
                    onTap: () => _showDurationDialog(
                        '课程时长', settings.classDuration, 30, 120, (v) {
                      settings.setClassDuration(v);
                      _regenerateTimes(settings);
                    }),
                  ),
                  const Divider(),
                  _ConfigTile(
                    icon: Icons.coffee_outlined,
                    title: '课间时长',
                    subtitle: '设置课间休息时间',
                    value: '${settings.breakDuration}分钟',
                    onTap: () => _showDurationDialog(
                        '课间时长', settings.breakDuration, 1, 60, (v) {
                      settings.setBreakDuration(v);
                      _regenerateTimes(settings);
                    }),
                  ),
                  const Divider(),
                  _ConfigTile(
                    icon: Icons.wb_sunny_outlined,
                    title: '上午节次数',
                    subtitle: '设置上午的课程节数',
                    value: '${settings.morningSections}节',
                    onTap: () => _showSectionDialog(
                      '上午节次数',
                      settings.morningSections,
                      maxCourseSection - settings.afternoonSections,
                      settings,
                      (v) {
                        settings.setMorningSections(v);
                        _regenerateTimes(settings);
                      },
                    ),
                  ),
                  const Divider(),
                  _ConfigTile(
                    icon: Icons.nights_stay_outlined,
                    title: '下午节次数',
                    subtitle: '设置下午的课程节数',
                    value: '${settings.afternoonSections}节',
                    onTap: () => _showSectionDialog(
                      '下午节次数',
                      settings.afternoonSections,
                      maxCourseSection - settings.morningSections,
                      settings,
                      (v) {
                        settings.setAfternoonSections(v);
                        _regenerateTimes(settings);
                      },
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('统一时长'),
                    subtitle: const Text('开启后修改任一节课时间将应用到全部节次',
                        style: TextStyle(fontSize: 12)),
                    value: settings.uniformDuration,
                    onChanged: (v) => settings.setUniformDuration(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (hasWarning)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '当前课表存在第${maxCourseSection}节的课程，但总节次仅设为${totalSections}节，部分课程可能无法正常显示',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (morning.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('上午',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            ...morning.map((e) => _TimeEntryTile(
                  entry: e,
                  onTap: () => _editEntry(e, settings),
                )),
            const SizedBox(height: 16),
          ],
          if (afternoon.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('下午',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            ...afternoon.map((e) => _TimeEntryTile(
                  entry: e,
                  onTap: () => _editEntry(e, settings),
                )),
          ],
        ],
      ),
    );
  }

  void _regenerateTimes(SettingsProvider settings) {
    final sp = context.read<ScheduleProvider>();
    final configName = sp.current?.classTimeConfigName ?? 'default';
    sp.regenerateClassTimes(
      classDuration: settings.classDuration,
      breakDuration: settings.breakDuration,
      morningSections: settings.morningSections,
      afternoonSections: settings.afternoonSections,
      configName: configName,
      startHour: 8,
      startMinute: 0,
      afternoonStartHour: 14,
      afternoonStartMinute: 0,
    );
    setState(() => _dirty = true);
  }

  void _editEntry(ClassTimeEntry entry, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _TimeEditSheet(
        entry: entry,
        uniformDuration: settings.uniformDuration,
        classDuration: settings.classDuration,
        breakDuration: settings.breakDuration,
        onSave: (updated) {
          setState(() {
            final idx = _entries.indexWhere((e) => e.id == updated.id);
            if (idx >= 0) {
              _entries[idx] = updated;
            }
            _dirty = true;
          });
          if (settings.uniformDuration) {
            _applyUniformDuration(updated, settings);
          } else {
            final sp = context.read<ScheduleProvider>();
            sp.adjustSubsequentClassTimes(updated.sectionNumber);
          }
        },
      ),
    );
  }

  void _applyUniformDuration(
      ClassTimeEntry changed, SettingsProvider settings) {
    final duration =
        _parseMinutes(changed.endTime) - _parseMinutes(changed.startTime);
    final sorted = List<ClassTimeEntry>.from(_entries)
      ..sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));

    for (int i = 0; i < sorted.length; i++) {
      final newStart = i == 0
          ? _parseMinutes(changed.startTime)
          : _parseMinutes(sorted[i - 1].endTime) + settings.breakDuration;
      sorted[i] = sorted[i].copyWith(
        startTime: _minutesToStr(newStart),
        endTime: _minutesToStr(newStart + duration),
      );
    }
    setState(() {
      _entries = sorted;
      _dirty = true;
    });
  }

  void _resetToDefault() {
    final defaults = _defaultTimes();
    setState(() {
      _entries = defaults;
      _dirty = true;
    });
  }

  List<ClassTimeEntry> _defaultTimes() {
    return [
      _makeEntry(1, '08:00', '08:45'),
      _makeEntry(2, '08:55', '09:40'),
      _makeEntry(3, '10:00', '10:45'),
      _makeEntry(4, '10:55', '11:40'),
      _makeEntry(5, '14:00', '14:45'),
      _makeEntry(6, '14:55', '15:40'),
      _makeEntry(7, '16:00', '16:45'),
      _makeEntry(8, '16:55', '17:40'),
      _makeEntry(9, '19:00', '19:45'),
      _makeEntry(10, '19:55', '20:40'),
    ];
  }

  ClassTimeEntry _makeEntry(int section, String start, String end) {
    return ClassTimeEntry(
        sectionNumber: section, startTime: start, endTime: end);
  }

  int _parseMinutes(String t) {
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToStr(int m) {
    final h = (m ~/ 60) % 24;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  void _showDurationDialog(
      String title, int current, int min, int max, ValueChanged<int> onConfirm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        int selected = current;
        return StatefulBuilder(builder: (ctx, setSt) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  title == '课程时长' ? '设置每节课的上课时间长度' : '设置每节课之间的休息时间',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: selected > min
                          ? () => setSt(() => selected--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('$selected',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                    ),
                    IconButton.filled(
                      onPressed: selected < max
                          ? () => setSt(() => selected++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Text('分钟', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  title == '课程时长' ? '建议设置40-50分钟' : '建议设置5-20分钟',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          onConfirm(selected);
                          Navigator.pop(ctx);
                        },
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showSectionDialog(String title, int current, int minAllowed,
      SettingsProvider settings, ValueChanged<int> onConfirm) {
    final maxCourseSection =
        context.read<ScheduleProvider>().getMaxCourseSection();
    final otherSections = title.contains('上午')
        ? settings.afternoonSections
        : settings.morningSections;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        int selected = current;
        return StatefulBuilder(builder: (ctx, setSt) {
          final totalAfter = selected + otherSections;
          final isBelowMin =
              maxCourseSection > 0 && totalAfter < maxCourseSection;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('系统会根据设置自动生成课程时间表',
                    style: Theme.of(context).textTheme.bodySmall),
                if (maxCourseSection > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isBelowMin
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '当前课表课程最大节次：第${maxCourseSection}节\n'
                      '合计${totalAfter}节（上午${title.contains("上午") ? selected : otherSections}'
                      '+下午${title.contains("上午") ? otherSections : selected}）',
                      style: TextStyle(
                        fontSize: 12,
                        color: isBelowMin
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: selected > (minAllowed > 0 ? minAllowed : 0)
                          ? () => setSt(() => selected--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text('$selected',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                    ),
                    IconButton.filled(
                      onPressed: selected < 14
                          ? () => setSt(() => selected++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Text('节', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  minAllowed > 0
                      ? '当前课表至少需要${minAllowed}节${title.contains("上午") ? "上午" : "下午"}课程'
                      : '设置为0表示没有${title.contains("上午") ? "上午" : "下午"}课程',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: isBelowMin
                            ? null
                            : () {
                                onConfirm(selected);
                                Navigator.pop(ctx);
                              },
                        child: const Text('确定'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;
  const _ConfigTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(value,
          style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      onTap: onTap,
    );
  }
}

class _TimeEntryTile extends StatelessWidget {
  final ClassTimeEntry entry;
  final VoidCallback onTap;
  const _TimeEntryTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          child:
              Text('${entry.sectionNumber}', style: const TextStyle(fontSize: 12)),
        ),
        title: Text('第${entry.sectionNumber}节'),
        subtitle: Text('${entry.startTime} — ${entry.endTime}'),
        trailing: const Icon(Icons.edit, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class _TimeEditSheet extends StatefulWidget {
  final ClassTimeEntry entry;
  final bool uniformDuration;
  final int classDuration;
  final int breakDuration;
  final ValueChanged<ClassTimeEntry> onSave;

  const _TimeEditSheet({
    required this.entry,
    required this.uniformDuration,
    required this.classDuration,
    required this.breakDuration,
    required this.onSave,
  });

  @override
  State<_TimeEditSheet> createState() => _TimeEditSheetState();
}

class _TimeEditSheetState extends State<_TimeEditSheet> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    _start = _parse(widget.entry.startTime);
    _end = _parse(widget.entry.endTime);
  }

  TimeOfDay _parse(String t) {
    final parts = t.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  @override
  Widget build(BuildContext context) {
    final duration = _minutes(_end) - _minutes(_start);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('编辑第${widget.entry.sectionNumber}节时间',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (widget.uniformDuration) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '统一时长模式：修改此节次时间将应用到所有节次',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text('本节 $duration 分钟',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('开始时间'),
            trailing: Text(_fmt(_start),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            onTap: () async {
              final t =
                  await showTimePicker(context: context, initialTime: _start);
              if (t != null) setState(() => _start = t);
            },
          ),
          ListTile(
            title: const Text('结束时间'),
            trailing: Text(_fmt(_end),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            onTap: () async {
              final t =
                  await showTimePicker(context: context, initialTime: _end);
              if (t != null) setState(() => _end = t);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onSave(widget.entry.copyWith(
                      startTime: _fmt(_start),
                      endTime: _fmt(_end),
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('确定'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
