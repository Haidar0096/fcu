/// Lint rule: main_common.dart can only import app/, dependency_injection/,
/// foundation/, and resources/.
///
/// The common main does the whole boot and hands over to the app layer; it
/// never reaches a feature or the router itself.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Common main importing the router
/// // lib/main_common.dart
/// import 'package:myapp/router/router.dart';
///
/// // ✅ GOOD: Common main importing the app layer
/// import 'package:myapp/app/app.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing main_common.dart import restrictions.
class MainCommonImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'main_common_import_restrictions',
    'main_common.dart can only import from app/, dependency_injection/, foundation/, or resources/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [MainCommonImportRestrictionsRule].
  MainCommonImportRestrictionsRule()
    : super(
        name: 'main_common_import_restrictions',
        description:
            'Prevents main_common.dart from importing disallowed modules.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _MainCommonImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [MainCommonImportRestrictionsRule].
class _MainCommonImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _MainCommonImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check the main_common.dart sitting directly under lib/
    if (!filePath.endsWith('/lib/main_common.dart')) return;

    // Only check package: imports (skip dart: and relative imports)
    if (!uri.startsWith('package:')) return;

    // Extract package name and path from import
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

    // main_common.dart can ONLY import app/, dependency_injection/,
    // foundation/, or resources/
    const allowedFolders = [
      'app/',
      'dependency_injection/',
      'foundation/',
      'resources/',
    ];

    // If importing from same package but NOT from allowed folders, report error
    if (!allowedFolders.any(importPath.startsWith)) {
      rule.reportAtNode(node);
    }
  }
}
