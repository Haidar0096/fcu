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
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in resources/ folder
    if (!filePath.contains('lib/resources/')) return;

    // Only check package: imports (skip dart: and relative imports)
    if (!uri.startsWith('package:')) return;

    // Extract package name from import
    final packageMatch = RegExp(r'package:([^/]+)/(.+)').firstMatch(uri);
    if (packageMatch == null) return;

    final importPackage = packageMatch.group(1)!;
    final importPath = packageMatch.group(2)!;

    // Get current package name from the library identifier
    final libraryElement = context.libraryElement;
    if (libraryElement == null) return;

    // Extract package name from library identifier (e.g., "package:myapp/...")
    final identifier = libraryElement.identifier;
    final currentPackageMatch = RegExp(
      r'package:([^/]+)/',
    ).firstMatch(identifier);
    if (currentPackageMatch == null) return;

    final currentPackage = currentPackageMatch.group(1)!;

    // Only check imports from the same package (skip external packages)
    if (importPackage != currentPackage) return;

    // Every home may import itself; resources/ is a leaf, so any OTHER folder
    // of the project's own code is a violation.
    if (!importPath.startsWith('resources/')) {
      rule.reportAtNode(node);
    }
  }
}
