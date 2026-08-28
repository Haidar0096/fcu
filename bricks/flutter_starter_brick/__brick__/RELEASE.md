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

1. Create a release-prep branch from development
2. On that branch, update the `versions` file with the new build numbers
3. On the same branch, update `CHANGELOG.md` with the release notes and the date — the date says `TBD` while the release date is unknown, the exact date once known; on release day a branch updates the date even if that is the only change
4. Open a PR from the release-prep branch to development
5. Team approves and merges the PR (squash and merge, like any other branch) —
   the version bump and the changelog never go straight onto development
6. Trigger GitHub Actions workflows against the development branch
7. Builds are uploaded to Google Play Internal Testing and TestFlight

### Testing

1. Team downloads and tests the builds from Internal Testing / TestFlight
2. If issues are found, fix them on a branch, merge it into development, and repeat the release-prep steps
3. When team confirms the builds are good, proceed to release

### Release

1. Open a PR from development to production
2. Team approves and merges the PR (regular merge, not squash)
3. Promote the release to production on Google Play Console and App Store Connect
4. Create a git tag on production carrying the version name only: `vX.Y.Z` — each platform's build number moves on its own in the `versions` file, so no single tag can name them all; the changelog rows are the build numbers' home
5. Verify after release (below)

## Verify after release

Verifying a mobile release means installing the BUILT artifact on a real device and running the release smoke pass on it — not re-checking the CI output. The checklist itself lives in the software-release skill's verify-after section; run it there and record the result with the release.

## Store timing facts

TODO({{dev_name.paramCase()}}): record this project's real store timings here once they are known — App Store review delay, Google Play review delay, and whether production rollout is staged (and over how many days). These decide when a release can actually be promoted, so they belong beside the flow rather than in someone's memory.

## Rollback

A store build that has shipped cannot be un-shipped. Going back to the last good version means releasing that version again as a **new build** through the same lane:

1. Create a release-prep branch and restore the code to the last good version
2. In the `versions` file, put the last good version name back and raise the build number above the bad build's — the stores reject a build number that is not higher
3. Merge the prep branch and run the same GitHub Actions workflows
4. Promote the new build in the Google Play Console and App Store Connect, and halt or reduce the bad build's rollout there
5. TODO({{dev_name.paramCase()}}): record any rollback step specific to this project here (data migrations, feature flags, server-side switches)

## Merge strategy

- **Feature → Development:** Use **squash merge** to keep development history clean
- **Development → Production:** Use **regular merge** (NOT squash) to preserve history link

## Building releases

### CI/CD (primary)

Releases are triggered via GitHub Actions:

1. Go to the repository on GitHub → **Actions** tab
2. Select **Deploy Android to Play Store** or **Deploy iOS to TestFlight**
3. Click **Run workflow**
4. Select the environment (`development` or `production` — the same two names the `env/<environment>.json` files carry)
5. Click **Run workflow** to start the build and upload

The Flutter version lives in `.fvmrc`; `setup-common-config.yml` reads it for both platforms. Java version and distribution live in `setup-common-config.yml`.

For first-time CI setup:
- **Android:** See `.github/workflows/README-android.md`
- **iOS:** See `.github/workflows/README-ios.md`

### Local scripts (fallback)

Local release scripts are available in the `scripts/` folder as a fallback in case CI is unavailable.

> **Important:** Before using local scripts, verify they are up to date with the CI workflows. The CI workflows are the primary release method and may include steps not present in the local scripts.

- **Android:** See `scripts/upload_to_play_store/README.md`
- **iOS:** See `scripts/upload_to_test_flight/README.md`
- **Web:** See `scripts/build_web/README.md` — read its opening note
  first: the lane cannot build while the shared code still imports
  `dart:io`.
