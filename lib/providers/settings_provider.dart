import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyShowWeekend = 'show_weekend';
  static const _keyCompactMode = 'compact_mode';
  static const _keySeedColor = 'seed_color';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keySectionCount = 'section_count';

  bool _showWeekend = false;
  bool _compactMode = false;
  int _seedColor = 0xFF5B9BD5;
  bool _onboardingDone = false;
  int _sectionCount = 12;

  bool get showWeekend => _showWeekend;
  bool get compactMode => _compactMode;
  int get seedColor => _seedColor;
  bool get onboardingDone => _onboardingDone;
  int get sectionCount => _sectionCount;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _showWeekend = prefs.getBool(_keyShowWeekend) ?? false;
    _compactMode = prefs.getBool(_keyCompactMode) ?? false;
    _seedColor = prefs.getInt(_keySeedColor) ?? 0xFF5B9BD5;
    _onboardingDone = prefs.getBool(_keyOnboardingDone) ?? false;
    _sectionCount = prefs.getInt(_keySectionCount) ?? 12;
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
}
