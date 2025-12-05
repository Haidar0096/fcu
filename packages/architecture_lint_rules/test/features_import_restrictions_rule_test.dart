/// Tests for [FeaturesImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/features_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FeaturesImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class FeaturesImportRestrictionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FeaturesImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromRouter_violation() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/features/auth/src/login_screen.dart', r'''
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login_screen.dart',
      [
        lint(
          0,
          41,
          messageContainsAll: [
            'features/ can only import from foundation/, resources/, fake_data/, or features/',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromApp_violation() async {
    newFile('$testPackageLibPath/app/app.dart', 'class App {}');

    newFile('$testPackageLibPath/features/auth/src/login_screen.dart', r'''
import 'package:test/app/app.dart';

var x = App();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login_screen.dart',
      [
        lint(
          0,
          35,
          messageContainsAll: [
            'features/ can only import from foundation/, resources/, fake_data/, or features/',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromFoundation_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/ui/widgets/button.dart',
      'class AppButton {}',
    );

    newFile('$testPackageLibPath/features/auth/src/login_screen.dart', r'''
import 'package:test/foundation/ui/widgets/button.dart';

var x = AppButton();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login_screen.dart',
    );
  }

  Future<void> test_importFromResources_allowed() async {
    newFile('$testPackageLibPath/resources/strings.dart', 'class Strings {}');

    newFile('$testPackageLibPath/features/auth/src/login_screen.dart', r'''
import 'package:test/resources/strings.dart';

var x = Strings();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login_screen.dart',
    );
  }
}
