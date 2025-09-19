import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';

part 'splash_state.dart';

/// Manages splash screen initialization flow
/// Waits for app metadata to load, then shows splash for 1.5 seconds
class SplashCubit extends Cubit<SplashState> with CubitUtils {
  SplashCubit({
    required AppLogger appLogger,
  }) : _appLogger = appLogger,
       super(const SplashInitial());

  final AppLogger _appLogger;

  static const String _tag = 'SplashCubit';


  /// Called when app metadata is loaded - starts splash timer
  void onMetadataLoaded() {
    _appLogger.log('App metadata loaded, starting splash timer', tag: _tag);
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
        _appLogger.log('Splash timer completed', tag: _tag);
        emitIfNotClosed(const SplashComplete());
      }
    });
  }
}
