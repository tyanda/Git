class WeatherData {
  final String temperature;
  final String feelsLike;
  final String description;
  final String city;
  final int humidity;
  final int pressure;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.city,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    return WeatherData(
      temperature: json['main']['temp'].round().toString(),
      feelsLike: json['main']['feels_like'].round().toString(),
      description: json['weather'][0]['description'],
      city: city,
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'],
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
    );
  }

  factory WeatherData.fromMeteoJson(Map<String, dynamic> json, String city) {
    final current = json['current_weather'];
    
    return WeatherData(
      temperature: current['temperature'].round().toString(),
      feelsLike: current['temperature'].round().toString(), // Open-Meteo не предоставляет ощущаемую температуру
      description: _translateMeteoCode(current['weathercode']),
      city: city,
      humidity: 65, // по умолчанию, так как Open-Meteo не предоставляет
      pressure: 1013, // по умолчанию, так как Open-Meteo не предоставляет
      windSpeed: current['windspeed'].toDouble(),
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
}