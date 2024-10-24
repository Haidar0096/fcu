## flutter_cli_utils

## Getting Started 🚀

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate flutter_cli_utils
```

Or locally via:

```sh
sh -e scripts/activate.sh <path_to_root_of_this_project>
```

## Usage

```sh
# Show CLI version
$ fcu --version

# Show usage help
$ fcu --help
```

Example:
```sh
fcu create --desc "Cool counter app" --org "com.countermeasures" --name "counter_app" --ios-lang swift --android-lang "java" --template app --target-platforms "android,ios" --output-directory "counter_app_flutter" --overwrite-existing-directory --use-starter-brick
```