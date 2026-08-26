part of 'splash_cubit.dart';

/// Base state for splash screen
sealed class SplashState {
  const SplashState();
}

/// Initial state when splash screen loads
final class SplashInitial extends SplashState {
  const SplashInitial();
}

/// State when splash initialization is complete and ready to navigate
final class SplashComplete extends SplashState {
  const SplashComplete();
}

/// State when a critical unrecoverable error occurs
final class SplashCriticalError extends SplashState {
  const SplashCriticalError({this.errorMessage});

  final String? errorMessage;
}
