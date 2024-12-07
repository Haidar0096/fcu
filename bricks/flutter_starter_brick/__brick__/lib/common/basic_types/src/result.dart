sealed class Result<F, S> {
  const Result();

  factory Result.success(S data) => Success._(data);

  factory Result.failure(F data) => Failure._(data);

  T when<T>({
    required T Function(S data) success,
    required T Function(F data) failure,
  });
}

class Success<S> extends Result<Never, S> {
  final S data;

  const Success._(this.data);

  @override
  T when<T>({
    required T Function(S data) success,
    required T Function(Never data) failure,
  }) =>
      success(data);
}

class Failure<F> extends Result<F, Never> {
  final F data;

  const Failure._(this.data);

  @override
  T when<T>({
    required T Function(Never data) success,
    required T Function(F data) failure,
  }) =>
      failure(data);
}
