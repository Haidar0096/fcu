// Mirrors the mobile skill page mobile/flutter/structure.md.
import 'dart:io';

final List<String> _violations = [];
late String _rootPath;

void main() {
  final root = Directory.current.absolute;
  _rootPath = root.path;
  final lib = Directory('${root.path}/lib');
  _checkEnvironmentFiles(root);
  if (!lib.existsSync()) {
    _add('lib', 1, 'the app must have a lib/ tree');
    _finish();
    return;
  }

  _checkTopLevel(lib);
  _checkModule(Directory('${lib.path}/app'), 2);
  _checkModule(Directory('${lib.path}/dependency_injection'), 2);
  _checkModule(Directory('${lib.path}/resources'), 2);
  _checkModule(Directory('${lib.path}/router'), 2);
  _checkFeatureTree(Directory('${lib.path}/features'));
  _checkFoundationTree(Directory('${lib.path}/foundation'));
  _checkForbiddenFolders(lib);
  _checkBlocFolders(lib);
  _checkConditionalFiles(lib);
  _checkGeneratedFiles(lib);
  _checkAppHome(lib);
  _checkResourcesHome(lib);
  _checkCompositionHomes(lib);
  _finish();
}

void _checkTopLevel(Directory lib) {
  const requiredHomes = {
    'app',
    'dependency_injection',
    'features',
    'foundation',
    'resources',
    'router',
  };
  const allowedHomes = {...requiredHomes, 'fake_data'};
  final entries = _visibleEntries(lib);
  final directories = {
    for (final entry in entries.whereType<Directory>()) _name(entry.path),
  };
  final files = {
    for (final entry in entries.whereType<File>()) _name(entry.path),
  };

  for (final home in requiredHomes) {
    if (!directories.contains(home)) {
      _add('lib/$home', 1, 'required top-level home is missing');
    }
  }
  for (final home in directories.difference(allowedHomes)) {
    _add('lib/$home', 1, 'unexpected top-level home');
  }
  final fakeData = Directory('${lib.path}/fake_data');
  if (fakeData.existsSync() && _allFiles(fakeData).isEmpty) {
    _add('lib/fake_data', 1, 'an empty home is omitted');
  }
  if (!files.contains('main.dart')) {
    _add('lib/main.dart', 1, 'the single entry point is missing');
  }
  for (final file in files) {
    if (file != 'main.dart') {
      _add('lib/$file', 1, 'unexpected file at the lib/ root');
    }
  }
}

void _checkEnvironmentFiles(Directory root) {
  final env = Directory('${root.path}/env');
  if (!env.existsSync()) {
    _add('env', 1, 'the build environment folder is missing');
    return;
  }

  final entries = _visibleEntries(env);
  final files = {
    for (final entry in entries.whereType<File>()) _name(entry.path),
  };
  if (files.isEmpty) {
    _add('env', 1, 'declare at least one build environment JSON file');
  }
  for (final entry in entries) {
    if (entry is! File || !_name(entry.path).endsWith('.json')) {
      _add(
        _relative(entry.path),
        1,
        'env/ contains JSON environment files only',
      );
    }
  }
}

void _checkFeatureTree(Directory features) {
  if (!features.existsSync()) return;
  for (final entry in _visibleEntries(features)) {
    if (entry is! Directory) {
      _add(_relative(entry.path), 4, 'features/ contains folders only');
      continue;
    }
    if (_looksLikeModule(entry)) {
      _checkModule(entry, 2);
      _checkFeatureModule(entry);
      continue;
    }

    final childNames = {
      for (final child in _visibleEntries(entry).whereType<Directory>())
        _name(child.path),
    };
    final platformBases = <String>{};
    for (final childName in childNames) {
      for (final suffix in ['_mobile', '_web']) {
        if (childName.endsWith(suffix)) {
          platformBases.add(
            childName.substring(0, childName.length - suffix.length),
          );
        }
      }
    }
    for (final child in _visibleEntries(entry)) {
      if (child is! Directory) {
        _add(
          _relative(child.path),
          4,
          'a business-domain grouping folder contains module folders only',
        );
        continue;
      }
      final childName = _name(child.path);
      if (childName == 'shared') {
        _checkSharedFolder(child);
      } else {
        _checkModule(child, 2);
        _checkFeatureModule(child);
      }
    }
    for (final base in platformBases) {
      for (final sibling in ['${base}_mobile', '${base}_web', 'shared']) {
        if (!childNames.contains(sibling)) {
          _add(
            _relative('${entry.path}/$sibling'),
            14,
            'a whole-feature platform split holds <feature>_mobile, '
            '<feature>_web, and shared/ together',
          );
        }
      }
    }
  }
}

