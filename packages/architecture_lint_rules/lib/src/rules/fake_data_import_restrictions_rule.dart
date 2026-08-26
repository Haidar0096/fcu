/// Lint rule: fake_data/ can only import features/, foundation/, and
/// resources/.
///
/// The fake-data registry composes fakes for the app's own types, so it
/// reaches features and foundation — but never the app layer, the router, or
/// the composition root.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Fake data importing the router
/// // lib/fake_data/src/fake_data_registry.dart
/// import 'package:myapp/router/router.dart';
///
/// // ✅ GOOD: Fake data importing a feature's api
/// import 'package:myapp/features/home/src/apis/home_api.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing fake_data import restrictions.
class FakeDataImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'fake_data_import_restrictions',
    'fake_data/ can only import from features/, foundation/, resources/, or fake_data/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [FakeDataImportRestrictionsRule].
  FakeDataImportRestrictionsRule()
    : super(
        name: 'fake_data_import_restrictions',
        description: 'Prevents fake_data from importing disallowed layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _FakeDataImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [FakeDataImportRestrictionsRule].
class _FakeDataImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _FakeDataImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in fake_data/ folder
    if (!filePath.contains('lib/fake_data/')) return;

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

    // fake_data/ can ONLY import features/, foundation/, resources/, or itself
    const allowedFolders = [
      'fake_data/',
      'features/',
      'foundation/',
      'resources/',
    ];

    // If importing from same package but NOT from allowed folders, report error
    if (!allowedFolders.any(importPath.startsWith)) {
      rule.reportAtNode(node);
    }
  }
}
