/// Tests for the architecture rules added in brick 4.4.1.
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/guard_post_await_bloc_emits_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_backend_url_literals_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_dto_in_ui_or_bloc_state_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_flutter_form_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_flutter_ui_in_bloc_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_framework_colors_in_ui_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_hardcoded_ui_strings_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_locator_reads_in_bloc_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_route_path_literals_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_secret_literals_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_snackbar_outside_banner_rule.dart';
import 'package:architecture_lint_rules/src/rules/no_transport_imports_in_ui_rule.dart';
import 'package:architecture_lint_rules/src/rules/require_root_screen_widget_rule.dart';
import 'package:architecture_lint_rules/src/rules/require_scoped_ignores_rule.dart';
import 'package:architecture_lint_rules/src/rules/vendor_imports_stay_in_wrappers_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(VendorImportsStayInWrappersRuleTest);
    defineReflectiveTests(VendorImportsSettingRuleTest);
    defineReflectiveTests(VendorImportsFolderSettingRuleTest);
    defineReflectiveTests(VendorImportsListSettingRuleTest);
    defineReflectiveTests(VendorImportsEmptySettingRuleTest);
    defineReflectiveTests(NoLocatorReadsInBlocRuleTest);
    defineReflectiveTests(NoFlutterUiInBlocRuleTest);
    defineReflectiveTests(GuardPostAwaitBlocEmitsRuleTest);
    defineReflectiveTests(NoBackendUrlLiteralsRuleTest);
    defineReflectiveTests(NoRoutePathLiteralsRuleTest);
    defineReflectiveTests(NoDtoInUiOrBlocStateRuleTest);
    defineReflectiveTests(NoTransportImportsInUiRuleTest);
    defineReflectiveTests(NoFrameworkColorsInUiRuleTest);
    defineReflectiveTests(NoSnackbarOutsideBannerRuleTest);
    defineReflectiveTests(NoFlutterFormRuleTest);
    defineReflectiveTests(RequireRootScreenWidgetRuleTest);
    defineReflectiveTests(NoHardcodedUiStringsRuleTest);
    defineReflectiveTests(RequireScopedIgnoresRuleTest);
    defineReflectiveTests(NoSecretLiteralsRuleTest);
  });
}

@reflectiveTest
class VendorImportsStayInWrappersRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = VendorImportsStayInWrappersRule();
    super.setUp();
  }

  Future<void> test_defaultWrapper_outsideWrapper_reports() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/features/auth/src/auth_repository.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [lint(0, source.indexOf('\n'))]);
  }

  Future<void> test_defaultWrapper_ownedFolder_isQuiet() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/foundation/platform/platform_io.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class VendorImportsSettingRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = VendorImportsStayInWrappersRule(
      wrappers: const {
        'dart:io': ['features/payments/src/vendor.dart'],
      },
    );
    super.setUp();
  }

  Future<void> test_setting_acceptsConfiguredFileOrFolder() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/features/payments/src/vendor.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class VendorImportsFolderSettingRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = VendorImportsStayInWrappersRule(
      wrappers: const {
        'dart:io': ['features/payments/src/apis'],
      },
    );
    super.setUp();
  }

  Future<void> test_folderSetting_insideFolder_isQuiet() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/features/payments/src/apis/vendor.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_folderSetting_outsideFolder_reports() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/features/payments/src/ui/vendor.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [lint(0, source.indexOf('\n'))]);
  }
}

@reflectiveTest
class VendorImportsListSettingRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = VendorImportsStayInWrappersRule(
      wrappers: const {
        'dart:io': [
          'features/payments/src/apis/vendor.dart',
          'foundation/networking',
        ],
      },
    );
    super.setUp();
  }

  Future<void> test_listSetting_listedFile_isQuiet() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/features/payments/src/apis/vendor.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_listSetting_listedFolder_isQuiet() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/foundation/networking/src/client_io.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_listSetting_elsewhere_reports() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/features/payments/src/ui/vendor.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [lint(0, source.indexOf('\n'))]);
  }
}

