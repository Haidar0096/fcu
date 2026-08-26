/// Tests for [DependencyInjectionImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/dependency_injection_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DependencyInjectionImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class DependencyInjectionImportRestrictionsRuleTest extends AnalysisRuleTest {
  static const _message =
      'dependency_injection/ can only import from fake_data/, features/, '
      'foundation/, resources/, router/, or dependency_injection/.';

  @override
  void setUp() {
    rule = DependencyInjectionImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromApp_violation() async {
    newFile('$testPackageLibPath/app/app.dart', 'class App {}');

    newFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
      r'''
import 'package:test/app/app.dart';

var x = App();
''',
    );

    await assertDiagnosticsInFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
      [
        lint(0, 35, messageContainsAll: [_message]),
      ],
    );
  }

  Future<void> test_importFromMainCommon_violation() async {
    newFile('$testPackageLibPath/main_common.dart', 'void mainCommon() {}');

    newFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
      r'''
import 'package:test/main_common.dart';

void x() => mainCommon();
''',
    );

    await assertDiagnosticsInFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
      [
        lint(0, 39, messageContainsAll: [_message]),
      ],
    );
  }

  Future<void> test_importFromFeatures_allowed() async {
    newFile(
      '$testPackageLibPath/features/auth/src/apis/auth_api.dart',
      'class AuthApi {}',
    );

    newFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
      r'''
import 'package:test/features/auth/src/apis/auth_api.dart';

var x = AuthApi();
''',
    );

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
    );
  }

  Future<void> test_importFromRouterAndFakeData_allowed() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');
    newFile('$testPackageLibPath/fake_data/fake_data.dart', 'class Fakes {}');

    newFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
      r'''
import 'package:test/fake_data/fake_data.dart';
import 'package:test/router/router.dart';

var x = Fakes();
var y = AppRouter();
''',
    );

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/dependency_injection/src/register_instances.dart',
    );
  }
}
