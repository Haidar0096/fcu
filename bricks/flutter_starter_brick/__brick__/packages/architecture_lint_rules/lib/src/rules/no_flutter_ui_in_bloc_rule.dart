/// Keeps Flutter UI and navigation APIs out of Bloc and Cubit classes.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoFlutterUiInBlocRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_flutter_ui_in_bloc',
    'Do not use Flutter UI, BuildContext, or navigation inside a Bloc or Cubit.',
    correctionMessage: 'Move UI and navigation work to the presentation layer.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoFlutterUiInBlocRule()
    : super(
        name: 'no_flutter_ui_in_bloc',
        description: 'Keeps Bloc and Cubit classes independent of Flutter UI.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _NoFlutterUiVisitor(this, context);
    registry
      ..addImportDirective(this, visitor)
      ..addMethodInvocation(this, visitor)
      ..addNamedType(this, visitor);
  }
}

class _NoFlutterUiVisitor extends SimpleAstVisitor<void> {
  _NoFlutterUiVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    if (!unitContainsBloc(context)) return;
    final uri = node.uri.stringValue;
    if (uri == 'package:flutter/material.dart' ||
        uri == 'package:flutter/widgets.dart' ||
        uri == 'package:flutter/cupertino.dart') {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitNamedType(NamedType node) {
    if (node.name.lexeme == 'BuildContext' && isInsideBloc(node)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isInsideBloc(node)) return;
    final name = node.methodName.name;
    final target = node.realTarget?.toSource();
    final isContextNavigation =
        target == 'context' &&
        const {
          'canPop',
          'go',
          'goNamed',
          'pop',
          'push',
          'pushNamed',
        }.contains(name);
    final isFrameworkNavigation =
        target != null &&
        (target == 'Navigator' ||
            target.startsWith('Navigator.') ||
            target == 'GoRouter' ||
            target.startsWith('GoRouter.'));
    if (isContextNavigation || isFrameworkNavigation) {
      rule.reportAtNode(node);
    }
  }
}
