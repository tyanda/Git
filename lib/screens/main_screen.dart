import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/audio_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/weather_widget.dart';
import '../widgets/horoscope_widget.dart';
import '../navigation/app_router.dart'; // Импортируем наш роутер

class MainScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const MainScreen({super.key, required this.onThemeToggle});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  int _colorIndex = 0;
  Timer? _bgTimer;
  Timer? _weatherTimer;
  int _remainingSeconds = 0;
  Timer? _sleepTimer;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _logoController = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _logoAnimation = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _logoController.repeat(reverse: true);

    _bgTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) setState(() => _colorIndex = (_colorIndex + 1) % 2);
    });

    // Load initial weather data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeather();
    });

    // Set up periodic weather updates
    _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      context.read<WeatherProvider>().fetchWeather();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    _logoController.dispose();
    _bgTimer?.cancel();
    _weatherTimer?.cancel();
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String currentDate = "";
    try {
      currentDate = DateFormat('EEEE, d MMMM', 'ru').format(DateTime.now()).toUpperCase();
    } catch (_) {
      currentDate = "СЕГОДНЯ";
    }

    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.blueGrey.shade400;

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final scrollPhysics = Theme.of(context).platform == TargetPlatform.android
        ? const ClampingScrollPhysics()
        : const BouncingScrollPhysics();

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
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: currentGradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _logoAnimation.value,
                    child: Image.asset(
                      'assets/logo.png',
                      width: screenWidth * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                
                // Определяем, является ли устройство планшетом или телефоном
                final isTablet = maxWidth > 600;
                
                // Адаптируем размеры в зависимости от типа устройства
                final double contentPadding = isTablet ? 32.0 : 20.0;
                final double elementSpacing = isTablet ? 0.03 : 0.02;
                
                return SingleChildScrollView(
                  physics: scrollPhysics,
                  padding: EdgeInsets.all(contentPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeader(isDark, textColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            Text(
                              currentDate,
                              style: TextStyle(
                                color: isDark ? Colors.white24 : Colors.blueGrey.withValues(alpha: 0.4),
                                letterSpacing: 2,
                                fontSize: maxWidth * 0.03,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: maxHeight * elementSpacing),
                        _buildWeatherSection(isDark, textColor, secondaryTextColor, maxHeight, maxWidth),
                        SizedBox(height: maxHeight * elementSpacing),
                        AudioVisualizer(isDark: isDark, screenHeight: maxHeight),
                        SizedBox(height: maxHeight * elementSpacing),
                        Column(
                          children: [
                            Text(
                              "СахаRadio",
                              style: TextStyle(
                                fontSize: maxWidth * 0.07,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 4),
                                Text(
                                  "102.4 FM • Радио Виктория",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: maxWidth * 0.035,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: maxHeight * elementSpacing),
                        _buildPlayButton(isDark, maxWidth),
                        SizedBox(height: maxHeight * elementSpacing),
                        HoroscopeWidget(
                          isDark: isDark,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          screenWidth: maxWidth,
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildHeader(bool isDark, Color textColor) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: widget.onThemeToggle,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amberAccent : Colors.blueGrey,
              size: 28,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.settings);
                },
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white70 : Colors.blueGrey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              _buildSleepTimerBadge(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection(bool isDark, Color textColor, Color secondaryTextColor, double screenHeight, double screenWidth) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 8 * _floatController.value),
        child: WeatherWidget(
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        ),
      ),
    );
  }

  Widget _buildPlayButton(bool isDark, double screenWidth) {
    double buttonSize = screenWidth * 0.25;
    
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return GestureDetector(
          onTap: audioProvider.togglePlay,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: audioProvider.isPlaying ? Colors.blueAccent.withValues(alpha: 0.4) : Colors.black12,
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Center(
              child: audioProvider.isLoading
                  ? SpinKitDoubleBounce(color: Colors.blueAccent, size: buttonSize * 0.4)
                  : Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: buttonSize * 0.65,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepTimerBadge(bool isDark) {
    return GestureDetector(
      onTap: () => _showSleepTimerMenu(isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _remainingSeconds > 0 ? Colors.orange.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer_outlined, 
              size: 20, 
              color: _remainingSeconds > 0 ? Colors.orange : (isDark ? Colors.white60 : Colors.blueGrey)
            ),
            if (_remainingSeconds > 0) ...[
              const SizedBox(width: 8),
              Text(
                "${(_remainingSeconds ~/ 60)}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.orange)
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSleepTimerMenu(bool isDark) {
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.blueGrey.shade400;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ТАЙМЕР СНА", 
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                color: secondaryTextColor, 
                letterSpacing: 1
              )
            ),
            const SizedBox(height: 15),
            _timerTile("15 минут", 15, isDark),
            _timerTile("30 минут", 30, isDark),
            _timerTile("60 минут", 60, isDark),
            if (_remainingSeconds > 0)
              TextButton(
                onPressed: () { 
                  setState(() => _remainingSeconds = 0); 
                  _sleepTimer?.cancel();
                  Navigator.pop(context); 
                },
                child: const Text(
                  "Отключить", 
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
                )
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _timerTile(String title, int mins, bool isDark) {
    return ListTile(
      title: Center(
        child: Text(
          title, 
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black, 
            fontWeight: FontWeight.w600
          )
        )
      ),
      onTap: () { 
        _setSleepTimer(mins);
        Navigator.pop(context); 
      },
    );
  }

  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() => _remainingSeconds = minutes * 60);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { 
        timer.cancel(); 
        return; 
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        // Stop the audio when timer ends
        context.read<AudioProvider>().togglePlay();
        timer.cancel();
      }
    });
  }
}