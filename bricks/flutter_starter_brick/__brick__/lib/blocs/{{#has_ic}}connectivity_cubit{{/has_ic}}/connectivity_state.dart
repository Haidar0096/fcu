part of 'connectivity_cubit.dart';

@immutable
sealed class ConnectivityState {
  const ConnectivityState();
}

/// Represents the state of the [ConnectivityCubit] when the device is connected
/// to the internet (i.e. has internet access).
final class Connected extends ConnectivityState {
  const Connected();
}

/// Represents the state of the [ConnectivityCubit] when the device is
/// disconnected from the internet (i.e. does not have internet access).
final class Disconnected extends ConnectivityState {
  const Disconnected();
}
