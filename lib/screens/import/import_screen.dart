import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../services/import_service.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  List<ParsedCourse>? _parsed;
  bool _loading = false;

  Future<void> _pickFile() async {
    setState(() => _loading = true);
    try {
      final importService = ImportService();
      final parsed = await importService.pickAndParseFile();
      setState(() => _parsed = parsed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _importAll() async {
    if (_parsed == null || _parsed!.isEmpty) return;
    final sp = context.read<ScheduleProvider>();
    if (sp.current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先创建课表')));
      return;
    }

    final importService = ImportService();
    final usedColors =
        sp.courses.map((c) => c.color).toList();
    final courses =
        importService.convertToCourses(_parsed!, sp.current!.id!, usedColors);

    for (final c in courses) {
      await sp.addCourse(c);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导入 ${courses.length} 门课程')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入课表'),
        actions: [
          if (_parsed != null && _parsed!.isNotEmpty)
            TextButton(
              onPressed: _importAll,
              child: const Text('全部导入'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _parsed == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('支持 JSON、ICS 格式'),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.file_open),
                        label: const Text('选择文件'),
                      ),
                    ],
                  ),
                )
              : _parsed!.isEmpty
                  ? const Center(child: Text('文件中没有找到课程数据'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _parsed!.length,
                      itemBuilder: (_, i) {
                        final c = _parsed![i];
                        return Card(
                          child: ListTile(
                            title: Text(c.courseName),
                            subtitle: Text(
                              '周${["", "一", "二", "三", "四", "五", "六", "日"][c.dayOfWeek]} '
                              '第${c.startSection}-${c.startSection + c.sectionCount - 1}节 '
                              '${c.weeks.length}周',
                            ),
                            trailing: Text(
                              c.classroom,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
