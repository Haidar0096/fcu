/// Lint rule: resources/ is a leaf folder and cannot import from the project.
///
/// The resources/ folder should only contain static assets and localization.
/// It cannot import from other project folders to maintain architectural purity.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Resources importing project code
/// // lib/resources/src/images.dart
/// import 'package:myapp/foundation/ui/theme.dart';
///
/// // ✅ GOOD: Resources with only external dependencies
/// import 'package:flutter/material.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing that resources cannot import project code.
class ResourcesCannotImportRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'resources_cannot_import',
    'resources/ is a leaf folder and cannot import from other project folders.',
  );

  /// Creates an instance of [ResourcesCannotImportRule].
  ResourcesCannotImportRule()
    : super(
        name: 'resources_cannot_import',
        description: 'Prevents resources from importing project code.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _ResourcesCannotImportVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [ResourcesCannotImportRule].
class _ResourcesCannotImportVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _ResourcesCannotImportVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in resources/ folder
    if (!filePath.contains('lib/resources/')) return;

    // Resources cannot import from any package:*/lib/ folders
    // Disallowed: foundation, features, app, router, dependency_injection
    if (RegExp(
      r'package:.+/(foundation|features|app|router|dependency_injection)/',
    ).hasMatch(uri)) {
      rule.reportAtNode(node);
    }
  }
}
