# flutter_cli_utils

Audience: Flutter CLI Utils contributors and adopters; public project setup and usage only.

## Getting Started 🚀

The CLI application is distributed as source on GitHub, not on
[pub.dev](https://pub.dev), so activate it from a local clone:

- Clone this repository
- Run the following script from the project root to activate the CLI application globally:

```sh
bash scripts/activate.sh
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
fcu create --desc "My starter app" --org "com.my_startup" --name "starter_app" --dev-name "developer" --ios-lang swift --android-lang "kotlin" --template app --target-platforms "android,ios" --output-directory "starter_app" --overwrite-existing-directory --use-starter-brick --initialize-git-repo
```
