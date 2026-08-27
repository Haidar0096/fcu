/// Tests for [RouterImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/router_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RouterImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class RouterImportRestrictionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RouterImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromApp_violation() async {
    newFile('$testPackageLibPath/app/app.dart', 'class App {}');

    newFile('$testPackageLibPath/router/src/app_router.dart', r'''
import 'package:test/app/app.dart';

var x = App();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/router/src/app_router.dart',
      [
        lint(
          0,
          35,
          messageContainsAll: [
            'router/ can only import from features/, foundation/, resources/, and dependency_injection/.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromFeatures_allowed() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/router/src/app_router.dart', r'''
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/router/src/app_router.dart',
    );
  }

  Future<void> test_importFromFoundation_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/ui/theme.dart',
      'class AppTheme {}',
    );

    newFile('$testPackageLibPath/router/src/app_router.dart', r'''
import 'package:test/foundation/ui/theme.dart';

var x = AppTheme();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/router/src/app_router.dart',
    );
  }

  Future<void> test_importFromDependencyInjection_allowed() async {
    newFile(
      '$testPackageLibPath/dependency_injection/injection.dart',
      'class DI {}',
    );

    newFile('$testPackageLibPath/router/src/app_router.dart', r'''
import 'package:test/dependency_injection/injection.dart';

var x = DI();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/router/src/app_router.dart',
    );
  }
}
