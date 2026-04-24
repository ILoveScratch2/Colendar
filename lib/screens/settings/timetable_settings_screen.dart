import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/settings_provider.dart';
import '../../utils/course_color_palette.dart';

class TimetableSettingsScreen extends StatelessWidget {
  const TimetableSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('课程表设置')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('显示周末'),
            subtitle: const Text('在课程表中显示周六、周日'),
            value: settings.showWeekend,
            onChanged: settings.setShowWeekend,
          ),
          SwitchListTile(
            title: const Text('紧凑模式'),
            subtitle: const Text('减小课程格高度'),
            value: settings.compactMode,
            onChanged: settings.setCompactMode,
          ),
          ListTile(
            title: const Text('显示节次数'),
            subtitle: Text('当前：${settings.sectionCount} 节'),
            trailing: DropdownButton<int>(
              value: settings.sectionCount,
              items: [8, 10, 11, 12, 13, 14]
                  .map((v) =>
                      DropdownMenuItem(value: v, child: Text('$v 节')))
                  .toList(),
              onChanged: (v) {
                if (v != null) settings.setSectionCount(v);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('作息时间设置'),
            leading: const Icon(Icons.access_time),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/classtimes'),
          ),
          const Divider(),
          _ThemeColorSection(settings: settings),
        ],
      ),
    );
  }
}

class _ThemeColorSection extends StatelessWidget {
  final SettingsProvider settings;
  const _ThemeColorSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text('主题色', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: CourseColorPalette.colors.take(12).map((hex) {
              final color = CourseColorPalette.colorFromHex(hex);
              // ignore: deprecated_member_use
              final colorVal = color.value;
              final selected = settings.seedColor == colorVal;
              return GestureDetector(
                onTap: () => settings.setSeedColor(colorVal),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.black87, width: 3)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
