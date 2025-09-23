#!/bin/bash

# This script builds the app in release mode and uploads it to TestFlight.
# It reads the iOS version name and build number from a file called
# versions present at the project root.

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSIONS_FILE="$PROJECT_ROOT/versions"

# Source the versions file
if [[ -f "$VERSIONS_FILE" ]]; then
    source "$VERSIONS_FILE"
else
    echo "❌ versions file not found at $VERSIONS_FILE"
    exit 1
fi

# Ensure required parameters are set
if [[ -z "$ios_version_name" || -z "$ios_build_number" ]]; then
    echo "❌ Missing required version information in versions file"
    exit 1
fi

# Read the API key and issuer ID
API_KEY_FILE="$SCRIPT_DIR/api_key_name"
ISSUER_ID_FILE="$SCRIPT_DIR/issuer_id"

if [[ ! -f "$API_KEY_FILE" ]]; then
    echo "❌ API key file not found: $API_KEY_FILE"
    exit 1
fi

if [[ ! -f "$ISSUER_ID_FILE" ]]; then
    echo "❌ Issuer ID file not found: $ISSUER_ID_FILE"
    exit 1
fi

api_key=$(cat "$API_KEY_FILE")
issuer_id=$(cat "$ISSUER_ID_FILE")

# Set the main Dart file (production for TestFlight)
main_file="lib/main_production.dart"

# Build IPA
echo "🚀 Building IPA for version $ios_version_name ($ios_build_number)..."
flutter build ipa \
    --release \
    --build-name="$ios_version_name" \
    --build-number="$ios_build_number" \
    -t "$main_file" || {
    echo "❌ Build failed"
    exit 1
}

# Upload to TestFlight via App Store Connect API
ipa_path=$(find "$PROJECT_ROOT/build/ios/ipa" -name "*.ipa" | head -n 1)

if [[ -z "$ipa_path" ]]; then
    echo "❌ No IPA file found in build/ios/ipa"
    exit 1
fi

echo "📤 Uploading $ipa_path to TestFlight..."
xcrun altool --upload-app --type ios \
    -f "$ipa_path" \
    --apiKey "$api_key" \
    --apiIssuer "$issuer_id" || {
    echo "❌ Upload failed"
    exit 1
}

echo "✅ Upload complete!"