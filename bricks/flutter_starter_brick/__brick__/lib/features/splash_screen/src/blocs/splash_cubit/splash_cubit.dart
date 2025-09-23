import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';

part 'splash_state.dart';

/// Manages splash screen initialization flow
/// Waits for app metadata to load, then shows splash for 1.5 seconds
class SplashCubit extends Cubit<SplashState> with CubitUtils {
  SplashCubit() : super(const SplashInitial());


  /// Called when app metadata is loaded - starts splash timer
  void onMetadataLoaded() {
    _startSplashTimer();
  }


  /// Called when app metadata loading fails - emits critical error state
  void onMetadataLoadingFailed({String? errorMessage}) => emitIfNotClosed(
    SplashCriticalError(errorMessage: errorMessage),
  );

  /// Starts 1.5 second timer before completing splash
  void _startSplashTimer() {
    Timer(const Duration(milliseconds: 1500), () {
      if (!isClosed) {
        emitIfNotClosed(const SplashComplete());
      }
    });
  }
}
