import 'package:sakha_radio/domain/usecases/usecase.dart';
import 'package:sakha_radio/domain/repositories/audio_repository.dart';

/// Use Case для загрузки аудио потока
class LoadAudioStream implements UseCaseWithoutParams<void> {
  final AudioRepository _audioRepository;

  LoadAudioStream(this._audioRepository);

  @override
  Future<void> call() async {
    return _audioRepository.loadAudioStream();
  }
}