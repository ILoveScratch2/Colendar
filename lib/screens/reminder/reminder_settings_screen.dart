import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../services/notification_service.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final sp = context.watch<ScheduleProvider>();
    final activeCount = sp.getActiveReminderCount();

    return Scaffold(
      appBar: AppBar(title: const Text('提醒设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('启用提醒'),
                  subtitle: const Text('关闭后所有课程提醒将暂停'),
                  value: settings.reminderEnabled,
                  onChanged: (v) => settings.setReminderEnabled(v),
                ),
                const Divider(indent: 72),
                ListTile(
                  title: const Text('默认提前时间'),
                  subtitle: const Text('新课程默认提前多久提醒'),
                  trailing: DropdownButton<int>(
                    value: settings.defaultReminderMinutes,
                    items: [5, 10, 15, 20, 30, 45, 60]
                        .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('${m}分钟')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) settings.setDefaultReminderMinutes(v);
                    },
                  ),
                ),
                const Divider(indent: 72),
                SwitchListTile(
                  title: const Text('Heads-Up通知'),
                  subtitle: const Text('弹出式通知，更显眼'),
                  value: settings.headsUpNotification,
                  onChanged: (v) => settings.setHeadsUpNotification(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_active,
                      color: Theme.of(context).colorScheme.primary),
                  title: const Text('活跃提醒'),
                  trailing: Text('${activeCount}个',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                const Divider(indent: 16),
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: const Text('测试通知'),
                  subtitle: const Text('发送一条测试通知'),
                  onTap: () async {
                    final ns = NotificationService();
                    await ns.showImmediateNotification(
                      id: 9999,
                      title: '测试通知',
                      body: '如果你看到这条消息，说明通知功能正常工作！',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('测试通知已发送')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('通知权限'),
                  subtitle: const Text('确保通知权限已开启'),
                  trailing: FilledButton.tonal(
                    onPressed: () async {
                      final ns = NotificationService();
                      final granted = await ns.requestPermission();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(granted ? '权限已获取' : '权限被拒绝')),
                        );
                      }
                    },
                    child: const Text('检查权限'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ReminderManagementScreen()),
            ),
            icon: const Icon(Icons.list_alt),
            label: const Text('管理所有提醒'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class ReminderManagementScreen extends StatelessWidget {
  const ReminderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final reminders = sp.reminders;

    return Scaffold(
      appBar: AppBar(title: const Text('提醒管理')),
      body: reminders.isEmpty
          ? const Center(child: Text('暂无提醒', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (_, i) {
                final r = reminders[i];
                final course = sp.courses.firstWhere(
                  (c) => c.id == r.courseId,
                  orElse: () => sp.courses.first,
                );
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Color(int.tryParse(course.color) ?? 0xFF5B9BD5)
                              .withValues(alpha: 0.2),
                      child: Text(course.courseName[0],
                          style: TextStyle(
                              color: Color(
                                  int.tryParse(course.color) ?? 0xFF5B9BD5))),
                    ),
                    title: Text(course.courseName),
                    subtitle: Text(
                      '第${r.weekNumber}周 周${["", "一", "二", "三", "四", "五", "六", "日"][r.dayOfWeek]} '
                      '提前${r.minutesBefore}分钟',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.isEnabled,
                          onChanged: (v) => sp.toggleReminder(r.id!, v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => sp.deleteReminder(r.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
