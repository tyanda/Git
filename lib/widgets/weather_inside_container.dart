import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';

class WeatherInsideContainer extends StatelessWidget {
  final bool isDark;

  const WeatherInsideContainer({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final weatherData = weatherProvider.weatherData;
        if (weatherData == null) {
          return const Center(
            child: Text(
              "Данные недоступны",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // Определение иконки и её цвета в зависимости от погоды
        Map<String, dynamic> getWeatherStyle(String description) {
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

        final style = getWeatherStyle(weatherData.description);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Город и описание
              Transform.translate(
                offset: const Offset(-39, 0),
                child: Text(
                  weatherData.city,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                weatherData.description.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Иконка погоды и температура
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    style['icon'],
                    size: 64,
                    color: style['color'],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${weatherData.temperature}°",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Ощущается ${weatherData.feelsLike}°",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Компактное отображение дополнительной информации
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSimpleWeatherInfo(
                    icon: Icons.water_drop,
                    value: "${weatherData.humidity}%",
                    color: Colors.blue[200]!,
                  ),
                  _buildSimpleWeatherInfo(
                    icon: Icons.air,
                    value: weatherData.windSpeed.toStringAsFixed(1),
                    color: Colors.green[200]!,
                  ),
                  _buildSimpleWeatherInfo(
                    icon: Icons.compress,
                    value: weatherData.pressure.toString(),
                    color: Colors.purple[200]!,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Вспомогательный метод для создания простого элемента погоды
  Widget _buildSimpleWeatherInfo({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}