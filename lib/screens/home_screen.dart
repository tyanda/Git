import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  int _colorIndex = 0;
  Timer? _bgTimer;

  @override
  void initState() {
    super.initState();

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

    _logoController.forward();

    _bgTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) setState(() => _colorIndex = (_colorIndex + 1) % 2);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<List<Color>> lightGradients = [
      [const Color(0xFFF8FAFC), const Color(0xFFE0F2FE), const Color(0xFFE8EFFF)],
      [const Color(0xFFE8EFFF), const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
    ];
    final List<List<Color>> darkGradients = [
      [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF334155)],
      [const Color(0xFF1E293B), const Color(0xFF0F172A), const Color(0xFF1E1B4B)],
    ];
    final currentGradient = isDark ? darkGradients[_colorIndex] : lightGradients[_colorIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: currentGradient,
              ),
            ),
          ),
          
          // Weather widget container positioned at the top
          Positioned(
            top: 66,
            left: 16,
            right: 16,
            child: Container(
              width: 382,
              height: 251,
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1E293B).withOpacity(0.8) 
                    : Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.2) 
                      : Colors.black.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: const Center(
                child: Text(
                  "Погода",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          // Centered animated logo
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFadeAnimation.value,
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withValues(
                                alpha: 0.2 * _logoFadeAnimation.value),
                            blurRadius: 60,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 160,
                        height: 160,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}