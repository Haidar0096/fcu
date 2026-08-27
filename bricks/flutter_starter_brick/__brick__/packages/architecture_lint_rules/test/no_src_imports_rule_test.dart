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

  Future<void> test_routerImportingSrc_allowed() async {
    newFile(
      '$testPackageLibPath/features/auth/src/auth_screen.dart',
      'class AuthScreen {}',
    );

    newFile('$testPackageLibPath/router/src/router.dart', r'''
import 'package:test/features/auth/src/auth_screen.dart';

var x = AuthScreen();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/router/src/router.dart',
    );
  }

  Future<void> test_fakeDataRegistryImportingSrc_allowed() async {
    newFile(
      '$testPackageLibPath/features/auth/src/apis/auth_api.dart',
      'class AuthApi {}',
    );

    newFile('$testPackageLibPath/fake_data/src/fake_data_registry.dart', r'''
import 'package:test/features/auth/src/apis/auth_api.dart';

var x = AuthApi();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/fake_data/src/fake_data_registry.dart',
    );
  }

  Future<void> test_fakeDataNonRegistryFileImportingSrc_violation() async {
    // The import table grants the src/ reach to the fake_data REGISTRY file,
    // not to the fake_data folder: any other file there uses the barrel.
    newFile(
      '$testPackageLibPath/features/auth/src/apis/auth_api.dart',
      'class AuthApi {}',
    );

    newFile('$testPackageLibPath/fake_data/src/fake_jokes.dart', r'''
import 'package:test/features/auth/src/apis/auth_api.dart';

var x = AuthApi();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/fake_data/src/fake_jokes.dart',
      [
        lint(
          0,
          59,
          messageContainsAll: [
            'Do not import from src/ folders directly. Use barrel files instead.',
          ],
        ),
      ],
    );
  }

  Future<void> test_barrelFileImportingAnotherModuleSrc_violation() async {
    newFile(
      '$testPackageLibPath/foundation/clipboard/src/clipboard_service.dart',
      'class ClipboardService {}',
    );

    newFile('$testPackageLibPath/app/app.dart', r'''
import 'package:test/foundation/clipboard/src/clipboard_service.dart';

var x = ClipboardService();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/app/app.dart', [
      lint(
        0,
        70,
        messageContainsAll: [
          'Do not import from src/ folders directly. Use barrel files instead.',
        ],
      ),
    ]);
  }

  Future<void> test_mainCommonImportingSrc_violation() async {
    newFile(
      '$testPackageLibPath/foundation/clipboard/src/clipboard_service.dart',
      'class ClipboardService {}',
    );

    newFile('$testPackageLibPath/main_common.dart', r'''
import 'package:test/foundation/clipboard/src/clipboard_service.dart';

var x = ClipboardService();
''');

    await assertDiagnosticsInFile('$testPackageLibPath/main_common.dart', [
      lint(
        0,
        70,
        messageContainsAll: [
          'Do not import from src/ folders directly. Use barrel files instead.',
        ],
      ),
    ]);
  }

  Future<void> test_moduleBarrelImportingItsOwnSrc_allowed() async {
    newFile(
      '$testPackageLibPath/foundation/clipboard/src/clipboard_service.dart',
      'class ClipboardService {}',
    );

    newFile('$testPackageLibPath/foundation/clipboard/clipboard.dart', r'''
import 'package:test/foundation/clipboard/src/clipboard_service.dart';

var x = ClipboardService();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/foundation/clipboard/clipboard.dart',
    );
  }

  Future<void> test_sameModuleSrcImport_threeLevelDeep_allowed() async {
    // Test case for 3-level deep modules like foundation/models/ui_models
    // Tests nested src/ folder handling that was previously reported as false flag
    newFile(
      '$testPackageLibPath/foundation/models/ui_models/src/ui_question_and_answer.dart',
      'class UiQuestionAndAnswer {}',
    );

    newFile(
      '$testPackageLibPath/foundation/models/ui_models/src/ui_patient_portal_appointment.dart',
      r'''
import 'package:test/foundation/models/ui_models/src/ui_question_and_answer.dart';

var x = UiQuestionAndAnswer();
''',
    );

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/foundation/models/ui_models/src/ui_patient_portal_appointment.dart',
    );
  }
}
