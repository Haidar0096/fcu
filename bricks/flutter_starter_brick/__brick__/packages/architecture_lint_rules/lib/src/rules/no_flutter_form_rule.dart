/// Prevents use of Flutter's Form widget.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoFlutterFormRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_flutter_form',
    'Do not use Flutter\'s Form widget.',
    correctionMessage: 'Use the project form-group helper.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoFlutterFormRule()
    : super(
        name: 'no_flutter_form',
        description: 'Keeps validation on the project form helper.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _FlutterFormVisitor(this, context),
    );
  }
}

class _FlutterFormVisitor extends SimpleAstVisitor<void> {
  _FlutterFormVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (constructorTypeName(node) == 'Form' &&
        importsPackage(context, 'flutter')) {
      rule.reportAtNode(node);
    }
  }
}
