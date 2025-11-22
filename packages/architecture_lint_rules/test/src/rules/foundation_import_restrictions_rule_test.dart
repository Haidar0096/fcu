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

  void test_foundationImportingFeatures_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/features/auth/auth.dart';

class HttpClient {}
''',
      [
        lint(0, 47),
      ],
    );
  }

  void test_foundationImportingApp_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/app/app.dart';

class HttpClient {}
''',
      [
        lint(0, 36),
      ],
    );
  }

  void test_foundationImportingRouter_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/router/router.dart';

class HttpClient {}
''',
      [
        lint(0, 42),
      ],
    );
  }

  void test_foundationImportingDI_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/dependency_injection/injection.dart';

class HttpClient {}
''',
      [
        lint(0, 59),
      ],
    );
  }

  void test_foundationImportingResources_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/resources/resources.dart';

class HttpClient {}
''');
  }

  void test_foundationImportingFoundation_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/foundation/logging/logger.dart';

class HttpClient {}
''');
  }

  void test_externalPackageImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:dio/dio.dart';

class HttpClient {}
''');
  }
}
