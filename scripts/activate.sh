#!/bin/bash

# This script activates the dart package globally

# Parse the path to the package from the command line arguments
package_path=$1

# Ensure the package path is not empty
if [ -z "$package_path" ]; then
  echo "Error: Package path is required"
  exit 1
fi

flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart pub global activate --source=path "$package_path"
flutter_cli_utils --help