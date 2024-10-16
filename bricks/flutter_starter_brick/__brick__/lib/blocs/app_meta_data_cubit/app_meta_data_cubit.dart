import 'dart:async';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:{{proj_name}}/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/services/logger/app_logger.dart';
import 'package:{{proj_name}}/services/logger/error_logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_meta_data_state.dart';

/// Cubit responsible for managing application metadata.
///
/// This cubit handles the retrieval and storage of various device and
/// application
/// information, such as device ID, OS type and version, app version, and build
/// number.
@LazySingletonService()
class AppMetaDataCubit extends BaseCubit<AppMetaDataState> {
  AppMetaDataCubit(
    this._logger,
    this._errorLogger,
  ) : super(const AppMetaDataInitial());

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
      final deviceId = await _getDeviceId();
      final osType = Platform.operatingSystem;
      final osVersion = Platform.operatingSystemVersion;

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

      // Report the error using ErrorLogger
      await _errorLogger.recordError(error: error, stackTrace: stackTrace);

      emit(AppMetaDataLoadingFailed(error: error, stackTrace: stackTrace));
    } finally {
      _initCompleter!.complete();
      _initCompleter = null;
    }
  }

  /// Retrieves the device's unique ID.
  ///
  /// Returns the device unique id for iOS and Android platforms.
  /// Returns null if the platform is not supported or if the ID can't be
  /// determined.
  Future<String?> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    } else if (Platform.isAndroid) {
      return const AndroidId().getId();
    } else {
      return null;
    }
  }
}
