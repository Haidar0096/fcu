/// Lint rule: dependency_injection/ can only import fake_data/, features/,
/// foundation/, resources/, and router/.
///
/// The composition root wires everything together, so it reaches nearly every
/// home — but never the app layer that composes it.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Composition root importing app
/// // lib/dependency_injection/src/register_instances.dart
/// import 'package:myapp/app/app.dart';
///
/// // ✅ GOOD: Composition root importing a feature
/// import 'package:myapp/features/home/src/apis/home_api.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing dependency_injection import restrictions.
class DependencyInjectionImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'dependency_injection_import_restrictions',
    'dependency_injection/ can only import from fake_data/, features/, foundation/, resources/, router/, or dependency_injection/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [DependencyInjectionImportRestrictionsRule].
  DependencyInjectionImportRestrictionsRule()
    : super(
        name: 'dependency_injection_import_restrictions',
        description:
            'Prevents dependency_injection from importing disallowed layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _DependencyInjectionImportRestrictionsVisitor(
      this,
      context,
    );
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [DependencyInjectionImportRestrictionsRule].
class _DependencyInjectionImportRestrictionsVisitor
    extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _DependencyInjectionImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in dependency_injection/ folder
    if (!filePath.contains('lib/dependency_injection/')) return;

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

    // dependency_injection/ can ONLY import fake_data/, features/,
    // foundation/, resources/, router/, or itself
    const allowedFolders = [
      'dependency_injection/',
      'fake_data/',
      'features/',
      'foundation/',
      'resources/',
      'router/',
    ];

    // If importing from same package but NOT from allowed folders, report error
    if (!allowedFolders.any(importPath.startsWith)) {
      rule.reportAtNode(node);
    }
  }
}
