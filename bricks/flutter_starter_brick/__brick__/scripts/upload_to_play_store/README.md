# Upload to Google Play Internal Testing

Builds and uploads Android AAB to Google Play Internal Testing track.

## Inputs

**Required:**
- `versions` file at project root with:
  - `android_version_name` (e.g., "1.2.2")
  - `android_build_number` (e.g., 26)
- `service_account_json_path` file in this directory with absolute path to Google Play service account JSON

## Setup (One-time)

### 1. Install Python Dependencies

```bash
pip install google-auth google-api-python-client
```

### 2. Create Google Play Service Account

Follow the Fastlane guide: [Collect your Google credentials](https://docs.fastlane.tools/getting-started/android/setup/#collect-your-google-credentials)

Summary:
- Create service account in Google Cloud Console
- Download JSON key file
- Grant permissions in Play Console (Release to testing tracks)

### 3. Configure Service Account Path

Create `service_account_json_path` file in this directory:

```bash
echo "/path/to/your/google-play-service-account.json" > service_account_json_path
```

**Important**: Keep the JSON file outside the project and never commit it.

## Usage

Run from project root:

```bash
# For development flavor (main_development.dart)
./scripts/upload_to_play_store/upload_to_playstore.sh dev

# For production flavor (main_production.dart)
./scripts/upload_to_play_store/upload_to_playstore.sh prod
```

## Output

1. Builds AAB using version from `versions` file
2. Uploads to Google Play **Internal Testing** track
3. App available for internal testers after Google's processing

## Notes

- Uses `fvm` for consistent Flutter SDK versions
- Package name is extracted automatically from `android/app/build.gradle.kts`
- First upload must be done manually via Play Console web interface
