/// Stops API and transport imports at the Bloc boundary.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoTransportImportsInUiRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_transport_imports_in_ui',
    'UI files must not import API, transport, or NetworkFailure code.',
    correctionMessage: 'Expose UI-shaped state from the Bloc instead.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoTransportImportsInUiRule()
    : super(
        name: 'no_transport_imports_in_ui',
        description: 'Keeps transport vocabulary out of presentation files.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addImportDirective(this, _TransportImportVisitor(this, context));
  }
}

class _TransportImportVisitor extends SimpleAstVisitor<void> {
  _TransportImportVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    final path = currentFilePath(context);
    if (path == null || !path.contains('/src/ui/')) return;
    final uri = node.uri.stringValue?.toLowerCase();
    if (uri == null) return;
    if (uri.contains('/apis/') ||
        uri.contains('/networking/') ||
        uri.contains('/transport/') ||
        uri.contains('network_failure')) {
      rule.reportAtNode(node);
    }
  }
}
