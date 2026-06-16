# Changelog

All notable changes to `lolay/triage-action` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.4.0] - 2026-06-15

### Changed

- `make gh-runs-status` now uses three-bucket conclusions (`skipped`/`neutral`
  render dim instead of as failures) and shows a run-age column.
- `make promote` moved under the `Danger` help section (force-pushes remote
  tags; still requires `CONFIRM_PROMOTE=1`).
- `make help` recognizes target names containing digits and dots.

### Added

- `make build` and `make format` documented no-op stubs, completing the
  standard core verb set.
- Initial composite action scaffold: `action.yml`, `install.sh`, `run.sh`, and
  root `VERSION` file for deterministic CLI pinning on floating action tags.
- Typed inputs for CI-relevant flags (`strict`, `severity`, `json`, `quiet`,
  `verbose`, `command-log`, `jobs`) plus `profile`, `config`, `version`,
  `working-directory`, and an `args` escape hatch.
- Repo dev Makefile (`lint`, `shellcheck`, `test`, `ci`, `doctor`, `tag`,
  `promote`) and dogfood CI workflow (`actionlint` + `shellcheck` + `uses: ./`
  smoke).
- Release workflow promoting floating tags `vX.Y` / `vX` and bumping `VERSION`
  on tag push (coordinated semver with `lolay/triage`).

## [0.3.0] - 2026-06-08

### Added

- First bootstrap release. Pins triage CLI `0.3.0` via the root `VERSION` file.
