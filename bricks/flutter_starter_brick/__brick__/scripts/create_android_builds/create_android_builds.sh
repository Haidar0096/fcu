#!/bin/bash

# This script builds Android APKs for all environments and architectures,
# plus an AAB (App Bundle) for production release to Google Play.
# See README.md for detailed setup instructions.

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSIONS_FILE="$PROJECT_ROOT/versions"

# Initialize variables
output_path=""
servers=("development" "staging" "production")
platforms=("android-arm" "android-arm64" "android-x64")

# Function to exit with error message
error_exit() {
    echo "❌ $1" >&2
    exit 1
}

# Parse the output directory argument
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --output-dir) output_path="$2"; shift ;;
        *) error_exit "Unknown parameter passed: $1" ;;
    esac
    shift
done

# Read and validate versions
if [[ -f "$VERSIONS_FILE" ]]; then
    source "$VERSIONS_FILE"
else
    error_exit "versions file not found at $VERSIONS_FILE"
fi

if [[ -z "$android_version_name" || -z "$android_build_number" ]]; then
    error_exit "Failed to read version information from versions file"
fi

version="$android_version_name"
version_code="$android_build_number"
version_formatted="v$version-build-$version_code"

# Set default output path if not specified
output_path=${output_path:-"$PROJECT_ROOT/artifacts"}

# Function to construct build command
get_build_cmd() {
    local version="$1"
    local version_code="$2"
    local target_platform="$3"
    local target_server="$4"
    local main_file="lib/main_${target_server}.dart"

    echo "flutter build apk --release \
--target-platform=\"$target_platform\" \
--build-name=\"$version\" \
--build-number=\"$version_code\" \
-t \"$main_file\""
}

# Function to get output APK path
get_output_path() {
    local platform="$1"
    local server="$2"
    echo "$output_path/app-$server-$version_formatted-$platform.apk"
}

# Function that builds the app and copies the output to the output path
build_and_copy() {
    local version="$1"
    local version_code="$2"
    local target_platform="$3"
    local target_server="$4"

    echo "🚧 Building version $version_formatted for $target_server on $target_platform"

    local build_cmd
    build_cmd=$(get_build_cmd "$version" "$version_code" "$target_platform" "$target_server")

    echo "🔧 Executing: $build_cmd"
    eval "$build_cmd" || error_exit "Build failed for $target_server on $target_platform"

    mkdir -p "$output_path"
    local output_file
    output_file=$(get_output_path "$target_platform" "$target_server")

    cp "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk" "$output_file" || error_exit "Failed to copy APK"
    echo "✅ Output saved to: $output_file"
}

# Build APKs for all combinations of servers and platforms
echo "📦 Building APKs for all environments and architectures..."
for server in "${servers[@]}"; do
    for platform in "${platforms[@]}"; do
        build_and_copy "$version" "$version_code" "$platform" "$server"
    done
done

# Build AAB for production (for Google Play Store)
echo ""
echo "📦 Building AAB for production release..."
echo "🚧 Building AAB version $version_formatted for Google Play Store"

aab_build_cmd="flutter build appbundle --release \
--build-name=\"$version\" \
--build-number=\"$version_code\" \
-t \"lib/main_production.dart\""

echo "🔧 Executing: $aab_build_cmd"
eval "$aab_build_cmd" || error_exit "AAB build failed for production"

# Copy AAB output to specified location
aab_output_file="$output_path/app-production-$version_formatted.aab"
cp "$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab" "$aab_output_file" || error_exit "Failed to copy AAB"
echo "✅ Production AAB saved to: $aab_output_file"
echo "📱 Ready for upload to Google Play Console"

echo ""
echo "🎉 All builds completed successfully!"