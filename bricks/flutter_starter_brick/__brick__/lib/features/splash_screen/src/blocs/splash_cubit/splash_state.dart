part of 'splash_cubit.dart';

/// Base state for splash screen
sealed class SplashState {
  const SplashState();
}

/// Initial state when splash screen loads
final class SplashInitialState extends SplashState {
  const SplashInitialState();
}

/// State when splash initialization is complete and ready to navigate
final class SplashCompleteState extends SplashState {
  const SplashCompleteState();
}

/// State when a critical unrecoverable error occurs
final class SplashCriticalErrorState extends SplashState {
  const SplashCriticalErrorState();
}
