import 'package:flutter/foundation.dart';

import '../database/schedule_dao.dart';
import '../database/course_dao.dart';
import '../database/class_time_dao.dart';
import '../database/adjustment_dao.dart';
import '../models/schedule.dart';
import '../models/course.dart';
import '../models/class_time.dart';
import '../models/course_adjustment.dart';
import '../utils/date_utils.dart' as du;

class ScheduleProvider extends ChangeNotifier {
  final _scheduleDao = ScheduleDao();
  final _courseDao = CourseDao();
  final _classTimeDao = ClassTimeDao();
  final _adjDao = AdjustmentDao();

  List<Schedule> _schedules = [];
  Schedule? _current;
  List<Course> _courses = [];
  List<ClassTimeEntry> _classTimes = [];
  List<CourseAdjustment> _adjustments = [];

  int _currentWeek = 1;
  int _selectedWeek = 1;
  bool _loaded = false;

  List<Schedule> get schedules => _schedules;
  Schedule? get current => _current;
  List<Course> get courses => _courses;
  List<ClassTimeEntry> get classTimes => _classTimes;
  List<CourseAdjustment> get adjustments => _adjustments;
  int get currentWeek => _currentWeek;
  int get selectedWeek => _selectedWeek;
  bool get loaded => _loaded;

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
  }

  List<Course> getCoursesForWeek(int week) {
    return _courses
        .where((c) => c.weeks.contains(week))
        .toList();
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
    // If deleted schedule was current, promote another
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
}
