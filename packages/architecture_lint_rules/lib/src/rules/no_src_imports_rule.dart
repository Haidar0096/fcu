/// Lint rule: Package imports should use barrel files, not src/ folders.
///
/// This rule enforces the use of barrel files for imports within the same package.
/// Importing directly from src/ folders breaks encapsulation and violates the
/// module pattern where src/ should be private implementation.
///
/// Exception: The dependency_injection/ folder is allowed to import from any
/// src/ folder as it needs direct access to classes for dependency registration.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Importing through src/ (from non-DI folder)
/// import 'package:myapp/foundation/clipboard/src/clipboard_service.dart';
///
/// // ✅ GOOD: Importing through barrel file
/// import 'package:myapp/foundation/clipboard/clipboard.dart';
///
/// // ✅ GOOD: dependency_injection/ can import src/
/// // (in dependency_injection/ folder only)
/// import 'package:myapp/features/auth/src/auth_cubit.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing no direct src/ imports.
class NoSrcImportsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'no_src_imports',
    'Do not import from src/ folders directly. Use barrel files instead.',
    correctionMessage:
        'Import through the barrel file (without /src/) to maintain encapsulation.',
  );

  /// Creates an instance of [NoSrcImportsRule].
  NoSrcImportsRule()
    : super(
        name: 'no_src_imports',
        description:
            'Prevents direct imports from src/ folders to enforce use of barrel files.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _NoSrcImportsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [NoSrcImportsRule].
class _NoSrcImportsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _NoSrcImportsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

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

    // Check if the import path contains /src/
    if (!importPath.contains('/src/')) return;

    // Get current file path to determine the module
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final currentFilePath = currentUnit.file.path;

    // Extract the module path from both current file and import
    // Module = everything before /src/ (e.g., "foundation/clipboard" or "features/auth")
    final currentModuleMatch = RegExp(
      r'lib/([^/]+(?:/[^/]+)*)/src/',
    ).firstMatch(currentFilePath);
    final importModuleMatch = RegExp(
      r'^([^/]+(?:/[^/]+)*)/src/',
    ).firstMatch(importPath);

    // If we can't determine modules, be conservative and don't report
    if (currentModuleMatch == null || importModuleMatch == null) return;

    final currentModule = currentModuleMatch.group(1)!;
    final importModule = importModuleMatch.group(1)!;

    // Exception: dependency_injection/ can import from any src/ folder
    if (currentModule == 'dependency_injection') {
      return;
    }

    // Only report if importing from a DIFFERENT module's src/
    if (currentModule != importModule) {
      rule.reportAtNode(node);
    }
  }
}
