# Upload to TestFlight

Builds and uploads iOS IPA to TestFlight for beta testing.

## Inputs

**Required:**
- `versions` file at project root with:
  - `ios_version_name` (e.g., "1.2.2")
  - `ios_build_number` (e.g., 32)
- `api_key_name` file in this directory with App Store Connect API Key name
- `issuer_id` file in this directory with App Store Connect Issuer ID

## Setup (One-time)

### 1. Create App Store Connect API Key

Follow Apple's guide: [Creating API Keys for App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)

Summary:
- Create a new key -> https://appstoreconnect.apple.com/access/integrations/api
- Download the .p8 file and note the Key ID (key file name) and Issuer ID (from the API Keys page above)
- Place the .p8 file at `~/.appstoreconnect/private_keys/AuthKey_<YOUR_KEY_ID>.p8`

### 2. Configure API Credentials

Create two files in this directory:

```bash
echo "YOUR_API_KEY_ID" > api_key_name
echo "YOUR_ISSUER_ID" > issuer_id
```

**Important**: Keep the .p8 key file secure and never commit credentials.

## Usage

Run from project root:

```bash
./scripts/upload_to_test_flight/upload_to_testflight.sh
```

## Output

1. Builds IPA using version from `versions` file
2. Uploads to TestFlight
3. App available for TestFlight testers after Apple's processing

## Notes

- Uses `fvm` for consistent Flutter SDK versions
- Builds from `lib/main_production.dart` entry point
- Requires .p8 API key file installed in Keychain or accessible to `xcrun altool`
