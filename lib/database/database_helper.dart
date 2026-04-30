import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../utils/constants.dart';

class DatabaseHelper {
  static const _dbName = 'colendar.db';
  static const _dbVersion = 2;

  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        school_name TEXT NOT NULL DEFAULT '',
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        total_weeks INTEGER NOT NULL DEFAULT 20,
        is_current INTEGER NOT NULL DEFAULT 0,
        class_time_config_name TEXT NOT NULL DEFAULT 'default'
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_name TEXT NOT NULL,
        teacher TEXT NOT NULL DEFAULT '',
        classroom TEXT NOT NULL DEFAULT '',
        day_of_week INTEGER NOT NULL,
        start_section INTEGER NOT NULL,
        section_count INTEGER NOT NULL DEFAULT 2,
        weeks TEXT NOT NULL DEFAULT '',
        schedule_id INTEGER NOT NULL,
        color TEXT NOT NULL DEFAULT '#5B9BD5',
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_minutes INTEGER NOT NULL DEFAULT 15,
        note TEXT NOT NULL DEFAULT '',
        course_code TEXT NOT NULL DEFAULT '',
        credit REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE class_times (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section_number INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        config_name TEXT NOT NULL DEFAULT 'default'
      )
    ''');

    await db.execute('''
      CREATE TABLE course_adjustments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_course_id INTEGER NOT NULL,
        schedule_id INTEGER NOT NULL,
        original_week_number INTEGER NOT NULL,
        original_day_of_week INTEGER NOT NULL DEFAULT 1,
        original_start_section INTEGER NOT NULL DEFAULT 1,
        original_section_count INTEGER NOT NULL DEFAULT 2,
        new_week_number INTEGER,
        new_day_of_week INTEGER,
        new_start_section INTEGER,
        new_section_count INTEGER,
        new_classroom TEXT,
        reason TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (original_course_id) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        course_name TEXT NOT NULL DEFAULT '',
        exam_type TEXT NOT NULL DEFAULT 'final',
        week_number INTEGER NOT NULL,
        day_of_week INTEGER,
        start_section INTEGER,
        section_count INTEGER,
        exam_time TEXT NOT NULL DEFAULT '',
        location TEXT NOT NULL DEFAULT '',
        seat TEXT NOT NULL DEFAULT '',
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_days INTEGER NOT NULL DEFAULT 1,
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id INTEGER NOT NULL,
        minutes_before INTEGER NOT NULL DEFAULT 15,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        week_number INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        trigger_time INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    for (var i = 0; i < AppConstants.defaultClassTimes.length; i++) {
      final times = AppConstants.defaultClassTimes[i];
      await db.insert('class_times', {
        'section_number': i + 1,
        'start_time': times[0],
        'end_time': times[1],
        'config_name': 'default',
      });
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create new tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS exams (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course_id INTEGER NOT NULL,
          course_name TEXT NOT NULL DEFAULT '',
          exam_type TEXT NOT NULL DEFAULT 'final',
          week_number INTEGER NOT NULL,
          day_of_week INTEGER,
          start_section INTEGER,
          section_count INTEGER,
          exam_time TEXT NOT NULL DEFAULT '',
          location TEXT NOT NULL DEFAULT '',
          seat TEXT NOT NULL DEFAULT '',
          reminder_enabled INTEGER NOT NULL DEFAULT 0,
          reminder_days INTEGER NOT NULL DEFAULT 1,
          note TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL DEFAULT '',
          FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course_id INTEGER NOT NULL,
          minutes_before INTEGER NOT NULL DEFAULT 15,
          is_enabled INTEGER NOT NULL DEFAULT 1,
          week_number INTEGER NOT NULL,
          day_of_week INTEGER NOT NULL,
          trigger_time INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL DEFAULT '',
          FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
        )
      ''');

      // Add new columns to course_adjustments
      final result = await db.rawQuery("PRAGMA table_info(course_adjustments)");
      final existingCols = result.map((r) => r['name'] as String).toSet();

      if (!existingCols.contains('original_day_of_week')) {
        await db.execute(
            'ALTER TABLE course_adjustments ADD COLUMN original_day_of_week INTEGER NOT NULL DEFAULT 1');
      }
      if (!existingCols.contains('original_start_section')) {
        await db.execute(
            'ALTER TABLE course_adjustments ADD COLUMN original_start_section INTEGER NOT NULL DEFAULT 1');
      }
      if (!existingCols.contains('original_section_count')) {
        await db.execute(
            'ALTER TABLE course_adjustments ADD COLUMN original_section_count INTEGER NOT NULL DEFAULT 2');
      }
      if (!existingCols.contains('new_section_count')) {
        await db.execute(
            'ALTER TABLE course_adjustments ADD COLUMN new_section_count INTEGER');
      }
      if (!existingCols.contains('new_classroom')) {
        await db.execute(
            'ALTER TABLE course_adjustments ADD COLUMN new_classroom TEXT');
      }
    }
  }
}
