/// Keeps every declared API on the named HTTP client its project declared for
/// it.
///
/// The contract this enforces is already written: an app registers its HTTP
/// clients under instance names, and the composition root — never the API
/// class — names the one client each API takes. Nothing checked that, and a
/// planted breach analyzed clean.
///
/// Which client an API takes is the PROJECT's answer, so it is declared in the
/// analyzed project's own `analysis_options.yaml`:
///
/// ```yaml
/// architecture_lint_rules:
///   api_http_clients:
///     ProfileApi: loggedInBackendHttpClient
/// ```
///
/// An API that is not declared is not checked: the rule invents no mapping.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/api_client_configuration_io.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

/// Rule enforcing that a declared API is built with its declared client.
class ApisTakeTheirDeclaredClientRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'apis_take_their_declared_client',
    'Build this class with the HTTP client declared for it.',
    correctionMessage:
        'In the composition root, resolve the client under the instance name '
        'this class is declared to take.',
    // WARNING, like every rule here: a request that rides the wrong client
    // either carries a token where none belongs or carries none where one is
    // required, and both fail at the server rather than at the build.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates the rule. [declarations] replaces the project's own settings and
  /// exists so a test can state a mapping without a file on disk.
  ApisTakeTheirDeclaredClientRule({Map<String, String>? declarations})
    : _declarations = declarations,
      super(
        name: 'apis_take_their_declared_client',
        description:
            'Keeps each API on the named HTTP client its project declared.',
      );

  final Map<String, String>? _declarations;

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _ApiClientVisitor(this, context, _declarations),
    );
  }
}

/// The declarations the starter ships, read off its own composition root: the
/// sample jokes endpoint needs no login, so its API takes the public client.
///
/// A project adds its own APIs beside this one in `analysis_options.yaml`; an
/// entry there wins over an entry here.
const Map<String, String> _defaultDeclarations = {
  'JokesApi': 'publicBackendHttpClient',
};

/// The only place a client is named: the composition root.
///
/// The rule reads nothing else, so a test double built in `test/` and a fake
/// registry are not mistaken for a wiring decision.
const String _compositionRoot = '/lib/dependency_injection/';

/// Every `InstanceNames.<name>` reference inside an expression.
final RegExp _instanceNameReference = RegExp(r'InstanceNames\.([A-Za-z0-9_]+)');

class _ApiClientVisitor extends SimpleAstVisitor<void> {
  _ApiClientVisitor(this.rule, this.context, this.overrideDeclarations);

  final AnalysisRule rule;
  final RuleContext context;
  final Map<String, String>? overrideDeclarations;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final filePath = currentFilePath(context);
    if (filePath == null) return;
    if (!filePath.replaceAll('\\', '/').contains(_compositionRoot)) return;

    final declarations =
        overrideDeclarations ??
        loadApiClientDeclarations(filePath, _defaultDeclarations);
    final declaredClient = declarations[constructorTypeName(node)];
    if (declaredClient == null) return;

    final namedClients = _instanceNameReference
        .allMatches(node.argumentList.toSource())
        .map((match) => match.group(1)!)
        .toSet();

    // Exactly one client, and the declared one. No name at all is a breach
    // too: an unnamed client is whichever one the container happens to hand
    // over.
    if (namedClients.length != 1 || namedClients.first != declaredClient) {
      rule.reportAtNode(node);
    }
  }
}
