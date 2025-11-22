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

  /// Test: Cross-feature import should report diagnostic
  void test_crossFeatureImport_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/features/profile/profile.dart';

class AuthService {}
''',
      [
        lint(0, 53),
      ],
    );
  }

  /// Test: Same feature import should NOT report diagnostic
  void test_sameFeatureImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/features/authentication/auth_repository.dart';

class AuthService {}
''');
  }

  /// Test: Foundation import should NOT report diagnostic
  void test_foundationImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/foundation/networking/http_client.dart';

class AuthService {}
''');
  }

  /// Test: Resources import should NOT report diagnostic
  void test_resourcesImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/resources/resources.dart';

class AuthScreen {}
''');
  }

  /// Test: External package import should NOT report diagnostic
  void test_externalPackageImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit {}
''');
  }

  /// Test: Dart SDK import should NOT report diagnostic
  void test_dartImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'dart:async';

class AuthService {}
''');
  }
}
