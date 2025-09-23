# Upload to TestFlight Script

This script builds the iOS app in release mode and uploads it to TestFlight using App Store Connect API authentication.

## Prerequisites

### 1. Create an App Store Connect API key

1. Go to https://appstoreconnect.apple.com/access/api
2. Create a key with "App Manager" role
3. Download the .p8 private key file (only downloadable once!)
4. Note the Key ID and Issuer ID

### 2. Set up the required files

Create the following files in your project:

#### Version file
Create `{PROJECT_ROOT}/versions` file with:
```
ios_version_name=1.0.0
ios_build_number=1
```

#### API Key Name file
Create `{PROJECT_ROOT}/scripts/upload_to_test_flight/api_key_name` file containing your Key ID (e.g., "ABCD1234EF")

#### Issuer ID file
Create `{PROJECT_ROOT}/scripts/upload_to_test_flight/issuer_id` file containing your Issuer ID (e.g., "12345678-1234-1234-1234-123456789012")

#### Private key file
Place the .p8 key file at:
```
~/appstore_connect/private_keys/{KEY_ID}.p8
```

## Usage

```bash
./scripts/upload_to_test_flight/upload_to_testflight.sh
```

## What this script does

1. Reads version info from the versions file
2. Builds IPA using main_production.dart entry point
3. Uploads to TestFlight using xcrun altool with API authentication

## Security Notes

⚠️ **Never commit these files to version control:**
- `api_key_name`
- `issuer_id`
- Any `.p8` files

These files should already be in `.gitignore` for your safety.

## Troubleshooting

### Common Issues

**"API key file not found"**
- Ensure `api_key_name` file exists in this directory
- File should contain only the key ID, no extra whitespace

**"Issuer ID file not found"**
- Ensure `issuer_id` file exists in this directory
- File should contain only the issuer ID

**"Authentication failed"**
- Verify the .p8 file exists at `~/appstore_connect/private_keys/{KEY_ID}.p8`
- Check that the Key ID in `api_key_name` matches the .p8 filename
- Ensure the API key has "App Manager" role in App Store Connect

**"No IPA file found"**
- Check that the Flutter build succeeded
- Verify iOS signing certificates are properly configured