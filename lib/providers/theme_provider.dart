import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Provider managing active ThemeMode (Light, Dark, or System Default)
/// with seamless local persistence across app restarts.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeFromDisk();
  }

  ThemeMode get themeMode => _themeMode;

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<File?> _getStorageFile() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return null;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/pocket_theme_mode.txt');
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadThemeFromDisk() async {
    try {
      final file = await _getStorageFile();
      if (file != null && await file.exists()) {
        final text = (await file.readAsString()).trim().toLowerCase();
        if (text == 'dark') {
          _themeMode = ThemeMode.dark;
          notifyListeners();
        } else if (text == 'light') {
          _themeMode = ThemeMode.light;
          notifyListeners();
        } else if (text == 'system') {
          _themeMode = ThemeMode.system;
          notifyListeners();
        }
      }
    } catch (_) {
      // Keep default
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final file = await _getStorageFile();
      if (file != null) {
        String modeString = 'system';
        if (mode == ThemeMode.dark) modeString = 'dark';
        if (mode == ThemeMode.light) modeString = 'light';
        await file.writeAsString(modeString);
      }
    } catch (_) {
      // In-memory fallback
    }
  }
}
