import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('ru', null);
  } catch (e) {
    debugPrint("Ошибка локализации: $e");
  }

  runApp(const RadioApp());
}

class RadioApp extends StatefulWidget {
  const RadioApp({super.key});

  @override
  State<RadioApp> createState() => _RadioAppState();
}

class _RadioAppState extends State<RadioApp> {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'user_theme_preference';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null && mounted) {
        setState(() {
          _themeMode = (savedTheme == 'dark') ? ThemeMode.dark : ThemeMode.light;
        });
      }
    } catch (e) {
      debugPrint("Ошибка настроек темы: $e");
    }
  }

  void toggleTheme() async {
    final newMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    setState(() => _themeMode = newMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, (newMode == ThemeMode.dark) ? 'dark' : 'light');
    } catch (e) {
      debugPrint("Ошибка сохранения темы: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Радио Виктория',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: _themeMode,
      home: RadioVictoria(
          onThemeToggle: toggleTheme),
    );
  }
}

class RadioVictoria extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const RadioVictoria({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<RadioVictoria> createState() => _RadioVictoriaState();
}

class _RadioVictoriaState extends State<RadioVictoria> with TickerProviderStateMixin {
  late AudioPlayer _player;
  bool isPlaying = false;
  bool isLoading = false;

  String temperature = "--";
  String weatherDescription = "Загрузка...";
  String cityName = "ЯКУТСК";
  String weatherMain = "Clear";

  String horoscopeText = "Выберите ваш знак зодиака";
  String selectedZodiac = "";
  bool isHoroscopeLoading = false;

  final List<Map<String, String>> zodiacSigns = [
    {"id": "aries", "name": "Овен", "icon": "♈"},
    {"id": "taurus", "name": "Телец", "icon": "♉"},
    {"id": "gemini", "name": "Близнецы", "icon": "♊"},
    {"id": "cancer", "name": "Рак", "icon": "♋"},
    {"id": "leo", "name": "Лев", "icon": "♌"},
    {"id": "virgo", "name": "Дева", "icon": "♍"},
    {"id": "libra", "name": "Весы", "icon": "♎"},
    {"id": "scorpio", "name": "Скорпион", "icon": "♏"},
    {"id": "sagittarius", "name": "Стрелец", "icon": "♐"},
    {"id": "capricorn", "name": "Козерог", "icon": "♑"},
    {"id": "aquarius", "name": "Водолей", "icon": "♒"},
    {"id": "pisces", "name": "Рыбы", "icon": "♓"},
  ];

  late AnimationController _waveController;
  late AnimationController _floatController;

  Timer? _weatherTimer;
  Timer? _sleepTimer;
  int _remainingSeconds = 0;

  final String _streamUrl = 'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

    _initPlayerEvents();
    _fetchWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 15), (timer) => _fetchWeather());
  }

  Future<void> _fetchHoroscope(String zodiacId) async {
    if (!mounted) {
      return;
    }
    setState(() {
      isHoroscopeLoading = true;
      selectedZodiac = zodiacId;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    final List<String> predictions = [
      "Сегодня удачный день для новых начинаний. Звезды на вашей стороне!",
      "Звезды обещают приятный сюрприз во второй половине дня. Будьте открыты.",
      "Хорошее время для общения с близкими и старыми друзьями.",
      "Вас ждет успех в делах, связанных с творчеством и идеями.",
      "Сегодня интуиция — ваш лучший советчик. Слушайте сердце.",
    ];

    if (mounted) {
      setState(() {
        horoscopeText = predictions[math.Random().nextInt(predictions.length)];
        isHoroscopeLoading = false;
      });
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final response = await http
          .get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Yakutsk&appid=853f930e386c944167e43673c683884d&units=metric&lang=ru'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateWeatherData(
          temp: data['main']['temp'].round().toString(),
          desc: data['weather'][0]['description'],
          main: data['weather'][0]['main'],
        );
      }
    } catch (e) {
      debugPrint("Weather Error: $e");
    }
  }

  void _updateWeatherData({required String temp, required String desc, required String main}) {
    if (!mounted) {
      return;
    }
    setState(() {
      temperature = temp;
      weatherDescription = desc.isNotEmpty ? desc[0].toUpperCase() + desc.substring(1) : "";
      weatherMain = main;
    });
  }

  void _initPlayerEvents() {
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isLoading = state.processingState == ProcessingState.buffering || state.processingState == ProcessingState.loading;
          isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _togglePlay() async {
    try {
      if (isPlaying) {
        await _player.stop();
      } else {
        setState(() => isLoading = true);
        await _player.setAudioSource(AudioSource.uri(Uri.parse(_streamUrl)), preload: false);
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка подключения к эфиру')),
        );
      }
    }
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
        _player.stop();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _waveController.dispose();
    _floatController.dispose();
    _weatherTimer?.cancel();
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String currentDate = DateFormat('EEEE, d MMMM', 'ru').format(DateTime.now()).toUpperCase();

    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.blueGrey.shade400;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE0F2FE)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: widget.onThemeToggle,
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.amber : Colors.blueGrey),
                      ),
                      _buildTimerBadge(isDark),
                    ],
                  ),
                ),
                Text(currentDate,
                    style: TextStyle(
                        color: secondaryTextColor,
                        letterSpacing: 1.5,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildWeather(isDark, textColor, secondaryTextColor),
                const SizedBox(height: 30),
                _buildVisualizer(isDark),
                const SizedBox(height: 20),
                Text("Радио Виктория",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor)),
                const Text("102.4 FM • САХА СИРЭ",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                const SizedBox(height: 40),
                _buildPlayButton(isDark),
                const SizedBox(height: 40),
                _buildHoroscope(isDark, textColor, secondaryTextColor),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBadge(bool isDark) {
    return GestureDetector(
      onTap: () => _showTimerMenu(isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: _remainingSeconds > 0
                ? Colors.orange.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(Icons.timer,
                size: 20,
                color: _remainingSeconds > 0
                    ? Colors.orange
                    : (isDark ? Colors.white60 : Colors.blueGrey)),
            if (_remainingSeconds > 0)
              Text(
                  " ${(_remainingSeconds ~/ 60)}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather(bool isDark, Color textColor, Color secondaryTextColor) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 5 * _floatController.value),
        child: Column(children: [
          Icon(weatherMain == 'Clear' ? Icons.wb_sunny : Icons.wb_cloudy,
              size: 60,
              color: weatherMain == 'Clear' ? Colors.orange : Colors.blueGrey),
          Text("$temperature°",
              style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -2)),
          Text("$cityName • $weatherDescription",
              style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildVisualizer(bool isDark) {
    return SizedBox(
      height: 60,
      child: isPlaying
          ? AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) => CustomPaint(
            painter: WavePainter(
                animation: _waveController.value, isDark: isDark),
            size: const Size(double.infinity, 60)),
      )
          : Center(
          child: Container(
              width: 60,
              height: 2,
              color: Colors.blueGrey.withValues(alpha: 0.2))),
    );
  }

  Widget _buildPlayButton(bool isDark) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: isPlaying
                      ? Colors.blueAccent.withValues(alpha: 0.3)
                      : Colors.black12,
                  blurRadius: 30,
                  spreadRadius: 5)
            ]),
        child: Center(
          child: isLoading
              ? const SpinKitDoubleBounce(color: Colors.blueAccent, size: 50)
              : Icon(isPlaying ? Icons.pause : Icons.play_arrow,
              size: 60, color: isDark ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildHoroscope(bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
      child: Column(children: [
        const Text("ГОРОСКОП НА СЕГОДНЯ",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.blueAccent)),
        const SizedBox(height: 20),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: zodiacSigns.length,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _fetchHoroscope(zodiacSigns[i]['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                    color: selectedZodiac == zodiacSigns[i]['id']
                        ? Colors.blueAccent
                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Text(zodiacSigns[i]['icon']!,
                        style: const TextStyle(fontSize: 28))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        if (isHoroscopeLoading)
          const SpinKitThreeBounce(color: Colors.blueAccent, size: 20),
        if (!isHoroscopeLoading)
          Text(horoscopeText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 15,
                  height: 1.5)),
      ]),
    );
  }

  void _showTimerMenu(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("ТАЙМЕР СНА",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 20),
          ListTile(
              title: const Center(child: Text("15 минут")),
              onTap: () {
                _setSleepTimer(15);
                Navigator.pop(context);
              }),
          ListTile(
              title: const Center(child: Text("30 минут")),
              onTap: () {
                _setSleepTimer(30);
                Navigator.pop(context);
              }),
          ListTile(
              title: const Center(child: Text("60 минут")),
              onTap: () {
                _setSleepTimer(60);
                Navigator.pop(context);
              }),
          ListTile(
              title: const Center(child: Text("Отключить", style: TextStyle(color: Colors.red))),
              onTap: () {
                setState(() => _remainingSeconds = 0);
                _sleepTimer?.cancel();
                Navigator.pop(context);
              }),
        ]),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final bool isDark;
  WavePainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.blueAccent.withValues(alpha: 0.5)
          : Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (double i = 0; i <= size.width; i++) {
      double y = 30 +
          math.sin((i / size.width * 2 * math.pi) + (animation * 2 * math.pi)) *
              20;
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}