#!/bin/bash

# This script builds the web app in release mode.
# It reads the Web version name and build number from a file called
# versions present at the project root.
#
# Usage:
#   ./build_web.sh development  # builds with env/development.json
#   ./build_web.sh production   # builds with env/production.json

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
ENVIRONMENT_FILE="$PROJECT_ROOT/env/$ENVIRONMENT.json"

# Source the versions file
if [[ -f "$VERSIONS_FILE" ]]; then
    source "$VERSIONS_FILE"
else
    echo "❌ versions file not found at $VERSIONS_FILE"
    exit 1
fi

# Ensure required parameters are set
if [[ -z "$web_version_name" || -z "$web_build_number" ]]; then
    echo "❌ Missing required version information in versions file"
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

# Build Web
echo "🚀 Building Web for version $web_version_name ($web_build_number) [$ENVIRONMENT]..."
fvm flutter build web \
    --release \
    --build-name="$web_version_name" \
    --build-number="$web_build_number" \
    --dart-define-from-file="$ENVIRONMENT_FILE" || {
    echo "❌ Build failed"
    exit 1
}

# Create a unique output directory name
OUTPUT_DIR="$PROJECT_ROOT/build/{{proj_name}}-$ENVIRONMENT-$web_version_name+$web_build_number-web"

# Remove existing output directory if it exists
if [[ -d "$OUTPUT_DIR" ]]; then
    rm -rf "$OUTPUT_DIR"
fi

# Rename build/web to the unique output directory
mv "$PROJECT_ROOT/build/web" "$OUTPUT_DIR" || { echo "❌ Failed to move the build output to $OUTPUT_DIR"; exit 1; }

echo "✅ Build complete! Output located at: $OUTPUT_DIR"
