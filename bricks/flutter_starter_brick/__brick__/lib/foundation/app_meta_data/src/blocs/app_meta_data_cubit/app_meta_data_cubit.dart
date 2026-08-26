import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/repositories/app_meta_data_repository.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';

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
    with CubitUtils<AppMetaDataState> {
  AppMetaDataCubit({
    required AppMetaDataRepository repository,
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
  }) : _repository = repository,
       _logger = appLogger,
       _errorLogger = errorLogger,
       super(const AppMetaDataInitial());

  final AppMetaDataRepository _repository;
  final AppLogger _logger;
  final ErrorLogger _errorLogger;

  static const String _tag = 'AppMetaDataCubit';

  Completer<void>? _initCompleter;

  /// Initializes and populates the metadata.
  ///
  /// This method should be called after the `runApp` function in the `main`
  /// function.
  /// It can be called multiple times to re-populate the metadata if needed.
  Future<void> init() async {
    if (_initCompleter == null) {
      _initCompleter = Completer<void>();
      unawaited(_init());
    }
    return _initCompleter!.future;
  }

  Future<void> _init() async {
    emit(const AppMetaDataLoading());

    try {
      final deviceId = await _repository.getDeviceId();
      final osType = kIsWeb ? 'web' : Platform.operatingSystem;
      final osVersion = kIsWeb ? 'n/a' : Platform.operatingSystemVersion;

      final versionInfo = await _repository.getAppVersionInfo();

      emitIfNotClosed(
        AppMetaDataLoaded(
          deviceId: deviceId ?? '',
          osType: osType,
          osVersion: osVersion,
          appVersion: versionInfo.appVersion,
          buildNumber: versionInfo.buildNumber,
        ),
      );
    } catch (error, stackTrace) {
      final errorMessage = 'Error while initializing AppMetaDataCubit: $error';
      _logger.log(errorMessage, tag: _tag);
      await _errorLogger.recordError(
        error: errorMessage,
        stackTrace: stackTrace,
      );

      emitIfNotClosed(const AppMetaDataLoadingFailed());
    } finally {
      _initCompleter!.complete();
      _initCompleter = null;
    }
  }
}
