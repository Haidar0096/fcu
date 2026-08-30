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
./scripts/build_web/build_web.sh development

# For production server
./scripts/build_web/build_web.sh production
```

## Output

Generates a unique output directory in `build/`, named in the house artifact form:

- **Development:** `build/{{proj_name}}-development-{version}+{build}-web`
- **Production:** `build/{{proj_name}}-production-{version}+{build}-web`
