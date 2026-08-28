/// Requires guarded Bloc and Cubit emissions after asynchronous gaps.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class GuardPostAwaitBlocEmitsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'guard_post_await_bloc_emits',
    'Guard post-await Bloc emissions with emitIfNotClosed and a close-guard mixin.',
    correctionMessage:
        'Use emitIfNotClosed after await and add the project close-guard mixin.',
    severity: DiagnosticSeverity.WARNING,
  );

  GuardPostAwaitBlocEmitsRule()
    : super(
        name: 'guard_post_await_bloc_emits',
        description: 'Prevents emitting after a Bloc or Cubit has closed.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _GuardPostAwaitVisitor(this);
    registry
      ..addAwaitExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _GuardPostAwaitVisitor extends SimpleAstVisitor<void> {
  _GuardPostAwaitVisitor(this.rule);

  final AnalysisRule rule;
  final Set<ClassDeclaration> reportedClasses = {};

  @override
  void visitAwaitExpression(AwaitExpression node) {
    final declaration = enclosingClass(node);
    if (declaration == null || !isBlocClass(declaration)) return;
    if (_hasCloseGuardMixin(declaration)) return;
    if (reportedClasses.add(declaration)) {
      rule.reportAtToken(declaration.namePart.typeName);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'emit' || !isInsideBloc(node)) return;
    final body = ancestorOfType<FunctionBody>(node);
    if (body == null) return;
    final collector = _AwaitCollector(body, node.offset)..collect();
    if (collector.hasEarlierAwait) rule.reportAtNode(node);
  }
}

bool _hasCloseGuardMixin(ClassDeclaration declaration) {
  final names = declaration.withClause?.mixinTypes
      .map((type) => type.name.lexeme)
      .toSet();
  if (names == null) return false;
  return names.any(
    (name) =>
        name == 'BlocUtils' ||
        name == 'CubitUtils' ||
        name == 'HydratedCubitUtils' ||
        name.contains('CloseGuard'),
  );
}

class _AwaitCollector extends RecursiveAstVisitor<void> {
  _AwaitCollector(this.body, this.beforeOffset);

  final FunctionBody body;
  final int beforeOffset;
  bool hasEarlierAwait = false;

  void collect() => body.accept(this);

  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (node.offset < beforeOffset &&
        ancestorOfType<FunctionBody>(node) == body) {
      hasEarlierAwait = true;
    }
  }
}