@reflectiveTest
class VendorImportsEmptySettingRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = VendorImportsStayInWrappersRule(wrappers: const {'dart:io': []});
    super.setUp();
  }

  Future<void> test_emptySetting_reportsEverywhere() async {
    const source = "import 'dart:io';\nFile? file;\n";
    final path = '$testPackageLibPath/foundation/platform/platform_io.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [lint(0, source.indexOf('\n'))]);
  }
}

@reflectiveTest
class NoLocatorReadsInBlocRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoLocatorReadsInBlocRule();
    super.setUp();
  }

  Future<void> test_locatorReadInCubit_reports() async {
    newFile(
      '$testPackageLibPath/foundation/locator/locator.dart',
      'class Locator { T get<T>() => null as T; } '
          'final serviceLocator = Locator();',
    );
    const source = r'''
import 'package:test/foundation/locator/locator.dart' as di;
class LoginCubit {
  void load() => di.serviceLocator.get<Object>();
}
''';
    newFile('$testPackageLibPath/login_cubit.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/login_cubit.dart', [
      lint(
        source.lastIndexOf('di.serviceLocator'),
        'di.serviceLocator.get<Object>()'.length,
      ),
    ]);
  }

  Future<void> test_callableLocatorReadInCubit_reports() async {
    newFile(
      '$testPackageLibPath/foundation/locator/locator.dart',
      'class Locator { T call<T>() => null as T; } '
          'final serviceLocator = Locator();',
    );
    const source = r'''
import 'package:test/foundation/locator/locator.dart' as di;
class LoginCubit {
  void load() => di.serviceLocator<Object>();
}
''';
    newFile('$testPackageLibPath/login_cubit.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/login_cubit.dart', [
      lint(
        source.lastIndexOf('di.serviceLocator'),
        'di.serviceLocator<Object>()'.length,
      ),
    ]);
  }

  Future<void> test_unrelatedLocalLocatorName_isQuiet() async {
    const source = r'''
final locator = Locator();
class Locator { T get<T>() => null as T; }
class LoginCubit {
  void load() => locator.get<Object>();
}
''';
    newFile('$testPackageLibPath/login_cubit.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/login_cubit.dart');
  }

  Future<void> test_injectedDependencyInCubit_isQuiet() async {
    const source = r'''
class LoginCubit {
  LoginCubit(this.repository);
  final Repository repository;
  void load() => repository.load();
}
class Repository { void load() {} }
''';
    newFile('$testPackageLibPath/login_cubit.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/login_cubit.dart');
  }
}

@reflectiveTest
class NoFlutterUiInBlocRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = NoFlutterUiInBlocRule();
    super.setUp();
  }

  Future<void> test_buildContextInBloc_reports() async {
    const source =
        "import 'package:flutter/widgets.dart' show BuildContext;\n"
        'class LoginBloc { void open(BuildContext context) {} }';
    newFile('$testPackageLibPath/login_bloc.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/login_bloc.dart', [
      lint(0, source.indexOf('\n')),
      lint(source.lastIndexOf('BuildContext'), 'BuildContext'.length),
    ]);
  }

  Future<void> test_flutterUiImportInBlocFile_reports() async {
    const source =
        "import 'package:flutter/material.dart' show Widget;\nWidget? marker;\nclass LoginBloc {}\n";
    newFile('$testPackageLibPath/login_bloc.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/login_bloc.dart', [
      lint(0, source.indexOf('\n')),
    ]);
  }

  Future<void> test_navigationCallInBloc_reports() async {
    const source = r'''import 'package:flutter/widgets.dart' show NavigatorState;
class LoginBloc {
  void close(NavigatorState navigator) => navigator.pop();
}
''';
    newFile('$testPackageLibPath/login_bloc.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/login_bloc.dart', [
      lint(0, source.indexOf('\n')),
      lint(
        source.indexOf('navigator.pop()'),
        'navigator.pop()'.length,
      ),
    ]);
  }

  Future<void> test_localBuildContextInBloc_isQuiet() async {
    const source =
        'class BuildContext {} '
        'class LoginBloc { void open(BuildContext context) {} }';
    newFile('$testPackageLibPath/login_bloc.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/login_bloc.dart');
  }

  Future<void> test_localNavigationLookalikeInBloc_isQuiet() async {
    const source = r'''
class Router { void go(String path) {} }
final context = Router();
class LoginBloc {
  void open() => context.go('/home');
}
''';
    newFile('$testPackageLibPath/login_bloc.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/login_bloc.dart');
  }

  Future<void> test_buildContextOutsideBloc_isQuiet() async {
    const source =
        'class BuildContext {} class ScreenController { void open(BuildContext context) {} }';
    newFile('$testPackageLibPath/screen_controller.dart', source);
    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/screen_controller.dart',
    );
  }
}

