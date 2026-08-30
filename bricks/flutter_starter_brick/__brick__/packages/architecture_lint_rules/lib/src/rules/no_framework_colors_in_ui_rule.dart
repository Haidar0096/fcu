/// Prevents framework palette colors in UI code except transparency.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoFrameworkColorsInUiRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_framework_colors_in_ui',
    'Use theme color roles instead of Colors.* in UI code.',
    correctionMessage: 'Read a ColorScheme role from the project theme.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoFrameworkColorsInUiRule()
    : super(
        name: 'no_framework_colors_in_ui',
        description: 'Keeps UI colors on the project theme roles.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addSimpleIdentifier(this, _ColorsVisitor(this, context));
  }
}

class _ColorsVisitor extends SimpleAstVisitor<void> {
  _ColorsVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!isUiFile(context)) return;
    if (node.name == 'transparent') return;
    final enclosingElement = node.element?.enclosingElement;
    if (enclosingElement is! ClassElement ||
        enclosingElement.name != 'Colors') {
      return;
    }
    if (enclosingElement.library.uri.toString() !=
        'package:flutter/src/material/colors.dart') {
      return;
    }
    rule.reportAtNode(node);
  }
}
