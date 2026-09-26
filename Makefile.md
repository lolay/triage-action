# Makefile Reference — triage-action

The [`Makefile`](./Makefile) is the single source of truth for repo dev and
release verbs. Humans, local agents, and CI all run the same targets — the CI
workflow calls `make ci`, so a green `make ci` locally means the same checks CI
runs.

Runtime install/run on **consumer** GitHub Actions runners use `install.sh` and
`run.sh` directly — never `make`.

## Target overview

| Target | Section | Purpose |
| --- | --- | --- |
| `help` | Develop | List targets (default goal) |
| `init` | Develop | Verify repo layout |
| `install-tools` | Develop | Install `actionlint` (`ACTIONLINT_VERSION`, checksum-verified) and `shellcheck` (`SHELLCHECK_VERSION`) into `.tools/bin`; no-op when already at the pins |
| `aw-compile` | Develop | Recompile gh-aw agent workflows (`agent-*.md` → `.lock.yml`) with the pinned `GH_AW_VERSION` |
| `aw-check` | Develop | `aw-compile`, then fail if any lock file changed or is uncommitted (CI runs this) |
| `build` | Develop | Documented no-op (composite action — nothing to compile) |
| `lint` | Develop | `actionlint` on `action.yml` and workflows |
| `format` | Develop | Documented no-op (no shell formatter configured) |
| `shellcheck` | Develop | `shellcheck install.sh run.sh` |
| `test` | Develop | `lint` + `shellcheck` |
| `ci` | Develop | Full pre-push gate (`test`) |
| `pre-commit` | Develop | Alias of `ci` |
| `doctor` | Develop | Check for `actionlint`, `shellcheck`, `gh` |
| `clean` | Develop | Remove `.tmp/` and `.tools/` |
| `gh-runs-list` | GitHub | In-flight Actions runs (`status != completed`) |
| `gh-runs-watch` | GitHub | Watch active runs to completion |
| `gh-runs-status` | GitHub | Last completed run per workflow; `skipped`/`neutral` are not failures |
| `tag` | Release | Create + push `v$(VERSION)` (`CONFIRM_TAG=1`) |
| `promote` | Danger | Force-push floating `vX.Y` / `vX` (`CONFIRM_PROMOTE=1`) |

## CI workflow

[`.github/workflows/ci.yml`](./.github/workflows/ci.yml) runs:

1. `make install-tools` — actionlint + shellcheck at the Makefile pins
2. `make ci` — `actionlint` + `shellcheck install.sh run.sh`
3. `make aw-check` (separate job) — gh-aw lock files match their sources
3. Dogfood smoke: `uses: ./` against this repo's `triage.yaml` (installs the CLI
   version pinned in `VERSION` or overridden via the `version` input)

## Tool pins and dependency updates

The Makefile is the only place tool versions are pinned (`ACTIONLINT_VERSION`,
`SHELLCHECK_VERSION`, `GH_AW_VERSION`). `make lint` / `make shellcheck` put `.tools/bin` first on
`PATH`, so the pinned binaries win once `make install-tools` has run.

[Renovate](./renovate.json) extends the shared preset in
[`lolay/triage` `.github/renovate-shared.json`](https://github.com/lolay/triage/blob/main/.github/renovate-shared.json)
(weekly grouped minor/patch PR, GitHub Actions, the Makefile pins). This repo
adds one rule: `VERSION` **follows** `lolay/triage` releases — Renovate opens a
dedicated `triage CLI` PR as soon as the CLI releases (no cooldown, no
auto-merge). Merge it, then `make tag VERSION=x.y.z CONFIRM_TAG=1` to release the
action at the same version.

Renovate PRs are assigned to the Copilot coding agent. When CI fails on one,
`renovate-autofix.yml` turns off its auto-merge and asks Copilot (via an
`@copilot` comment) to fix it; a maintainer reviews and merges.

## Agent workflows

Issues can opt into the triage-estate agent state machine (triage → plan →
implement → review, ported from `lolay/nowline`). The canonical reference is
[`lolay/triage` `.github/AGENT_TRIAGE.md`](https://github.com/lolay/triage/blob/main/.github/AGENT_TRIAGE.md);
this repo carries a [stub](./.github/AGENT_TRIAGE.md) and copies of the
workflows, prompts, and runbooks.

## Release workflow

[`.github/workflows/release.yml`](./.github/workflows/release.yml) triggers on
tag push `v*`:

1. Write/bump the root `VERSION` file to match the tagged CLI semver (coordinated
   with `lolay/triage`)
2. Promote floating tags `vX.Y` and `vX` (remote pushes last)

See the CLI repo's [`specs/action.md`](https://github.com/lolay/triage/blob/main/specs/action.md)
for the full action contract and coordinated versioning rules.

## See also

- [`README.md`](./README.md) — usage and inputs
- [`CHANGELOG.md`](./CHANGELOG.md) — release notes
- [`lolay/triage` specs/action.md](https://github.com/lolay/triage/blob/main/specs/action.md) — canonical contract