@reflectiveTest
class GuardPostAwaitBlocEmitsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = GuardPostAwaitBlocEmitsRule();
    super.setUp();
  }

  Future<void> test_unguardedEmitAfterAwait_reportsClassAndEmit() async {
    const source = r'''
class LoginCubit {
  Future<void> load() async {
    await fetch();
    emit(1);
  }
  Future<void> fetch() async {}
  void emit(Object value) {}
}
''';
    newFile('$testPackageLibPath/login_cubit.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/login_cubit.dart', [
      lint(source.indexOf('LoginCubit'), 'LoginCubit'.length),
      lint(source.indexOf('emit(1)'), 'emit(1)'.length),
    ]);
  }

  Future<void> test_closeGuardAndGuardedEmit_areQuiet() async {
    const source = r'''
mixin CubitUtilsMixin { void emitIfNotClosed(Object value) {} }
class LoginCubit with CubitUtilsMixin {
  Future<void> load() async {
    await fetch();
    emitIfNotClosed(1);
  }
  Future<void> fetch() async {}
}
''';
    newFile('$testPackageLibPath/login_cubit.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/login_cubit.dart');
  }
}

@reflectiveTest
class NoBackendUrlLiteralsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoBackendUrlLiteralsRule();
    super.setUp();
  }

  Future<void> test_backendUrlInClient_reports() async {
    const source =
        "class ApiClient { final baseUrl = 'https://api.example.com'; }";
    final path = '$testPackageLibPath/foundation/networking/api_client.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [
      lint(source.indexOf("'https"), "'https://api.example.com'".length),
    ]);
  }

  Future<void> test_backendUrlInEnvironmentVariables_reports() async {
    const source =
        "class EnvironmentVariables { static const apiUrl = 'https://api.example.com'; }";
    final path = '$testPackageLibPath/environment_variables.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [
      lint(source.indexOf("'https"), "'https://api.example.com'".length),
    ]);
  }
}

@reflectiveTest
class NoRoutePathLiteralsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoRoutePathLiteralsRule();
    super.setUp();
  }

  Future<void> test_literalNavigationPath_reports() async {
    const source = "void go(String path) {} void open() => go('/settings');";
    newFile('$testPackageLibPath/features/settings/src/ui/page.dart', source);
    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/settings/src/ui/page.dart',
      [lint(source.indexOf("'/settings'"), "'/settings'".length)],
    );
  }

  Future<void> test_routePathFamily_isQuiet() async {
    const source =
        "class SettingsRoutePath { static const path = '/settings'; }";
    newFile('$testPackageLibPath/router/src/route_path.dart', source);
    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/router/src/route_path.dart',
    );
  }
}

