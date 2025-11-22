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

  /// Test: Resources importing foundation should report diagnostic
  void test_resourcesImportingFoundation_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/foundation/ui/theme.dart';

class Images {}
''',
      [
        lint(0, 48),
      ],
    );
  }

  /// Test: Resources importing features should report diagnostic
  void test_resourcesImportingFeatures_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/features/home/home.dart';

class Images {}
''',
      [
        lint(0, 47),
      ],
    );
  }

  /// Test: Resources importing app should report diagnostic
  void test_resourcesImportingApp_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/app/app.dart';

class Images {}
''',
      [
        lint(0, 36),
      ],
    );
  }

  /// Test: Resources importing router should report diagnostic
  void test_resourcesImportingRouter_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/router/router.dart';

class Images {}
''',
      [
        lint(0, 42),
      ],
    );
  }

  /// Test: Resources importing dependency_injection should report diagnostic
  void test_resourcesImportingDI_reportsDiagnostic() async {
    await assertDiagnostics(
      r'''
import 'package:myapp/dependency_injection/injection.dart';

class Images {}
''',
      [
        lint(0, 59),
      ],
    );
  }

  /// Test: External package import should NOT report diagnostic
  void test_externalPackageImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

class Images {}
''');
  }

  /// Test: Dart SDK import should NOT report diagnostic
  void test_dartImport_noDiagnostic() async {
    await assertNoDiagnostics(r'''
import 'dart:ui';

class Images {}
''');
  }
}
