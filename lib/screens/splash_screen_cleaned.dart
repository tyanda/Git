import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const SplashScreen({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Настройка анимации логотипа
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Запуск анимации логотипа
    _logoController.forward();

    // Переход на главный экран через 3.5 секунды
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainScreen(
              onThemeToggle: widget.onThemeToggle,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Фоновое изображение из папки assets
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(isDark ? 'assets/bg_dark.png' : 'assets/bg_light.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Затемняющий слой для глубины
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),

          // 3. Контент (Логотип и Индикатор)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированный логотип
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.3 * _logoFadeAnimation.value),
                                blurRadius: 50,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 180,
                            height: 180,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Текст "Давайте начнем" как на референсе
                Text(
                  "Давайте начнем",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Индикатор загрузки без текста
                const SpinKitWave(
                  color: Colors.white30,
                  size: 40,
                  type: SpinKitWaveType.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}