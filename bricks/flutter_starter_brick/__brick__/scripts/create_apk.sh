#!/bin/bash

# This script builds the app in release mode for different servers and copies each output into
# a specified output folder. It reads the android version name and code from a file called
# versions present at the project root.
# The output folder can be specified with the --output-dir parameter.

# Initialize variables
output_path=""{{#has_envs}}
servers=("development" "staging" "production"){{/has_envs}}
platforms=("android-arm" "android-arm64" "android-x64")
VERSIONS_FILE="versions"

# Function to exit with error message
error_exit() {
    echo "$1" >&2
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
[[ -f "$VERSIONS_FILE" ]] || error_exit "$VERSIONS_FILE not found at project root"

version=$(grep "android_version_name" "$VERSIONS_FILE" | cut -d'=' -f2)
version_code=$(grep "android_build_number" "$VERSIONS_FILE" | cut -d'=' -f2)

[[ -z "$version" || -z "$version_code" ]] && error_exit "Failed to read version information from $VERSIONS_FILE"

# Set default output path if not specified
output_path=${output_path:-"./artifacts"}
version_formatted="v$version-build-$version_code"

# Function to construct build command
get_build_cmd() {
    local version="$1"
    local version_code="$2"
    local target_platform="$3"{{#has_envs}}
    local target_server="$4"
    local main_file="lib/main_$target_server.dart"{{/has_envs}}{{^has_envs}}
    local main_file="lib/main.dart"{{/has_envs}}

    echo "flutter build apk --release \
--target-platform=\"$target_platform\" \
--build-name=\"$version\" \
--build-number=\"$version_code\" \
-t \"$main_file\""
}

# Function to get output APK path
get_output_path() {
    local platform="$1"{{#has_envs}}
    local server="$2"
    echo "$output_path/app-$server-$version_formatted-$platform.apk"{{/has_envs}}{{^has_envs}}
    echo "$output_path/app-$version_formatted-$platform.apk"{{/has_envs}}
}

# Function that builds the app and copies the output to the output path
build_and_copy() {
    local version="$1"
    local version_code="$2"
    local target_platform="$3"{{#has_envs}}
    local target_server="$4"
    echo "Building version $version_formatted for $target_server on $target_platform"{{/has_envs}}{{^has_envs}}
    echo "Building version $version_formatted for $target_platform"{{/has_envs}}

    # Get and execute build command
    local build_cmd=$(get_build_cmd "$version" "$version_code" "$target_platform"{{#has_envs}} "$target_server"{{/has_envs}})
    echo "Executing: $build_cmd"
    eval "$build_cmd"

    # Copy the output
    mkdir -p "$output_path"
    local output_file=$(get_output_path "$target_platform"{{#has_envs}} "$target_server"{{/has_envs}})
    cp build/app/outputs/flutter-apk/app-release.apk "$output_file"
}

# Build for all combinations of servers and platforms
{{#has_envs}}
for server in "${servers[@]}"; do
    for platform in "${platforms[@]}"; do
        build_and_copy "$version" "$version_code" "$platform" "$server"
    done
done{{/has_envs}}{{^has_envs}}
for platform in "${platforms[@]}"; do
    build_and_copy "$version" "$version_code" "$platform"
done{{/has_envs}}