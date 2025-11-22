/// Tests for [MainEnvironmentFilesImportRestrictionsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/main_environment_files_import_restrictions_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MainEnvironmentFilesImportRestrictionsRuleTest);
  });
}

@reflectiveTest
class MainEnvironmentFilesImportRestrictionsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MainEnvironmentFilesImportRestrictionsRule();
    super.setUp();
  }

  void test_mainFileImportingApp_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/app/app.dart';

void main() {}
''',
      [
        lint(0, 36),
      ],
    );
  }

  void test_mainFileImportingFeatures_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/features/home/home.dart';

void main() {}
''',
      [
        lint(0, 47),
      ],
    );
  }

  void test_mainFileImportingRouter_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/router/router.dart';

void main() {}
''',
      [
        lint(0, 42),
      ],
    );
  }

  void test_mainFileImportingDI_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/dependency_injection/injection.dart';

void main() {}
''',
      [
        lint(0, 59),
      ],
    );
  }

  void test_mainFileImportingFoundation_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/foundation/environments/environment.dart';

void main() {}
''');
  }

  void test_mainFileImportingMainCommon_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:myapp/main_common.dart';

void main() {}
''');
  }

  void test_externalPackageImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

void main() {}
''');
  }

  void test_dartImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'dart:async';

void main() {}
''');
  }
}
