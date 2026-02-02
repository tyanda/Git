import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_data.dart';

class WeatherService {
  static final String _openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String _city = "Yakutsk";
  
  Future<WeatherData?> fetchWeather() async {
    try {
      // Try OpenWeather first
      final openWeatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_openWeatherApiKey&units=metric&lang=ru'
      );
      
      final openWeatherResponse = await http.get(openWeatherUrl, headers: {
        'User-Agent': 'RadioVictoria/1.0 (Web)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));
      
      if (openWeatherResponse.statusCode == 200) {
        final data = json.decode(openWeatherResponse.body);
        return WeatherData.fromJson(data, _city);
      }
    } catch (e) {
      debugPrint("OpenWeather failed: $e");
    }
    
    // Fallback to Open-Meteo
    try {
      final meteoUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=62.03&longitude=129.73&current_weather=true&timezone=Asia/Yakutsk'
      );
      
      final meteoResponse = await http.get(meteoUrl, headers: {
        'User-Agent': 'RadioVictoria/1.0 (Web)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));
      
      if (meteoResponse.statusCode == 200) {
        final data = json.decode(meteoResponse.body);
        return WeatherData.fromMeteoJson(data, _city);
      }
    } catch (e) {
      debugPrint("Open-Meteo failed: $e");
    }
    
    return null;
  }
}