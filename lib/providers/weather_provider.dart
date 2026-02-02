import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;

  final WeatherService _weatherService = WeatherService();

  Future<void> fetchWeather() async {
    debugPrint("WeatherProvider: fetchWeather called");
    // If we have recent data (less than 10 minutes old), use it
    if (_weatherData != null && _lastFetchTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastFetchTime!);
      if (difference.inMinutes < 10) {
        debugPrint("WeatherProvider: Using cached data (less than 10 minutes old)");
        // Use cached data
        return;
      }
    }

    debugPrint("WeatherProvider: Fetching new weather data");
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _weatherService.fetchWeather();
      if (data != null) {
        debugPrint("WeatherProvider: New weather data received");
        _weatherData = data;
        _lastFetchTime = DateTime.now();
      } else {
        debugPrint("WeatherProvider: No weather data received from service");
      }
    } catch (e) {
      debugPrint("WeatherProvider: Weather fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}