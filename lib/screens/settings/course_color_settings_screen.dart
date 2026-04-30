import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/course_color_palette.dart';

class CourseColorSettingsScreen extends StatelessWidget {
  const CourseColorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final sp = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('课程颜色设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('主题色',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                SwitchListTile(
                  title: const Text('动态取色'),
                  subtitle: const Text('跟随系统壁纸自动调整配色'),
                  value: settings.useDynamicColor,
                  onChanged: (v) => settings.setUseDynamicColor(v),
                ),
                const Divider(indent: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('选择种子颜色',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: CourseColorPalette.colors.take(12).map((hex) {
                      final color = CourseColorPalette.colorFromHex(hex);
                      final selected = settings.seedColor == color.toARGB32();
                      return GestureDetector(
                        onTap: () => settings.setSeedColor(color.toARGB32()),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    width: 3)
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('课程配色',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: () => _randomizeColors(context, sp, settings),
                        child: const Text('随机方案'),
                      ),
                    ],
                  ),
                ),
                ...sp.courses.map((course) {
                  final color =
                      CourseColorPalette.colorFromHex(course.color);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(course.courseName[0],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                    title: Text(course.courseName),
                    trailing: SizedBox(
                      width: 200,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: CourseColorPalette.colors
                              .take(12)
                              .map((hex) {
                            final c = CourseColorPalette.colorFromHex(hex);
                            final selected =
                                course.color == hex;
                            return GestureDetector(
                              onTap: () => _setCourseColor(
                                  context, sp, course.id!, hex),
                              child: Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: selected
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          width: 2)
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _randomizeColors(
      BuildContext context, ScheduleProvider sp, SettingsProvider settings) {
    final colors = List<String>.from(CourseColorPalette.colors);
    colors.shuffle();
    for (int i = 0; i < sp.courses.length; i++) {
      final newColor = colors[i % colors.length];
      sp.updateCourse(sp.courses[i].copyWith(color: newColor));
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已应用随机配色方案')));
  }

  void _setCourseColor(
      BuildContext context, ScheduleProvider sp, int courseId, String color) {
    final course = sp.courses.firstWhere((c) => c.id == courseId);
    sp.updateCourse(course.copyWith(color: color));
  }
}
