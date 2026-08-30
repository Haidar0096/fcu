/// Lint rule: Imports should use barrel files, not src/ folders.
///
/// This rule enforces the use of barrel files for imports within the same
/// package.
/// Importing directly from src/ folders through package, relative, default, or
/// conditional URIs breaks encapsulation and violates the module pattern where
/// src/ should be private implementation.
///
/// Exception: the composition roots — dependency_injection/, router/, and the
/// fake_data/ registry FILE — are allowed to import from any src/ folder, as
/// they need direct access to classes in order to compose them. The exemption
/// on fake_data/ is the registry file alone (lib/fake_data/src/
/// fake_data_registry.dart), not the whole folder: every other file under
/// fake_data/ goes through the barrel like any other module.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Importing through src/ (from a non-composition folder)
/// import 'package:myapp/foundation/clipboard/src/clipboard_service.dart';
///
/// // ✅ GOOD: Importing through barrel file
/// import 'package:myapp/foundation/clipboard/clipboard.dart';
///
/// // ✅ GOOD: a composition root can import src/
/// // (anywhere in dependency_injection/ or router/, and in the one file
/// // lib/fake_data/src/fake_data_registry.dart)
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
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
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

/// The top-level homes that may reach into another module's src/ to compose
/// it, WHOLE: the import table's two sanctioned reachers-in that are homes.
///
/// `fake_data/` is deliberately absent — the table grants that exemption to its
/// registry file only, which [_fakeDataRegistryPath] names.
const _composingHomes = {'dependency_injection', 'router'};

/// The one file inside `fake_data/` the import table lets reach into another
/// module's src/: "its registry".
const _fakeDataRegistryPath = 'fake_data/src/fake_data_registry.dart';

const _rootSrcModule = '<root-src>';

String? _packageRelativePath(String filePath) {
  final normalized = filePath.replaceAll('\\', '/');
  final markerIndex = normalized.lastIndexOf('/lib/');
  if (markerIndex >= 0) {
    return normalized.substring(markerIndex + '/lib/'.length);
  }
  return normalized.startsWith('lib/') ? normalized.substring(4) : null;
}

/// The module a file belongs to.
///
/// A file inside a src/ folder belongs to the module owning that src/. Any
/// other file under lib/ belongs to the folder it sits in (a barrel, a
/// composition-root file), and the main.dart file directly under lib/ belongs
/// to no module at all.
String? _moduleOfPath(String relativePath) {
  final segments = relativePath.split('/');
  final srcIndex = segments.indexOf('src');
  if (srcIndex >= 0) {
    return srcIndex == 0
        ? _rootSrcModule
        : segments.sublist(0, srcIndex).join('/');
  }
  if (segments.length == 1) return null;
  return segments.sublist(0, segments.length - 1).join('/');
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

/// Visitor implementation for [NoSrcImportsRule].
class _NoSrcImportsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _NoSrcImportsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final currentPath = _packageRelativePath(currentUnit.file.path);
    if (currentPath == null) return;
    final currentModule = _moduleOfPath(currentPath);

    if (_composingHomes.contains(currentPath.split('/').first) ||
        currentPath == _fakeDataRegistryPath) {
      return;
    }

    final libraryElement = context.libraryElement;
    if (libraryElement == null) return;
    final identifier = libraryElement.identifier;
    final currentPackageMatch = RegExp(
      r'^package:([^/]+)/',
    ).firstMatch(identifier);
    if (currentPackageMatch == null) return;
    final currentPackage = currentPackageMatch.group(1)!;

    final uriLiterals = <StringLiteral>[
      node.uri,
      for (final configuration in node.configurations) configuration.uri,
    ];
    for (final uriLiteral in uriLiterals) {
      final uri = uriLiteral.stringValue;
      if (uri == null) continue;
      final importPath = _samePackageImportPath(
        uri,
        currentPackage,
        currentPath,
      );
      if (importPath == null) continue;
      final importSegments = importPath.split('/');
      final srcIndex = importSegments.indexOf('src');
      if (srcIndex < 0) continue;
      final importModule = srcIndex == 0
          ? _rootSrcModule
          : importSegments.sublist(0, srcIndex).join('/');
      if (currentModule != importModule) {
        rule.reportAtNode(node);
        return;
      }
    }
  }
}
