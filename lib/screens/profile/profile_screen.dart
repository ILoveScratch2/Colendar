import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          // Summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sp.current?.name ?? '暂无学期',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '共 ${sp.courses.length} 门课程  第 ${sp.currentWeek} 周',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const _SectionHeader('课程表'),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('学期管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/semester'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('调课管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/adjustments'),
          ),
          const Divider(),
          const _SectionHeader('外观'),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('课程表设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/timetable'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('作息时间设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/classtimes'),
          ),
          const Divider(),
          const _SectionHeader('关于'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Colendar'),
            subtitle: const Text('v1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
