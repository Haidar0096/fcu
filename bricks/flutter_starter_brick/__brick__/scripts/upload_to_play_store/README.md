# Upload to Google Play Internal Testing

Builds and uploads Android AAB to Google Play Internal Testing track.

## Prerequisites

- [fvm](https://fvm.app/) installed and project Flutter version configured (`fvm install`)
- Java JDK 17+ (install via [SDKMAN](https://sdkman.io/) or [Adoptium](https://adoptium.net/))
- Android SDK (install via [Android Studio](https://developer.android.com/studio))
- Python 3 installed
- Android signing configured (see "Android Signing Setup" below)
- App already uploaded manually to [Google Play Console](https://play.google.com/console/) at least once (API uploads require an existing app listing)

## Inputs

- `versions` file at project root with `android_version_name` and `android_build_number`
- `service_account_json_path` file in this directory with absolute path to Google Play service account JSON

## Android Signing Setup (One-time)

### 1. Create a Signing Keystore

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Store the keystore file outside the project directory. Never commit it.

### 2. Create `android/key.properties`

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=your-store-password
keyAlias=upload
keyPassword=your-key-password
```

### 3. Configure Gradle Signing

`android/app/build.gradle.kts` must load `key.properties` in its `signingConfigs` block. Follow [Flutter's Android deployment guide](https://docs.flutter.dev/deployment/android#configure-signing-in-gradle) for the exact configuration.

### 4. Gitignore

Ensure `.gitignore` includes `android/key.properties` and `*.jks`.

## Upload Setup (One-time)

### 1. Install Python Dependencies

```bash
pip3 install google-auth google-api-python-client
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

Keep the JSON file outside the project and never commit it.

## Usage

Run from project root:

```bash
# For development server
./scripts/upload_to_play_store/upload_to_playstore.sh dev

# For production server
./scripts/upload_to_play_store/upload_to_playstore.sh prod
```

## Output

1. Builds AAB using version from `versions` file
2. Uploads to Google Play **Internal Testing** track
3. App available for internal testers after Google's processing
