import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
      fontFamily: 'Roboto',
      // Здесь можно добавить другие стили, например, для текста или кнопок
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
      fontFamily: 'Roboto',
      // Здесь можно добавить другие стили, например, для текста или кнопок
    );
  }
}
