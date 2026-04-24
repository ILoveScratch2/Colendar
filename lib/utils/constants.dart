class AppConstants {
  // Section limits
  static const int minSection = 1;
  static const int maxSection = 14;
  static const int defaultSectionCount = 12;

  // Week limits
  static const int minWeek = 1;
  static const int maxWeek = 30;
  static const int defaultTotalWeeks = 20;

  // Reminder defaults
  static const int defaultReminderMinutes = 15;

  // Day of week
  static const int minDay = 1;
  static const int maxDay = 7;

  // Default class times (section -> [start, end])
  static const List<List<String>> defaultClassTimes = [
    ['08:00', '08:45'],
    ['08:55', '09:40'],
    ['10:00', '10:45'],
    ['10:55', '11:40'],
    ['14:00', '14:45'],
    ['14:55', '15:40'],
    ['16:00', '16:45'],
    ['16:55', '17:40'],
    ['19:00', '19:45'],
    ['19:55', '20:40'],
    ['20:50', '21:35'],
    ['21:45', '22:30'],
  ];
}
