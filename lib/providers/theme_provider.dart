import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  static const String _themeKey = 'user_theme_preference';

  ThemeProvider(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  static Future<ThemeMode> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        return (savedTheme == 'dark') ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint("Ошибка при загрузке темы: $e");
    }
    return ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, (_themeMode == ThemeMode.dark) ? 'dark' : 'light');
    } catch (e) {
      debugPrint("Ошибка при сохранении темы: $e");
    }
  }
}