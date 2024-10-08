import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/services/timers/periodic_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

part 'connectivity_state.dart';

@LazySingletonService()
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const Connected()) {
    _setupConnectionCheckerTimer();
    _setupConnectivityListener();
  }

  late final Timer _connectionCheckerTimer;
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  Completer<bool>? _hasInternetAccessCompleter;

  void _setupConnectionCheckerTimer() =>
      _connectionCheckerTimer = createPeriodicTimer(
        period: const Duration(seconds: 15),
        callback: (timer) async => emit(await _internetCheckResult()),
        fireImmediately: true,
      );

  void _setupConnectivityListener() =>
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
            (connectivityResultList) async =>
                emit(await _internetCheckResult()),
          );

  Future<ConnectivityState> _internetCheckResult() async =>
      switch (await _hasInternetAccess()) {
        true => const Connected(),
        false => const Disconnected(),
      };

  /// Checks if device has internet access.
  Future<bool> _hasInternetAccess() async {
    if (_hasInternetAccessCompleter != null) {
      return _hasInternetAccessCompleter!.future;
    }
    _hasInternetAccessCompleter = Completer<bool>();
    unawaited(_startInternetCheck());
    return _hasInternetAccessCompleter!.future;
  }

  Future<void> _startInternetCheck() async {
    try {
      final hasConnection = await InternetConnection().hasInternetAccess;
      _hasInternetAccessCompleter!.complete(hasConnection);
    } catch (_) {
      _hasInternetAccessCompleter!.complete(false);
    }
    _hasInternetAccessCompleter = null;
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    _connectionCheckerTimer.cancel();
    return super.close();
  }
}