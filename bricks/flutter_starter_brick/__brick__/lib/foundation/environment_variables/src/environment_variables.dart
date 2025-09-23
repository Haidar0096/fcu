import 'package:flutter/foundation.dart';

/// Environment-specific variables for the application.
sealed class EnvironmentVariables {
  const EnvironmentVariables._();

  /// The base URL for the backend API.
  String get backendBaseUrl;
}

/// Development environment variables.
final class DevelopmentEnvironmentVariables extends EnvironmentVariables {
  const DevelopmentEnvironmentVariables() : super._();

  @override
  String get backendBaseUrl {
    // TODO({{dev_name}}): Update with your development API URL
    // Example API for demonstration - replace with your actual API
    return 'https://api.chucknorris.io';
  }
}

/// Staging environment variables.
final class StagingEnvironmentVariables extends EnvironmentVariables {
  const StagingEnvironmentVariables() : super._();

  @override
  String get backendBaseUrl {
    // TODO({{dev_name}}): Update with your staging API URL
    return 'https://api.chucknorris.io';
  }
}

/// Production environment variables.
final class ProductionEnvironmentVariables extends EnvironmentVariables {
  const ProductionEnvironmentVariables() : super._();

  @override
  String get backendBaseUrl {
    // TODO({{dev_name}}): Update with your production API URL
    return 'https://api.chucknorris.io';
  }
}
