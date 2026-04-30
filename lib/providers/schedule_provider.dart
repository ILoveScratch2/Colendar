import 'package:flutter/foundation.dart';

import '../database/schedule_dao.dart';
import '../database/course_dao.dart';
import '../database/class_time_dao.dart';
import '../database/adjustment_dao.dart';
import '../database/exam_dao.dart';
import '../database/reminder_dao.dart';
import '../models/schedule.dart';
import '../models/course.dart';
import '../models/class_time.dart';
import '../models/course_adjustment.dart';
import '../models/exam.dart';
import '../models/reminder.dart';
import '../utils/date_utils.dart' as du;

class ScheduleProvider extends ChangeNotifier {
  final _scheduleDao = ScheduleDao();
  final _courseDao = CourseDao();
  final _classTimeDao = ClassTimeDao();
  final _adjDao = AdjustmentDao();
  final _examDao = ExamDao();
  final _reminderDao = ReminderDao();

  List<Schedule> _schedules = [];
  Schedule? _current;
  List<Course> _courses = [];
  List<ClassTimeEntry> _classTimes = [];
  List<CourseAdjustment> _adjustments = [];
  List<Exam> _exams = [];
  List<Reminder> _reminders = [];

  int _currentWeek = 1;
  int _selectedWeek = 1;
  bool _loaded = false;

  // Virtual clipboard
  Course? _clipboardCourse;

  List<Schedule> get schedules => _schedules;
  Schedule? get current => _current;
  List<Course> get courses => _courses;
  List<ClassTimeEntry> get classTimes => _classTimes;
  List<CourseAdjustment> get adjustments => _adjustments;
  List<Exam> get exams => _exams;
  List<Reminder> get reminders => _reminders;
  int get currentWeek => _currentWeek;
  int get selectedWeek => _selectedWeek;
  bool get loaded => _loaded;
  Course? get clipboardCourse => _clipboardCourse;
  bool get hasClipboardCourse => _clipboardCourse != null;

