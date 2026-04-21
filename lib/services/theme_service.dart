import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeService extends ChangeNotifier {
  final SharedPreferences _prefs;
  late bool _isDarkMode;
  bool _hasUserPreference = false;

  ThemeService(this._prefs) {
    final saved = _prefs.getBool(AppConstants.themeKey);
    if (saved != null) {
      _isDarkMode = saved;
      _hasUserPreference = true;
    } else {
      // Follow the device/system setting
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
    }
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    if (!_hasUserPreference) return ThemeMode.system;
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _hasUserPreference = true;
    _prefs.setBool(AppConstants.themeKey, _isDarkMode);
    notifyListeners();
  }
}
