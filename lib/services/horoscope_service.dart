import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter/foundation.dart';

class HoroscopeService {
  static const Map<String, String> _zodiacMap = {
    'aries': 'Овен',
    'taurus': 'Телец',
    'gemini': 'Близнецы',
    'cancer': 'Рак',
    'leo': 'Лев',
    'virgo': 'Дева',
    'libra': 'Весы',
    'scorpio': 'Скорпион',
    'sagittarius': 'Стрелец',
    'capricorn': 'Козерог',
    'aquarius': 'Водолей',
    'pisces': 'Рыбы',
  };

  Future<String> fetchHoroscope(String zodiacId) async {
    try {
      final url = Uri.parse('https://horo.mail.ru/prediction/$zodiacId/today/');
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var mainElement = document.querySelector('main[data-qa="ArticleLayout"]');
        if (mainElement != null) {
          mainElement.querySelectorAll('a').forEach((element) => element.remove());
          String cleanText = mainElement.text.trim();
          return cleanText.isNotEmpty ? cleanText : "Не удалось получить прогноз.";
        } else {
          throw Exception("Не удалось найти текст");
        }
      } else {
        throw Exception("Код: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Ошибка загрузки гороскопа: $e");
      // Return a default message when CORS or network issues occur
      return "Не удалось загрузить гороскоп. Проверьте подключение к интернету.";
    }
  }

  static Map<String, String> getZodiacSigns() {
    return _zodiacMap;
  }
}