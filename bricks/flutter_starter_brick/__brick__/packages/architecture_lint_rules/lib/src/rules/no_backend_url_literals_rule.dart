/// Keeps backend URLs in EnvironmentVariables.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoBackendUrlLiteralsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_backend_url_literals',
    'Keep backend URL literals in EnvironmentVariables.',
    correctionMessage: 'Move the URL to the EnvironmentVariables family.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoBackendUrlLiteralsRule()
    : super(
        name: 'no_backend_url_literals',
        description: 'Prevents backend URLs from becoming call-site config.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addSimpleStringLiteral(this, _BackendUrlVisitor(this, context));
  }
}

class _BackendUrlVisitor extends SimpleAstVisitor<void> {
  _BackendUrlVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final value = node.value;
    if (!value.startsWith('http://') && !value.startsWith('https://')) return;
    if (_isEnvironmentVariablesLocation(node, context)) return;
    if (_looksLikeBackendLocation(node, context)) rule.reportAtNode(node);
  }
}

bool _isEnvironmentVariablesLocation(AstNode node, RuleContext context) {
  final path = currentFilePath(context);
  return isInsideNamedClass(node, 'EnvironmentVariables') ||
      (path?.contains('/environment_variables/') ?? false);
}

bool _looksLikeBackendLocation(AstNode node, RuleContext context) {
  final path = currentFilePath(context);
  if (path != null &&
      (path.contains('/networking/') || path.contains('/apis/'))) {
    return true;
  }
  final declaration = enclosingClass(node);
  if (declaration != null) {
    final name = className(declaration);
    if (name.endsWith('Api') ||
        name.endsWith('Client') ||
        name.endsWith('Repository') ||
        name.endsWith('Service')) {
      return true;
    }
  }
  final parentSource = node.parent?.toSource().toLowerCase() ?? '';
  return const {
    'apiurl',
    'backendurl',
    'baseurl',
    'baseuri',
    'serverurl',
  }.any(parentSource.contains);
}
