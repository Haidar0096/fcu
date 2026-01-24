# Build Web Application

Builds the Flutter Web application in release mode for Development or Production environments.

## Inputs

**Required:**
- `versions` file at project root with:
  - `web_version_name` (e.g., "1.0.0")
  - `web_build_number` (e.g., 1)

## Usage

Run from project root:

```bash
# For development flavor (main_development.dart)
./scripts/build_web/build_web.sh dev

# For production flavor (main_production.dart)
./scripts/build_web/build_web.sh prod
```

## Output

The script generates a unique output directory in `build/` to prevent overwriting:

- **Development:** `build/web_dev_v{version}_{build}`
- **Production:** `build/web_prod_v{version}_{build}`

Inside this folder is the fully built web application (HTML, JS, assets) ready for deployment.

## Notes

- Uses `fvm` for consistent Flutter SDK versions
- Builds from `lib/main_development.dart` (Dev) or `lib/main_production.dart` (Prod)
