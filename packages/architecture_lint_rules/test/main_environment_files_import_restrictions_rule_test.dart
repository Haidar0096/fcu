/// Tests for [MainEnvironmentFilesImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/main_environment_files_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MainEnvironmentFilesImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class MainEnvironmentFilesImportRestrictionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MainEnvironmentFilesImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_mainDevelopment_importFromApp_violation() async {
    newFile('$testPackageLibPath/app/app.dart', 'class App {}');

    newFile('$testPackageLibPath/main_development.dart', r'''
library;
import 'package:test/app/app.dart';

var x = App();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main_development.dart', [
      lint(
        9,
        35,
        messageContainsAll: [
          'main_development/staging/production.dart can only import foundation/ (for Environment) and main_common.dart.',
        ],
      ),
    ]);
  }

  Future<void> test_mainProduction_importFromRouter_violation() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/main_production.dart', r'''
library;
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main_production.dart', [
      lint(
        9,
        41,
        messageContainsAll: [
          'main_development/staging/production.dart can only import foundation/ (for Environment) and main_common.dart.',
        ],
      ),
    ]);
  }

  Future<void> test_importFromFoundation_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/environments/environment.dart',
      'class Environment {}',
    );

    newFile('$testPackageLibPath/main_development.dart', r'''
library;
import 'package:test/foundation/environments/environment.dart';

var x = Environment();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/main_development.dart',
    );
  }

  Future<void> test_importFromMainCommon_allowed() async {
    newFile('$testPackageLibPath/main_common.dart', 'void mainCommon() {}');

    newFile('$testPackageLibPath/main_development.dart', r'''
library;
import 'package:test/main_common.dart';

void main() => mainCommon();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/main_development.dart',
    );
  }
}
