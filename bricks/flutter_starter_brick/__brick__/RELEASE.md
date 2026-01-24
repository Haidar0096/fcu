# Release Process

## Pre-release checklist

Before releasing, ensure the following:

- Register all the changes in CHANGELOG.md
- Update version numbers in `versions` file

## Release workflow

### Starting point (clean state)

Development and production branches are synchronized (development has been merged into production).

### Feature development

1. Create a feature branch from development
2. Work on the feature
3. Push the feature branch to remote
4. Open a PR from feature branch to development
5. Team approves and merges the PR (squash and merge)

### Preparing for release

1. Update `versions` file with new build numbers
2. Update `CHANGELOG.md` with release notes
3. Open a PR from development to production
4. Team approves and merges the PR (regular merge, not squash)

### After release

1. Create a git tag on production: `vX.Y.Z+build_number`

## Merge strategy

- **Feature → Development:** Use **squash merge** to keep development history clean
- **Development → Production:** Use **regular merge** (NOT squash) to preserve history link

## Building releases

- **Android:** See `scripts/upload_to_play_store/README.md`
- **iOS:** See `scripts/upload_to_test_flight/README.md`
- **Web:** See `scripts/build_web/README.md`
