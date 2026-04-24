/// Utilities for date/week calculations.
class DateUtils {
  static const _dayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const _dayShortNames = ['一', '二', '三', '四', '五', '六', '日'];

  /// Calculate which week of the semester the given date falls in (1-based).
  static int calculateWeekNumber(DateTime semesterStart, DateTime current) {
    final startDay =
        DateTime(semesterStart.year, semesterStart.month, semesterStart.day);
    final currentDay = DateTime(current.year, current.month, current.day);
    if (currentDay.isBefore(startDay)) return 1;
    final days = currentDay.difference(startDay).inDays;
    final week = (days ~/ 7) + 1;
    return week.clamp(1, 30);
  }

  /// Get the Monday of the given week number.
  static DateTime getMondayOfWeek(DateTime semesterStart, int weekNumber) {
    // Find Monday of the first week
    final dow = semesterStart.weekday; // 1=Mon
    final firstMonday =
        semesterStart.subtract(Duration(days: dow - 1));
    return firstMonday.add(Duration(days: (weekNumber - 1) * 7));
  }

  static String dayName(int dayOfWeek) =>
      (dayOfWeek >= 1 && dayOfWeek <= 7) ? _dayNames[dayOfWeek - 1] : '';

  static String dayShortName(int dayOfWeek) =>
      (dayOfWeek >= 1 && dayOfWeek <= 7) ? _dayShortNames[dayOfWeek - 1] : '';
}
