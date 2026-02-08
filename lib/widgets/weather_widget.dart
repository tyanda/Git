import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherWidget extends StatefulWidget {
  final bool isDark;
  final Color textColor;
  final Color secondaryTextColor;
  final double screenHeight;
  final double screenWidth;

  const WeatherWidget({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.secondaryTextColor,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    // Анимация плавного парения (вверх-вниз)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  // Определение иконки и её цвета в зависимости от погоды
  Map<String, dynamic> _getWeatherStyle(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('облач') || desc.contains('cloud')) {
      return {'icon': Icons.cloud_queue, 'color': Colors.blueGrey[300]};
    } else if (desc.contains('дождь') || desc.contains('rain')) {
      return {'icon': Icons.umbrella_rounded, 'color': Colors.blueAccent};
    } else if (desc.contains('снег') || desc.contains('snow')) {
      return {'icon': Icons.ac_unit, 'color': Colors.lightBlueAccent};
    } else if (desc.contains('гроза') || desc.contains('storm')) {
      return {'icon': Icons.thunderstorm, 'color': Colors.deepPurpleAccent};
    }
    // По умолчанию: Солнце
    return {'icon': Icons.wb_sunny_rounded, 'color': Colors.orangeAccent};
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final weatherData = weatherProvider.weatherData;
        if (weatherData == null) {
          return Center(
            child: Text(
              "Данные недоступны",
              style: TextStyle(color: widget.textColor, fontSize: 16),
            ),
          );
        }

        final style = _getWeatherStyle(weatherData.description);

        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              // Эффект парения: смещение по вертикали
              offset: Offset(0, 12 * _floatController.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Город и описание
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "${weatherData.city} • ${weatherData.description}".toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: widget.secondaryTextColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Иконка погоды
                  Icon(
                    style['icon'],
                    size: widget.screenWidth * 0.2,
                    color: style['color'],
                  ),

                  // Температура
                  Text(
                    "${weatherData.temperature}°",
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.28,
                      fontWeight: FontWeight.w900,
                      color: widget.textColor,
                      height: 1.1,
                      letterSpacing: -5,
                    ),
                  ),

                  // Ощущается как
                  Text(
                    "Ощущается как ${weatherData.feelsLike}°",
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.secondaryTextColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Дополнительная информация
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Colors.blue[300],
                            size: widget.screenWidth * 0.08,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${weatherData.humidity}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.secondaryTextColor,
                            ),
                          ),
                          Text(
                            "Влажность",
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.air,
                            color: Colors.green[300],
                            size: widget.screenWidth * 0.08,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${weatherData.windSpeed.toStringAsFixed(1)} м/с",
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.secondaryTextColor,
                            ),
                          ),
                          Text(
                            "Ветер",
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.compress,
                            color: Colors.purple[300],
                            size: widget.screenWidth * 0.08,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${weatherData.pressure} мм",
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.secondaryTextColor,
                            ),
                          ),
                          Text(
                            "Давление",
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}