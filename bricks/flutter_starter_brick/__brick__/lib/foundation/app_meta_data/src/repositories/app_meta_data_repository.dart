import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Repository for device and application metadata retrieval.
///
/// Abstracts device ID retrieval across platforms:
/// - Web: generates a UUID and caches it in SharedPreferences for reuse
/// - iOS: uses identifierForVendor
/// - Android: uses AndroidId
/// - Other platforms: returns null (backend auto-generates)
class AppMetaDataRepository {
  AppMetaDataRepository({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _deviceIdKey = 'AppMetaDataRepository.device_id';

  /// Retrieves the device's unique ID.
  ///
  /// Returns null if the platform is not supported or if the ID can't be
  /// determined.
  Future<String?> getDeviceId() async {
    if (kIsWeb) {
      return _getWebDeviceId();
    }

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    } else if (Platform.isAndroid) {
      return const AndroidId().getId();
    } else {
      return null;
    }
  }

  /// Reads the running build's own version facts off the platform bundle.
  ///
  /// Important: see https://pub.dev/packages/package_info_plus for the timing
  /// constraints on reading package info.
  Future<({String appVersion, String buildNumber})> getAppVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return (
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  /// Web: returns cached UUID from SharedPreferences, or generates and caches
  /// a new one if none exists.
  Future<String> _getWebDeviceId() async {
    final cached = _sharedPreferences.getString(_deviceIdKey);
    if (cached != null) {
      return cached;
    }

    final deviceId = const Uuid().v4();
    await _sharedPreferences.setString(_deviceIdKey, deviceId);
    return deviceId;
  }
}
