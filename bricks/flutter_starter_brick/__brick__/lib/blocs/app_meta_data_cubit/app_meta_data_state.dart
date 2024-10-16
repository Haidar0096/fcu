part of 'app_meta_data_cubit.dart';

/// Base class for all app meta data states.
sealed class AppMetaDataState {
  const AppMetaDataState();

  /// Indicates whether the app meta data is currently being loaded.
  bool get loading => false;

  /// The unique identifier for the device.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get deviceId => '';

  /// The type of the operating system (e.g., iOS, Android).
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get osType => '';

  /// The version of the operating system.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get osVersion => '';

  /// The version of the app.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get appVersion => '';

  /// The build number of the app.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get buildNumber => '';

  /// A formatted string containing both the app version and build number.
  ///
  /// Returns an empty string if either appVersion or buildNumber is empty.
  String get appVersionAndBuildNumberString => '';
}

/// Represents the initial state when the app meta data has not been loaded yet.
final class AppMetaDataInitial extends AppMetaDataState {
  const AppMetaDataInitial();
}

/// Represents the state when the app meta data is being loaded.
final class AppMetaDataLoading extends AppMetaDataState {
  const AppMetaDataLoading();

  @override
  bool get loading => true;
}

/// Represents the state when the app meta data has been successfully loaded.
final class AppMetaDataLoaded extends AppMetaDataState {
  const AppMetaDataLoaded({
    required this.deviceId,
    required this.osType,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
  });

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

/// Represents the state when the app meta data loading has failed.
final class AppMetaDataLoadingFailed extends AppMetaDataState {
  const AppMetaDataLoadingFailed({
    required this.error,
    this.stackTrace,
  });

  /// The error that caused the loading to fail.
  final Object error;

  /// The stack trace associated with the error, if available.
  final StackTrace? stackTrace;
}
