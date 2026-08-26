/// Lint rule: Package imports should use barrel files, not src/ folders.
///
/// This rule enforces the use of barrel files for imports within the same package.
/// Importing directly from src/ folders breaks encapsulation and violates the
/// module pattern where src/ should be private implementation.
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
///
/// The path is anchored on `/lib/` so a file of the same name elsewhere (a
/// test double, a nested package) is not mistaken for the registry.
const _fakeDataRegistryPath = '/lib/fake_data/src/fake_data_registry.dart';

/// The module a file belongs to.
///
/// A file inside a src/ folder belongs to the module owning that src/. Any
/// other file under lib/ belongs to the folder it sits in (a barrel, a
/// composition-root file), and a file directly under lib/ (main_common.dart,
/// main_<environment>.dart) belongs to no module at all.
String? _moduleOfFile(String filePath) {
  final srcMatch = RegExp(r'lib/([^/]+(?:/[^/]+)*?)/src/').firstMatch(filePath);
  if (srcMatch != null) return srcMatch.group(1);

  final libMatch = RegExp(r'lib/(.*)$').firstMatch(filePath);
  if (libMatch == null) return null;

  final segments = libMatch.group(1)!.split('/');
  if (segments.length == 1) return '';
  return segments.sublist(0, segments.length - 1).join('/');
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

    // Module = everything before /src/ (e.g., "foundation/clipboard" or
    // "features/auth"). Use non-greedy matching (*?) to stop at the FIRST
    // /src/ encountered (handles nested src folders like
    // features/x/src/blocs/y/src/).
    final importModuleMatch = RegExp(
      r'^([^/]+(?:/[^/]+)*?)/src/',
    ).firstMatch(importPath);

    // If we can't determine the modules, be conservative and don't report
    final currentModule = _moduleOfFile(currentFilePath);
    if (currentModule == null || importModuleMatch == null) return;

    final importModule = importModuleMatch.group(1)!;

    // Exception: the composition roots can import from any src/ folder.
    // dependency_injection/ and router/ are exempt as WHOLE homes; inside
    // fake_data/ only the registry file is.
    if (_composingHomes.contains(currentModule.split('/').first)) {
      return;
    }
    if (currentFilePath.endsWith(_fakeDataRegistryPath)) {
      return;
    }

    // Only report if importing from a DIFFERENT module's src/
    if (currentModule != importModule) {
      rule.reportAtNode(node);
    }
  }
}
