# Release Guide

Audience: fcu and starter-brick release maintainers; limited to release operations and public repository facts.

This document outlines the release process for both the Flutter Starter Brick and the Flutter CLI Utils (fcu) tool.

## Releasing the Flutter Starter Brick

To release a new version of the starter brick to BrickHub:

1. **Update the version** in `bricks/flutter_starter_brick/brick.yaml`

   ```yaml
   version: 0.1.0+1  # Update this
   ```

2. **Update the changelog** at `bricks/flutter_starter_brick/CHANGELOG.md`
   - Document all changes, improvements, and fixes
   - Follow [Keep a Changelog](https://keepachangelog.com/) format

3. **Publish to BrickHub**

   ```bash
   cd bricks/flutter_starter_brick
   mason publish --dry-run   # must say "No issues detected"
   mason publish
   ```

   The bundle must stay under 2 MB. Mason bundles everything under
   `__brick__`, git-ignored or not: a `.dart_tool/` left inside
   `__brick__/packages/architecture_lint_rules/` by a `dart test` run there
   adds about 50 MB and fails the dry run — delete it first.

## Releasing the CLI Tool (fcu)

The steps themselves live in the software-release skill; this section records
the flow this repo uses.

1. **Cut a release-prep branch from `development`**

   ```bash
   git switch development && git pull
   git switch -c chore/release-v1.0.0
   ```

   The version bump and the changelog entry ride this branch like any other
   change — never a direct write on `development`.

2. **Update the version** in `pubspec.yaml` (at project root)

   ```yaml
   version: 1.0.0  # Update this
   ```

3. **Generate version info**

   ```bash
   dart run build_runner build
   ```

   This regenerates `lib/src/version.dart`. `test/src/version_test.dart`
   fails while that file is stale, so run `dart test` before opening the PR.

4. **Update the changelog** — `bricks/flutter_starter_brick/CHANGELOG.md`
   is the repo's one changelog (there is no root `CHANGELOG.md`); a CLI
   change gets its line under the brick version it ships with. Add the
   release notes and the release date — `TBD` while the date is unknown,
   the exact date once it is known (on release day a branch updates the
   date even if that is the only change).

5. **Open the release-prep PR into `development` and squash-merge it**

   ```bash
   gh pr create --base development --head chore/release-v1.0.0 --title "Release v1.0.0" --body "Release version 1.0.0"
   gh pr merge --squash --delete-branch
   ```

6. **Open the PR from `development` into `production`, and merge it only on
   the explicit human go**

   ```bash
   gh pr create --base production --head development --title "Release v1.0.0 to production" --body "Release version 1.0.0"
   # after review and the go:
   gh pr merge --merge --delete-branch=false
   ```

7. **Tag the release on `production`**

   Two tag namespaces, because the two versions move independently: the bare
   `vX.Y.Z` names a BRICK release, `cli-vX.Y.Z` names a CLI release. Tagging a
   CLI release `vX.Y.Z` would collide with the brick tag of that number.

   **The brick section above carries no git flow of its own, so a brick release
   uses steps 1, 4 and 5 to 8 of this section — and takes the brick tag.**

   ```bash
   git switch production && git pull
   git tag cli-v1.0.0        # a CLI release
   # git tag v1.0.0          # a brick release — the brick's version, not the CLI's
   git push origin cli-v1.0.0
   # git push origin v1.0.0   # a brick release — pushes the tag made above
   ```

8. **Create the GitHub Release from the pushed tag**

   For a CLI release:

   ```bash
   gh release create cli-v1.0.0 --title "CLI v1.0.0" --generate-notes
   ```

   For a brick release:

   ```bash
   gh release create v1.0.0 --title "Brick v1.0.0" --generate-notes
   ```

   > **Note**: The CLI tool is currently distributed as source code on GitHub (not published to pub.dev)

## Pre-release Checklist

Before releasing either component:

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped appropriately (follow [Semantic Versioning](https://semver.org/))
- [ ] No hardcoded paths or development configurations
- [ ] Brick bundle updated if brick was modified
- [ ] Proof app generated from the LOCAL brick (`mason add --path`, not
      BrickHub) and every command in its `.github/workflows/checks.yml`
      run green in that app before publishing. `fcu create` has no
      local-brick flag — it always runs `mason add flutter_starter_brick`
      against BrickHub — so the local proof takes two stages: create the
      empty Flutter app, then point Mason at the working tree.

      ```bash
      # Stage 1 — the same answers you would give `fcu create`.
      flutter create --empty --project-name my_proof --org com.example \
        -t app --platforms android,ios,web,windows,linux,macos my_proof
      cd my_proof

      # Stage 2 — the brick from this working tree, not BrickHub.
      mason init
      mason add flutter_starter_brick --path <repo>/bricks/flutter_starter_brick
      mason get

      # The pre-gen hook replaces `lib/` only in fresh `flutter create`
      # output. It requires `.metadata`, `pubspec.yaml` and `lib/main.dart`
      # in the project root, plus a sentinel naming the same token that
      # `mason make` is given. The sentinel holds three newline-terminated
      # lines: the literal version marker, the token, and the
      # symlink-resolved absolute project root. The hook deletes it.
      TOKEN=$(openssl rand -hex 32)
      printf '%s\n%s\n%s\n' fcu-fresh-flutter-output-v1 "$TOKEN" "$(pwd -P)" \
        > fcu_fresh_flutter_output.sentinel

      mason make flutter_starter_brick --on-conflict overwrite \
        --proj_name my_proof --proj_desc 'A proof app' --org_name com.example \
        --dev_name developer --fresh_output_token "$TOKEN"
      ```

## Version Synchronization

While the brick and CLI tool versions are independent, consider:

- Major brick changes may warrant a CLI version bump
- Document minimum compatible versions in both READMEs
