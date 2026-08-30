# Upload to TestFlight

Audience: release operators authorized for iOS uploads; permitted content: the TestFlight upload procedure and credential locations, never credential values.

Builds and uploads iOS IPA to TestFlight for beta testing.

## Prerequisites

- [fvm](https://fvm.app/) installed and project Flutter version configured (`fvm install`)
- Xcode installed
- [CocoaPods](https://cocoapods.org/) installed (`gem install cocoapods`)
- iOS signing configured: Apple Distribution certificate, App Store provisioning profile, Xcode Manual signing for Release, and `ios/ci/ExportOptions.plist` filled in. See `.github/workflows/README-ios.md` — sections "Xcode Signing Setup" and "ExportOptions.plist".
- App already created on [App Store Connect](https://appstoreconnect.apple.com/)

## Inputs

- `versions` file at project root with `ios_version_name` and `ios_build_number`
- `api_key_name` file in this directory with App Store Connect API Key ID
- `issuer_id` file in this directory with App Store Connect Issuer ID

## Setup (One-time)

### 1. Create App Store Connect API Key

Follow Apple's guide: [Creating API Keys for App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)

Summary:
- Create a new key at https://appstoreconnect.apple.com/access/integrations/api
- Download the .p8 file and note the Key ID (key file name) and Issuer ID (from the API Keys page above)
- Place the .p8 file at `~/.appstoreconnect/private_keys/AuthKey_<YOUR_KEY_ID>.p8`

### 2. Configure API Credentials

Create two files in this directory:

```bash
echo "YOUR_API_KEY_ID" > api_key_name
echo "YOUR_ISSUER_ID" > issuer_id
```

Keep the .p8 key file secure and never commit credentials.

## Usage

Run from project root:

```bash
# For development server
./scripts/upload_to_test_flight/upload_to_testflight.sh development

# For production server
./scripts/upload_to_test_flight/upload_to_testflight.sh production
```

## Output

1. Builds IPA using version from `versions` file
2. Uploads to TestFlight via `xcrun altool`
3. App available for TestFlight testers after Apple's processing
