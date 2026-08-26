part of 'jokes_cubit.dart';

/// Base state for jokes feature
sealed class JokesState {
  const JokesState();

  /// Whether a joke is currently being fetched.
  bool get isLoading => switch (this) {
    JokesLoading() => true,
    JokesInitial() || JokesLoaded() || JokesFailed() => false,
  };
}

/// Initial state before any joke is fetched
final class JokesInitial extends JokesState {
  const JokesInitial();
}

/// Loading state while fetching a joke
final class JokesLoading extends JokesState {
  const JokesLoading();
}

/// Success state with a loaded joke
final class JokesLoaded extends JokesState {
  const JokesLoaded(this.joke);

  final UiJoke joke;
}

/// Error state when joke fetching fails
final class JokesFailed extends JokesState {
  const JokesFailed(this.uiFailure);

  final UiNetworkFailure uiFailure;
}
