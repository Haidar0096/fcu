import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';

/// Environment-specific variables for the application.
class EnvironmentVariables {
  /// Reads and validates the values supplied by the build.
  EnvironmentVariables()
    : backendBaseUrl = _requiredValue(
        key: _backendBaseUrlKey,
        value: _backendBaseUrl,
      ),
      reportReceiverPath = _reportReceiverPath,
      reportSenderKind = _requiredEnum(
        key: _reportSenderKindKey,
        name: _reportSenderKind,
        values: ReportSenderKind.values,
      ),
      environment = _requiredEnum(
        key: _environmentKey,
        name: _environment,
        values: Environment.values,
      );

  static const String _backendBaseUrlKey = 'BACKEND_BASE_URL';
  static const String _reportReceiverPathKey = 'REPORT_RECEIVER_PATH';
  static const String _reportSenderKindKey = 'REPORT_SENDER_KIND';
  static const String _environmentKey = 'ENVIRONMENT';

  static const String _backendBaseUrl = String.fromEnvironment(
    _backendBaseUrlKey,
  );
  static const String _reportReceiverPath = String.fromEnvironment(
    _reportReceiverPathKey,
  );
  static const String _reportSenderKind = String.fromEnvironment(
    _reportSenderKindKey,
  );
  static const String _environment = String.fromEnvironment(_environmentKey);

  /// The short name this app puts on every report it sends.
  ///
  /// The project's report table takes reports from every app the project owns
  /// — this app, its website, an admin panel — so without a name on each one
  /// they are a single undifferentiated pile. It is ONE name for the app,
  /// identical in every environment, which is why it is answered here rather
  /// than once in each environment file.
  static const String appShortName = '{{proj_name}}';

  /// The base URL for the backend API.
  final String backendBaseUrl;

  /// Which report sender the app uses. The dependency injection file reads
  /// this once and registers the matching implementation; it is the only
  /// line a change of destination touches.
  final ReportSenderKind reportSenderKind;

  /// The path of the project's own receiver endpoint, relative to
  /// [backendBaseUrl] — the endpoint the phone and web apps post their
  /// reports to.
  ///
  /// It ships EMPTY, and empty is an answer: the project's own backend does
  /// not exist yet, and a plausible-looking guess here would send real
  /// reports and stack traces to whatever host the base URL happens to name.
  /// It is ASKED FOR at project setup and written in from the answer — never
  /// invented. While it is empty the report road parks every report on the
  /// device instead of posting it.
  final String reportReceiverPath;

  /// The environment selected by the build.
  final Environment environment;
}

String _requiredValue({required String key, required String value}) {
  if (value.isEmpty) {
    throw StateError('Missing required environment value: $key');
  }
  return value;
}

T _requiredEnum<T extends Enum>({
  required String key,
  required String name,
  required List<T> values,
}) {
  final requiredName = _requiredValue(key: key, value: name);
  for (final value in values) {
    if (value.name == requiredName) return value;
  }
  throw StateError('Invalid environment value for $key: $requiredName');
}
