# {{proj_name.pascalCase()}}

{{proj_desc}}

For release process and building, see [RELEASE.md](RELEASE.md).

## Running the app

1. Navigate to the project root directory
2. Run the following commands in order:

   ```bash
   flutter pub get
   flutter gen-l10n
   dart run build_runner build
   flutter run --dart-define-from-file=env/development.json
   ```

Use `env/production.json` for the production environment. The committed files
hold build settings only; this app holds no secrets.
