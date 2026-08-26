import 'package:{{proj_name}}/foundation/logging/logging.dart';

/// Environment-specific variables for the application.
sealed class EnvironmentVariables {
  const EnvironmentVariables._();

  /// The short name this app puts on every report it sends.
  ///
  /// The project's report table takes reports from every app the project owns
  /// — this app, its website, an admin panel — so without a name on each one
  /// they are a single undifferentiated pile. It is ONE name for the app,
  /// identical in every environment, which is why it is answered here rather
  /// than once per environment below.
  String get appShortName => '{{proj_name}}';

  /// The base URL for the backend API.
  String get backendBaseUrl;

  /// Which report sender the app uses. The dependency injection file reads
  /// this once and registers the matching implementation; it is the only
  /// line a change of destination touches.
  ReportSenderKind get reportSenderKind;

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
  String get reportReceiverPath;
}

/// Development environment variables.
final class DevelopmentEnvironmentVariables extends EnvironmentVariables {
  const DevelopmentEnvironmentVariables() : super._();

  // TODO({{dev_name}}): Update with your development API URL
  // Example API for demonstration - replace with your actual API
  @override
  String get backendBaseUrl => const String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api.chucknorris.io',
  );

  @override
  ReportSenderKind get reportSenderKind => ReportSenderKind.ownBackend;

  // Empty until the project's own receiver lands: filling this in is what
  // switches the report road on.
  @override
  String get reportReceiverPath => '';
}

/// Production environment variables.
final class ProductionEnvironmentVariables extends EnvironmentVariables {
  const ProductionEnvironmentVariables() : super._();

  @override
  String get backendBaseUrl {
    // TODO({{dev_name}}): Update with your production API URL
    return 'https://api.chucknorris.io';
  }

  @override
  ReportSenderKind get reportSenderKind => ReportSenderKind.ownBackend;

  // Empty until the project's own receiver lands: filling this in is what
  // switches the report road on.
  @override
  String get reportReceiverPath => '';
}