void _checkFeatureModule(Directory module) {
  final moduleName = _name(module.path);
  final src = Directory('${module.path}/src');
  if (!src.existsSync()) return;
  const kinds = {'ui', 'blocs', 'models', 'apis'};
  for (final entry in _visibleEntries(src)) {
    if (entry is! Directory || !kinds.contains(_name(entry.path))) {
      _add(
        _relative(entry.path),
        5,
        'a feature src/ splits only into ui, blocs, models, and apis',
      );
    }
  }

  final ui = Directory('${src.path}/ui');
  if (ui.existsSync()) {
    for (final entry in _visibleEntries(ui).whereType<Directory>()) {
      _add(_relative(entry.path), 7, 'a feature ui/ folder must stay flat');
    }
  }

  if (moduleName.endsWith('_screen')) {
    final screen = File('${ui.path}/$moduleName.dart');
    if (!screen.existsSync()) {
      _add(
        _relative(screen.path),
        4,
        'a *_screen module needs a same-named screen file under src/ui',
      );
    }
  }

  final models = Directory('${src.path}/models');
  if (models.existsSync()) {
    const modelKinds = {
      'dtos',
      'ui_models',
      'enums',
      'errors',
      'events',
      'mixins',
    };
    for (final entry in _visibleEntries(models)) {
      if (entry is! Directory || !modelKinds.contains(_name(entry.path))) {
        _add(
          _relative(entry.path),
          5,
          'models/ contains only the prescribed model kind folders',
        );
      }
    }
  }
}

void _checkSharedFolder(Directory shared) {
  final barrel = File('${shared.path}/shared.dart');
  if (!barrel.existsSync()) {
    _add(_relative(barrel.path), 8, 'every feature shared/ needs shared.dart');
  }
  final nestedSrc = Directory('${shared.path}/src');
  if (nestedSrc.existsSync()) {
    _add(
      _relative(nestedSrc.path),
      8,
      'feature shared/ holds kind folders directly, without src/',
    );
  }
  const kinds = {'ui', 'blocs', 'models', 'apis'};
  for (final entry in _visibleEntries(shared)) {
    if (entry.path == barrel.path || entry.path == nestedSrc.path) continue;
    if (entry is! Directory || !kinds.contains(_name(entry.path))) {
      _add(
        _relative(entry.path),
        8,
        'feature shared/ holds only shared.dart and the ui, blocs, models, '
        'and apis kind folders',
      );
    }
  }
}

void _checkFoundationTree(Directory foundation) {
  if (!foundation.existsSync()) return;
  const groupingFolders = {'ui', 'models', 'blocs'};
  for (final entry in _visibleEntries(foundation)) {
    if (entry is! Directory) {
      _add(_relative(entry.path), 9, 'foundation/ contains capability folders');
      continue;
    }
    if (_looksLikeModule(entry)) {
      _checkModule(entry, 2);
      continue;
    }
    final name = _name(entry.path);
    if (!groupingFolders.contains(name)) {
      _add(
        _relative(entry.path),
        9,
        'a foundation capability needs its barrel and src/ shape',
      );
      continue;
    }
    for (final child in _visibleEntries(entry)) {
      if (child is Directory) {
        _checkModule(child, 2);
      } else {
        _add(
          _relative(child.path),
          2,
          'a pure grouping folder contains module folders only',
        );
      }
    }
  }
}

bool _looksLikeModule(Directory directory) {
  final name = _name(directory.path);
  return File('${directory.path}/$name.dart').existsSync() ||
      Directory('${directory.path}/src').existsSync();
}

