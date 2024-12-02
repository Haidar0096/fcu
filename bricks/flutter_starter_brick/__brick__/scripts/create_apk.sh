#!/bin/bash

# This script builds the app in release mode for different servers and copies each output into
# a specified output folder. It reads the android version name and code from a file called
# versions present at the project root

# Initialize variables
output_path=""{{#has_envs}}
servers=("development" "staging" "production"){{/has_envs}}
platforms=("android-arm" "android-arm64" "android-x64")

# Parse the output directory argument
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --output-dir) output_path="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Read versions from file
if [[ ! -f "versions" ]]; then
  echo "versions file not found at project root"
  exit 1
fi

# Extract versions using grep and cut
version=$(grep "android_version_name" versions | cut -d'=' -f2)
version_code=$(grep "android_build_number" versions | cut -d'=' -f2)

# Validate versions were read correctly
if [[ -z "$version" || -z "$version_code" ]]; then
  echo "Failed to read version information from versions file"
  exit 1
fi

# Set default output path if not specified
if [[ -z "$output_path" ]]; then
  output_path="./artifacts"
fi

# Set the version name and version code formatted string
version_formatted=v$version-build-$version_code

# Function that builds the app and copies the output to the output path
build_and_copy() {
  local version="$1"
  local version_code="$2"
  local target_platform="$3"{{#has_envs}}
  local target_server="$4"

  echo "Building for $target_server on $target_platform"
  flutter build apk \
    --release \
    --target-platform="$target_platform" \
    --build-name="$version" \
    --build-number="$version_code" \
    -t "lib/main_$target_server.dart"{{/has_envs}}{{^has_envs}}
  echo "Building for $target_platform"
  flutter build apk \
    --release \
    --target-platform="$target_platform" \
    --build-name="$version" \
    --build-number="$version_code" \
    -t "lib/main.dart"{{/has_envs}}

  # Create the outputs folder if it does not exist, and copy the outputs to it
  mkdir -p "$output_path"{{#has_envs}}
  cp build/app/outputs/flutter-apk/app-release.apk "$output_path/app-$target_server-$version_formatted-$target_platform.apk"{{/has_envs}}{{^has_envs}}
  cp build/app/outputs/flutter-apk/app-release.apk "$output_path/app-$version_formatted-$target_platform.apk"{{/has_envs}}
}

# Build for all combinations of servers and platforms
{{#has_envs}}
for server in "${servers[@]}"; do
  for platform in "${platforms[@]}"; do
    build_and_copy "$version" "$version_code" "$platform" "$server"
  done
done
{{/has_envs}}{{^has_envs}}
for platform in "${platforms[@]}"; do
  build_and_copy "$version" "$version_code" "$platform"
done
{{/has_envs}}