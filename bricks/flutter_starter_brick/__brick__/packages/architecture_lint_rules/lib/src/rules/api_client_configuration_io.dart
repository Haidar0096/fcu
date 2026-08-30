/// Reads the api-to-client declarations from the analyzed project's options
/// file.
library;

import 'dart:io';

import 'package:yaml/yaml.dart';

Map<String, String> loadApiClientDeclarations(
  String filePath,
  Map<String, String> defaults,
) {
  final normalizedPath = filePath.replaceAll('\\', '/');
  final marker = normalizedPath.lastIndexOf('/lib/');
  if (marker < 0) return defaults;
  final root = normalizedPath.substring(0, marker);
  final optionsFile = File('$root/analysis_options.yaml');
  if (!optionsFile.existsSync()) return defaults;
  try {
    return parseApiClientDeclarations(
      optionsFile.readAsStringSync(),
      defaults: defaults,
    );
  } on FileSystemException catch (error) {
    throw FileSystemException(
      'Cannot read API client declarations: ${error.message}',
      optionsFile.path,
      error.osError,
    );
  } on FormatException catch (error) {
    throw FormatException(
      'Invalid API client declarations in ${optionsFile.path}: '
      '${error.message}',
    );
  }
}

Map<String, String> parseApiClientDeclarations(
  String optionsContent, {
  required Map<String, String> defaults,
}) {
  final yaml = loadYaml(optionsContent);
  if (yaml == null) return {...defaults};
  if (yaml is! YamlMap) {
    throw const FormatException('analysis_options.yaml must be a map.');
  }
  final pluginOptions = yaml['architecture_lint_rules'];
  if (pluginOptions == null) return {...defaults};
  if (pluginOptions is! YamlMap) {
    throw const FormatException(
      'architecture_lint_rules must be a map.',
    );
  }
  final declarations = pluginOptions['api_http_clients'];
  if (declarations == null) return {...defaults};
  if (declarations is! YamlMap) {
    throw const FormatException('api_http_clients must be a map.');
  }

  final configured = <String, String>{};
  for (final entry in declarations.entries) {
    final apiName = entry.key;
    final clientName = entry.value;
    if (apiName is! String ||
        apiName.trim().isEmpty ||
        clientName is! String ||
        clientName.trim().isEmpty) {
      throw FormatException(
        'Every api_http_clients entry must map a non-empty API name to a '
        'non-empty client name; invalid entry: $apiName.',
      );
    }
    configured[apiName] = clientName;
  }
  return {...defaults, ...configured};
}
