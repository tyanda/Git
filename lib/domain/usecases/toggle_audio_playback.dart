import 'package:sakha_radio/domain/usecases/usecase.dart';
import 'package:sakha_radio/domain/repositories/audio_repository.dart';

/// Use Case для переключения состояния воспроизведения аудио
class ToggleAudioPlayback implements UseCaseWithoutParams<void> {
  final AudioRepository _audioRepository;

  ToggleAudioPlayback(this._audioRepository);

  @override
  Future<void> call() async {
    return _audioRepository.togglePlayback();
  }
}