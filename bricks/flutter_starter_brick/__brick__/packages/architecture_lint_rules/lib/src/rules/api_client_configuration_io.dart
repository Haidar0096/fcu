/// Reads the api-to-client declarations from the analyzed project's options
/// file.
library;

import 'dart:io';

import 'package:yaml/yaml.dart';

final Map<String, Map<String, String>> _configurationCache = {};

Map<String, String> loadApiClientDeclarations(
  String filePath,
  Map<String, String> defaults,
) {
  final normalizedPath = filePath.replaceAll('\\', '/');
  final marker = normalizedPath.lastIndexOf('/lib/');
  if (marker < 0) return defaults;
  final root = normalizedPath.substring(0, marker);
  return _configurationCache.putIfAbsent(root, () {
    final optionsFile = File('$root/analysis_options.yaml');
    try {
      if (optionsFile.existsSync()) {
        return parseApiClientDeclarations(
          optionsFile.readAsStringSync(),
          defaults: defaults,
        );
      }
    } on Object {
      return defaults;
    }
    return defaults;
  });
}

Map<String, String> parseApiClientDeclarations(
  String optionsContent, {
  required Map<String, String> defaults,
}) {
  final configured = <String, String>{};
  final yaml = loadYaml(optionsContent);
  if (yaml is YamlMap) {
    final pluginOptions = yaml['architecture_lint_rules'];
    final declarations = pluginOptions is YamlMap
        ? pluginOptions['api_http_clients']
        : null;
    if (declarations is YamlMap) {
      for (final entry in declarations.entries) {
        final apiName = entry.key;
        final clientName = entry.value;
        if (apiName is! String || clientName is! String) continue;
        configured[apiName] = clientName;
      }
    }
  }
  return {...defaults, ...configured};
}
