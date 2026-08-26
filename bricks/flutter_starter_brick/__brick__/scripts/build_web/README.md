# Build Web Application

> **This lane does not build yet.** The starter's shared code still
> imports `dart:io`, and the web compiler rejects that import, so
> `flutter build web` fails before this script reaches its output step.
> That import has to go first. Until it does, read this script as the
> shape of the lane rather than a lane the project can run.

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
