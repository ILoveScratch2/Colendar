import '../models/schedule.dart';
import 'database_helper.dart';

class ScheduleDao {
  Future<List<Schedule>> getAllSchedules() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('schedules', orderBy: 'id DESC');
    return maps.map(Schedule.fromMap).toList();
  }

  Future<Schedule?> getCurrentSchedule() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('schedules',
        where: 'is_current = 1', limit: 1);
    if (maps.isEmpty) return null;
    return Schedule.fromMap(maps.first);
  }

  Future<Schedule?> getById(int id) async {
    final db = await DatabaseHelper.database;
    final maps =
        await db.query('schedules', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Schedule.fromMap(maps.first);
  }

  Future<int> insert(Schedule schedule) async {
    final db = await DatabaseHelper.database;
    return db.insert('schedules', schedule.toMap());
  }

  Future<void> update(Schedule schedule) async {
    final db = await DatabaseHelper.database;
    await db.update('schedules', schedule.toMap(),
        where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setCurrentSchedule(int id) async {
    final db = await DatabaseHelper.database;
    await db.transaction((txn) async {
      await txn.update('schedules', {'is_current': 0});
      await txn
          .update('schedules', {'is_current': 1}, where: 'id = ?', whereArgs: [id]);
    });
  }
}
