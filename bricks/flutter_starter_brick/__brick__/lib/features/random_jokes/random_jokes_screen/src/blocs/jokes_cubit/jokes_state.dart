part of 'jokes_cubit.dart';

/// Base state for the jokes feature.
sealed class JokesState {
  const JokesState();

  /// Whether a joke is currently being fetched.
  bool get isLoading => switch (this) {
    JokesLoadingState() => true,
    JokesInitialState() || JokesLoadedState() || JokesFailedState() => false,
  };

  /// The last joke that loaded successfully, retained during refresh and
  /// failure so the screen never blanks after it has useful data.
  UiJoke? get lastGoodJoke => switch (this) {
    JokesInitialState() => null,
    JokesLoadingState(:final lastGoodJoke) ||
    JokesFailedState(:final lastGoodJoke) =>
      lastGoodJoke,
    JokesLoadedState(:final joke) => joke,
  };
}

/// Initial state before any joke is fetched.
final class JokesInitialState extends JokesState {
  const JokesInitialState();
}

/// Loading state while fetching a joke.
final class JokesLoadingState extends JokesState {
  const JokesLoadingState({required this.lastGoodJoke});

  @override
  final UiJoke? lastGoodJoke;
}

/// Success state with a loaded joke.
final class JokesLoadedState extends JokesState {
  const JokesLoadedState({required this.joke});

  final UiJoke joke;
}

/// Error state when joke fetching fails.
final class JokesFailedState extends JokesState {
  const JokesFailedState({required this.uiFailure, required this.lastGoodJoke});

  final UiNetworkFailure uiFailure;

  @override
  final UiJoke? lastGoodJoke;
}
