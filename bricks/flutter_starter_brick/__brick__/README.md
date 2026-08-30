# {{proj_name.pascalCase()}}

{{proj_desc}}

For release process and building, see [RELEASE.md](RELEASE.md).

## Running the app

1. Navigate to the project root directory
2. Run the following commands in order:

   ```bash
   fvm install
   fvm flutter pub get
   fvm flutter gen-l10n
   fvm dart run build_runner build --delete-conflicting-outputs
   fvm flutter run --dart-define-from-file=env/development.json
   ```

Use `env/production.json` for the production environment. The committed files
hold build settings only; this app holds no secrets.
