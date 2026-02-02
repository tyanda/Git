import 'package:flutter/material.dart';
import '../services/horoscope_service.dart';

class HoroscopeProvider with ChangeNotifier {
  String _horoscopeText = "Нажмите на ваш знак зодиака для прогноза";
  String _selectedZodiac = "";
  bool _isLoading = false;

  // Cache for horoscope data
  final Map<String, String> _horoscopeCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  String get horoscopeText => _horoscopeText;
  String get selectedZodiac => _selectedZodiac;
  bool get isLoading => _isLoading;

  final HoroscopeService _horoscopeService = HoroscopeService();

  Future<void> fetchHoroscope(String zodiacId) async {
    debugPrint("HoroscopeProvider: fetchHoroscope called for zodiacId: $zodiacId");
    // If the same zodiac sign is tapped again, reset
    if (_selectedZodiac == zodiacId) {
      debugPrint("HoroscopeProvider: Same zodiac sign tapped, resetting");
      _selectedZodiac = "";
      _horoscopeText = "Нажмите на ваш знак зодиака для прогноза";
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Check cache first (valid for 1 hour)
    if (_horoscopeCache.containsKey(zodiacId)) {
      final cacheTime = _cacheTimestamps[zodiacId];
      if (cacheTime != null) {
        final now = DateTime.now();
        final difference = now.difference(cacheTime);
        if (difference.inHours < 1) {
          debugPrint("HoroscopeProvider: Using cached data for $zodiacId");
          // Use cached data
          _selectedZodiac = zodiacId;
          _horoscopeText = _horoscopeCache[zodiacId]!;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
    }

    debugPrint("HoroscopeProvider: Fetching new data for $zodiacId");
    _isLoading = true;
    _selectedZodiac = zodiacId;
    _horoscopeText = "Загрузка прогноза...";
    notifyListeners();

    try {
      final text = await _horoscopeService.fetchHoroscope(zodiacId);
      debugPrint("HoroscopeProvider: Received horoscope text with length: ${text.length}");
      _horoscopeText = text;

      // Cache the result
      _horoscopeCache[zodiacId] = text;
      _cacheTimestamps[zodiacId] = DateTime.now();
    } catch (e) {
      _horoscopeText = "Не удалось загрузить гороскоп.";
      debugPrint("HoroscopeProvider: Horoscope fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}