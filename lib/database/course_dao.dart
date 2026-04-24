import '../models/course.dart';
import 'database_helper.dart';

class CourseDao {
  Future<List<Course>> getCoursesBySchedule(int scheduleId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('courses',
        where: 'schedule_id = ?', whereArgs: [scheduleId]);
    return maps.map(Course.fromMap).toList();
  }

  Future<Course?> getCourseById(int id) async {
    final db = await DatabaseHelper.database;
    final maps =
        await db.query('courses', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Course.fromMap(maps.first);
  }

  Future<int> insert(Course course) async {
    final db = await DatabaseHelper.database;
    return db.insert('courses', course.toMap());
  }

  Future<void> update(Course course) async {
    final db = await DatabaseHelper.database;
    await db.update('courses', course.toMap(),
        where: 'id = ?', whereArgs: [course.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBySchedule(int scheduleId) async {
    final db = await DatabaseHelper.database;
    await db
        .delete('courses', where: 'schedule_id = ?', whereArgs: [scheduleId]);
  }
}
