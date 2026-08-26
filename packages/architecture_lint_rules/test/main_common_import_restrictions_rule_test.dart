/// Tests for [MainCommonImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/main_common_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MainCommonImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class MainCommonImportRestrictionsRuleTest extends AnalysisRuleTest {
  static const _message =
      'main_common.dart can only import from app/, dependency_injection/, '
      'foundation/, or resources/.';

  @override
  void setUp() {
    rule = MainCommonImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromRouter_violation() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/main_common.dart', r'''
library;
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main_common.dart', [
      lint(9, 41, messageContainsAll: [_message]),
    ]);
  }

  Future<void> test_importFromFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/main_common.dart', r'''
library;
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main_common.dart', [
      lint(9, 46, messageContainsAll: [_message]),
    ]);
  }

  Future<void> test_importFromAppAndDependencyInjection_allowed() async {
    newFile('$testPackageLibPath/app/app.dart', 'class App {}');
    newFile(
      '$testPackageLibPath/dependency_injection/dependency_injection.dart',
      'class ServiceLocator {}',
    );

    newFile('$testPackageLibPath/main_common.dart', r'''
library;
import 'package:test/app/app.dart';
import 'package:test/dependency_injection/dependency_injection.dart';

var x = App();
var y = ServiceLocator();
''');

    await assertNoDiagnosticsInFile('$testPackageLibPath/main_common.dart');
  }

  Future<void> test_featureFileNamedMainCommon_notCoveredByThisRule() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/features/home/main_common.dart', r'''
library;
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/home/main_common.dart',
    );
  }

  Future<void> test_environmentMain_notCoveredByThisRule() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/main_development.dart', r'''
library;
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/main_development.dart',
    );
  }
}
