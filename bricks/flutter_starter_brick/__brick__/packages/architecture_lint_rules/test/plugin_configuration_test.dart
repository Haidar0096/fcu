/// Tests for the analyzer plugin configuration contract.
library;

import 'package:analyzer/src/lint/config.dart';
import 'package:architecture_lint_rules/src/rules/api_client_configuration_io.dart';
import 'package:architecture_lint_rules/src/rules/vendor_import_configuration_io.dart';
import 'package:architecture_lint_rules/src/rules/vendor_imports_stay_in_wrappers_rule.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('official diagnostics map disables a project rule', () {
    final diagnostics = parseDiagnosticsSection(
      loadYaml('vendor_imports_stay_in_wrappers: false') as YamlNode,
    );

    expect(
      diagnostics[VendorImportsStayInWrappersRule.code.lowerCaseName]
          ?.isEnabled,
      isFalse,
    );
  });

  test('vendor wrapper setting accepts a file, folder, list, and nowhere', () {
    final wrappers = parseVendorImportWrapperSettings(r'''
architecture_lint_rules:
  vendor_import_wrappers:
    dio: foundation/networking
    http:
      - foundation/networking
      - features/downloads/src/download_http.dart
    flutter_svg: resources/src/images.dart
    provider: []
''', defaults: const {});

    expect(wrappers['dio'], ['foundation/networking']);
    expect(wrappers['http'], [
      'foundation/networking',
      'features/downloads/src/download_http.dart',
    ]);
    expect(wrappers['flutter_svg'], ['resources/src/images.dart']);
    expect(wrappers['provider'], isEmpty);
  });

  test('api client declarations add to and override the shipped ones', () {
    final declarations = parseApiClientDeclarations(
      r'''
architecture_lint_rules:
  api_http_clients:
    JokesApi: loggedInBackendHttpClient
    ProfileApi: loggedInBackendHttpClient
''',
      defaults: const {'JokesApi': 'publicBackendHttpClient'},
    );

    expect(declarations['JokesApi'], 'loggedInBackendHttpClient');
    expect(declarations['ProfileApi'], 'loggedInBackendHttpClient');
  });

  test('an options file with no api client block keeps the shipped ones', () {
    final declarations = parseApiClientDeclarations(
      'architecture_lint_rules:\n  vendor_import_wrappers:\n    dio: x\n',
      defaults: const {'JokesApi': 'publicBackendHttpClient'},
    );

    expect(declarations, {'JokesApi': 'publicBackendHttpClient'});
  });
}
