/// Keeps transient feedback on the shared banner road.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoSnackbarOutsideBannerRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_snackbar_outside_banner',
    'Use the shared banner code instead of SnackBar or ScaffoldMessenger.',
    correctionMessage: 'Show feedback through the shared banner extension.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoSnackbarOutsideBannerRule()
    : super(
        name: 'no_snackbar_outside_banner',
        description: 'Keeps transient feedback on one shared road.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _SnackbarVisitor(this, context);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addSimpleIdentifier(this, visitor);
  }
}

class _SnackbarVisitor extends SimpleAstVisitor<void> {
  _SnackbarVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  bool get _isBannerCode {
    final path = currentFilePath(context)?.toLowerCase();
    return path != null &&
        (path.contains('/banners/') || path.split('/').last.contains('banner'));
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_isBannerCode && constructorTypeName(node) == 'SnackBar') {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!_isBannerCode && node.name == 'ScaffoldMessenger') {
      rule.reportAtNode(node);
    }
  }
}
