import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/horoscope_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/splash_screen.dart';
import 'ui/app_theme.dart';
import 'navigation/app_router.dart';

/// Главная точка входа в приложение "Радио Виктория"
///
/// Метод инициализирует:
/// - Загрузку переменных окружения
/// - Настройку ориентации экрана
/// - Локализацию
/// - Предпочтения темы
/// - Провайдеры состояний
void main() async {
  debugPrint("Начало инициализации приложения");

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("Flutter Binding инициализирован");

  // Загрузка переменных окружения из файла .env с обработкой ошибок
  try {
    await dotenv.load(fileName: ".env");
    debugPrint(".env файл успешно загружен");
  } catch (e) {
    debugPrint("Ошибка загрузки .env файла: $e");
  }

  // Блокировка ориентации экрана в портретный режим с обработкой ошибок
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint("Ориентация экрана установлена");
  } catch (e) {
    debugPrint("Ошибка установки ориентации экрана: $e");
  }

  // Инициализация локализации для форматирования дат
  try {
    await initializeDateFormatting('ru', null);
    debugPrint("Локализация инициализирована");
  } catch (e) {
    debugPrint("Ошибка инициализации локализации: $e");
  }

  // Загрузка сохраненных пользовательских предпочтений темы
  final initialThemeMode = await ThemeProvider.loadThemePreference();

  runApp(
    MultiProvider(
      providers: [
        // Провайдер управления темой приложения
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialThemeMode)),
        // Провайдер погоды
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        // Провайдер гороскопа
        ChangeNotifierProvider(create: (_) => HoroscopeProvider()),
        // Провайдер аудио
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: const RadioApp(),
    ),
  );
}

/// Основной класс приложения, управляющий темой и маршрутизацией
class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'СахаРадио',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          onGenerateRoute: AppRouter.generateRoute,
          home: SplashScreen(
            onThemeToggle: context.read<ThemeProvider>().toggleTheme,
          ),
        );
      },
    );
  }
}