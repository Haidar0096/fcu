part of 'app_meta_data_cubit.dart';

/// Base class for all app meta data states.
sealed class AppMetaDataState {
  const AppMetaDataState();

  /// Indicates whether the app meta data is currently being loaded.
  bool get loading => switch (this) {
    AppMetaDataLoadingState() => true,
    AppMetaDataInitialState() ||
    AppMetaDataLoadedState() ||
    AppMetaDataLoadingFailedState() => false,
  };

  /// The unique identifier for the device.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get deviceId => switch (this) {
    AppMetaDataLoadedState(:final deviceId) => deviceId,
    AppMetaDataInitialState() ||
    AppMetaDataLoadingState() ||
    AppMetaDataLoadingFailedState() => '',
  };

  /// The type of the operating system (e.g., iOS, Android).
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get osType => switch (this) {
    AppMetaDataLoadedState(:final osType) => osType,
    AppMetaDataInitialState() ||
    AppMetaDataLoadingState() ||
    AppMetaDataLoadingFailedState() => '',
  };

  /// The version of the operating system.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get osVersion => switch (this) {
    AppMetaDataLoadedState(:final osVersion) => osVersion,
    AppMetaDataInitialState() ||
    AppMetaDataLoadingState() ||
    AppMetaDataLoadingFailedState() => '',
  };

  /// The version of the app.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get appVersion => switch (this) {
    AppMetaDataLoadedState(:final appVersion) => appVersion,
    AppMetaDataInitialState() ||
    AppMetaDataLoadingState() ||
    AppMetaDataLoadingFailedState() => '',
  };

  /// The build number of the app.
  ///
  /// Returns an empty string if not available or if initialization failed.
  String get buildNumber => switch (this) {
    AppMetaDataLoadedState(:final buildNumber) => buildNumber,
    AppMetaDataInitialState() ||
    AppMetaDataLoadingState() ||
    AppMetaDataLoadingFailedState() => '',
  };

  /// A formatted string containing both the app version and build number.
  ///
  /// Returns an empty string if either appVersion or buildNumber is empty.
  String get appVersionAndBuildNumberString => switch (this) {
    AppMetaDataLoadedState(:final appVersion, :final buildNumber)
        when appVersion.isNotEmpty && buildNumber.isNotEmpty =>
      'v-$appVersion+$buildNumber',
    AppMetaDataInitialState() ||
    AppMetaDataLoadingState() ||
    AppMetaDataLoadedState() ||
    AppMetaDataLoadingFailedState() => '',
  };
}

/// Represents the initial state when the app meta data has not been loaded yet.
final class AppMetaDataInitialState extends AppMetaDataState {
  const AppMetaDataInitialState();
}

/// Represents the state when the app meta data is being loaded.
final class AppMetaDataLoadingState extends AppMetaDataState {
  const AppMetaDataLoadingState();
}

/// Represents the state when the app meta data has been successfully loaded.
final class AppMetaDataLoadedState extends AppMetaDataState {
  const AppMetaDataLoadedState({
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
/// The repository logs and reports the raw error; neither it nor its stack
/// rides the state, so no widget can render them.
final class AppMetaDataLoadingFailedState extends AppMetaDataState {
  const AppMetaDataLoadingFailedState();
}
