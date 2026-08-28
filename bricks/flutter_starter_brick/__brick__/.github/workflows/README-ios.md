# Deploy iOS to TestFlight — CI Setup Guide

GitHub Actions workflow that builds an iOS IPA and uploads it to TestFlight.

## Prerequisites

- App already created on App Store Connect
- Apple Distribution certificate (.p12)
- App Store provisioning profile (.mobileprovision)
- App Store Connect API key (.p8)
- `setup-common-config.yml`'s Flutter version matches the `.fvmrc` pin at the project root, byte for byte (both ship pinned; move them together)

## GitHub Secrets (6 required)

To set a secret: go to your repository on GitHub → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

### 1. IOS_CERTIFICATE_BASE64

Base64-encoded Apple Distribution certificate (.p12 file).

**Where to get it:** If you have Xcode auto-signing enabled, you'll need to create a manual distribution certificate:

1. Open **Keychain Access** → Certificate Assistant → Request a Certificate From a Certificate Authority (save CSR to disk)
2. Go to [Apple Developer Portal → Certificates](https://developer.apple.com/account/resources/certificates/list)
3. Click **+** → **Apple Distribution** → upload your CSR
4. Download the `.cer` file
5. Double-click to import into Keychain
6. In Keychain Access, find the certificate → right-click → **Export as .p12** (set a password)

```bash
base64 -i /path/to/distribution.p12 | gh secret set IOS_CERTIFICATE_BASE64 --repo OWNER/REPO
```

### 2. IOS_CERTIFICATE_PASSWORD

Password you set when exporting the .p12 certificate.

Set it manually on GitHub (never pass passwords via CLI).

### 3. IOS_PROVISIONING_PROFILE_BASE64

Base64-encoded App Store provisioning profile (.mobileprovision file).

**Where to get it:**

1. Go to [Apple Developer Portal → Profiles](https://developer.apple.com/account/resources/profiles/list)
2. Click **+** → **App Store Connect** → select your app → select the distribution certificate created above
3. Download the `.mobileprovision` file

```bash
base64 -i /path/to/profile.mobileprovision | gh secret set IOS_PROVISIONING_PROFILE_BASE64 --repo OWNER/REPO
```

### 4. APP_STORE_CONNECT_API_KEY_ID

The Key ID of your App Store Connect API key.

**Where to get it:** See `scripts/upload_to_test_flight/README.md` — "Create App Store Connect API Key". The Key ID is the key file name shown on the API Keys page.

Set it manually on GitHub.

### 5. APP_STORE_CONNECT_ISSUER_ID

The Issuer ID for your App Store Connect API keys.

**Where to get it:** See `scripts/upload_to_test_flight/README.md` — same API Keys page. The Issuer ID is shown at the top.

Set it manually on GitHub.

### 6. APP_STORE_CONNECT_API_KEY_BASE64

Base64-encoded App Store Connect API key (.p8 file).

**Where to get it:** See `scripts/upload_to_test_flight/README.md` for setup. If you already have the key locally:

```bash
base64 -i ~/.appstoreconnect/private_keys/AuthKey_YOUR_KEY_ID.p8 | gh secret set APP_STORE_CONNECT_API_KEY_BASE64 --repo OWNER/REPO
```

## Project Requirements

These must exist in the repo for the workflow to work:

| File | Purpose |
|------|---------|
| `versions` | Contains `ios_version_name` and `ios_build_number` (shell variable format: `ios_version_name=0.0.1`) |
| `ios/ci/ExportOptions.plist` | Manual signing config for CI export — must have Team ID and profile name filled in (see below) |
| `lib/main.dart` | Single app entry point |
| `env/development.json`, `env/production.json` | Build settings for the two environments |

## Xcode Signing Setup

The Xcode project must have **Manual signing** for the Release configuration:

1. Open the project in Xcode
2. Select the Runner target → **Signing & Capabilities**
3. For **Release** configuration: uncheck "Automatically manage signing"
4. Select your provisioning profile and Apple Distribution certificate
5. **Debug** configuration can stay on Automatic signing

Do this via Xcode UI — don't edit `project.pbxproj` directly. Xcode adds `[sdk=iphoneos*]` qualifiers that are easy to miss manually.

## ExportOptions.plist

Open `ios/ci/ExportOptions.plist` and replace the two TODO placeholders:

1. **Team ID** — replace `TODO(...): Replace with Apple Team ID` with your Apple Developer Team ID (found in [Apple Developer → Membership](https://developer.apple.com/account#MembershipDetailsCard))
2. **Provisioning profile name** — replace `TODO(...): Replace with provisioning profile name` with the exact name of your provisioning profile as shown on Apple Developer Portal

The bundle ID key is already set to your project's bundle ID.

## Shared Configuration

Flutter version, Java version, and Java distribution are defined in `setup-common-config.yml`. Update versions there to change them for both Android and iOS workflows. The Flutter version there and the `.fvmrc` pin at the project root are the same version with two readers — change both in the same commit, never one alone.

## Adapting for a New Project

1. Copy `.github/workflows/deploy-ios.yml` and `setup-common-config.yml`
2. Set all 6 secrets listed above
3. Fill in the two TODO placeholders in the shipped `ios/ci/ExportOptions.plist` — team ID and provisioning profile name (see "ExportOptions.plist" above); the bundle ID is already set
4. Configure Xcode Manual signing for Release (see above)
5. Update `setup-common-config.yml` and `.fvmrc` with the same correct Flutter version
6. If your project doesn't use `build_runner`, `gen-l10n`, or CocoaPods, remove those steps
