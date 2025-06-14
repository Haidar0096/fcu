part of 'jokes_cubit.dart';

sealed class JokesState {
  bool get loading;
}

final class JokesInitial extends JokesState {
  @override
  bool get loading => false;
}

final class JokesLoading extends JokesState {
  @override
  bool get loading => true;
}

final class JokesLoaded extends JokesState {
  JokesLoaded(this.joke);

  final UiJoke joke;

  @override
  bool get loading => false;
}

final class JokesFailed extends JokesState {
  JokesFailed(this.message);

  final String message;

  @override
  bool get loading => false;
}
