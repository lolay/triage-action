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
| `lint` | Develop | `actionlint` on `action.yml` and workflows |
| `shellcheck` | Develop | `shellcheck install.sh run.sh` |
| `test` | Develop | `lint` + `shellcheck` |
| `ci` | Develop | Full pre-push gate (`test`) |
| `pre-commit` | Develop | Alias of `ci` |
| `doctor` | Develop | Check for `actionlint`, `shellcheck`, `gh` |
| `clean` | Develop | Remove `.tmp/` |
| `tag` | Release | Create + push `v$(VERSION)` (`CONFIRM_TAG=1`) |
| `promote` | Release | Force-push floating `vX.Y` / `vX` (`CONFIRM_PROMOTE=1`) |

## CI workflow

[`.github/workflows/ci.yml`](./.github/workflows/ci.yml) runs:

1. `actionlint` (pinned binary)
2. `shellcheck install.sh run.sh`
3. Dogfood smoke: `uses: ./` against this repo's `triage.yaml` (installs the CLI
   version pinned in `VERSION` or overridden via the `version` input)

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