void _checkModule(Directory module, int rule) {
  if (!module.existsSync()) return;
  final name = _name(module.path);
  final barrel = File('${module.path}/$name.dart');
  final src = Directory('${module.path}/src');
  if (!barrel.existsSync()) {
    _add(
      _relative(barrel.path),
      rule,
      'module barrel must match its folder name',
    );
  }
  if (!src.existsSync()) {
    _add(_relative(src.path), rule, 'module code must live under src/');
  }
  for (final entry in _visibleEntries(module)) {
    if (entry.path == barrel.path || entry.path == src.path) continue;
    _add(
      _relative(entry.path),
      rule,
      'a module root contains only its barrel and src/',
    );
  }
}

void _checkForbiddenFolders(Directory lib) {
  const forbidden = {'data', 'domain', 'presentation', 'services'};
  for (final directory in _allDirectories(lib)) {
    final name = _name(directory.path);
    if (forbidden.contains(name) && _hasForbiddenArchitecturalRole(directory)) {
      _add(
        _relative(directory.path),
        name == 'services' ? 9 : 1,
        'this layer-first or generic bucket name is forbidden',
      );
    }
    if (name == 'widgets' && _relative(directory.path).contains('/src/ui/')) {
      _add(
        _relative(directory.path),
        7,
        'ui/ is the widget folder and cannot contain nested widgets/',
      );
    }
    final parentName = _name(directory.parent.path);
    if (name == 'widgets' && (parentName == 'src' || parentName == 'shared')) {
      _add(
        _relative(directory.path),
        7,
        'the widget folder is named ui/ at every level, never widgets/',
      );
    }
  }
}

bool _hasForbiddenArchitecturalRole(Directory directory) {
  final segments = _relative(directory.path).split('/');
  if (segments.length < 2 || segments.first != 'lib') return false;

  if (segments.length == 2) return true;
  if (_name(directory.parent.path) == 'src') return true;

  final home = segments[1];
  if (home == 'foundation') return true;
  if (home == 'features') {
    return segments.length > 3;
  }
  return false;
}

void _checkBlocFolders(Directory lib) {
  for (final blocs in _allDirectories(lib).where(
    (directory) =>
        _name(directory.path) == 'blocs' &&
        _name(directory.parent.path) == 'src',
  )) {
    for (final entry in _visibleEntries(blocs)) {
      if (entry is! Directory) {
        _add(
          _relative(entry.path),
          6,
          'each Bloc or Cubit gets its own folder under blocs/',
        );
        continue;
      }
      final name = _name(entry.path);
      final mainFile = File('${entry.path}/$name.dart');
      if (!mainFile.existsSync()) {
        _add(
          _relative(mainFile.path),
          6,
          'Bloc/Cubit folder and main file names must match',
        );
      }
      for (final child in _visibleEntries(entry)) {
        if (child is! File) {
          _add(
            _relative(child.path),
            6,
            'Bloc/Cubit folders contain files only',
          );
          continue;
        }
        final childName = _name(child.path);
        if (name.endsWith('_cubit') && childName.endsWith('_event.dart')) {
          _add(_relative(child.path), 6, 'a cubit has no event file');
        }
        final allowed =
            childName == '$name.dart' ||
            childName.endsWith('_state.dart') ||
            childName.endsWith('_event.dart') ||
            childName.endsWith('.g.dart') ||
            childName.endsWith('.freezed.dart');
        if (!allowed) {
          _add(
            _relative(child.path),
            6,
            'Bloc/Cubit folders contain only the main, state, event, and generated files',
          );
        }
      }
    }
  }
}

void _checkGeneratedFiles(Directory lib) {
  for (final file in _allFiles(lib)) {
    final name = _name(file.path);
    for (final suffix in ['.g.dart', '.freezed.dart']) {
      if (!name.endsWith(suffix)) continue;
      final base = file.path.substring(0, file.path.length - suffix.length);
      final declaring = File('$base.dart');
      if (!declaring.existsSync()) {
        _add(
          _relative(file.path),
          15,
          'a generated file sits beside the file that declares its part',
        );
        continue;
      }
      final partPattern =
          r'''^\s*part\s+['"]''' +
          RegExp.escape(name) +
          r'''['"]\s*;\s*(?://.*)?$''';
      if (!RegExp(
        partPattern,
        multiLine: true,
      ).hasMatch(declaring.readAsStringSync())) {
        _add(
          _relative(file.path),
          15,
          'the sibling source must declare the matching part file',
        );
      }
    }
  }
}

