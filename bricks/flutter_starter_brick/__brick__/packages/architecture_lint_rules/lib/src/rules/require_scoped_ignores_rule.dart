/// Prevents file-wide ignores and requires a reason on line ignores.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class RequireScopedIgnoresRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'require_scoped_ignores',
    'Do not use file-wide ignores; line ignores must include a reason.',
    correctionMessage:
        'Use a line ignore followed by "--" and a plain-English reason.',
    severity: DiagnosticSeverity.WARNING,
  );

  RequireScopedIgnoresRule()
    : super(
        name: 'require_scoped_ignores',
        description: 'Keeps suppressions narrow and explained.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _ScopedIgnoreVisitor(this, context));
  }
}

class _ScopedIgnoreVisitor extends SimpleAstVisitor<void> {
  _ScopedIgnoreVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final content = context.currentUnit?.content;
    if (content == null) return;
    var offset = 0;
    for (final line in content.split('\n')) {
      final trimmed = line.trimLeft();
      final leadingLength = line.length - trimmed.length;
      if (RegExp(r'^//\s*ignore_for_file\s*:').hasMatch(trimmed)) {
        rule.reportAtOffset(offset + leadingLength, trimmed.length);
      } else if (RegExp(r'^//\s*ignore\s*:').hasMatch(trimmed) &&
          !_hasReason(trimmed)) {
        rule.reportAtOffset(offset + leadingLength, trimmed.length);
      }
      offset += line.length + 1;
    }
  }
}

bool _hasReason(String comment) {
  final reasonIndex = comment.indexOf(' -- ');
  if (reasonIndex < 0) return false;
  final reason = comment.substring(reasonIndex + 4).trim();
  return RegExp('[A-Za-z]{3}').hasMatch(reason);
}
