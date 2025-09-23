# Release Guide

This document outlines the release process for both the Flutter Starter Brick and the Flutter CLI Utils (fcu) tool.

## Releasing the Flutter Starter Brick

To release a new version of the starter brick to BrickHub:

1. **Update the version** in `bricks/flutter_starter_brick/brick.yaml`

   ```yaml
   version: 0.1.0+1  # Update this
   ```

2. **Update the changelog** at `bricks/flutter_starter_brick/CHANGELOG.md`
   - Document all changes, improvements, and fixes
   - Follow [Keep a Changelog](https://keepachangelog.com/) format

3. **Publish to BrickHub**

   ```bash
   cd bricks/flutter_starter_brick
   mason publish
   ```

## Releasing the CLI Tool (fcu)

To release a new version of the Flutter CLI Utils tool:

1. **Update the version** in `pubspec.yaml` (at project root)

   ```yaml
   version: 1.0.0+1  # Update this
   ```

2. **Generate version info**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   This generates the required version information in `lib/src/version.dart`

3. **Verify brick reference**
   - Check `lib/src/commands/new_project_command.dart` around line 335
   - Remove the `--path` flag and local path before release
   - The code should reference BrickHub, not a local path:

   ```dart
   // For development (remove before release):
   final masonAddResult = await Process.run('mason', [
     'add',
     'flutter_starter_brick',
     '--path',  // TODO remove this and the next line before publishing
     '/Users/haidarmehsen/dev/projects/flutter/projects/flutter_cli_utils/bricks/flutter_starter_brick'
   ], workingDirectory: tempDirectory.path);

   // For release (use this):
   final masonAddResult = await Process.run('mason', [
     'add',
     'flutter_starter_brick',
   ], workingDirectory: tempDirectory.path);
   ```

4. **Push to GitHub**

   ```bash
   git add .
   git commit -m "chore: release v1.0.0"
   git push origin main
   ```

   > **Note**: The CLI tool is currently distributed as source code on GitHub (not published to pub.dev)

## Pre-release Checklist

Before releasing either component:

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped appropriately (follow [Semantic Versioning](https://semver.org/))
- [ ] No hardcoded paths or development configurations
- [ ] Brick bundle updated if brick was modified

## Version Synchronization

While the brick and CLI tool versions are independent, consider:

- Major brick changes may warrant a CLI version bump
- Document minimum compatible versions in both READMEs
