/// Prevents wire DTO types from entering widgets or Bloc state.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoDtoInUiOrBlocStateRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_dto_in_ui_or_bloc_state',
    'Do not expose DTO types to widgets or Bloc state.',
    correctionMessage: 'Convert the DTO to its UI model at the Bloc boundary.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoDtoInUiOrBlocStateRule()
    : super(
        name: 'no_dto_in_ui_or_bloc_state',
        description: 'Stops wire models at the Bloc boundary.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addNamedType(this, _DtoTypeVisitor(this, context));
  }
}

class _DtoTypeVisitor extends SimpleAstVisitor<void> {
  _DtoTypeVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitNamedType(NamedType node) {
    if (!node.name.lexeme.endsWith('Dto')) return;
    if (_isWidgetLocation(node, context) ||
        _isBlocStateLocation(node, context)) {
      rule.reportAtNode(node);
    }
  }
}

bool _isWidgetLocation(AstNode node, RuleContext context) {
  final path = currentFilePath(context);
  if (path?.contains('/src/ui/') ?? false) return true;
  final declaration = enclosingClass(node);
  if (declaration == null) return false;
  final name = className(declaration);
  final superclass = declaration.extendsClause?.superclass.name.lexeme;
  return name.endsWith('Widget') ||
      name.endsWith('Screen') ||
      superclass == 'StatelessWidget' ||
      superclass == 'StatefulWidget' ||
      superclass == 'State';
}

bool _isBlocStateLocation(AstNode node, RuleContext context) {
  final path = currentFilePath(context);
  if (path == null || !path.contains('/blocs/')) return false;
  final declaration = enclosingClass(node);
  return path.endsWith('_state.dart') ||
      (declaration != null && className(declaration).endsWith('State'));
}
