import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/schedule_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/course.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/course_color_palette.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainView();
  }
}

class _MainView extends StatefulWidget {
  const _MainView();

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final sp = context.read<ScheduleProvider>();
    _pageController = PageController(initialPage: (sp.selectedWeek - 1).clamp(0, 29));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final settings = context.watch<SettingsProvider>();

    if (!sp.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (sp.current == null) {
      return _NoScheduleView();
    }

    final totalWeeks = sp.current!.totalWeeks;
    final selectedWeek = sp.selectedWeek;
    final monday = du.DateUtils.getMondayOfWeek(sp.current!.startDate, selectedWeek);

    return Scaffold(
      appBar: _buildAppBar(context, sp, selectedWeek, totalWeeks, monday),
      body: Column(
        children: [
          _WeekHeader(
            monday: monday,
            showWeekend: settings.showWeekend,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalWeeks,
              onPageChanged: (i) => sp.setSelectedWeek(i + 1),
              itemBuilder: (_, i) {
                return _TimetableWeekView(
                  week: i + 1,
                  showWeekend: settings.showWeekend,
                  sectionCount: settings.sectionCount,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/course/new?scheduleId=${sp.current!.id}'),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ScheduleProvider sp,
      int selectedWeek, int totalWeeks, DateTime monday) {
    final isCurrentWeek = selectedWeek == sp.currentWeek;
    return AppBar(
      title: GestureDetector(
        onTap: () => context.push('/semester'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sp.current?.name ?? '课程表',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '第$selectedWeek周${isCurrentWeek ? '（本周）' : ''}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today),
          tooltip: '回到本周',
          onPressed: () {
            sp.setSelectedWeek(sp.currentWeek);
            _pageController.animateToPage(
              sp.currentWeek - 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.list),
          tooltip: '课程列表',
          onPressed: () => context.push('/courses'),
        ),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final DateTime monday;
  final bool showWeekend;

  const _WeekHeader({required this.monday, required this.showWeekend});

  @override
  Widget build(BuildContext context) {
    final days = showWeekend ? 7 : 5;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const SizedBox(width: 32), // section number column
          ...List.generate(days, (i) {
            final date = monday.add(Duration(days: i));
            final isToday = _isToday(date);
            final dayNames = ['一', '二', '三', '四', '五', '六', '日'];
            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayNames[i],
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _TimetableWeekView extends StatelessWidget {
  final int week;
  final bool showWeekend;
  final int sectionCount;

  const _TimetableWeekView({
    required this.week,
    required this.showWeekend,
    required this.sectionCount,
  });

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ScheduleProvider>();
    final days = showWeekend ? 7 : 5;
    final courses = sp.getCoursesForWeek(week);
    final adjustments = sp.adjustments;

    // Build effective display map: (day, startSection) -> Course
    final Map<String, Course> displayMap = {};
    final Map<String, bool> adjustedMap = {};

    // First pass: mark cancelled courses (adjustment with no new time)
    final Set<String> cancelledKeys = {};
    for (final adj in adjustments) {
      if (adj.newWeekNumber == null &&
          adj.newDayOfWeek == null &&
          adj.originalWeekNumber == week) {
        // cancelled - find the course
        final course =
            courses.firstWhere((c) => c.id == adj.originalCourseId, orElse: () => Course(
              courseName: '', dayOfWeek: 1, startSection: 1, weeks: [], scheduleId: 0));
        if (course.id != null) {
          cancelledKeys.add('${course.dayOfWeek}_${course.startSection}');
        }
      }
    }

    // Place normal courses
    for (final c in courses) {
      final key = '${c.dayOfWeek}_${c.startSection}';
      if (!cancelledKeys.contains(key)) {
        displayMap[key] = c;
      }
    }

    // Overlay adjusted courses appearing in this week
    for (final adj in adjustments) {
      if (adj.newWeekNumber == week &&
          adj.newDayOfWeek != null &&
          adj.newStartSection != null) {
        final course = courses.firstWhere(
            (c) => c.id == adj.originalCourseId,
            orElse: () => Course(
              courseName: '', dayOfWeek: 1, startSection: 1, weeks: [], scheduleId: 0));
        if (course.id != null) {
          final key = '${adj.newDayOfWeek}_${adj.newStartSection}';
          displayMap[key] = course;
          adjustedMap[key] = true;
        }
      }
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section numbers column
          Column(
            children: List.generate(sectionCount, (i) {
              return SizedBox(
                height: 64,
                width: 32,
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              );
            }),
          ),
          // Day columns
          ...List.generate(days, (dayIdx) {
            final dayOfWeek = dayIdx + 1;
            return Expanded(
              child: _DayColumn(
                dayOfWeek: dayOfWeek,
                sectionCount: sectionCount,
                displayMap: displayMap,
                adjustedMap: adjustedMap,
                week: week,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final int dayOfWeek;
  final int sectionCount;
  final Map<String, Course> displayMap;
  final Map<String, bool> adjustedMap;
  final int week;

  const _DayColumn({
    required this.dayOfWeek,
    required this.sectionCount,
    required this.displayMap,
    required this.adjustedMap,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    // Build a list of slots, merging multi-section courses
    final slots = <_CourseSlot>[];
    int skip = 0;
    for (int s = 1; s <= sectionCount; s++) {
      if (skip > 0) {
        skip--;
        continue;
      }
      final key = '${dayOfWeek}_$s';
      final course = displayMap[key];
      if (course != null) {
        final span = course.sectionCount.clamp(1, sectionCount - s + 1);
        slots.add(_CourseSlot(
          course: course,
          startSection: s,
          span: span,
          isAdjusted: adjustedMap[key] ?? false,
        ));
        skip = span - 1;
      } else {
        slots.add(_CourseSlot(course: null, startSection: s, span: 1));
      }
    }

    return Column(
      children: slots.map((slot) {
        if (slot.course == null) {
          return SizedBox(height: 64.0 * slot.span, width: double.infinity);
        }
        return _CourseCard(
          course: slot.course!,
          span: slot.span,
          isAdjusted: slot.isAdjusted,
        );
      }).toList(),
    );
  }
}

class _CourseSlot {
  final Course? course;
  final int startSection;
  final int span;
  final bool isAdjusted;
  const _CourseSlot({
    required this.course,
    required this.startSection,
    required this.span,
    this.isAdjusted = false,
  });
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final int span;
  final bool isAdjusted;

  const _CourseCard({
    required this.course,
    required this.span,
    this.isAdjusted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = CourseColorPalette.colorFromHex(course.color);
    return GestureDetector(
      onTap: () => context.push('/course/${course.id}'),
      child: Container(
        height: 64.0 * span - 2,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (course.classroom.isNotEmpty)
              Text(
                course.classroom,
                style:
                    const TextStyle(fontSize: 10, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (isAdjusted)
              const Icon(Icons.swap_horiz, size: 12, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _NoScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('课程表')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('还没有课程表', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('点击下方按钮新建课程表',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/semester'),
              icon: const Icon(Icons.add),
              label: const Text('新建课程表'),
            ),
          ],
        ),
      ),
    );
  }
}
