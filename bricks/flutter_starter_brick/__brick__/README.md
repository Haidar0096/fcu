# {{proj_name.pascalCase()}}

{{proj_desc}}

## Release Process

This app uses a file-based versioning system for managing Android and iOS releases.

### Version Management

All version information is stored in the `versions` file in the project root, example:

```
android_build_number=1
android_version_name=1.0.0
ios_build_number=1
ios_version_name=1.0.0
```

### Release Steps

#### 1. Update Version Numbers

Edit the `versions` file in the project root:
- Increment `android_build_number` for each Android release
- Increment `ios_build_number` for each iOS release
- Update `android_version_name` and `ios_version_name` following semantic versioning (MAJOR.MINOR.PATCH)

#### 2. Update CHANGELOG

Update `CHANGELOG.md` (at the root of the project) with the changes included in this release:
- Add the new version number as a header
- List all changes, features, and bug fixes
- Include the release date

#### 3. Android Release

**Option A: Build and Upload to Google Play Internal Testing (Recommended)**

```bash
./scripts/upload_to_play_store/upload_to_playstore.sh
```

See readme at `scripts/upload_to_play_store/README.md` for detailed setup instructions.

**Option B: Build APKs and AAB (for manual distribution)**

```bash
./scripts/create_android_builds/create_android_builds.sh
```

Options:
- `--output-dir <path>`: Specify output directory (default: `./artifacts`)

See readme at `scripts/create_android_builds/README.md` for more details.

#### 4. iOS Release

To build and upload directly to TestFlight:

```bash
./scripts/upload_to_test_flight/upload_to_testflight.sh
```

See readme at `scripts/upload_to_test_flight/README.md` for detailed setup instructions.

### Notes

- All scripts use `fvm` (Flutter Version Manager) to ensure consistent Flutter SDK versions
