/// Lint rule: fake_data/ can only import fake_data/, features/, foundation/,
/// and resources/.
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
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final sourcePath = _pathUnderFinalLib(currentUnit.file.path);
    if (sourcePath == null || !sourcePath.startsWith('fake_data/')) return;

    final libraryElement = context.libraryElement;
    if (libraryElement == null) return;
    final currentPackageMatch = RegExp(
      r'package:([^/]+)/',
    ).firstMatch(libraryElement.identifier);
    if (currentPackageMatch == null) return;
    final currentPackage = currentPackageMatch.group(1)!;

    final uriNodes = <StringLiteral>[
      node.uri,
      ...node.configurations.map((configuration) => configuration.uri),
    ];
    for (final uriNode in uriNodes) {
      final uri = uriNode.stringValue;
      if (uri == null) continue;
      final importPath = _samePackageImportPath(
        uri: uri,
        currentPackage: currentPackage,
        sourcePath: sourcePath,
      );
      if (importPath != null && !_isAllowedImportPath(importPath)) {
        rule.reportAtNode(node);
        return;
      }
    }
  }

  static const _allowedFolders = [
    'fake_data/',
    'features/',
    'foundation/',
    'resources/',
  ];

  String? _samePackageImportPath({
    required String uri,
    required String currentPackage,
    required String sourcePath,
  }) {
    if (uri.startsWith('package:')) {
      final packageMatch = RegExp(r'package:([^/]+)/(.+)').firstMatch(uri);
      if (packageMatch == null || packageMatch.group(1) != currentPackage) {
        return null;
      }
      return packageMatch.group(2)!;
    }

    final parsedUri = Uri.tryParse(uri);
    if (parsedUri == null || parsedUri.hasScheme) return null;
    final resolvedPath = Uri(path: '/$sourcePath').resolveUri(parsedUri).path;
    return resolvedPath.startsWith('/')
        ? resolvedPath.substring(1)
        : resolvedPath;
  }

  bool _isAllowedImportPath(String importPath) =>
      _allowedFolders.any(importPath.startsWith);

  String? _pathUnderFinalLib(String filePath) {
    final normalizedPath = filePath.replaceAll('\\', '/');
    final libIndex = normalizedPath.lastIndexOf('/lib/');
    if (libIndex < 0) return null;
    return normalizedPath.substring(libIndex + '/lib/'.length);
  }
}
