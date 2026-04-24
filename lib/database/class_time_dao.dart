import '../models/class_time.dart';
import 'database_helper.dart';

class ClassTimeDao {
  Future<List<ClassTimeEntry>> getByConfig(String configName) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('class_times',
        where: 'config_name = ?',
        whereArgs: [configName],
        orderBy: 'section_number ASC');
    return maps.map(ClassTimeEntry.fromMap).toList();
  }

  Future<void> upsert(ClassTimeEntry entry) async {
    final db = await DatabaseHelper.database;
    if (entry.id != null) {
      await db.update('class_times', entry.toMap(),
          where: 'id = ?', whereArgs: [entry.id]);
    } else {
      await db.insert('class_times', entry.toMap());
    }
  }

  Future<void> deleteByConfig(String configName) async {
    final db = await DatabaseHelper.database;
    await db.delete('class_times',
        where: 'config_name = ?', whereArgs: [configName]);
  }
}
