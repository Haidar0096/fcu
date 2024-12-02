#!/bin/bash

# This script activates the dart package globally

# Get the directory where the script is located, regardless of where it's called from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the parent directory (project root)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Navigate to project root
cd "$PROJECT_ROOT" || { echo "Failed to cd to $PROJECT_ROOT"; exit 1; }

flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart pub global activate --source=path "$PROJECT_ROOT"
fcu --help