@reflectiveTest
class NoDtoInUiOrBlocStateRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoDtoInUiOrBlocStateRule();
    super.setUp();
  }

  Future<void> test_dtoInWidget_reports() async {
    const source =
        'class ProfileWidget { ProfileWidget(this.dto); final UserDto dto; } class UserDto {}';
    final path =
        '$testPackageLibPath/features/profile/src/ui/profile_widget.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [
      lint(source.indexOf('UserDto'), 'UserDto'.length),
    ]);
  }

  Future<void> test_uiModelInWidget_isQuiet() async {
    const source =
        'class ProfileWidget { ProfileWidget(this.model); final UserViewModel model; } class UserViewModel {}';
    final path =
        '$testPackageLibPath/features/profile/src/ui/profile_widget.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class NoTransportImportsInUiRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoTransportImportsInUiRule();
    super.setUp();
  }

  Future<void> test_networkingImportInUi_reports() async {
    newFile(
      '$testPackageLibPath/foundation/networking/client.dart',
      'class Client {}',
    );
    const source =
        "import 'package:test/foundation/networking/client.dart';\nClient? client;\n";
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [lint(0, source.indexOf('\n'))]);
  }

  Future<void> test_blocImportInUi_isQuiet() async {
    newFile(
      '$testPackageLibPath/features/auth/src/blocs/login_cubit.dart',
      'class LoginCubit {}',
    );
    const source =
        "import 'package:test/features/auth/src/blocs/login_cubit.dart';\nLoginCubit? cubit;\n";
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class NoFrameworkColorsInUiRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = NoFrameworkColorsInUiRule();
    super.setUp();
  }

  Future<void> test_frameworkColorInUi_reports() async {
    const source =
        "import 'package:flutter/material.dart' as material;\n"
        'var color = material.Colors.red;';
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [
      lint(source.lastIndexOf('red'), 'red'.length),
    ]);
  }

  Future<void> test_transparentInUi_isQuiet() async {
    newFile(
      '/packages/flutter/lib/src/material/colors.dart',
      'abstract final class Colors { '
          'static final transparent = Object(); }',
    );
    const source =
        "import 'package:flutter/src/material/colors.dart' as material;\n"
        'var color = material.Colors.transparent;';
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_localColorsName_isQuiet() async {
    const source =
        'class Colors { static final red = Object(); } var color = Colors.red;';
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class NoSnackbarOutsideBannerRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = NoSnackbarOutsideBannerRule();
    super.setUp();
  }

  Future<void> test_snackbarOutsideBanner_reports() async {
    newFile(
      '/packages/flutter/lib/src/material/snack_bar.dart',
      'class SnackBar { const SnackBar(); }',
    );
    const source =
        "import 'package:flutter/src/material/snack_bar.dart' as material;\n"
        'var bar = const material.SnackBar();';
    const construction = 'const material.SnackBar()';
    newFile('$testPackageLibPath/features/auth/src/ui/login.dart', source);
    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/ui/login.dart',
      [lint(source.indexOf(construction), construction.length)],
    );
  }

  Future<void> test_snackbarInsideBanner_isQuiet() async {
    newFile(
      '/packages/flutter/lib/src/material/snack_bar.dart',
      'class SnackBar { const SnackBar(); }',
    );
    const source =
        "import 'package:flutter/src/material/snack_bar.dart' as material;\n"
        'var bar = const material.SnackBar();';
    final path =
        '$testPackageLibPath/foundation/ui/widgets/src/sliding_banner.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }

  Future<void> test_localSnackBarName_isQuiet() async {
    const source = 'class SnackBar {} var bar = SnackBar();';
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class NoFlutterFormRuleTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = NoFlutterFormRule();
    super.setUp();
  }

  Future<void> test_flutterForm_reports() async {
    newFile(
      '/packages/flutter/lib/src/widgets/form.dart',
      'class Form { const Form({required Object child}); } '
          'class SizedBox { const SizedBox(); }',
    );
    const source =
        "import 'package:flutter/src/widgets/form.dart' as widgets;\n"
        'var form = widgets.Form(child: const widgets.SizedBox());';
    const construction = 'widgets.Form(child: const widgets.SizedBox())';
    newFile('$testPackageLibPath/features/auth/src/ui/login.dart', source);
    await assertDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/ui/login.dart',
      [lint(source.indexOf(construction), construction.length)],
    );
  }

  Future<void> test_localFormName_isQuiet() async {
    const source =
        "import 'package:flutter/widgets.dart' show Widget;\n"
        'Widget? marker; class Form {} var form = Form();';
    newFile('$testPackageLibPath/features/auth/src/ui/login.dart', source);
    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/ui/login.dart',
    );
  }

  Future<void> test_projectFormHelper_isQuiet() async {
    const source = 'class FormGroup {} var form = FormGroup();';
    newFile('$testPackageLibPath/features/auth/src/ui/login.dart', source);
    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/features/auth/src/ui/login.dart',
    );
  }
}

