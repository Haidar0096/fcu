# Build Android APKs and AAB

Builds APKs for all environments/architectures and production AAB for Google Play.

## Prerequisites

- [fvm](https://fvm.app/) installed and project Flutter version configured (`fvm install`)
- Java JDK 17+
- Android SDK
- Android signing configured (see `scripts/upload_to_play_store/README.md` — "Android Signing Setup")

## Inputs

- `versions` file at project root with `android_version_name` and `android_build_number`
- Optional: `--output-dir` flag for custom output location

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

**6 APKs** — for each combination of:
- Servers: development, production
- Platforms: android-arm, android-arm64, android-x64
- Named: `app-{server}-v{version}-build-{code}-{platform}.apk`

**1 AAB** — for Google Play Store:
- Production environment only
- Named: `app-production-v{version}-build-{code}.aab`
