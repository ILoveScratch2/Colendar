import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyShowWeekend = 'show_weekend';
  static const _keyCompactMode = 'compact_mode';
  static const _keySeedColor = 'seed_color';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keySectionCount = 'section_count';
  static const _keyClassDuration = 'class_duration';
  static const _keyBreakDuration = 'break_duration';
  static const _keyUniformDuration = 'uniform_duration';
  static const _keyMorningSections = 'morning_sections';
  static const _keyAfternoonSections = 'afternoon_sections';
  static const _keyDisplayMode = 'display_mode';
  static const _keyReminderEnabled = 'reminder_enabled';
  static const _keyDefaultReminderMinutes = 'default_reminder_minutes';
  static const _keyHeadsUpNotification = 'heads_up_notification';
  static const _keyGlassEffect = 'glass_effect';
  static const _keyBackgroundBlur = 'background_blur';
  static const _keyBackgroundDim = 'background_dim';
  static const _keyUseDynamicColor = 'use_dynamic_color';
  static const _keySaturation = 'saturation';

  bool _showWeekend = false;
  bool _compactMode = false;
  int _seedColor = 0xFF5B9BD5;
  bool _onboardingDone = false;
  int _sectionCount = 12;
  int _classDuration = 45;
  int _breakDuration = 10;
  bool _uniformDuration = false;
  int _morningSections = 4;
  int _afternoonSections = 4;
  String _displayMode = 'adaptive';
  bool _reminderEnabled = true;
  int _defaultReminderMinutes = 15;
  bool _headsUpNotification = true;
  bool _glassEffect = false;
  double _backgroundBlur = 4.0;
  double _backgroundDim = 0.3;
  bool _useDynamicColor = true;
  double _saturation = 1.0;

  bool get showWeekend => _showWeekend;
  bool get compactMode => _compactMode;
  int get seedColor => _seedColor;
  bool get onboardingDone => _onboardingDone;
  int get sectionCount => _sectionCount;
  int get classDuration => _classDuration;
  int get breakDuration => _breakDuration;
  bool get uniformDuration => _uniformDuration;
  int get morningSections => _morningSections;
  int get afternoonSections => _afternoonSections;
  String get displayMode => _displayMode;
  bool get reminderEnabled => _reminderEnabled;
  int get defaultReminderMinutes => _defaultReminderMinutes;
  bool get headsUpNotification => _headsUpNotification;
  bool get glassEffect => _glassEffect;
  double get backgroundBlur => _backgroundBlur;
  double get backgroundDim => _backgroundDim;
  bool get useDynamicColor => _useDynamicColor;
  double get saturation => _saturation;

  bool get isAdaptiveMode => _displayMode == 'adaptive';
  int get totalSections => _morningSections + _afternoonSections;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _showWeekend = prefs.getBool(_keyShowWeekend) ?? false;
    _compactMode = prefs.getBool(_keyCompactMode) ?? false;
    _seedColor = prefs.getInt(_keySeedColor) ?? 0xFF5B9BD5;
    _onboardingDone = prefs.getBool(_keyOnboardingDone) ?? false;
    _sectionCount = prefs.getInt(_keySectionCount) ?? 12;
    _classDuration = prefs.getInt(_keyClassDuration) ?? 45;
    _breakDuration = prefs.getInt(_keyBreakDuration) ?? 10;
    _uniformDuration = prefs.getBool(_keyUniformDuration) ?? false;
    _morningSections = prefs.getInt(_keyMorningSections) ?? 4;
    _afternoonSections = prefs.getInt(_keyAfternoonSections) ?? 4;
    _displayMode = prefs.getString(_keyDisplayMode) ?? 'adaptive';
    _reminderEnabled = prefs.getBool(_keyReminderEnabled) ?? true;
    _defaultReminderMinutes = prefs.getInt(_keyDefaultReminderMinutes) ?? 15;
    _headsUpNotification = prefs.getBool(_keyHeadsUpNotification) ?? true;
    _glassEffect = prefs.getBool(_keyGlassEffect) ?? false;
    _backgroundBlur = prefs.getDouble(_keyBackgroundBlur) ?? 4.0;
    _backgroundDim = prefs.getDouble(_keyBackgroundDim) ?? 0.3;
    _useDynamicColor = prefs.getBool(_keyUseDynamicColor) ?? true;
    _saturation = prefs.getDouble(_keySaturation) ?? 1.0;
    notifyListeners();
  }

  Future<void> setShowWeekend(bool v) async {
    _showWeekend = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowWeekend, v);
    notifyListeners();
  }

  Future<void> setCompactMode(bool v) async {
    _compactMode = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompactMode, v);
    notifyListeners();
  }

  Future<void> setSeedColor(int v) async {
    _seedColor = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeedColor, v);
    notifyListeners();
  }

  Future<void> setOnboardingDone(bool v) async {
    _onboardingDone = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, v);
    notifyListeners();
  }

  Future<void> setSectionCount(int v) async {
    _sectionCount = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySectionCount, v);
    notifyListeners();
  }

  Future<void> setClassDuration(int v) async {
    _classDuration = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyClassDuration, v);
    notifyListeners();
  }

  Future<void> setBreakDuration(int v) async {
    _breakDuration = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBreakDuration, v);
    notifyListeners();
  }

  Future<void> setUniformDuration(bool v) async {
    _uniformDuration = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUniformDuration, v);
    notifyListeners();
  }

  Future<void> setMorningSections(int v) async {
    _morningSections = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMorningSections, v);
    notifyListeners();
  }

  Future<void> setAfternoonSections(int v) async {
    _afternoonSections = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAfternoonSections, v);
    notifyListeners();
  }

  Future<void> setDisplayMode(String v) async {
    _displayMode = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayMode, v);
    notifyListeners();
  }

  Future<void> setReminderEnabled(bool v) async {
    _reminderEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, v);
    notifyListeners();
  }

  Future<void> setDefaultReminderMinutes(int v) async {
    _defaultReminderMinutes = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultReminderMinutes, v);
    notifyListeners();
  }

  Future<void> setHeadsUpNotification(bool v) async {
    _headsUpNotification = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHeadsUpNotification, v);
    notifyListeners();
  }

  Future<void> setGlassEffect(bool v) async {
    _glassEffect = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGlassEffect, v);
    notifyListeners();
  }

  Future<void> setBackgroundBlur(double v) async {
    _backgroundBlur = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBackgroundBlur, v);
    notifyListeners();
  }

  Future<void> setBackgroundDim(double v) async {
    _backgroundDim = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBackgroundDim, v);
    notifyListeners();
  }

  Future<void> setUseDynamicColor(bool v) async {
    _useDynamicColor = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDynamicColor, v);
    notifyListeners();
  }

  Future<void> setSaturation(double v) async {
    _saturation = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySaturation, v);
    notifyListeners();
  }
}
