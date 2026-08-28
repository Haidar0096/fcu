/// Prevents service-locator reads inside Bloc and Cubit classes.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
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
    final visitor = _LocatorVisitor(this, context);
    registry
      ..addMethodInvocation(this, visitor)
      ..addFunctionExpressionInvocation(this, visitor);
  }
}

class _LocatorVisitor extends SimpleAstVisitor<void> {
  _LocatorVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  bool get _importsGetIt => importsPackage(context, 'get_it');

  bool get _importsLocator => context.definingUnit.unit.directives
      .whereType<ImportDirective>()
      .any((directive) {
        final uri = directive.uri.stringValue;
        return uri != null && uri.contains('/locator/');
      });

  /// `GetIt.I<T>()` and `getIt<T>()` resolve to a call on a getter's value,
  /// which the analyzer represents as a function-expression invocation.
  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (!isInsideBloc(node)) return;

    final function = node.function.toSource();
    final getItRead =
        _importsGetIt && (function == 'GetIt' || function.startsWith('GetIt.'));
    final namedLocatorRead = const {
      'getIt',
      'locator',
      'serviceLocator',
    }.contains(function);

    if (getItRead || namedLocatorRead) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!isInsideBloc(node)) return;

    final name = node.methodName.name;
    final target = node.realTarget?.toSource();
    final importsGetIt = _importsGetIt;
    final importsLocator = _importsLocator;

    final directLocatorRead =
        (importsGetIt || importsLocator) &&
        target == null &&
        const {'get', 'getIt', 'locator', 'tryGet'}.contains(name);
    final getItRead =
        importsGetIt &&
        target != null &&
        (target == 'GetIt' || target.startsWith('GetIt.'));
    final namedLocatorRead =
        target != null &&
        const {'getIt', 'locator', 'serviceLocator'}.contains(target);

    if (directLocatorRead || getItRead || namedLocatorRead) {
      rule.reportAtNode(node);
    }
  }
}
