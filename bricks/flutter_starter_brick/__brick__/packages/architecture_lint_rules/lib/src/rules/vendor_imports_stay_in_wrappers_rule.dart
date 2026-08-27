/// Keeps configured vendor imports inside their owned wrapper locations.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';
import 'package:architecture_lint_rules/src/rules/vendor_import_configuration_io.dart';

/// Rule enforcing one owned import location per configured vendor package.
class VendorImportsStayInWrappersRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'vendor_imports_stay_in_wrappers',
    'Import this vendor package only from its configured wrapper.',
    correctionMessage:
        'Move the import into the configured wrapper and expose an owned API.',
    severity: DiagnosticSeverity.WARNING,
  );

  VendorImportsStayInWrappersRule({Map<String, List<String>>? wrappers})
    : _wrappers = wrappers,
      super(
        name: 'vendor_imports_stay_in_wrappers',
        description: 'Keeps vendor imports behind project-owned wrappers.',
      );

  final Map<String, List<String>>? _wrappers;

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addImportDirective(
      this,
      _VendorImportsVisitor(this, context, _wrappers),
    );
  }
}

const Map<String, List<String>> _defaultWrappers = {
  'dart:io': ['*_io.dart'],
  'dio': ['foundation/networking'],
  'f_logs': ['foundation/logging'],
  'flutter_riverpod': [],
  'flutter_svg': ['resources/src/images.dart'],
  'hooks_riverpod': [],
  'http': ['foundation/networking'],
  'logger': ['foundation/logging'],
  'logging': ['foundation/logging'],
  'loggy': ['foundation/logging'],
  'provider': [],
  'riverpod': [],
  'riverpod_annotation': [],
  'talker': ['foundation/logging'],
  'talker_flutter': ['foundation/logging'],
};

class _VendorImportsVisitor extends SimpleAstVisitor<void> {
  _VendorImportsVisitor(this.rule, this.context, this.overrideWrappers);

  final AnalysisRule rule;
  final RuleContext context;
  final Map<String, List<String>>? overrideWrappers;

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    final filePath = currentFilePath(context);
    if (uri == null || filePath == null) return;

    final packageName = _packageName(uri);
    if (packageName == null) return;

    final wrappers =
        overrideWrappers ??
        loadVendorImportConfiguration(filePath, _defaultWrappers);
    final allowedLocations = wrappers[packageName];
    if (allowedLocations == null) return;

    final relativePath = _relativeLibPath(filePath);
    if (relativePath == null) return;

    if (!allowedLocations.any(
      (location) => _matchesLocation(relativePath, location),
    )) {
      rule.reportAtNode(node);
    }
  }
}

String? _packageName(String uri) {
  if (uri == 'dart:io') return uri;
  final match = RegExp(r'^package:([^/]+)/').firstMatch(uri);
  return match?.group(1);
}

String? _relativeLibPath(String filePath) {
  final normalizedPath = filePath.replaceAll('\\', '/');
  final marker = normalizedPath.lastIndexOf('/lib/');
  if (marker < 0) return null;
  return normalizedPath.substring(marker + '/lib/'.length);
}

bool _matchesLocation(String filePath, String location) {
  final normalized = location
      .replaceFirst(RegExp(r'^lib/'), '')
      .replaceAll(RegExp(r'^/+|/+$'), '');
  if (normalized.startsWith('*')) {
    return filePath.split('/').last.endsWith(normalized.substring(1));
  }
  return filePath == normalized || filePath.startsWith('$normalized/');
}
