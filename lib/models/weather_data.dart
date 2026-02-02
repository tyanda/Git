class WeatherData {
  final String temperature;
  final String description;
  final String main;
  final String city;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.main,
    required this.city,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    return WeatherData(
      temperature: json['main']['temp'].round().toString(),
      description: json['weather'][0]['description'],
      main: json['weather'][0]['main'],
      city: city,
    );
  }

  factory WeatherData.fromMeteoJson(Map<String, dynamic> json, String city) {
    final current = json['current_weather'];
    return WeatherData(
      temperature: current['temperature'].round().toString(),
      description: _translateMeteoCode(current['weathercode']),
      main: _mapMeteoCodeToMain(current['weathercode']),
      city: city,
    );
  }

  static String _translateMeteoCode(int code) {
    if (code == 0) return "Ясно";
    if (code <= 3) return "Облачно";
    if (code <= 48) return "Туман";
    if (code <= 65) return "Дождь";
    if (code <= 77) return "Снег";
    return "Облачно";
  }

  static String _mapMeteoCodeToMain(int code) {
    if (code == 0) return "Clear";
    if (code <= 3) return "Clouds";
    if (code <= 65) return "Rain";
    if (code <= 77) return "Snow";
    return "Clouds";
  }
}