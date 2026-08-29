import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/platform/platform_info.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/repositories/app_meta_data_repository.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';

part 'app_meta_data_state.dart';

/// Cubit responsible for managing application metadata.
///
/// This cubit handles the retrieval and storage of various device and
/// application information, such as device ID, OS type and version,
/// app version, and build number.
///
/// Conflict matrix: none — [init] is the only action and its completer makes a
/// second run impossible while the first is in flight. A matrix becomes needed
/// the moment a second action can sit in an async gap beside it.
class AppMetaDataCubit extends Cubit<AppMetaDataState>
    with CubitUtilsMixin<AppMetaDataState> {
  AppMetaDataCubit({
    required AppMetaDataRepository repository,
  }) : _repository = repository,
       super(const AppMetaDataInitialState());

  final AppMetaDataRepository _repository;

  Completer<void>? _initCompleter;

  /// Initializes and populates the metadata.
  ///
  /// This method should be called after the `runApp` function in the `main`
  /// function.
  /// It can be called multiple times to re-populate the metadata if needed.
  Future<void> init() async {
    if (_initCompleter == null) {
      final completer = Completer<void>();
      _initCompleter = completer;
      unawaited(_init(completer));
    }
    return _initCompleter!.future;
  }

  Future<void> _init(Completer<void> completer) async {
    emit(const AppMetaDataLoadingState());

    try {
      final deviceIdResult = await _repository.getDeviceId();
      if (isClosed) return;
      final deviceIdOutcome = deviceIdResult.when(
        success: (value) => (failed: false, value: value),
        failure: (_) => (failed: true, value: null),
      );
      if (deviceIdOutcome.failed) {
        emitIfNotClosed(const AppMetaDataLoadingFailedState());
        return;
      }

      final osType = platformOperatingSystem;
      final osVersion = platformOperatingSystemVersion;

      final versionResult = await _repository.getAppVersionInfo();
      if (isClosed) return;
      final versionOutcome = versionResult.when(
        success: (value) => (failed: false, value: value),
        failure: (_) => (failed: true, value: null),
      );
      if (versionOutcome.failed) {
        emitIfNotClosed(const AppMetaDataLoadingFailedState());
        return;
      }
      final versionInfo = versionOutcome.value!;

      emitIfNotClosed(
        AppMetaDataLoadedState(
          deviceId: deviceIdOutcome.value ?? '',
          osType: osType,
          osVersion: osVersion,
          appVersion: versionInfo.appVersion,
          buildNumber: versionInfo.buildNumber,
        ),
      );
    } finally {
      _finishInitialization(completer);
    }
  }

  void _finishInitialization(Completer<void> completer) {
    if (!completer.isCompleted) completer.complete();
    if (identical(_initCompleter, completer)) _initCompleter = null;
  }

  @override
  Future<void> close() {
    final completer = _initCompleter;
    if (completer != null) _finishInitialization(completer);
    return super.close();
  }
}
