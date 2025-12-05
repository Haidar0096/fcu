/// Tests for [NoSrcImportsRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_src_imports_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoSrcImportsRuleTest);
  });
}

@reflectiveTest
class NoSrcImportsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoSrcImportsRule();
    super.setUp();
  }

  Future<void> test_differentModuleSrcImport_violation() async {
    newFile(
      '$testPackageLibPath/foundation/clipboard/src/clipboard_service.dart',
      'class ClipboardService {}',
    );

    newFile(
      '$testPackageLibPath/foundation/networking/src/http_client.dart',
      r'''
import 'package:test/foundation/clipboard/src/clipboard_service.dart';

var x = ClipboardService();
''',
    );

    await assertDiagnosticsInFile(
      '$testPackageLibPath/foundation/networking/src/http_client.dart',
      [
        lint(
          0,
          70,
          messageContainsAll: [
            'Do not import from src/ folders directly. Use barrel files instead.',
          ],
        ),
      ],
    );
  }

  Future<void> test_sameModuleSrcImport_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/networking/src/client.dart',
      'class Client {}',
    );

    newFile('$testPackageLibPath/foundation/networking/src/http.dart', r'''
import 'package:test/foundation/networking/src/client.dart';

var x = Client();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/foundation/networking/src/http.dart',
    );
  }

  Future<void> test_barrelFileImport_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/clipboard/clipboard.dart',
      'class ClipboardService {}',
    );

    newFile(
      '$testPackageLibPath/foundation/networking/src/http_client.dart',
      r'''
import 'package:test/foundation/clipboard/clipboard.dart';

var x = ClipboardService();
''',
    );

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/foundation/networking/src/http_client.dart',
    );
  }

  Future<void> test_dependencyInjectionImportingSrc_allowed() async {
    newFile(
      '$testPackageLibPath/features/auth/src/auth_cubit.dart',
      'class AuthCubit {}',
    );

    newFile('$testPackageLibPath/dependency_injection/src/injection.dart', r'''
import 'package:test/features/auth/src/auth_cubit.dart';

var x = AuthCubit();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/dependency_injection/src/injection.dart',
    );
  }
}
