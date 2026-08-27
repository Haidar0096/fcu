/// Detects concrete secret-shaped literals in Dart source.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class NoSecretLiteralsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_secret_literals',
    'Do not embed secret-looking literals in Dart source.',
    correctionMessage: 'Remove the secret and rotate it if it was real.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoSecretLiteralsRule()
    : super(
        name: 'no_secret_literals',
        description: 'Catches concrete key and token shapes in Dart source.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addSimpleStringLiteral(this, _SecretLiteralVisitor(this));
  }
}

class _SecretLiteralVisitor extends SimpleAstVisitor<void> {
  _SecretLiteralVisitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (_knownSecretShape(node.value) ||
        (_hasSensitiveName(node) && _looksHighEntropy(node.value))) {
      rule.reportAtNode(node);
    }
  }
}

bool _knownSecretShape(String value) =>
    RegExp(r'-----BEGIN [A-Z ]*PRIVATE KEY-----').hasMatch(value) ||
    RegExp(r'^AKIA[0-9A-Z]{16}$').hasMatch(value) ||
    RegExp(r'^AIza[0-9A-Za-z_-]{30,}$').hasMatch(value) ||
    RegExp(r'^gh[pousr]_[0-9A-Za-z]{20,}$').hasMatch(value) ||
    RegExp(r'^sk_live_[0-9A-Za-z]{16,}$').hasMatch(value) ||
    RegExp(
      r'^[A-Za-z0-9_-]{16,}\.[A-Za-z0-9_-]{16,}\.[A-Za-z0-9_-]{16,}$',
    ).hasMatch(value);

bool _hasSensitiveName(SimpleStringLiteral node) {
  final parent = node.parent;
  String? name;
  if (parent is VariableDeclaration) {
    name = parent.name.lexeme;
  } else if (parent is NamedArgument) {
    name = parent.name.lexeme;
  }
  if (name == null) return false;
  final normalized = name.toLowerCase();
  return const {
    'apikey',
    'accesstoken',
    'clientsecret',
    'password',
    'privatekey',
    'secret',
    'token',
  }.any(normalized.contains);
}

bool _looksHighEntropy(String value) {
  if (value.length < 24 || RegExp(r'\s').hasMatch(value)) return false;
  return RegExp('[a-z]').hasMatch(value) &&
      RegExp('[A-Z]').hasMatch(value) &&
      RegExp('[0-9]').hasMatch(value);
}
