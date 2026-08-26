part of 'app_meta_data_cubit.dart';

/// Base class for all app meta data states.
sealed class AppMetaDataState {
  const AppMetaDataState();

  /// Indicates whether the app meta data is currently being loaded.
  bool get loading => switch (this) {
    AppMetaDataLoading() => true,
    AppMetaDataInitial() ||
    AppMetaDataLoaded() ||
    AppMetaDataLoadingFailed() => false,
  };

  /// The unique identifier for the device.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get deviceId => switch (this) {
    AppMetaDataLoaded(:final deviceId) => deviceId,
    AppMetaDataInitial() ||
    AppMetaDataLoading() ||
    AppMetaDataLoadingFailed() => '',
  };

  /// The type of the operating system (e.g., iOS, Android).
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get osType => switch (this) {
    AppMetaDataLoaded(:final osType) => osType,
    AppMetaDataInitial() ||
    AppMetaDataLoading() ||
    AppMetaDataLoadingFailed() => '',
  };

  /// The version of the operating system.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get osVersion => switch (this) {
    AppMetaDataLoaded(:final osVersion) => osVersion,
    AppMetaDataInitial() ||
    AppMetaDataLoading() ||
    AppMetaDataLoadingFailed() => '',
  };

  /// The version of the app.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get appVersion => switch (this) {
    AppMetaDataLoaded(:final appVersion) => appVersion,
    AppMetaDataInitial() ||
    AppMetaDataLoading() ||
    AppMetaDataLoadingFailed() => '',
  };

  /// The build number of the app.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get buildNumber => switch (this) {
    AppMetaDataLoaded(:final buildNumber) => buildNumber,
    AppMetaDataInitial() ||
    AppMetaDataLoading() ||
    AppMetaDataLoadingFailed() => '',
  };

  /// A formatted string containing both the app version and build number.
  ///
  /// Returns an empty string if either appVersion or buildNumber is empty.
  String get appVersionAndBuildNumberString => switch (this) {
    AppMetaDataLoaded(:final appVersion, :final buildNumber)
        when appVersion.isNotEmpty && buildNumber.isNotEmpty =>
      'v-$appVersion+$buildNumber',
    AppMetaDataInitial() ||
    AppMetaDataLoading() ||
    AppMetaDataLoaded() ||
    AppMetaDataLoadingFailed() => '',
  };
}

/// Represents the initial state when the app meta data has not been loaded yet.
final class AppMetaDataInitial extends AppMetaDataState {
  const AppMetaDataInitial();
}

/// Represents the state when the app meta data is being loaded.
final class AppMetaDataLoading extends AppMetaDataState {
  const AppMetaDataLoading();
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
}

/// Represents the state when the app meta data loading has failed.
///
/// The raw error and its stack trace are logged and reported inside the cubit;
/// they deliberately do not ride the state, so no widget can render them.
final class AppMetaDataLoadingFailed extends AppMetaDataState {
  const AppMetaDataLoadingFailed();
}
