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
    registry.addSimpleStringLiteral(
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
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.value.isEmpty || !_isWidgetLocation(node, context)) return;
    if (_isTextArgument(node) || _isLabelArgument(node)) {
      rule.reportAtNode(node);
    }
  }
}

bool _isTextArgument(SimpleStringLiteral node) {
  final creation = ancestorOfType<InstanceCreationExpression>(node);
  return creation != null &&
      constructorTypeName(creation) == 'Text' &&
      creation.argumentList.arguments.isNotEmpty &&
      creation.argumentList.arguments.first == node;
}

bool _isLabelArgument(SimpleStringLiteral node) {
  final named = node.parent;
  if (named is! NamedArgument ||
      !_labelArgumentNames.contains(named.name.lexeme)) {
    return false;
  }
  return named.parent?.parent is InstanceCreationExpression;
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
