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

    final expression = _singleBuildExpression(node.body);
    if (expression == null) return;
    if (expression is InstanceCreationExpression &&
        constructorTypeName(expression) == 'RootScreenWidget') {
      return;
    }
    rule.reportAtToken(node.name);
  }
}

Expression? _singleBuildExpression(FunctionBody body) {
  if (body is ExpressionFunctionBody) return body.expression;
  if (body is! BlockFunctionBody) return null;
  final returns = body.block.statements.whereType<ReturnStatement>().toList();
  if (returns.length != 1) return null;
  return returns.single.expression;
}
