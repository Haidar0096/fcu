/// Tests for [ResourcesCannotImportRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/resources_cannot_import_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ResourcesCannotImportRuleTest);
  });
}

@reflectiveTest
class ResourcesCannotImportRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ResourcesCannotImportRule();
    super.setUp();
  }

  Future<void> test_importFromFoundation_violation() async {
    newFile(
      '$testPackageLibPath/foundation/ui/theme.dart',
      'class AppTheme {}',
    );

    newFile('$testPackageLibPath/resources/src/images.dart', r'''
import 'package:test/foundation/ui/theme.dart';

var x = AppTheme();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/resources/src/images.dart',
      [
        lint(
          0,
          47,
          messageContainsAll: [
            'resources/ is a leaf folder and cannot import from other project folders.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/resources/src/strings.dart', r'''
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/resources/src/strings.dart',
      [
        lint(
          0,
          46,
          messageContainsAll: [
            'resources/ is a leaf folder and cannot import from other project folders.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromExternalPackage_allowed() async {
    newFile('$testPackageLibPath/resources/src/images.dart', r'''
void test() {}
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/resources/src/images.dart',
    );
  }
}
