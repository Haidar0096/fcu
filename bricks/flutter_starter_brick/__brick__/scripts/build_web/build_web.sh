#!/bin/bash

# This script builds the web app in release mode.
# It reads the Web version name and build number from a file called
# versions present at the project root.
#
# Usage:
#   ./build_web.sh dev   # builds main_development.dart
#   ./build_web.sh prod  # builds main_production.dart

# Check for flavor argument
if [[ -z "$1" ]]; then
    echo "❌ Usage: $0 <dev|prod>"
    echo "   dev  - builds lib/main_development.dart"
    echo "   prod - builds lib/main_production.dart"
    exit 1
fi

FLAVOR="$1"

# Set main file and output suffix based on flavor
case "$FLAVOR" in
    dev)
        main_file="lib/main_development.dart"
        output_suffix="dev"
        ;;
    prod)
        main_file="lib/main_production.dart"
        output_suffix="prod"
        ;;
    *)
        echo "❌ Invalid flavor: $FLAVOR"
        echo "   Valid options: dev, prod"
        exit 1
        ;;
esac

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
if [[ -z "$web_version_name" || -z "$web_build_number" ]]; then
    echo "❌ Missing required version information in versions file"
    exit 1
fi

# Prepare project
echo "📦 Preparing project..."
fvm flutter pub get || { echo "❌ flutter pub get failed"; exit 1; }
fvm flutter gen-l10n || { echo "❌ flutter gen-l10n failed"; exit 1; }
fvm dart run build_runner build --delete-conflicting-outputs || { echo "❌ build_runner failed"; exit 1; }

# Build Web
echo "🚀 Building Web for version $web_version_name ($web_build_number) [$FLAVOR]..."
fvm flutter build web \
    --release \
    --build-name="$web_version_name" \
    --build-number="$web_build_number" \
    -t "$main_file" || {
    echo "❌ Build failed"
    exit 1
}

# Create a unique output directory name
OUTPUT_DIR="$PROJECT_ROOT/build/web_${output_suffix}_v${web_version_name}_${web_build_number}"

# Remove existing output directory if it exists
if [[ -d "$OUTPUT_DIR" ]]; then
    rm -rf "$OUTPUT_DIR"
fi

# Rename build/web to the unique output directory
mv "$PROJECT_ROOT/build/web" "$OUTPUT_DIR"

echo "✅ Build complete! Output located at: $OUTPUT_DIR"
