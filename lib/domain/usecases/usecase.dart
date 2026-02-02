/// Базовый класс для всех Use Cases
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

/// Базовый класс для Use Cases без параметров
abstract class UseCaseWithoutParams<T> {
  Future<T> call();
}