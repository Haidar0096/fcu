#!/bin/bash

# This script builds the app in release mode and uploads it to Google Play Internal Testing.
# It reads the Android version name and build number from a file called
# versions present at the project root.
#
# Usage:
#   ./upload_to_playstore.sh development  # uses env/development.json
#   ./upload_to_playstore.sh production   # uses env/production.json

# Check for environment argument
if [[ -z "$1" ]]; then
    echo "❌ Usage: $0 <development|production>"
    echo "   development - builds with env/development.json"
    echo "   production  - builds with env/production.json"
    exit 1
fi

ENVIRONMENT="$1"

case "$ENVIRONMENT" in
    development|production) ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "   Valid options: development, production"
        exit 1
        ;;
esac

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSIONS_FILE="$PROJECT_ROOT/versions"
ANDROID_DIR="$PROJECT_ROOT/android"
ENVIRONMENT_FILE="$PROJECT_ROOT/env/$ENVIRONMENT.json"

# Source the versions file
if [[ -f "$VERSIONS_FILE" ]]; then
    source "$VERSIONS_FILE"
else
    echo "❌ versions file not found at $VERSIONS_FILE"
    exit 1
fi

# Ensure required parameters are set
if [[ -z "$android_version_name" || -z "$android_build_number" ]]; then
    echo "❌ Missing required version information in versions file"
    exit 1
fi

# Read the service account JSON path
SERVICE_ACCOUNT_PATH_FILE="$SCRIPT_DIR/service_account_json_path"

if [[ ! -f "$SERVICE_ACCOUNT_PATH_FILE" ]]; then
    echo "❌ Service account path file not found: $SERVICE_ACCOUNT_PATH_FILE"
    echo "ℹ️  Create this file and add the path to your Google Play service account JSON"
    exit 1
fi

service_account_json=$(cat "$SERVICE_ACCOUNT_PATH_FILE")

if [[ ! -f "$service_account_json" ]]; then
    echo "❌ Service account JSON not found at: $service_account_json"
    exit 1
fi

# Prepare project
echo "📦 Preparing project..."
# Clean first: a dev-only plugin left in a stale generated registrant by an
# earlier debug run fails the release build.
fvm flutter clean || { echo "❌ flutter clean failed"; exit 1; }
fvm flutter pub get || { echo "❌ flutter pub get failed"; exit 1; }
fvm flutter gen-l10n || { echo "❌ flutter gen-l10n failed"; exit 1; }
fvm dart run build_runner build || { echo "❌ build_runner failed"; exit 1; }

# Build AAB
echo "🚀 Building AAB for version $android_version_name ($android_build_number) [$ENVIRONMENT]..."
fvm flutter build appbundle \
    --release \
    --build-name="$android_version_name" \
    --build-number="$android_build_number" \
    --dart-define-from-file="$ENVIRONMENT_FILE" || {
    echo "❌ Build failed"
    exit 1
}

# Find the AAB
aab_path="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"

if [[ ! -f "$aab_path" ]]; then
    echo "❌ No AAB file found at $aab_path"
    exit 1
fi

# Check if required Python packages are installed
if ! python3 -c "import google.oauth2, googleapiclient" 2>/dev/null; then
    echo "❌ Required Python packages not found. Please install them:"
    echo "   pip install google-auth google-api-python-client"
    exit 1
fi

# Extract package name from build.gradle.kts
package_name=$(grep 'applicationId' "$ANDROID_DIR/app/build.gradle.kts" | sed 's/.*"\(.*\)".*/\1/')

if [[ -z "$package_name" ]]; then
    echo "❌ Could not extract applicationId from build.gradle.kts"
    exit 1
fi

# Upload to Play Store Internal Testing using Python script
# (No fastlane required - uses Google Play Developer API directly)
echo "📤 Uploading $aab_path to Google Play Internal Testing..."
echo "   Package: $package_name"
python3 "$SCRIPT_DIR/upload_to_playstore.py" \
    "$aab_path" \
    "$service_account_json" \
    "$package_name" || {
    echo "❌ Upload failed"
    exit 1
}

echo "✅ Upload complete!"
