/// Keeps backend URL literals out of Dart source.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoBackendUrlLiteralsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_backend_url_literals',
    'Backend URL literals cannot live in Dart source.',
    correctionMessage: 'Move the URL to the environment JSON files.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoBackendUrlLiteralsRule()
    : super(
        name: 'no_backend_url_literals',
        description: 'Prevents backend URLs from living in Dart source.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _BackendUrlVisitor(this, context);
    registry
      ..addSimpleStringLiteral(this, visitor)
      ..addAdjacentStrings(this, visitor)
      ..addStringInterpolation(this, visitor)
      ..addInstanceCreationExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _BackendUrlVisitor extends SimpleAstVisitor<void> {
  _BackendUrlVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  static final RegExp _httpScheme = RegExp(
    r'^\s*https?://',
    caseSensitive: false,
  );
  static final RegExp _uriFactoryWithLiteral = RegExp(
    r'''^Uri\.(?:parse|http|https)\(\s*[rR]?['"]''',
  );
  static final RegExp _uriConstructorWithLiteralAddress = RegExp(
    r'''(?:scheme\s*:\s*[rR]?['"]https?['"]|host\s*:\s*[rR]?['"])''',
    caseSensitive: false,
  );

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.parent is AdjacentStrings) return;
    _checkString(node);
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) => _checkString(node);

  @override
  void visitStringInterpolation(StringInterpolation node) =>
      _checkString(node);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_isLiteralUriConstructor(node) || !_isBackendUrlContext(node)) return;
    rule.reportAtNode(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!_isLiteralUriFactory(node) || !_isBackendUrlContext(node)) return;
    rule.reportAtNode(node);
  }

  void _checkString(StringLiteral node) {
    if (_insideReportedUriExpression(node)) return;
    if (!_isBackendUrlContext(node) || !_encodesHttpAddress(node)) return;
    rule.reportAtNode(node);
  }

  bool _encodesHttpAddress(StringLiteral node) {
    final constantValue = node.stringValue;
    if (constantValue != null) return _httpScheme.hasMatch(constantValue);

    // Interpolation makes the complete value non-constant. In a proven
    // backend-base-url context, that expression is itself the literal URL
    // construction this rule forbids.
    return node is StringInterpolation || node is AdjacentStrings;
  }

  bool _insideReportedUriExpression(AstNode node) {
    for (
      AstNode? current = node.parent;
      current != null;
      current = current.parent
    ) {
      if (current is InstanceCreationExpression &&
          _isLiteralUriConstructor(current) &&
          _isBackendUrlContext(current)) {
        return true;
      }
      if (current is MethodInvocation &&
          _isLiteralUriFactory(current) &&
          _isBackendUrlContext(current)) {
        return true;
      }
      if (current is VariableDeclaration || current is AssignmentExpression) {
        break;
      }
    }
    return false;
  }

  bool _isLiteralUriConstructor(InstanceCreationExpression node) =>
      node.constructorName.type.name.lexeme == 'Uri' &&
      _uriConstructorWithLiteralAddress.hasMatch(node.toSource());

  bool _isLiteralUriFactory(MethodInvocation node) =>
      node.target?.toSource() == 'Uri' &&
      _uriFactoryWithLiteral.hasMatch(node.toSource());

  bool _isBackendUrlContext(AstNode node) {
    for (AstNode? current = node; current != null; current = current.parent) {
      final parent = current.parent;
      if (parent is VariableDeclaration &&
          _isBackendUrlName(parent.name.lexeme)) {
        return true;
      }
      final namedArgument = parent == null
          ? null
          : RegExp(
              r'^([A-Za-z_]\w*)\s*:',
            ).firstMatch(parent.toSource());
      if (namedArgument != null &&
          _isBackendUrlName(namedArgument.group(1)!)) {
        return true;
      }
      if (parent is AssignmentExpression &&
          _isBackendUrlName(parent.leftHandSide.toSource().split('.').last)) {
        return true;
      }
    }
    return false;
  }

  bool _isBackendUrlName(String name) {
    final normalizedName = name.replaceAll('_', '').toLowerCase();
    if (const {
      'backendurl',
      'backendbaseurl',
      'backenduri',
      'backendbaseuri',
    }.contains(normalizedName)) {
      return true;
    }

    final path = context.currentUnit?.file.path
        .replaceAll('\\', '/')
        .toLowerCase();
    if (path == null) return false;
    final isNetworking = path.contains('/foundation/networking/');
    final isEnvironmentVariables = path.endsWith(
      '/environment_variables.dart',
    );
    if (const {'baseurl', 'baseuri'}.contains(normalizedName)) {
      return isNetworking;
    }
    if (const {
      'apiurl',
      'apibaseurl',
      'apiuri',
      'apibaseuri',
    }.contains(normalizedName)) {
      return isNetworking || isEnvironmentVariables;
    }
    return false;
  }
}
