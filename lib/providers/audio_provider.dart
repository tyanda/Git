import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider with ChangeNotifier {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  static const String _streamUrl = 'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657';

  AudioProvider() {
    _player = AudioPlayer();
    _initPlayerEvents();
    _autoPlay();
  }

  void _initPlayerEvents() {
    _player.playerStateStream.listen((state) {
      _isLoading = state.processingState == ProcessingState.buffering ||
                  state.processingState == ProcessingState.loading;
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> togglePlay() async {
    debugPrint("togglePlay called. Current state: isPlaying=$_isPlaying");
    if (_isPlaying) {
      debugPrint("Stopping audio playback");
      await _player.stop();
      debugPrint("Audio playback stopped");
    } else {
      debugPrint("Starting audio playback");
      _isLoading = true;
      notifyListeners();
      
      try {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(_streamUrl)),
          preload: false,
        );
        
        await _player.play();
        debugPrint("Audio playback started successfully");
      } catch (e) {
        debugPrint("Error starting audio playback: $e");
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _autoPlay() async {
    debugPrint("AutoPlay initiated");
    // Небольшая задержка перед автозапуском
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_streamUrl)),
        preload: false,
      );
      await _player.play();
      debugPrint("AutoPlay successful");
    } catch (e) {
      debugPrint("AutoPlay error: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}