#!/bin/bash

# This script builds the app in release mode and uploads it to TestFlight.
# See README.md for detailed setup instructions.
#
# Usage:
#   ./upload_to_testflight.sh development  # builds main_development.dart
#   ./upload_to_testflight.sh production   # builds main_production.dart

# Check for environment argument
if [[ -z "$1" ]]; then
    echo "❌ Usage: $0 <development|production>"
    echo "   development - builds lib/main_development.dart"
    echo "   production  - builds lib/main_production.dart"
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

main_file="lib/main_$ENVIRONMENT.dart"

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

# Prepare project
echo "📦 Preparing project..."
# Clean first: a dev-only plugin left in a stale generated registrant by an
# earlier debug run fails the release build.
fvm flutter clean || { echo "❌ flutter clean failed"; exit 1; }
fvm flutter pub get || { echo "❌ flutter pub get failed"; exit 1; }
fvm flutter gen-l10n || { echo "❌ flutter gen-l10n failed"; exit 1; }
fvm dart run build_runner build || { echo "❌ build_runner failed"; exit 1; }
(cd "$PROJECT_ROOT/ios" && pod install) || { echo "❌ pod install failed"; exit 1; }

# Build IPA
echo "🚀 Building IPA for version $ios_version_name ($ios_build_number) [$ENVIRONMENT]..."
fvm flutter build ipa \
    --release \
    --build-name="$ios_version_name" \
    --build-number="$ios_build_number" \
    -t "$main_file" \
    --export-options-plist="$PROJECT_ROOT/ios/ci/ExportOptions.plist" || {
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
