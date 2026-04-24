import '../models/course_adjustment.dart';
import 'database_helper.dart';

class AdjustmentDao {
  Future<List<CourseAdjustment>> getBySchedule(int scheduleId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('course_adjustments',
        where: 'schedule_id = ?', whereArgs: [scheduleId]);
    return maps.map(CourseAdjustment.fromMap).toList();
  }

  Future<List<CourseAdjustment>> getByCourse(int courseId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('course_adjustments',
        where: 'original_course_id = ?', whereArgs: [courseId]);
    return maps.map(CourseAdjustment.fromMap).toList();
  }

  Future<int> insert(CourseAdjustment adj) async {
    final db = await DatabaseHelper.database;
    return db.insert('course_adjustments', adj.toMap());
  }

  Future<void> update(CourseAdjustment adj) async {
    final db = await DatabaseHelper.database;
    await db.update('course_adjustments', adj.toMap(),
        where: 'id = ?', whereArgs: [adj.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('course_adjustments', where: 'id = ?', whereArgs: [id]);
  }
}
