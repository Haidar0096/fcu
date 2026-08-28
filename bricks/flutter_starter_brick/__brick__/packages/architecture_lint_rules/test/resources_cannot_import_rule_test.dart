/// Tests for [ResourcesCannotImportRule].
library;

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/package_config_file_builder.dart';
import 'package:architecture_lint_rules/src/rules/resources_cannot_import_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ResourcesCannotImportRuleTest);
  });
}

@reflectiveTest
class ResourcesCannotImportRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ResourcesCannotImportRule();
    super.setUp();
  }

  Future<void> test_importFromFoundation_violation() async {
    newFile(
      '$testPackageLibPath/foundation/ui/theme.dart',
      'class AppTheme {}',
    );

    newFile('$testPackageLibPath/resources/src/images.dart', r'''
import 'package:test/foundation/ui/theme.dart';

var x = AppTheme();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/resources/src/images.dart',
      [
        lint(
          0,
          47,
          messageContainsAll: [
            'resources/ is a leaf folder and cannot import from other project folders.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromFeatures_violation() async {
    newFile('$testPackageLibPath/features/auth/auth.dart', 'class Auth {}');

    newFile('$testPackageLibPath/resources/src/strings.dart', r'''
import 'package:test/features/auth/auth.dart';

var x = Auth();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/resources/src/strings.dart',
      [
        lint(
          0,
          46,
          messageContainsAll: [
            'resources/ is a leaf folder and cannot import from other project folders.',
          ],
        ),
      ],
    );
  }

  Future<void> test_importFromExternalPackage_allowed() async {
    // The other package's path carries a `features/` segment, which a
    // path-only deny-list would flag.
    newPackage(
      'other',
    ).addFile('lib/features/auth/auth.dart', 'class OtherAuth {}');
    writeTestPackageConfig(PackageConfigFileBuilder());

    newFile('$testPackageLibPath/resources/src/images.dart', r'''
import 'package:other/features/auth/auth.dart';

var x = OtherAuth();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/resources/src/images.dart',
    );
  }

  Future<void> test_importFromResourcesItself_allowed() async {
    newFile('$testPackageLibPath/resources/src/fonts.dart', 'class Fonts {}');

    newFile('$testPackageLibPath/resources/src/images.dart', r'''
import 'package:test/resources/src/fonts.dart';

var x = Fonts();
''');

    await assertNoDiagnosticsInFile(
      '$testPackageLibPath/resources/src/images.dart',
    );
  }

  Future<void> test_importFromFakeData_violation() async {
    newFile('$testPackageLibPath/fake_data/fake_data.dart', 'class Fakes {}');

    newFile('$testPackageLibPath/resources/src/images.dart', r'''
import 'package:test/fake_data/fake_data.dart';

var x = Fakes();
''');

    await assertDiagnosticsInFile(
      '$testPackageLibPath/resources/src/images.dart',
      [
        lint(
          0,
          47,
          messageContainsAll: [
            'resources/ is a leaf folder and cannot import from other project folders.',
          ],
        ),
      ],
    );
  }
}