@reflectiveTest
class RequireRootScreenWidgetRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RequireRootScreenWidgetRule();
    super.setUp();
  }

  Future<void> test_otherOutermostWidget_reports() async {
    const source =
        'class Container {} class LoginScreen { Object build() => Container(); }';
    final path = '$testPackageLibPath/features/auth/src/ui/login_screen.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [
      lint(source.indexOf('build'), 'build'.length),
    ]);
  }

  Future<void> test_rootScreenWidgetOutermost_isQuiet() async {
    const source =
        'class RootScreenWidget {} class LoginScreen { Object build() => RootScreenWidget(); }';
    final path = '$testPackageLibPath/features/auth/src/ui/login_screen.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class NoHardcodedUiStringsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoHardcodedUiStringsRule();
    super.setUp();
  }

  Future<void> test_textLiteral_reports() async {
    const source =
        "class Text { Text(Object value); } var widget = Text('Hello');";
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertDiagnosticsInFile(path, [
      lint(source.indexOf("'Hello'"), "'Hello'".length),
    ]);
  }

  Future<void> test_localizedText_isQuiet() async {
    const source =
        "class Text { Text(Object value); } class Strings { String get hello => 'value'; } final strings = Strings(); var widget = Text(strings.hello);";
    final path = '$testPackageLibPath/features/auth/src/ui/login.dart';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

@reflectiveTest
class RequireScopedIgnoresRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RequireScopedIgnoresRule();
    super.setUp();
  }

  Future<void> test_fileWideIgnore_reports() async {
    const source = '// ignore_for_file: unused_local_variable\nvoid f() {}\n';
    newFile('$testPackageLibPath/example.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/example.dart', [
      lint(0, source.indexOf('\n')),
    ]);
  }

  Future<void> test_lineIgnoreWithReason_isQuiet() async {
    const source =
        '// ignore: unused_local_variable -- Demonstrates the required reason.\nvoid f() {}\n';
    newFile('$testPackageLibPath/example.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/example.dart');
  }
}

@reflectiveTest
class NoSecretLiteralsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = NoSecretLiteralsRule();
    super.setUp();
  }

  Future<void> test_awsAccessKeyShape_reports() async {
    const source = "const key = 'AKIA1234567890ABCDEF';";
    newFile('$testPackageLibPath/config.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/config.dart', [
      lint(source.indexOf("'AKIA"), "'AKIA1234567890ABCDEF'".length),
    ]);
  }

  Future<void> test_rsaPrivateKeyHeader_reports() async {
    const source = "const pem = '-----BEGIN RSA PRIVATE KEY-----';";
    newFile('$testPackageLibPath/config.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/config.dart', [
      lint(
        source.indexOf("'-----"),
        "'-----BEGIN RSA PRIVATE KEY-----'".length,
      ),
    ]);
  }

  Future<void> test_jwtShape_reports() async {
    const source =
        "const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';";
    newFile('$testPackageLibPath/config.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/config.dart', [
      lint(source.indexOf("'eyJ"), source.length - source.indexOf("'eyJ") - 1),
    ]);
  }

  Future<void> test_highEntropyValueOnSecretName_reports() async {
    const source = "const apiKey = 'Qz7pL2mN9vX4kR8tW1yB6cD3';";
    newFile('$testPackageLibPath/config.dart', source);
    await assertDiagnosticsInFile('$testPackageLibPath/config.dart', [
      lint(source.indexOf("'Qz7"), "'Qz7pL2mN9vX4kR8tW1yB6cD3'".length),
    ]);
  }

  Future<void> test_highEntropyValueOnPlainName_isQuiet() async {
    const source = "const requestId = 'Qz7pL2mN9vX4kR8tW1yB6cD3';";
    newFile('$testPackageLibPath/config.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/config.dart');
  }

  Future<void> test_nonSecretPlaceholder_isQuiet() async {
    const source = "const key = 'replace-me';";
    newFile('$testPackageLibPath/config.dart', source);
    await assertNoDiagnosticsInFile('$testPackageLibPath/config.dart');
  }
}
