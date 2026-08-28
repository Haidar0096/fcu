/// Tests for [NoFeatureCrossImportsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_feature_cross_imports_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoFeatureCrossImportsRuleTest);
  });
}

@reflectiveTest
class NoFeatureCrossImportsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoFeatureCrossImportsRule();
    super.setUp();
  }

  Future<void> test_differentFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', '');
    newFile(
      '$testPackageLibPath/features/profile/profile.dart',
      'class Profile {}',
    );

    newFile('$testPackageLibPath/features/auth/src/login.dart', r'''
import 'package:test/features/profile/profile.dart';

var x = Profile();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login.dart',
      [
        lint(
          0,
          52,
          messageContainsAll: ['Features cannot import from other features.'],
        ),
      ],
    );
  }

  Future<void> test_sameFeature_allowed() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/features/auth/src/login.dart', r'''
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login.dart',
    );
  }

  Future<void> test_importFromFoundation_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/networking/http_client.dart',
      'class HttpClient {}',
    );

    newFile('$testPackageLibPath/features/auth/src/login.dart', r'''
import 'package:test/foundation/networking/http_client.dart';

var x = HttpClient();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/login.dart',
    );
  }

  Future<void> test_sharedWithinSameParent_allowed() async {
    newFile(
      '$testPackageLibPath/features/health/shared/models.dart',
      'class HealthModel {}',
    );

    newFile('$testPackageLibPath/features/health/add_screen/src/add.dart', r'''
import 'package:test/features/health/shared/models.dart';

var x = HealthModel();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/health/add_screen/src/add.dart',
    );
  }

  Future<void> test_sharedFromDifferentParent_violation() async {
    newFile(
      '$testPackageLibPath/features/auth/shared/models.dart',
      'class AuthModel {}',
    );

    newFile('$testPackageLibPath/features/health/add_screen/src/add.dart', r'''
import 'package:test/features/auth/shared/models.dart';

var x = AuthModel();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/health/add_screen/src/add.dart',
      [
        lint(
          0,
          55,
          messageContainsAll: ['Features cannot import from other features.'],
        ),
      ],
    );
  }
}
