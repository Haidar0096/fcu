/// Lint rule: app/ can only import app/, dependency_injection/, foundation/,
/// resources/, and router/.
///
/// The app layer composes the root widgets. It reaches the router and the
/// composition root, but never a feature directly.
///
/// Examples:
/// ```dart
/// // ❌ BAD: App importing a feature
/// // lib/app/src/root_app_widget.dart
/// import 'package:myapp/features/home/home.dart';
///
/// // ✅ GOOD: App importing the router
/// import 'package:myapp/router/router.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

String? _packageRelativePath(String filePath) {
  final normalized = filePath.replaceAll('\\', '/');
  final markerIndex = normalized.lastIndexOf('/lib/');
  if (markerIndex >= 0) {
    return normalized.substring(markerIndex + '/lib/'.length);
  }
  return normalized.startsWith('lib/') ? normalized.substring(4) : null;
}

String? _resolveRelativeImport(String currentPath, String uri) {
  final normalized = uri.replaceAll('\\', '/');
  final parsed = Uri.tryParse(normalized);
  if (parsed == null || parsed.hasScheme || normalized.startsWith('/')) {
    return null;
  }
  final segments = currentPath.split('/')..removeLast();
  for (final segment in parsed.pathSegments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (segments.isEmpty) return null;
      segments.removeLast();
    } else {
      segments.add(segment);
    }
  }
  return segments.join('/');
}

String? _samePackageImportPath(
  String uri,
  String currentPackage,
  String currentPath,
) {
  final normalized = uri.replaceAll('\\', '/');
  final packageMatch = RegExp(r'^package:([^/]+)/(.+)$').firstMatch(normalized);
  if (packageMatch != null) {
    return packageMatch.group(1) == currentPackage
        ? packageMatch.group(2)
        : null;
  }
  return _resolveRelativeImport(currentPath, normalized);
}

/// Rule enforcing app import restrictions.
class AppImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'app_import_restrictions',
    'app/ can only import from dependency_injection/, foundation/, resources/, router/, or app/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [AppImportRestrictionsRule].
  AppImportRestrictionsRule()
    : super(
        name: 'app_import_restrictions',
        description: 'Prevents app from importing disallowed layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _AppImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [AppImportRestrictionsRule].
class _AppImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _AppImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final currentPath = _packageRelativePath(currentUnit.file.path);
    if (currentPath == null || currentPath.split('/').first != 'app') return;

    final libraryElement = context.libraryElement;
    if (libraryElement == null) return;
    final identifier = libraryElement.identifier;
    final currentPackageMatch = RegExp(
      r'^package:([^/]+)/',
    ).firstMatch(identifier);
    if (currentPackageMatch == null) return;
    final currentPackage = currentPackageMatch.group(1)!;
    final importPath = _samePackageImportPath(
      uri,
      currentPackage,
      currentPath,
    );
    if (importPath == null) return;

    // app/ can ONLY import dependency_injection/, foundation/, resources/,
    // router/, or itself
    const allowedFolders = [
      'app/',
      'dependency_injection/',
      'foundation/',
      'resources/',
      'router/',
    ];

    if (!allowedFolders.any(importPath.startsWith)) {
      rule.reportAtNode(node);
    }
  }
}
