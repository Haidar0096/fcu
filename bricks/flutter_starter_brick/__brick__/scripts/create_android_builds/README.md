# Build Android APKs and AAB

Builds APKs for all environments/architectures and production AAB for Google Play.

## Inputs

**Required:**
- `versions` file at project root with:
  - `android_version_name` (e.g., "1.0.0")
  - `android_build_number` (e.g., 1)

**Optional:**
- `--output-dir` flag for custom output location

## Usage

Run from project root:

```bash
./scripts/create_android_builds/create_android_builds.sh
```

Or with custom output:
```bash
./scripts/create_android_builds/create_android_builds.sh --output-dir /path/to/output
```

## Output

Generates in output directory (default: `./artifacts`):

**6 APKs** - For each combination of:
- Servers: development, production
- Platforms: android-arm, android-arm64, android-x64
- Named: `app-{server}-v{version}-build-{code}-{platform}.apk`

**1 AAB** - For Google Play Store:
- Production environment only
- Named: `app-production-v{version}-build-{code}.aab`

## Notes

- Uses `fvm` for consistent Flutter SDK versions
- Builds from `lib/main_{environment}.dart` entry points
- Production AAB uses `lib/main_production.dart`
