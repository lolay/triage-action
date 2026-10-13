# Changelog

All notable changes to `lolay/triage-action` are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.5.0] - 2026-10-13

### Added

- Automatic releases. Renovate's `triage CLI` PR now opens as soon as the CLI
  releases (it was held to the shared Friday-morning schedule) and automerges
  once CI passes. When `ci` then passes on `main` and `v$(VERSION)` doesn't
  exist yet, the release workflow cuts the CHANGELOG, tags the commit, and
  promotes `vX.Y` / `vX`. `make tag` stays as a manual fallback.

### Fixed

- Dogfood `triage.yaml` uses the structural `group:` + `items:` form; the
  triage CLI 0.4.0 pinned in `VERSION` rejects a check that sets both `tool:`
  and `group:`, which failed the dogfood smoke job.
- An exact release tag could install the previous triage CLI. The release
  workflow wrote `VERSION` to match the tag *after* the tag was cut, so the fix
  reached `vX.Y` / `vX` but never the immutable `vX.Y.Z`. It now verifies that
  `VERSION` at the tagged commit equals the tag, fails the release on a
  mismatch, and only then points the floating tags at that commit. `make tag`
  refuses unless `VERSION` at `HEAD` already equals the version being tagged,
  and `make promote` points the floating tags at the exact tag instead of the
  local checkout.
- Known issue, left as published: the exact `v0.4.0` tag carries `VERSION`
  0.3.0 and installs triage 0.3.0. Pin `v0.4` or `v0.5.0` instead.

### Changed

- Installs triage CLI 0.5.0 by default (`VERSION`, was 0.4.0). 0.5.0 adds
  `recommended` / `recommended_from` on tool checks: a tool below its
  recommended version is a warning, so `strict: true` fails it.
- CI: `actions/checkout` v7 (was v6) and actionlint 1.7.12 (was 1.7.7).
- Tool versions are pinned only in the `Makefile` (`ACTIONLINT_VERSION`,
  `SHELLCHECK_VERSION`); CI installs them with `make install-tools` instead of
  a duplicated actionlint version in `ci.yml` and an unpinned apt shellcheck.
  shellcheck is now v0.11.0.

### Added

- `make install-tools`: installs pinned actionlint (checksum-verified) and
  shellcheck into a gitignored `.tools/bin`, which `make lint`/`make shellcheck`
  prefer over `PATH`.
- Renovate: `renovate.json` extends the shared `lolay/triage` preset and makes
  `VERSION` follow `lolay/triage` releases (dedicated PR, no cooldown).
- Agent state machine (ported from `lolay/nowline`, canonical doc in
  `lolay/triage`): gh-aw phase workflows with prompts, verdict/label glue,
  Copilot PR stamping and validation, label runbooks, `agent-labels.yml`, and
  a local `.github/AGENT_TRIAGE.md` stub.
- Renovate autofix: Renovate PRs are assigned to the Copilot coding agent, and
  `renovate-autofix.yml` disables auto-merge and asks Copilot to fix a failing
  Renovate PR (once per commit, at most three times per PR).
- `copilot-setup-steps.yml`, `make aw-compile` / `make aw-check` (pinned
  `GH_AW_VERSION`, CI-enforced), `AI_POLICY.md`, issue and PR templates.
- Agent models: `claude-opus-5.5` for plan and deep implementation,
  `claude-sonnet-5` for triage, fast implementation, and review. nowline's
  `claude-sonnet-4.5` was deprecated in Copilot on 2026-09-01.

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
