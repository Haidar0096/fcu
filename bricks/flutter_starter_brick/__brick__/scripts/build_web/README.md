# Build Web Application

Builds the Flutter Web application in release mode.

## Prerequisites

- [fvm](https://fvm.app/) installed and project Flutter version configured (`fvm install`)

## Inputs

- `versions` file at project root with `web_version_name` and `web_build_number`

## Usage

Run from project root:

```bash
# For development server
./scripts/build_web/build_web.sh dev

# For production server
./scripts/build_web/build_web.sh prod
```

## Output

Generates a unique output directory in `build/`:

- **Development:** `build/web_dev_v{version}_{build}`
- **Production:** `build/web_prod_v{version}_{build}`