void _checkConditionalFiles(Directory lib) {
  const suffixes = ['_io.dart', '_web.dart', '_stub.dart'];
  final bases = <String>{};
  for (final file in _allFiles(lib)) {
    final name = _name(file.path);
    for (final suffix in suffixes) {
      if (name.endsWith(suffix)) {
        bases.add(file.path.substring(0, file.path.length - suffix.length));
      }
    }
  }
  for (final base in bases) {
    for (final suffix in ['.dart', ...suffixes]) {
      final sibling = File('$base$suffix');
      if (!sibling.existsSync()) {
        _add(
          _relative(sibling.path),
          14,
          'conditional files need facade, _io, _web, and _stub siblings',
        );
      }
    }
  }
}

void _checkAppHome(Directory lib) {
  final src = Directory('${lib.path}/app/src');
  if (!src.existsSync()) return;
  const allowed = {'root_app_widget.dart', 'root_blocs_provider.dart'};
  if (!File('${src.path}/root_app_widget.dart').existsSync()) {
    _add(
      'lib/app/src/root_app_widget.dart',
      16,
      'app/ holds the root app widget',
    );
  }
  for (final entry in _visibleEntries(src)) {
    if (entry is! File || !allowed.contains(_name(entry.path))) {
      _add(
        _relative(entry.path),
        16,
        'app/src contains only the root app widget and optional root blocs provider',
      );
    }
  }
}

void _checkResourcesHome(Directory lib) {
  final arb = Directory('${lib.path}/resources/src/arb');
  if (!arb.existsSync()) {
    _add(
      _relative(arb.path),
      17,
      'resources must own the generated localization source folder',
    );
  }
}

void _checkCompositionHomes(Directory lib) {
  final locator = Directory('${lib.path}/foundation/locator');
  if (!locator.existsSync()) {
    _add(
      _relative(locator.path),
      18,
      'the owned locator facade belongs in foundation/locator',
    );
  }
  final register = File(
    '${lib.path}/dependency_injection/src/register_instances.dart',
  );
  if (!register.existsSync()) {
    _add(
      _relative(register.path),
      18,
      'the one composition root is register_instances.dart',
    );
  }
  final misplaced = File(
    '${lib.path}/dependency_injection/src/service_locator.dart',
  );
  if (misplaced.existsSync()) {
    _add(
      _relative(misplaced.path),
      18,
      'the locator facade must not live in dependency_injection',
    );
  }
}

List<FileSystemEntity> _visibleEntries(Directory directory) {
  if (!directory.existsSync()) return const [];
  return directory
      .listSync(followLinks: false)
      .where((entry) => !_name(entry.path).startsWith('.'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
}

Iterable<Directory> _allDirectories(Directory root) => root
    .listSync(recursive: true, followLinks: false)
    .whereType<Directory>()
    .where(
      (directory) => !_relative(
        directory.path,
      ).split('/').any((segment) => segment.startsWith('.')),
    );

Iterable<File> _allFiles(Directory root) => root
    .listSync(recursive: true, followLinks: false)
    .whereType<File>()
    .where(
      (file) => !_relative(
        file.path,
      ).split('/').any((segment) => segment.startsWith('.')),
    );

String _name(String path) => path.replaceAll('\\', '/').split('/').last;

String _relative(String path) {
  final normalizedRoot = _rootPath.replaceAll('\\', '/');
  final normalizedPath = path.replaceAll('\\', '/');
  if (normalizedPath == normalizedRoot) return '.';
  if (normalizedPath.startsWith('$normalizedRoot/')) {
    return normalizedPath.substring(normalizedRoot.length + 1);
  }
  return normalizedPath;
}

void _add(String path, int rule, String message) {
  _violations.add('$path — structure.md rule $rule: $message');
}

void _finish() {
  if (_violations.isEmpty) {
    stdout.writeln('Structure check passed.');
    return;
  }
  _violations.sort();
  stderr.writeln(
    'Structure check failed with ${_violations.length} violation(s):',
  );
  for (final violation in _violations) {
    stderr.writeln('- $violation');
  }
  exitCode = 1;
}
