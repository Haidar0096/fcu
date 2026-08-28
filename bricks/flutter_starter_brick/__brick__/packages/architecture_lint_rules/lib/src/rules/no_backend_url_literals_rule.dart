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
    registry.addSimpleStringLiteral(this, _BackendUrlVisitor(this));
  }
}

class _BackendUrlVisitor extends SimpleAstVisitor<void> {
  _BackendUrlVisitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final value = node.value;
    if (!value.startsWith('http://') && !value.startsWith('https://')) return;
    rule.reportAtNode(node);
  }
}
