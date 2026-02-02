/// Модель состояния аудио плеера
class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final String? errorMessage;

  AudioState({
    required this.isPlaying,
    required this.isLoading,
    this.errorMessage,
  });

  /// Создает копию состояния с обновленными значениями
  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Создает состояние по умолчанию (не воспроизводится, не загружается)
  factory AudioState.initial() {
    return AudioState(
      isPlaying: false,
      isLoading: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AudioState &&
      other.isPlaying == isPlaying &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => isPlaying.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;

  @override
  String toString() => 'AudioState(isPlaying: $isPlaying, isLoading: $isLoading, errorMessage: $errorMessage)';
}