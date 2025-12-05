/// Tests for [FoundationImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/foundation_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FoundationImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class FoundationImportRestrictionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FoundationImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile(
      '$testPackageLibPath/foundation/networking/src/http_client.dart',
      r'''
import 'package:test/features/auth/auth.dart';

var x = Auth();
''',
    );

    await assertDiagnosticsInFile(
      '$testPackageLibPath/foundation/networking/src/http_client.dart',
      [
        lint(
          0,
          46,
          messageContainsAll: [
            'foundation/ can only import from resources/ or other foundation subfolders.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromRouter_violation() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/foundation/navigation/src/navigator.dart', r'''
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/foundation/navigation/src/navigator.dart',
      [
        lint(
          0,
          41,
          messageContainsAll: [
            'foundation/ can only import from resources/ or other foundation subfolders.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromResources_allowed() async {
    newFile('$testPackageLibPath/resources/strings.dart', 'class Strings {}');

    newFile('$testPackageLibPath/foundation/ui/src/theme.dart', r'''
import 'package:test/resources/strings.dart';

var x = Strings();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/foundation/ui/src/theme.dart',
    );
  }

  Future<void> test_importFromOtherFoundation_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/networking/http_client.dart',
      'class HttpClient {}',
    );

    newFile('$testPackageLibPath/foundation/utils/src/api_helper.dart', r'''
import 'package:test/foundation/networking/http_client.dart';

var x = HttpClient();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/foundation/utils/src/api_helper.dart',
    );
  }
}
