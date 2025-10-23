#!/bin/bash

# This script builds the app in release mode and uploads it to Google Play Internal Testing.
# It reads the Android version name and build number from a file called
# versions present at the project root.

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSIONS_FILE="$PROJECT_ROOT/versions"
ANDROID_DIR="$PROJECT_ROOT/android"

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

# Set the main Dart file (production for Play Store)
main_file="lib/main_production.dart"

# Build AAB
echo "🚀 Building AAB for version $android_version_name ($android_build_number)..."
fvm flutter build appbundle \
    --release \
    --build-name="$android_version_name" \
    --build-number="$android_build_number" \
    -t "$main_file" || {
    echo "❌ Build failed"
    exit 1
}

# Find the AAB
aab_path="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"

if [[ ! -f "$aab_path" ]]; then
    echo "❌ No AAB file found at $aab_path"
    exit 1
fi

# Check if fastlane is installed
if ! command -v fastlane &> /dev/null; then
    echo "❌ Fastlane not found. Please install it:"
    echo "   gem install fastlane"
    exit 1
fi

# Upload to Play Store Internal Testing using Fastlane
echo "📤 Uploading $aab_path to Google Play Internal Testing..."
cd "$ANDROID_DIR" && \
fastlane internal aab:"$aab_path" json_key:"$service_account_json" || {
    echo "❌ Upload failed"
    exit 1
}

echo "✅ Upload complete!"
