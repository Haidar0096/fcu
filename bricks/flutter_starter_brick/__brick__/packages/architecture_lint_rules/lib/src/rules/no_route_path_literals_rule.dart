/// Keeps route path strings in the RoutePath family.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoRoutePathLiteralsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_route_path_literals',
    'Keep route path literals in the RoutePath family.',
    correctionMessage: 'Reference the matching RoutePath constant.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoRoutePathLiteralsRule()
    : super(
        name: 'no_route_path_literals',
        description: 'Prevents route paths from gaining a second string home.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addSimpleStringLiteral(
      this,
      _RoutePathLiteralVisitor(this, context),
    );
  }
}

class _RoutePathLiteralVisitor extends SimpleAstVisitor<void> {
  _RoutePathLiteralVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (!node.value.startsWith('/') || node.value.startsWith('//')) return;
    final declaration = enclosingClass(node);
    if (declaration != null && className(declaration).endsWith('RoutePath')) {
      return;
    }

    final path = currentFilePath(context);
    final invocation = ancestorOfType<MethodInvocation>(node);
    final methodName = invocation?.methodName.name;
    final isNavigationCall = const {
      'go',
      'goNamed',
      'push',
      'pushNamed',
      'pushReplacement',
      'replace',
    }.contains(methodName);
    final isRouterFile = path?.contains('/router/') ?? false;
    if (isNavigationCall || isRouterFile) rule.reportAtNode(node);
  }
}
