import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/repositories/app_meta_data_repository.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_meta_data_state.dart';

/// Cubit responsible for managing application metadata.
///
/// This cubit handles the retrieval and storage of various device and
/// application information, such as device ID, OS type and version,
/// app version, and build number.
class AppMetaDataCubit extends Cubit<AppMetaDataState> {
  AppMetaDataCubit(this._repository, this._logger, this._errorLogger)
    : super(const AppMetaDataInitial());

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
  ///
  /// Important: See https://pub.dev/packages/package_info_plus for more
  /// information on timing constraints for package info retrieval.
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

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      emit(
        AppMetaDataLoaded(
          deviceId: deviceId ?? '',
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          buildNumber: buildNumber,
        ),
      );
    } catch (error, stackTrace) {
      _logger.log(
        'Error while initializing AppMetaDataCubit: $error',
        tag: _tag,
      );

      // Report the error using ErrorLogger.
      await _errorLogger.recordError(error: error, stackTrace: stackTrace);

      emit(AppMetaDataLoadingFailed(error: error, stackTrace: stackTrace));
    } finally {
      _initCompleter!.complete();
      _initCompleter = null;
    }
  }
}
