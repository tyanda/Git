import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeUtils {
  static const String _themeKey = 'user_theme_preference';

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

  static Future<void> saveThemePreference(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, (themeMode == ThemeMode.dark) ? 'dark' : 'light');
    } catch (e) {
      debugPrint("Ошибка при сохранении темы: $e");
    }
  }
}