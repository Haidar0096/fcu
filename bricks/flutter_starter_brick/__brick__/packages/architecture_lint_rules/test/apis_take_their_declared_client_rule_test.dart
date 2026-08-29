/// Tests for the rule that keeps a declared API on its declared HTTP client.
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:architecture_lint_rules/src/rules/apis_take_their_declared_client_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ApisTakeTheirDeclaredClientRuleTest);
    defineReflectiveTests(ApisTakeTheirShippedDeclarationTest);
  });
}

/// The types a composition root needs before it can wire anything.
const String _preamble = r'''
enum InstanceNames { publicBackendHttpClient, loggedInBackendHttpClient }
class HttpClient {}
class Locator { T get<T>({String? instanceName}) => null as T; }
final getIt = Locator();
class JokesApi { JokesApi(this.client); final HttpClient client; }
class ProfileApi { ProfileApi(this.client); final HttpClient client; }
''';

const String _publicWiring =
    'JokesApi(getIt.get<HttpClient>(instanceName: '
    'InstanceNames.publicBackendHttpClient.name))';

const String _loggedInWiring =
    'JokesApi(getIt.get<HttpClient>(instanceName: '
    'InstanceNames.loggedInBackendHttpClient.name))';

const String _unnamedWiring = 'JokesApi(getIt.get<HttpClient>())';

@reflectiveTest
class ApisTakeTheirDeclaredClientRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ApisTakeTheirDeclaredClientRule(
      declarations: const {'JokesApi': 'publicBackendHttpClient'},
    );
    super.setUp();
  }

  String get _compositionRootPath =>
      '$testPackageLibPath/dependency_injection/src/register_instances.dart';

  Future<void> test_wrongClient_reports() async {
    const source = '$_preamble\nfinal api = $_loggedInWiring;\n';
    newFile(_compositionRootPath, source);
    await assertDiagnosticsInFile(_compositionRootPath, [
      lint(source.indexOf(_loggedInWiring), _loggedInWiring.length),
    ]);
  }

  Future<void> test_noClientNamed_reports() async {
    const source = '$_preamble\nfinal api = $_unnamedWiring;\n';
    newFile(_compositionRootPath, source);
    await assertDiagnosticsInFile(_compositionRootPath, [
      lint(source.indexOf(_unnamedWiring), _unnamedWiring.length),
    ]);
  }

  Future<void> test_declaredClient_isQuiet() async {
    const source = '$_preamble\nfinal api = $_publicWiring;\n';
    newFile(_compositionRootPath, source);
    await assertNoDiagnosticsInFile(_compositionRootPath);
  }

  Future<void> test_undeclaredApi_isQuiet() async {
    const source =
        '$_preamble\nfinal api = ProfileApi(getIt.get<HttpClient>());\n';
    newFile(_compositionRootPath, source);
    await assertNoDiagnosticsInFile(_compositionRootPath);
  }

  Future<void> test_outsideTheCompositionRoot_isQuiet() async {
    final path = '$testPackageLibPath/features/jokes/src/apis/wiring.dart';
    const source = '$_preamble\nfinal api = $_loggedInWiring;\n';
    newFile(path, source);
    await assertNoDiagnosticsInFile(path);
  }
}

/// The declaration the starter ships, with no settings file behind it.
@reflectiveTest
class ApisTakeTheirShippedDeclarationTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ApisTakeTheirDeclaredClientRule();
    super.setUp();
  }

  String get _compositionRootPath =>
      '$testPackageLibPath/dependency_injection/src/register_instances.dart';

  Future<void> test_shippedDeclaration_wrongClient_reports() async {
    const source = '$_preamble\nfinal api = $_loggedInWiring;\n';
    newFile(_compositionRootPath, source);
    await assertDiagnosticsInFile(_compositionRootPath, [
      lint(source.indexOf(_loggedInWiring), _loggedInWiring.length),
    ]);
  }

  Future<void> test_shippedDeclaration_publicClient_isQuiet() async {
    const source = '$_preamble\nfinal api = $_publicWiring;\n';
    newFile(_compositionRootPath, source);
    await assertNoDiagnosticsInFile(_compositionRootPath);
  }
}
