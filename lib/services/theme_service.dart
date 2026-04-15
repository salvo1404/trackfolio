import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'storage_service.dart';
import '../utils/constants.dart';

class ThemeService extends ChangeNotifier {
  final StorageService _storage;
  late bool _isDarkMode;
  bool _hasUserPreference = false;

  ThemeService(this._storage) {
    final saved = _storage.getBool(AppConstants.themeKey);
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
    _storage.setBool(AppConstants.themeKey, _isDarkMode);
    notifyListeners();
  }
}
