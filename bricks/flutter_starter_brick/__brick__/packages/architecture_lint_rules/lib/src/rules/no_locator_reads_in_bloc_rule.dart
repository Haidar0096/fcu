/// Prevents service-locator reads inside Bloc and Cubit classes.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoLocatorReadsInBlocRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_locator_reads_in_bloc',
    'Do not read GetIt or a service locator inside a Bloc or Cubit.',
    correctionMessage: 'Inject the dependency through the constructor.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoLocatorReadsInBlocRule()
    : super(
        name: 'no_locator_reads_in_bloc',
        description: 'Keeps Bloc and Cubit dependencies constructor-injected.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _LocatorVisitor(this);
    registry
      ..addMethodInvocation(this, visitor)
      ..addFunctionExpressionInvocation(this, visitor);
  }
}

class _LocatorVisitor extends SimpleAstVisitor<void> {
  _LocatorVisitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (!isInsideBloc(node)) return;
    if (_isLocatorElement(node.element)) rule.reportAtNode(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isInsideBloc(node)) return;
    if (_isLocatorElement(node.methodName.element)) rule.reportAtNode(node);
  }

  bool _isLocatorElement(Element? element) {
    final baseElement = element?.baseElement;
    if (baseElement == null) return false;
    final libraryUri = baseElement.library?.uri.toString();
    if (libraryUri == null ||
        (!libraryUri.startsWith('package:get_it/') &&
            !libraryUri.replaceAll('\\', '/').contains('/locator/'))) {
      return false;
    }
    return const {'call', 'get', 'getAsync', 'tryGet'}.contains(
      baseElement.displayName,
    );
  }
}
