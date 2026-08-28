# Deploy Android to Play Store — CI Setup Guide

GitHub Actions workflow that builds an Android AAB and uploads it to Google Play Internal Testing.

## Prerequisites

- App already uploaded manually to Google Play Console at least once
- Google Play service account with API access
- Android signing keystore (.jks)
- `setup-common-config.yml`'s Flutter version matches the `.fvmrc` pin at the project root, byte for byte (both ship pinned; move them together)

## GitHub Secrets (5 required)

To set a secret: go to your repository on GitHub → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

### 1. ANDROID_KEYSTORE_BASE64

Base64-encoded Android signing keystore (.jks file).

**Where to get it:** From your local keystore file. If you don't have one, see `scripts/upload_to_play_store/README.md` — "Android Signing Setup".

```bash
base64 -i /path/to/your-release.jks | gh secret set ANDROID_KEYSTORE_BASE64 --repo OWNER/REPO
```

### 2. ANDROID_KEY_ALIAS

The alias of the signing key inside the keystore.

**Where to get it:** You chose this when creating the keystore. If you forgot, run:

```bash
keytool -list -v -keystore /path/to/your-release.jks
```

Set it manually on GitHub.

### 3. ANDROID_KEY_PASSWORD

Password for the signing key.

**Where to get it:** You set this when creating the keystore.

Set it manually on GitHub (never pass passwords via CLI).

### 4. ANDROID_STORE_PASSWORD

Password for the keystore file itself.

**Where to get it:** You set this when creating the keystore. Often the same as KEY_PASSWORD.

Set it manually on GitHub (never pass passwords via CLI).

### 5. PLAY_SERVICE_ACCOUNT_JSON_BASE64

Base64-encoded Google Play service account JSON key file.

**Where to get it:** See `scripts/upload_to_play_store/README.md` — "Upload Setup" for how to create the service account.

```bash
base64 -i /path/to/service-account.json | gh secret set PLAY_SERVICE_ACCOUNT_JSON_BASE64 --repo OWNER/REPO
```

## Project Requirements

These must exist in the repo for the workflow to work:

| File | Purpose |
|------|---------|
| `versions` | Contains `android_version_name` and `android_build_number` (shell variable format: `android_version_name=0.0.1`) |
| `android/app/build.gradle.kts` | Release signing config must read from `key.properties` (see `scripts/upload_to_play_store/README.md` — "Android Signing Setup") |
| `scripts/upload_to_play_store/upload_to_playstore.py` | Python script that uploads AAB via Google Play API |
| `lib/main.dart` | Single app entry point |
| `env/development.json`, `env/production.json` | Build settings for the two environments |

## Shared Configuration

Flutter version, Java version, and Java distribution are defined in `setup-common-config.yml`. Update versions there to change them for both Android and iOS workflows. The Flutter version there and the `.fvmrc` pin at the project root are the same version with two readers — change both in the same commit, never one alone.

## Adapting for a New Project

1. Copy `.github/workflows/deploy-android.yml` and `setup-common-config.yml`
2. Copy `scripts/upload_to_play_store/` folder
3. Set all 5 secrets listed above
4. Update `setup-common-config.yml` and `.fvmrc` with the same correct Flutter version
5. Set the package name once, as `applicationId` in `android/app/build.gradle.kts` — the workflow reads it from there, so nothing in `deploy-android.yml` needs editing
6. If your project uses native code requiring NDK, add an "Install NDK" step before the build
7. If your `android/gradle.properties` has high memory settings (e.g., `-Xmx8G`), keep the "Configure Gradle memory for CI" step — CI runners only have 7GB RAM
8. If your project doesn't use `build_runner` or `gen-l10n`, remove those steps
