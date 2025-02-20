#!/bin/bash

# This script builds the app in release mode and uploads it to TestFlight.
# It reads the ios version name and build number from a file called
# versions present at the project root.

# Change to the directory of the script
cd "$(dirname "$0")" || {
    echo "Failed to change to script directory"
    exit 1
}

# Source the versions file from parent directory
source ../../versions || {
    echo "Failed to source versions file from parent directory"
    exit 1
}

# Ensure required parameters are set
if [[ -z "$ios_version_name" || -z "$ios_build_number" ]]; then
    echo "Missing required version information in versions file"
    exit 1
fi

# Read the API key and issuer ID
api_key=$(cat ./api_key_name) || {
    echo "Failed to read api_key_name file"
    exit 1
}

issuer_id=$(cat ./issuer_id) || {
    echo "Failed to read issuer_id file"
    exit 1
}

# Set the main dart file based on environment
main_file="lib/main_production.dart"

# Build command
build_command="flutter build ipa \
    --release \
    --build-name=$ios_version_name \
    --build-number=$ios_build_number \
    -t $main_file"

echo "Running command: $build_command"
eval "$build_command" || {
    echo "Build failed"
    exit 1
}

# Upload command
upload_command="xcrun altool --upload-app --type ios \
    -f build/ios/ipa/*.ipa \
    --apiKey $api_key \
    --apiIssuer $issuer_id"

echo "Running command: $upload_command"
eval "$upload_command" || {
    echo "Upload failed"
    exit 1
}