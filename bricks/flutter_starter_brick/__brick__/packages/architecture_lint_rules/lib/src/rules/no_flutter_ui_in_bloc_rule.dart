/// Keeps Flutter UI and navigation APIs out of Bloc and Cubit classes.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
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
    final type = node.type;
    final element = type is InterfaceType ? type.element : node.element;
    if (isInsideBloc(node) &&
        element?.displayName == 'BuildContext' &&
        _isFromPackage(element, 'flutter')) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isInsideBloc(node)) return;
    final element = node.methodName.element;
    final ownerName = element?.enclosingElement?.displayName;
    final isFlutterNavigation =
        _isFromPackage(element, 'flutter') &&
        const {'Navigator', 'NavigatorState'}.contains(ownerName);
    final isGoRouterNavigation = _isFromPackage(element, 'go_router');
    if (isFlutterNavigation || isGoRouterNavigation) {
      rule.reportAtNode(node);
    }
  }
}

bool _isFromPackage(Element? element, String packageName) {
  final uri = element?.library?.uri;
  return uri != null &&
      uri.scheme == 'package' &&
      uri.pathSegments.isNotEmpty &&
      uri.pathSegments.first == packageName;
}
