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

  void test_featureImportingApp_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/app/app.dart';

class AuthService {}
''',
      [
        lint(0, 36),
      ],
    );
  }

  void test_featureImportingRouter_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/router/router.dart';

class AuthService {}
''',
      [
        lint(0, 42),
      ],
    );
  }

  void test_featureImportingDI_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/dependency_injection/injection.dart';

class AuthService {}
''',
      [
        lint(0, 59),
      ],
    );
  }

  void test_featureImportingFoundation_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/foundation/networking/http_client.dart';

class AuthService {}
''');
  }

  void test_featureImportingResources_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/resources/resources.dart';

class AuthScreen {}
''');
  }

  void test_featureImportingFakeData_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/fake_data/fake_data.dart';

class AuthService {}
''');
  }

  void test_featureImportingFeatures_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/features/auth/auth.dart';

class HomeService {}
''');
  }

  void test_externalPackageImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit {}
''');
  }
}
