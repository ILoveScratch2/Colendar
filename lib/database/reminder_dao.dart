import 'package:sqflite/sqflite.dart';

import '../models/reminder.dart';
import 'database_helper.dart';

class ReminderDao {
  Future<List<Reminder>> getBySchedule(int scheduleId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT r.* FROM reminders r
      INNER JOIN courses c ON r.course_id = c.id
      WHERE c.schedule_id = ?
      ORDER BY r.week_number ASC, r.day_of_week ASC
    ''', [scheduleId]);
    return maps.map(Reminder.fromMap).toList();
  }

  Future<List<Reminder>> getByCourse(int courseId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('reminders',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'week_number ASC, day_of_week ASC');
    return maps.map(Reminder.fromMap).toList();
  }

  Future<List<Reminder>> getActive() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('reminders',
        where: 'is_enabled = 1',
        orderBy: 'week_number ASC, day_of_week ASC');
    return maps.map(Reminder.fromMap).toList();
  }

  Future<List<Reminder>> getByDay(int weekNumber, int dayOfWeek) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('reminders',
        where: 'week_number = ? AND day_of_week = ? AND is_enabled = 1',
        whereArgs: [weekNumber, dayOfWeek]);
    return maps.map(Reminder.fromMap).toList();
  }

  Future<int> insert(Reminder reminder) async {
    final db = await DatabaseHelper.database;
    return db.insert('reminders', reminder.toMap());
  }

  Future<void> update(Reminder reminder) async {
    final db = await DatabaseHelper.database;
    await db.update('reminders', reminder.toMap(),
        where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByCourse(int courseId) async {
    final db = await DatabaseHelper.database;
    await db.delete('reminders', where: 'course_id = ?', whereArgs: [courseId]);
  }

  Future<void> deleteExpired(int currentWeek) async {
    final db = await DatabaseHelper.database;
    await db.delete('reminders',
        where: 'week_number < ?', whereArgs: [currentWeek]);
  }

  Future<int> getActiveCount() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM reminders WHERE is_enabled = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> updateEnabled(int id, bool enabled) async {
    final db = await DatabaseHelper.database;
    await db.update('reminders',
        {'is_enabled': enabled ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
