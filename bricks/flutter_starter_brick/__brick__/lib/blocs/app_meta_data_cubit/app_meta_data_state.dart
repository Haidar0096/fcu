part of 'app_meta_data_cubit.dart';

abstract class AppMetaDataState {
  const AppMetaDataState();

  bool get loading;

  /// The device id, if available and if the cubit initialized successfully,
  /// otherwise empty string.
  String get deviceId;

  /// The operating system type, if available and if the cubit initialized
  /// successfully, otherwise empty string.
  String get osType;

  /// The operating system version, if available and if the cubit initialized
  /// successfully, otherwise empty string.
  String get osVersion;

  /// The app version, if available and if the cubit initialized successfully,
  /// otherwise empty string.
  String get appVersion;

  /// The build number, if available and if the cubit initialized successfully,
  /// otherwise empty string.
  String get buildNumber;

  /// Returns a string that contains the app version and build number, if they
  /// are both not empty, otherwise an empty string.
  String get appVersionAndBuildNumberString;
}

/// Initial state of the app meta data, the cubit is not initialized yet.
final class AppMetaDataInitial extends AppMetaDataState {
  const AppMetaDataInitial();

  @override
  bool get loading => false;

  @override
  String get deviceId => '';

  @override
  String get osType => '';

  @override
  String get osVersion => '';

  @override
  String get appVersion => '';

  @override
  String get buildNumber => '';

  @override
  String get appVersionAndBuildNumberString => '';
}

/// The app meta data is being loaded.
final class AppMetaDataLoading extends AppMetaDataState {
  const AppMetaDataLoading();

  @override
  bool get loading => true;

  @override
  String get deviceId => '';

  @override
  String get osType => '';

  @override
  String get osVersion => '';

  @override
  String get appVersion => '';

  @override
  String get buildNumber => '';

  @override
  String get appVersionAndBuildNumberString => '';
}

/// The app meta data has been loaded.
final class AppMetaDataLoaded extends AppMetaDataState {
  const AppMetaDataLoaded({
    required this.deviceId,
    required this.osType,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
  });

  @override
  bool get loading => false;

  @override
  final String deviceId;

  @override
  final String osType;

  @override
  final String osVersion;

  @override
  final String appVersion;

  @override
  final String buildNumber;

  @override
  String get appVersionAndBuildNumberString {
    if (appVersion.isNotEmpty && buildNumber.isNotEmpty) {
      return 'v-$appVersion+$buildNumber';
    }
    return '';
  }
}

/// The app meta data loading has failed.
final class AppMetaDataLoadingFailed extends AppMetaDataState {
  const AppMetaDataLoadingFailed({
    required this.error,
    this.stackTrace,
  });

  /// The error that caused the loading to fail.
  final Object error;

  /// The stack trace of the error that caused the loading to fail.
  final StackTrace? stackTrace;

  @override
  bool get loading => false;

  @override
  String get deviceId => '';

  @override
  String get osType => '';

  @override
  String get osVersion => '';

  @override
  String get appVersion => '';

  @override
  String get buildNumber => '';

  @override
  String get appVersionAndBuildNumberString => '';
}
