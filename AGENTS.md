# AGENTS.md

Orientation for AI coding agents working in **lolay/triage-action**.

## What this repo is

A composite GitHub Action (bash + `action.yml`) that installs the
[`triage`](https://github.com/lolay/triage) CLI from release assets and runs a
profile in CI. It lives as a nested child of
[`lolay/triage-workspace`](https://github.com/lolay/triage-workspace).

## Canonical contract

[`lolay/triage` specs/action.md](https://github.com/lolay/triage/blob/main/specs/action.md)
is the source of truth for inputs, version resolution, asset mapping, and exit
codes. Changes to observable behavior must stay in sync with that spec.

## Build commands

Always use this repo's Makefile — never run underlying tools directly:

```bash
make init        # verify layout
make ci          # full gate (actionlint + shellcheck)
make pre-commit  # alias of ci
make doctor      # tool presence check
```

## Changelog

User-visible changes require an entry under `## [Unreleased]` in `CHANGELOG.md`
before commit.

## Workspace parent

When working across repos, read the workspace
[`AGENTS.md`](../AGENTS.md) delegation protocol: commits belong in this repo's
git history, not the workspace wrapper.

## Hard rules

- `action.yml` inputs/outputs, version resolution in `install.sh`, and exit-code
  handling in `run.sh` follow
  [`lolay/triage` `specs/action.md`](https://github.com/lolay/triage/blob/main/specs/action.md).
  Change the spec first (discuss-first, see `AI_POLICY.md`).
- `VERSION` follows `lolay/triage` releases via Renovate; don't edit it by hand.
- Releases and floating tags (`make tag`, `make promote`, `release.yml`) are
  maintainer-only.

## AI assistance and the agent flow

Follow [`AI_POLICY.md`](./AI_POLICY.md): `Assisted-by:` on every AI-assisted
commit and in the PR's `## AI assistance` section. The agent state machine is
documented in [`lolay/triage` `.github/AGENT_TRIAGE.md`](https://github.com/lolay/triage/blob/main/.github/AGENT_TRIAGE.md)
(local stub: [`.github/AGENT_TRIAGE.md`](./.github/AGENT_TRIAGE.md)). If you
touch frontmatter in `.github/workflows/agent-*.md`, run `make aw-compile` and
commit the regenerated `.lock.yml` files (`make aw-check` verifies).

If you are asked to fix a failing Renovate PR: keep the update, make the
smallest change that gets `make pre-commit` green, regenerate files with
Makefile targets rather than by hand, and explain in a comment instead of
forcing a fix when the update needs a design decision.
