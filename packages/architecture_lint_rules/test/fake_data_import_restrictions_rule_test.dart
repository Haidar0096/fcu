/// Tests for [FakeDataImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/fake_data_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FakeDataImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class FakeDataImportRestrictionsRuleTest extends AnalysisRuleTest {
  static const _message =
      'fake_data/ can only import from features/, foundation/, resources/, '
      'or fake_data/.';

  @override
  void setUp() {
    rule = FakeDataImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromRouter_violation() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/fake_data/src/fake_data_registry.dart', r'''
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/fake_data/src/fake_data_registry.dart',
      [
        lint(0, 41, messageContainsAll: [_message]),
      ],
    );
  }

  Future<void> test_importFromDependencyInjection_violation() async {
    newFile(
      '$testPackageLibPath/dependency_injection/dependency_injection.dart',
      'class ServiceLocator {}',
    );

    newFile('$testPackageLibPath/fake_data/src/fake_data_registry.dart', r'''
import 'package:test/dependency_injection/dependency_injection.dart';

var x = ServiceLocator();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/fake_data/src/fake_data_registry.dart',
      [
        lint(0, 69, messageContainsAll: [_message]),
      ],
    );
  }

  Future<void> test_importFromFeaturesAndFoundation_allowed() async {
    newFile(
      '$testPackageLibPath/features/auth/src/apis/auth_api.dart',
      'class AuthApi {}',
    );
    newFile(
      '$testPackageLibPath/foundation/networking/networking.dart',
      'class HttpClient {}',
    );

    newFile('$testPackageLibPath/fake_data/src/fake_data_registry.dart', r'''
import 'package:test/features/auth/src/apis/auth_api.dart';
import 'package:test/foundation/networking/networking.dart';

var x = AuthApi();
var y = HttpClient();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/fake_data/src/fake_data_registry.dart',
    );
  }
}
