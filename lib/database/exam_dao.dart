import '../models/exam.dart';
import 'database_helper.dart';

class ExamDao {
  Future<List<Exam>> getBySchedule(int scheduleId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT e.* FROM exams e
      INNER JOIN courses c ON e.course_id = c.id
      WHERE c.schedule_id = ?
      ORDER BY e.week_number ASC, e.exam_time ASC
    ''', [scheduleId]);
    return maps.map(Exam.fromMap).toList();
  }

  Future<List<Exam>> getByCourse(int courseId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('exams',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'week_number ASC, exam_time ASC');
    return maps.map(Exam.fromMap).toList();
  }

  Future<List<Exam>> getByWeekRange(int scheduleId, int startWeek, int endWeek) async {
    final db = await DatabaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT e.* FROM exams e
      INNER JOIN courses c ON e.course_id = c.id
      WHERE c.schedule_id = ? AND e.week_number BETWEEN ? AND ?
      ORDER BY e.week_number ASC, e.exam_time ASC
    ''', [scheduleId, startWeek, endWeek]);
    return maps.map(Exam.fromMap).toList();
  }

  Future<Exam?> getById(int id) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('exams', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Exam.fromMap(maps.first);
  }

  Future<int> insert(Exam exam) async {
    final db = await DatabaseHelper.database;
    return db.insert('exams', exam.toMap());
  }

  Future<void> update(Exam exam) async {
    final db = await DatabaseHelper.database;
    await db.update('exams', exam.toMap(),
        where: 'id = ?', whereArgs: [exam.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('exams', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByCourse(int courseId) async {
    final db = await DatabaseHelper.database;
    await db.delete('exams', where: 'course_id = ?', whereArgs: [courseId]);
  }

  Future<List<Exam>> getUpcoming(int scheduleId, int currentWeek) async {
    final db = await DatabaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT e.* FROM exams e
      INNER JOIN courses c ON e.course_id = c.id
      WHERE c.schedule_id = ? AND e.week_number >= ?
      ORDER BY e.week_number ASC, e.exam_time ASC
      LIMIT 10
    ''', [scheduleId, currentWeek]);
    return maps.map(Exam.fromMap).toList();
  }
}
