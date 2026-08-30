/// Prevents hard-coded user-visible strings in Text and label arguments.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

class NoHardcodedUiStringsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_hardcoded_ui_strings',
    'Do not hard-code user-visible text or labels.',
    correctionMessage: 'Read the string from app localizations.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoHardcodedUiStringsRule()
    : super(
        name: 'no_hardcoded_ui_strings',
        description: 'Keeps user-visible strings in localization resources.',
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
      _HardcodedUiStringVisitor(this, context),
    );
  }
}

const Set<String> _labelArgumentNames = {
  'actionText',
  'buttonText',
  'errorText',
  'helperText',
  'hintText',
  'label',
  'labelText',
  'semanticLabel',
  'text',
  'title',
  'tooltip',
};

class _HardcodedUiStringVisitor extends SimpleAstVisitor<void> {
  _HardcodedUiStringVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_isWidgetLocation(node, context)) return;

    final arguments = node.argumentList.arguments;
    if (constructorTypeName(node) == 'Text' && arguments.isNotEmpty) {
      _reportIfHardcoded(arguments.first.argumentExpression);
    }

    for (final named in arguments.whereType<NamedArgument>()) {
      if (_labelArgumentNames.contains(named.name.lexeme)) {
        _reportIfHardcoded(named.argumentExpression);
      }
    }
  }

  void _reportIfHardcoded(Expression expression) {
    final detector = _HardcodedStringDetector();
    expression.accept(detector);
    if (detector.found) rule.reportAtNode(expression);
  }
}

class _HardcodedStringDetector extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.value.isNotEmpty) found = true;
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    if (node.value.isNotEmpty) found = true;
  }
}

bool _isWidgetLocation(AstNode node, RuleContext context) {
  if (isUiFile(context)) return true;
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
