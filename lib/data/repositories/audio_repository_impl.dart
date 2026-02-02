import 'package:sakha_radio/domain/repositories/audio_repository.dart';
import 'package:sakha_radio/domain/models/audio_state.dart';
import 'package:sakha_radio/data/datasources/audio_remote_data_source.dart';

/// Реализация репозитория для работы с аудио
class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource _remoteDataSource;

  AudioRepositoryImpl(this._remoteDataSource);

  @override
  Future<AudioState> getAudioState() async {
    // В реальной реализации здесь будет логика получения состояния
    // Пока возвращаем состояние по умолчанию
    return AudioState.initial();
  }

  @override
  Future<void> togglePlayback() async {
    // Делегируем управление воспроизведением источнику данных
    return _remoteDataSource.togglePlayback();
  }

  @override
  Future<void> loadAudioStream() async {
    // Делегируем загрузку потока источнику данных
    return _remoteDataSource.loadAudioStream();
  }
}