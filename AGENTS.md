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
