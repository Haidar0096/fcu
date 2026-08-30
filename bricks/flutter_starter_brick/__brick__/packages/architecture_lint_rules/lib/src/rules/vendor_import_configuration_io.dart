/// Reads vendor-wrapper settings from the analyzed project's options file.
library;

import 'dart:io';

import 'package:yaml/yaml.dart';

Map<String, List<String>> loadVendorImportConfiguration(
  String filePath,
  Map<String, List<String>> defaults,
) {
  final normalizedPath = filePath.replaceAll('\\', '/');
  final marker = normalizedPath.lastIndexOf('/lib/');
  if (marker < 0) return defaults;
  final root = normalizedPath.substring(0, marker);
  final optionsFile = File('$root/analysis_options.yaml');
  try {
    if (optionsFile.existsSync()) {
      return parseVendorImportWrapperSettings(
        optionsFile.readAsStringSync(),
        defaults: defaults,
      );
    }
  } on Object {
    return defaults;
  }
  return defaults;
}

Map<String, List<String>> parseVendorImportWrapperSettings(
  String optionsContent, {
  required Map<String, List<String>> defaults,
}) {
  final configured = <String, List<String>>{};
  final yaml = loadYaml(optionsContent);
  if (yaml is YamlMap) {
    final pluginOptions = yaml['architecture_lint_rules'];
    final wrapperOptions = pluginOptions is YamlMap
        ? pluginOptions['vendor_import_wrappers']
        : null;
    if (wrapperOptions is YamlMap) {
      for (final entry in wrapperOptions.entries) {
        final name = entry.key;
        final locations = _locations(entry.value);
        if (name is! String || locations == null) continue;
        configured[name] = locations;
      }
    }
  }
  return {...defaults, ...configured};
}

List<String>? _locations(Object? value) {
  if (value is String) return [value];
  if (value is YamlList && value.every((entry) => entry is String)) {
    return value.cast<String>().toList();
  }
  return null;
}
