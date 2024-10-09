import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:bloc/bloc.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/services/logger/app_logger.dart';
import 'package:{{proj_name}}/services/logger/error_logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_meta_data_state.dart';

@LazySingletonService()
class AppMetaDataCubit extends Cubit<AppMetaDataState> {
  AppMetaDataCubit(
    this._logger,
    this._errorLogger,
  ) : super(const AppMetaDataInitial());

  final AppLogger _logger;
  final ErrorLogger _errorLogger;

  static const String _tag = 'AppMetaDataCubit';

  /// Call this to populate the meta data. Calling this method more than once
  /// will re-populate the metadata.
  /// This method must be called after `runApp` function in the `main` function.
  /// - see https://pub.dev/packages/package_info_plus for more info.
  Future<void> init() async {
    if (state.loading) return;

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
      await _errorLogger.recordError(
        error: error,
        stackTrace: stackTrace,
      );

      emit(AppMetaDataLoadingFailed(error: error, stackTrace: stackTrace));
    }
  }

  /// Returns the device unique id, or null if it can't be determined or if the
  /// platform is not supported.
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
