# Create Android Builds Script

This script builds Android APKs for all environments and architectures, plus an AAB (App Bundle) for production release to Google Play Store.

## Prerequisites

### 1. Android signing setup

Ensure you have configured Android signing for your app:
1. Generate or obtain your keystore file
2. Configure signing in `android/app/build.gradle`
3. Set up `android/key.properties` (never commit this file)

### 2. Set up the required files

Create the following file in your project:

#### Version file

Create `{PROJECT_ROOT}/versions` file with:
```
android_version_name=1.0.0
android_build_number=1
```

## Usage

```bash
# Build to default artifacts directory
./scripts/create_android_builds/create_android_builds.sh

# Build to custom output directory
./scripts/create_android_builds/create_android_builds.sh --output-dir /path/to/output
```

## What this script does

1. **Builds 9 APKs** - One for each combination of:
   - Environments: development, staging, production
   - Architectures: arm, arm64, x64
   - File naming: `app-{environment}-v{version}-build-{code}-{architecture}.apk`

2. **Builds 1 AAB** - For production release to Google Play Store:
   - Uses production environment only
   - Includes all architectures
   - File naming: `app-production-v{version}-build-{code}.aab`

3. **Output location**:
   - Default: `{PROJECT_ROOT}/artifacts/`
   - Custom: Use `--output-dir` parameter

## Output Structure

After running the script, you'll have:

```
artifacts/
├── app-development-v1.0.0-build-1-android-arm.apk
├── app-development-v1.0.0-build-1-android-arm64.apk
├── app-development-v1.0.0-build-1-android-x64.apk
├── app-staging-v1.0.0-build-1-android-arm.apk
├── app-staging-v1.0.0-build-1-android-arm64.apk
├── app-staging-v1.0.0-build-1-android-x64.apk
├── app-production-v1.0.0-build-1-android-arm.apk
├── app-production-v1.0.0-build-1-android-arm64.apk
├── app-production-v1.0.0-build-1-android-x64.apk
└── app-production-v1.0.0-build-1.aab
```

## Distribution Guide

### APK Files
- **Development APKs**: For internal testing and debugging
- **Staging APKs**: For QA and UAT testing
- **Production APKs**: For direct distribution outside Google Play

### AAB File
- **Production AAB**: Upload to Google Play Console for store distribution
- Google Play will automatically generate optimized APKs for each device

## Troubleshooting

### Common Issues

**"versions file not found"**
- Ensure `versions` file exists at project root
- File should contain `android_version_name` and `android_build_number`

**"Build failed for {environment} on {platform}"**
- Check Flutter environment setup: `flutter doctor`
- Verify Android SDK installation
- Ensure signing configuration is correct

**"Failed to copy APK"**
- Check disk space availability
- Verify write permissions for output directory

**Build runs but APKs are unsigned**
- Configure signing in `android/app/build.gradle`
- Ensure `android/key.properties` exists and is correct
- Verify keystore file path and credentials

## Version Management

The script uses the same `versions` file as the iOS upload script, allowing you to manage versions for both platforms in one place:

```bash
# Update versions for both platforms
echo "android_version_name=1.0.1" > versions
echo "android_build_number=2" >> versions
echo "ios_version_name=1.0.1" >> versions
echo "ios_build_number=2" >> versions
```

## Security Notes

⚠️ **Never commit these files to version control:**
- `android/key.properties`
- Your keystore files (`.jks` or `.keystore`)

These should already be in `.gitignore` for your safety.