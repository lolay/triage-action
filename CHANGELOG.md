# Changelog

All notable changes to `lolay/triage-action` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

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
