import 'package:just_audio/just_audio.dart';

/// Источник данных для работы с аудио стримингом
class AudioRemoteDataSource {
  late AudioPlayer _player;
  static const String _streamUrl = 'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657';

  AudioRemoteDataSource() {
    _player = AudioPlayer();
  }

  /// Переключить состояние воспроизведения
  Future<void> togglePlayback() async {
    if (_player.playing) {
      await _player.stop();
    } else {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_streamUrl)),
        preload: false,
      );
      await _player.play();
    }
  }

  /// Загрузить аудио поток
  Future<void> loadAudioStream() async {
    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(_streamUrl)),
      preload: false,
    );
  }

  /// Получить текущее состояние воспроизведения
  bool get isPlaying => _player.playing;

  /// Получить состояние загрузки
  bool get isLoading => _player.processingState == ProcessingState.buffering ||
                        _player.processingState == ProcessingState.loading;

  /// Освободить ресурсы
  void dispose() {
    _player.dispose();
  }
}