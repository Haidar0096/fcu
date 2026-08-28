/// Tests for [AppImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/app_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AppImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class AppImportRestrictionsRuleTest extends AnalysisRuleTest {
  static const _message =
      'app/ can only import from dependency_injection/, foundation/, '
      'resources/, router/, or app/.';

  @override
  void setUp() {
    rule = AppImportRestrictionsRule();
    super.setUp();
  }

  Future<void> test_importFromFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/app/src/root_app_widget.dart', r'''
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/app/src/root_app_widget.dart',
      [
        lint(0, 46, messageContainsAll: [_message]),
      ],
    );
  }

  Future<void> test_importFromFakeData_violation() async {
    newFile('$testPackageLibPath/fake_data/fake_data.dart', 'class Fakes {}');

    newFile('$testPackageLibPath/app/src/root_app_widget.dart', r'''
import 'package:test/fake_data/fake_data.dart';

var x = Fakes();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/app/src/root_app_widget.dart',
      [
        lint(0, 47, messageContainsAll: [_message]),
      ],
    );
  }

  Future<void> test_importFromRouter_allowed() async {
    newFile('$testPackageLibPath/router/router.dart', 'class AppRouter {}');

    newFile('$testPackageLibPath/app/src/root_app_widget.dart', r'''
import 'package:test/router/router.dart';

var x = AppRouter();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/app/src/root_app_widget.dart',
    );
  }

  Future<void> test_importFromDependencyInjection_allowed() async {
    newFile(
      '$testPackageLibPath/dependency_injection/dependency_injection.dart',
      'class ServiceLocator {}',
    );

    newFile('$testPackageLibPath/app/src/root_blocs_provider.dart', r'''
import 'package:test/dependency_injection/dependency_injection.dart';

var x = ServiceLocator();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/app/src/root_blocs_provider.dart',
    );
  }

  Future<void> test_importFromFoundationAndResources_allowed() async {
    newFile('$testPackageLibPath/foundation/ui/theme.dart', 'class Theme {}');
    newFile('$testPackageLibPath/resources/resources.dart', 'class Images {}');

    newFile('$testPackageLibPath/app/src/root_app_widget.dart', r'''
import 'package:test/foundation/ui/theme.dart';
import 'package:test/resources/resources.dart';

var x = Theme();
var y = Images();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/app/src/root_app_widget.dart',
    );
  }
}
