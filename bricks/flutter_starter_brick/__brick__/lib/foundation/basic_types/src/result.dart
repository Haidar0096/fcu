sealed class Result<F, S> {
  const Result();

  factory Result.success(S data) => Success._(data);

  factory Result.failure(F data) => Failure._(data);

  T when<T>({
    required T Function(S data) success,
    required T Function(F data) failure,
  });

  /// Transforms the success value if present, otherwise passes
  /// through the failure as is.
  Result<F, S2> mapSuccess<S2>(S2 Function(S data) transform) => when(
    success: (data) => Result.success(transform(data)),
    failure: Result.failure,
  );

  Future<T> whenAsync<T>({
    required Future<T> Function(S data) success,
    required Future<T> Function(F data) failure,
  });
}

class Success<S> extends Result<Never, S> {
  const Success._(this.data);

  final S data;

  @override
  T when<T>({
    required T Function(S data) success,
    required T Function(Never data) failure,
  }) => success(data);

  @override
  Future<T> whenAsync<T>({
    required Future<T> Function(S data) success,
    required Future<T> Function(Never data) failure,
  }) async => success(data);

  @override
  String toString() => 'Success{data: $data}';
}

class Failure<F> extends Result<F, Never> {
  const Failure._(this.data);

  final F data;

  @override
  T when<T>({
    required T Function(Never data) success,
    required T Function(F data) failure,
  }) => failure(data);

  @override
  Future<T> whenAsync<T>({
    required Future<T> Function(Never data) success,
    required Future<T> Function(F data) failure,
  }) async => failure(data);

  @override
  String toString() => 'Failure{data: $data}';
}
