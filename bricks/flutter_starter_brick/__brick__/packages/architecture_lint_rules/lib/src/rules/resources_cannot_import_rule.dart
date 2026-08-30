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
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
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
    final currentPath = context.currentUnit?.file.path
        .replaceAll('\\', '/');
    if (currentPath == null) return;

    const resourcesMarker = '/lib/resources/';
    final resourcesIndex = currentPath.indexOf(resourcesMarker);
    if (resourcesIndex < 0) return;

    final importedPath = node.libraryImport?.importedLibrary?.firstFragment
        .source.fullName
        .replaceAll('\\', '/');
    if (importedPath == null) return;

    final projectRoot = currentPath.substring(0, resourcesIndex);
    if (!importedPath.startsWith('$projectRoot/')) return;

    if (!importedPath.startsWith('$projectRoot/lib/resources/')) {
      rule.reportAtNode(node);
    }
  }
}
