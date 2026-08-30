/// Requires RootScreenWidget at the outer edge of each screen build.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class RequireRootScreenWidgetRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'require_root_screen_widget',
    'A screen build must return RootScreenWidget as its outermost widget.',
    correctionMessage: 'Wrap the screen in RootScreenWidget at the build root.',
    severity: DiagnosticSeverity.WARNING,
  );

  RequireRootScreenWidgetRule()
    : super(
        name: 'require_root_screen_widget',
        description: 'Keeps platform chrome and back handling on every screen.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodDeclaration(this, _RootScreenVisitor(this, context));
  }
}

class _RootScreenVisitor extends SimpleAstVisitor<void> {
  _RootScreenVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme != 'build' || !isScreenFile(context)) return;
    final declaration = enclosingClass(node);
    if (declaration == null) return;
    final name = className(declaration);
    if (!name.endsWith('Screen') && !name.endsWith('ScreenState')) return;

    if (!_allBuildReturnsUseRootScreenWidget(node.body)) {
      rule.reportAtToken(node.name);
    }
  }
}

bool _allBuildReturnsUseRootScreenWidget(FunctionBody body) {
  if (body is ExpressionFunctionBody) {
    return _isRootScreenWidget(body.expression);
  }
  if (body is! BlockFunctionBody) return false;

  final collector = _BuildReturnCollector();
  body.block.accept(collector);
  return collector.expressions.isNotEmpty &&
      collector.expressions.every(
        (expression) => expression != null && _isRootScreenWidget(expression),
      );
}

bool _isRootScreenWidget(Expression expression) {
  var current = expression;
  while (current is ParenthesizedExpression) {
    current = current.expression;
  }
  return current is InstanceCreationExpression &&
      constructorTypeName(current) == 'RootScreenWidget';
}

class _BuildReturnCollector extends RecursiveAstVisitor<void> {
  final List<Expression?> expressions = [];

  @override
  void visitReturnStatement(ReturnStatement node) {
    expressions.add(node.expression);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // A nested closure or local function has return paths of its own, not
    // return paths from the screen's build method.
  }
}
