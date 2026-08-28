sealed class Result<F, S> {
  const Result();

  factory Result.success({required S data}) => Success._(data: data);

  factory Result.failure({required F data}) => Failure._(data: data);

  T when<T>({
    required T Function(S data) success,
    required T Function(F data) failure,
  });

  /// Transforms the success value if present, otherwise passes
  /// through the failure as is.
  Result<F, S2> mapSuccess<S2>(S2 Function(S data) transform) => when(
    success: (data) => Result.success(data: transform(data)),
    failure: (data) => Result.failure(data: data),
  );

  Future<T> whenAsync<T>({
    required Future<T> Function(S data) success,
    required Future<T> Function(F data) failure,
  });
}

final class Success<S> extends Result<Never, S> {
  const Success._({required this.data});

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

final class Failure<F> extends Result<F, Never> {
  const Failure._({required this.data});

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
