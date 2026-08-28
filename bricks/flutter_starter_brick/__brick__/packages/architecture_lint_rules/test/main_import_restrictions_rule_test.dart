/// Tests for [MainImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/main_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MainImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class MainImportRestrictionsRuleTest extends AnalysisRuleTest {
  static const _message =
      'main.dart can only import from app/, dependency_injection/, '
      'foundation/, or resources/.';

  @override
  void setUp() {
    rule = MainImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromRouter_violation() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/main.dart', r'''
library;
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main.dart', [
      lint(9, 41, messageContainsAll: [_message]),
    ]);
  }

  Future<void> test_importFromFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/main.dart', r'''
library;
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main.dart', [
      lint(9, 46, messageContainsAll: [_message]),
    ]);
  }

  Future<void> test_bootImports_allowed() async {
    newFile('$testPackageLibPath/app/app.dart', 'class App {}');
    newFile(
      '$testPackageLibPath/dependency_injection/dependency_injection.dart',
      'class ServiceLocator {}',
    );
    newFile(
      '$testPackageLibPath/foundation/environment_variables/environment_variables.dart',
      'class EnvironmentVariables {}',
    );
    newFile('$testPackageLibPath/resources/resources.dart', 'class Fonts {}');

    newFile('$testPackageLibPath/main.dart', r'''
library;
import 'package:test/app/app.dart';
import 'package:test/dependency_injection/dependency_injection.dart';
import 'package:test/foundation/environment_variables/environment_variables.dart';
import 'package:test/resources/resources.dart';

var a = App();
var b = ServiceLocator();
var c = EnvironmentVariables();
var d = Fonts();
''');

    await assertNoDiagnosticsInFile('$testPackageLibPath/main.dart');
  }

  Future<void> test_nestedMainFile_notCovered() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/features/home/main.dart', r'''
library;
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/home/main.dart',
    );
  }
}
