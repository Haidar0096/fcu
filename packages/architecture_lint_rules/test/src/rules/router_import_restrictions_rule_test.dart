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

  void test_routerImportingApp_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/app/app.dart';

class AppRouter {}
''',
      [
        lint(0, 36),
      ],
    );
  }

  void test_routerImportingFeatures_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/features/home/home.dart';

class AppRouter {}
''');
  }

  void test_routerImportingFoundation_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/foundation/ui/theme.dart';

class AppRouter {}
''');
  }

  void test_routerImportingResources_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/resources/resources.dart';

class AppRouter {}
''');
  }

  void test_routerImportingDI_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/dependency_injection/injection.dart';

class AppRouter {}
''');
  }

  void test_routerImportingRouter_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/router/routes.dart';

class AppRouter {}
''');
  }

  void test_externalPackageImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:go_router/go_router.dart';

class AppRouter {}
''');
  }
}
