import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';

part 'splash_state.dart';

/// Manages splash screen initialization flow
/// Waits for app metadata to load, then shows splash for 1.5 seconds
///
/// Conflict matrix: none — the metadata outcome arrives once and the two
/// entry points are mutually exclusive. A matrix becomes needed the moment a
/// second action (a forced-update check, a session restore) can sit in an
/// async gap beside the splash timer.
class SplashCubit extends Cubit<SplashState> with CubitUtils<SplashState> {
  SplashCubit() : super(const SplashInitialState());

  /// How long the splash stays up once the metadata has arrived.
  static const Duration _splashDuration = Duration(milliseconds: 1500);

  Timer? _splashTimer;

  void onMetadataLoaded() => _startSplashTimer();

  void onMetadataLoadingFailed({required String? errorMessage}) =>
      emit(SplashCriticalErrorState(errorMessage: errorMessage));

  void _startSplashTimer() {
    _cancelSplashTimer();
    _splashTimer = Timer(
      _splashDuration,
      () => emitIfNotClosed(const SplashCompleteState()),
    );
  }

  void _cancelSplashTimer() {
    _splashTimer?.cancel();
    _splashTimer = null;
  }

  @override
  Future<void> close() {
    _cancelSplashTimer();
    return super.close();
  }
}
