import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/platform/platform_info.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/src/repositories/app_meta_data_repository_keys.dart';
import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';

/// Repository for device and application metadata retrieval.
///
/// Hides `android_id`, `device_info_plus`, `package_info_plus`,
/// `shared_preferences`, and `uuid`.
///
/// Abstracts device ID retrieval across platforms:
/// - Web: generates a UUID and caches it in SharedPreferences for reuse
/// - iOS: uses identifierForVendor
/// - Android: uses AndroidId
/// - Other platforms: returns null (backend auto-generates)
class AppMetaDataRepository {
  AppMetaDataRepository({
    required AndroidId androidId,
    required AppLogger appLogger,
    required DeviceInfoPlugin deviceInfoPlugin,
    required ErrorLogger errorLogger,
    required SharedPreferences sharedPreferences,
    required Uuid uuid,
  }) : _androidId = androidId,
       _appLogger = appLogger,
       _deviceInfoPlugin = deviceInfoPlugin,
       _errorLogger = errorLogger,
       _sharedPreferences = sharedPreferences,
       _uuid = uuid;

  final AndroidId _androidId;
  final AppLogger _appLogger;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final ErrorLogger _errorLogger;
  final SharedPreferences _sharedPreferences;
  final Uuid _uuid;

  static const String _tag = 'AppMetaDataRepository';

  /// Retrieves the device's unique ID.
  ///
  /// Returns null if the platform is not supported or if the ID can't be
  /// determined.
  Future<Result<String, String?>> getDeviceId() async {
    try {
      if (kIsWeb) {
        return Result.success(data: await _getWebDeviceId());
      }

      if (platformIsIos) {
        return Result.success(
          data: (await _deviceInfoPlugin.iosInfo).identifierForVendor,
        );
      } else if (platformIsAndroid) {
        return Result.success(data: await _androidId.getId());
      } else {
        return Result.success(data: null);
      }
    } catch (error, stackTrace) {
      final message = 'Failed to read the device identifier: $error';
      await _recordFailure(
        message: message,
        stackTrace: stackTrace,
      );
      return Result.failure(data: message);
    }
  }

  /// Reads the running build's own version facts off the platform bundle.
  ///
  /// Important: see https://pub.dev/packages/package_info_plus for the timing
  /// constraints on reading package info.
  Future<Result<String, ({String appVersion, String buildNumber})>>
  getAppVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return Result.success(
        data: (
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
        ),
      );
    } catch (error, stackTrace) {
      final message = 'Failed to read the app version information: $error';
      await _recordFailure(
        message: message,
        stackTrace: stackTrace,
      );
      return Result.failure(data: message);
    }
  }

  /// Web: returns cached UUID from SharedPreferences, or generates and caches
  /// a new one if none exists.
  Future<String> _getWebDeviceId() async {
    final cached = _sharedPreferences.getString(
      AppMetaDataRepositoryKeys.deviceId,
    );
    if (cached != null) {
      return cached;
    }

    final deviceId = _uuid.v4();
    await _sharedPreferences.setString(
      AppMetaDataRepositoryKeys.deviceId,
      deviceId,
    );
    return deviceId;
  }

  Future<void> _recordFailure({
    required String message,
    required StackTrace stackTrace,
  }) async {
    _appLogger.log(message: message, tag: _tag, stackTrace: stackTrace);
    await _errorLogger.recordError(error: message, stackTrace: stackTrace);
  }
}
