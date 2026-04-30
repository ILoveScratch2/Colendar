import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/schedule_provider.dart';
import '../../services/export_service.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('导出课表')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    sp.current?.name ?? '当前课表',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '共 ${sp.courses.length} 门课程',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Divider(),
                ...ExportService.formats.map((f) => ListTile(
                      leading: Icon(_formatIcon(f),
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(ExportService.formatName(f)),
                      subtitle: Text(_formatDesc(f),
                          style: const TextStyle(fontSize: 12)),
                      trailing:
                          const Icon(Icons.chevron_right),
                      onTap: () => _export(context, sp, f),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _formatIcon(String f) {
    switch (f) {
      case 'json':
        return Icons.code;
      case 'ics':
        return Icons.calendar_month;
      case 'csv':
        return Icons.table_chart;
      case 'txt':
        return Icons.description;
      default:
        return Icons.file_present;
    }
  }

  String _formatDesc(String f) {
    switch (f) {
      case 'json':
        return '结构化数据，可重新导入';
      case 'ics':
        return '导入到系统日历/Google Calendar';
      case 'csv':
        return '表格格式，可用Excel打开';
      case 'txt':
        return '纯文本，方便阅读打印';
      default:
        return '';
    }
  }

  Future<void> _export(
      BuildContext context, ScheduleProvider sp, String format) async {
    try {
      final exportService = ExportService();
      await exportService.exportCourses(
        sp.courses,
        sp.current?.name ?? '课表',
        format,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }
}
