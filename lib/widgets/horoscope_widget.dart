import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/horoscope_provider.dart';
import '../services/horoscope_service.dart';

class HoroscopeWidget extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color secondaryTextColor;
  final double screenWidth;

  const HoroscopeWidget({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.secondaryTextColor,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ГОРОСКОП",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: secondaryTextColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 75,
            child: _buildZodiacSignsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacSignsList(BuildContext context) {
    final zodiacSigns = HoroscopeService.getZodiacSigns();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      physics: const BouncingScrollPhysics(),
      itemCount: zodiacSigns.length,
      itemBuilder: (context, index) {
        final entry = zodiacSigns.entries.elementAt(index);
        final id = entry.key;
        final name = entry.value;

        return Consumer<HoroscopeProvider>(
          builder: (context, horoscopeProvider, child) {
            final isSelected = horoscopeProvider.selectedZodiac == id;

            return GestureDetector(
              onTap: () {
                _showHoroscopeModal(context, id, name);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 65,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : (isDark ? Colors.white10 : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getZodiacIcon(id),
                      style: TextStyle(fontSize: 24, color: isSelected ? Colors.white : null),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showHoroscopeModal(BuildContext context, String id, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Consumer<HoroscopeProvider>(
              builder: (context, horoscopeProvider, child) {
                // Загружаем гороскоп при открытии модального окна
                if (horoscopeProvider.selectedZodiac != id || horoscopeProvider.horoscopeText == "Нажмите на ваш знак зодиака для прогноза") {
                  Future.microtask(() => horoscopeProvider.fetchHoroscope(id));
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Ручка для перетаскивания
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white30 : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Заголовок
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              _getZodiacIcon(id),
                              style: const TextStyle(fontSize: 30),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      // Разделитель
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                      // Контент гороскопа
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Scrollbar(
                            controller: scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  if (horoscopeProvider.isLoading && horoscopeProvider.selectedZodiac == id)
                                    const SpinKitThreeBounce(color: Colors.blueAccent, size: 25)
                                  else
                                    Text(
                                      horoscopeProvider.horoscopeText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getZodiacIcon(String id) {
    switch (id) {
      case 'aries': return "♈";
      case 'taurus': return "♉";
      case 'gemini': return "♊";
      case 'cancer': return "♋";
      case 'leo': return "♌";
      case 'virgo': return "♍";
      case 'libra': return "♎";
      case 'scorpio': return "♏";
      case 'sagittarius': return "♐";
      case 'capricorn': return "♑";
      case 'aquarius': return "♒";
      case 'pisces': return "♓";
      default: return "★";
    }
  }
}