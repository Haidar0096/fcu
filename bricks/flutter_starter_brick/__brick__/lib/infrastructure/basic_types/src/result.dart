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
  const Success._(this.data);

  final S data;

  @override
  T when<T>({
    required T Function(S data) success,
    required T Function(Never data) failure,
  }) => success(data);

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
  String toString() => 'Failure{data: $data}';
}
