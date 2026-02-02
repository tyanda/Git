import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_data.dart';

class WeatherService {
  static final String _openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static const String _city = "Yakutsk";
  
  Future<WeatherData?> fetchWeather() async {
    debugPrint("Fetching weather data for $_city");
    try {
      // Try OpenWeather first
      final openWeatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_openWeatherApiKey&units=metric&lang=ru'
      );
      
      debugPrint("Attempting OpenWeather API call: $openWeatherUrl");
      final openWeatherResponse = await http.get(openWeatherUrl, headers: {
        'User-Agent': 'RadioVictoria/1.0 (Web)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));
      
      debugPrint("OpenWeather response status: ${openWeatherResponse.statusCode}");
      if (openWeatherResponse.statusCode == 200) {
        final data = json.decode(openWeatherResponse.body);
        debugPrint("OpenWeather data received successfully");
        return WeatherData.fromJson(data, _city);
      } else {
        debugPrint("OpenWeather API returned status ${openWeatherResponse.statusCode}");
      }
    } catch (e) {
      debugPrint("OpenWeather failed: $e");
    }
    
    // Fallback to Open-Meteo
    debugPrint("Falling back to Open-Meteo API");
    try {
      final meteoUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=62.03&longitude=129.73&current_weather=true&timezone=Asia/Yakutsk'
      );
      
      debugPrint("Attempting Open-Meteo API call: $meteoUrl");
      final meteoResponse = await http.get(meteoUrl, headers: {
        'User-Agent': 'RadioVictoria/1.0 (Web)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));
      
      debugPrint("Open-Meteo response status: ${meteoResponse.statusCode}");
      if (meteoResponse.statusCode == 200) {
        final data = json.decode(meteoResponse.body);
        debugPrint("Open-Meteo data received successfully");
        return WeatherData.fromMeteoJson(data, _city);
      } else {
        debugPrint("Open-Meteo API returned status ${meteoResponse.statusCode}");
      }
    } catch (e) {
      debugPrint("Open-Meteo failed: $e");
    }
    
    debugPrint("Both weather services failed, returning null");
    return null;
  }
}