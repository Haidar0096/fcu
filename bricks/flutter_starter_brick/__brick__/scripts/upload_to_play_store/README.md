# Upload to Google Play Internal Testing

Builds and uploads Android AAB to Google Play Internal Testing track.

## Inputs

**Required:**
- `versions` file at project root with:
  - `android_version_name` (e.g., "1.2.2")
  - `android_build_number` (e.g., 26)
- `android/fastlane/Fastfile` with deployment lane definitions
- `service_account_json_path` file in this directory with absolute path to Google Play service account JSON

## Setup (One-time)

### 1. Install Fastlane

Run from anywhere (global install):

```bash
gem install fastlane
```

### 2. Setup Fastlane Configuration

Create `android/fastlane/Fastfile` with deployment lanes:

```ruby
# Fastfile for Android deployment

default_platform(:android)

platform :android do
  desc "Deploy to Google Play Internal Testing"
  lane :internal do |options|
    upload_to_play_store(
      aab: options[:aab],
      json_key: options[:json_key],
      package_name: '{{org_name}}.{{proj_name}}',
      track: 'internal',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_changelogs: true
    )
  end

  desc "Deploy to Google Play Beta"
  lane :beta do |options|
    upload_to_play_store(
      aab: options[:aab],
      json_key: options[:json_key],
      package_name: '{{org_name}}.{{proj_name}}',
      track: 'beta',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_changelogs: true
    )
  end

  desc "Deploy to Google Play Production"
  lane :production do |options|
    upload_to_play_store(
      aab: options[:aab],
      json_key: options[:json_key],
      package_name: '{{org_name}}.{{proj_name}}',
      track: 'production',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_changelogs: true
    )
  end
end
```

### 3. Create Google Play Service Account

Follow the Fastlane guide: [Collect your Google credentials](https://docs.fastlane.tools/getting-started/android/setup/#collect-your-google-credentials)

Summary:
- Create service account in Google Cloud Console
- Download JSON key file
- Grant permissions in Play Console (Release to testing tracks)

### 4. Configure Service Account Path

Create `service_account_json_path` file in this directory:

```bash
echo "/path/to/your/google-play-service-account.json" > service_account_json_path
```

**Important**: Keep the JSON file outside the project and never commit it.

## Usage

Run from project root:

```bash
./scripts/upload_to_play_store/upload_to_playstore.sh
```

## Output

1. Builds AAB using version from `versions` file
2. Uploads to Google Play **Internal Testing** track
3. App available for internal testers after Google's processing

## Notes

- Uses `fvm` for consistent Flutter SDK versions
- Builds from `lib/main_production.dart` entry point
- First upload must be done manually via Play Console web interface
