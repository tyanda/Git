import 'package:sakha_radio/domain/models/audio_state.dart';

/// Абстрактный класс репозитория для работы с аудио
abstract class AudioRepository {
  /// Получить текущее состояние аудио
  Future<AudioState> getAudioState();

  /// Переключить состояние воспроизведения
  Future<void> togglePlayback();

  /// Загрузить аудио поток
  Future<void> loadAudioStream();
}