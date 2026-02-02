import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
    }
  }
}