  Future<void> load() async {
    _schedules = await _scheduleDao.getAllSchedules();
    _current = await _scheduleDao.getCurrentSchedule();
    if (_current == null && _schedules.isNotEmpty) {
      _current = _schedules.first;
    }
    if (_current != null) {
      await _loadCurrentScheduleData();
      _currentWeek = du.DateUtils.calculateWeekNumber(
          _current!.startDate, DateTime.now());
      _selectedWeek = _currentWeek;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _loadCurrentScheduleData() async {
    if (_current == null) return;
    _courses = await _courseDao.getCoursesBySchedule(_current!.id!);
    _classTimes =
        await _classTimeDao.getByConfig(_current!.classTimeConfigName);
    _adjustments = await _adjDao.getBySchedule(_current!.id!);
    _exams = await _examDao.getBySchedule(_current!.id!);
    _reminders = await _reminderDao.getBySchedule(_current!.id!);
  }

  List<Course> getCoursesForWeek(int week) {
    return _courses
        .where((c) => c.weeks.contains(week))
        .toList();
  }

  List<Exam> getExamsForWeek(int week) {
    return _exams.where((e) => e.weekNumber == week).toList();
  }

  void setSelectedWeek(int week) {
    _selectedWeek = week.clamp(1, _current?.totalWeeks ?? 30);
    notifyListeners();
  }

  // ---- Schedule CRUD ----

  Future<void> addSchedule(Schedule schedule) async {
    final id = await _scheduleDao.insert(schedule);
    if (_schedules.isEmpty) {
      await _scheduleDao.setCurrentSchedule(id);
    }
    await load();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _scheduleDao.update(schedule);
    await load();
  }

  Future<void> deleteSchedule(int id) async {
    await _courseDao.deleteBySchedule(id);
    await _scheduleDao.delete(id);
    if (_current?.id == id) {
      final all = await _scheduleDao.getAllSchedules();
      if (all.isNotEmpty) {
        await _scheduleDao.setCurrentSchedule(all.first.id!);
      }
    }
    await load();
  }

  Future<void> switchSchedule(int id) async {
    await _scheduleDao.setCurrentSchedule(id);
    await load();
  }

  // ---- Course CRUD ----

  Future<void> addCourse(Course course) async {
    await _courseDao.insert(course);
    await _loadCurrentScheduleData();
    notifyListeners();
  }

  Future<void> updateCourse(Course course) async {
    await _courseDao.update(course);
    await _loadCurrentScheduleData();
    notifyListeners();
  }

  Future<void> deleteCourse(int id) async {
    await _courseDao.delete(id);
    await _loadCurrentScheduleData();
    notifyListeners();
  }

  int getMaxCourseSection() {
    if (_courses.isEmpty) return 0;
    return _courses
        .map((c) => c.startSection + c.sectionCount - 1)
        .reduce((a, b) => a > b ? a : b);
  }

  // ---- Class Time ----

  Future<void> saveClassTimes(
      List<ClassTimeEntry> entries, String configName) async {
    await _classTimeDao.deleteByConfig(configName);
    for (final e in entries) {
      await _classTimeDao.upsert(e.copyWith(id: null, configName: configName));
    }
    _classTimes = await _classTimeDao.getByConfig(configName);
    notifyListeners();
  }

  Future<void> regenerateClassTimes({
    required int classDuration,
    required int breakDuration,
    required int morningSections,
    required int afternoonSections,
    required String configName,
    required int startHour,
    required int startMinute,
    required int afternoonStartHour,
    required int afternoonStartMinute,
  }) async {
    final total = morningSections + afternoonSections;
    if (total == 0) {
      await _classTimeDao.deleteByConfig(configName);
      _classTimes = [];
      notifyListeners();
      return;
    }

    final newTimes = <ClassTimeEntry>[];
    var currentTime = _timeInMinutes(startHour, startMinute);

    for (int i = 1; i <= total; i++) {
      final endTime = currentTime + classDuration;
      newTimes.add(ClassTimeEntry(
        sectionNumber: i,
        startTime: _minutesToTimeStr(currentTime),
        endTime: _minutesToTimeStr(endTime),
        configName: configName,
      ));

      if (i == morningSections && afternoonSections > 0) {
        currentTime = _timeInMinutes(afternoonStartHour, afternoonStartMinute);
      } else {
        currentTime = endTime + breakDuration;
      }
    }

    await _classTimeDao.deleteByConfig(configName);
    for (final e in newTimes) {
      await _classTimeDao.upsert(e);
    }
    _classTimes = newTimes;
    notifyListeners();
  }

  static int _timeInMinutes(int hour, int minute) => hour * 60 + minute;

  static String _minutesToTimeStr(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void adjustSubsequentClassTimes(int changedSection) {
    if (_classTimes.isEmpty) return;
    final sorted = List<ClassTimeEntry>.from(_classTimes)
      ..sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
    final idx = sorted.indexWhere((e) => e.sectionNumber == changedSection);
    if (idx < 0 || idx >= sorted.length - 1) return;

    for (int i = idx + 1; i < sorted.length; i++) {
      final prevEnd = _parseMinutes(sorted[i - 1].endTime);
      final dur = _parseMinutes(sorted[i].endTime) -
          _parseMinutes(sorted[i].startTime);
      final newStart = prevEnd;
      sorted[i] = sorted[i].copyWith(
        startTime: _minutesToTimeStr(newStart),
        endTime: _minutesToTimeStr(newStart + dur),
      );
    }
    _classTimes = sorted;
    notifyListeners();
  }

  static int _parseMinutes(String t) {
    final parts = t.split(':');
    return int.tryParse(parts[0])! * 60 + int.tryParse(parts[1])!;
  }

  // ---- Adjustments ----

  Future<void> addAdjustment(CourseAdjustment adj) async {
    await _adjDao.insert(adj);
    _adjustments = await _adjDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  Future<void> deleteAdjustment(int id) async {
    await _adjDao.delete(id);
    _adjustments = await _adjDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  // ---- Exams ----

  Future<void> addExam(Exam exam) async {
    await _examDao.insert(exam);
    _exams = await _examDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  Future<void> updateExam(Exam exam) async {
    await _examDao.update(exam);
    _exams = await _examDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  Future<void> deleteExam(int id) async {
    await _examDao.delete(id);
    _exams = await _examDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  // ---- Reminders ----

  Future<void> addReminder(Reminder reminder) async {
    await _reminderDao.insert(reminder);
    _reminders = await _reminderDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _reminderDao.update(reminder);
    _reminders = await _reminderDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  Future<void> deleteReminder(int id) async {
    await _reminderDao.delete(id);
    _reminders = await _reminderDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  Future<void> toggleReminder(int id, bool enabled) async {
    await _reminderDao.updateEnabled(id, enabled);
    _reminders = await _reminderDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  int getActiveReminderCount() {
    return _reminders.where((r) => r.isEnabled).length;
  }

  Future<void> deleteExpiredReminders() async {
    await _reminderDao.deleteExpired(_currentWeek);
    _reminders = await _reminderDao.getBySchedule(_current!.id!);
    notifyListeners();
  }

  // ---- Clipboard ----

  void copyCourseToClipboard(Course course) {
    _clipboardCourse = course;
    notifyListeners();
  }

  void clearClipboard() {
    _clipboardCourse = null;
    notifyListeners();
  }

  Future<void> pasteCourseFromClipboard({
    int? dayOfWeek,
    int? startSection,
    List<int>? weeks,
  }) async {
    if (_clipboardCourse == null || _current == null) return;
    final src = _clipboardCourse!;
    final newCourse = src.copyWith(
      id: null,
      scheduleId: _current!.id!,
      dayOfWeek: dayOfWeek ?? src.dayOfWeek,
      startSection: startSection ?? src.startSection,
      weeks: weeks ?? src.weeks,
    );
    await _courseDao.insert(newCourse);
    await _loadCurrentScheduleData();
    notifyListeners();
  }
}
