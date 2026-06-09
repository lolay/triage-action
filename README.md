# triage-action

GitHub Action wrapper for [**triage**](https://github.com/lolay/triage) — the
environment doctor. Installs the `triage` CLI from `lolay/triage` release assets
(tool-cache aware) and runs a profile in CI.

Canonical contract (inputs, version resolution, asset mapping, exit codes):
[`lolay/triage` specs/action.md](https://github.com/lolay/triage/blob/main/specs/action.md).

## Usage

Pin the action with a floating or exact tag:

```yaml
- uses: lolay/triage-action@v0.3    # latest 0.3.x (preferred pre-1.0)
- uses: lolay/triage-action@v0      # latest 0.x
- uses: lolay/triage-action@v0.3.0  # exact (immutable)
```

Common CI step:

```yaml
- uses: lolay/triage-action@v0.3
  with:
    profile: ci
    strict: true
    json: true
    command-log: .triage/commands.log
```

## Inputs

All inputs are optional. See the full table in
[`specs/action.md`](https://github.com/lolay/triage/blob/main/specs/action.md#2-inputs).

| Input | Default | Purpose |
| --- | --- | --- |
| `version` | `VERSION` file | Override the CLI version to install (e.g. `0.3.0`) |
| `profile` | default profile | Profile to run |
| `config` | discovered config | Path to `triage.yaml` |
| `strict` | `false` | Treat warnings as errors |
| `severity` | `false` | Graded exit ladder |
| `json` | `false` | Machine-readable output |
| `quiet` | `false` | Hide passing checks |
| `verbose` | `false` | Replay failed-check output |
| `command-log` | disabled | Per-check command log path |
| `jobs` | CLI default | Max concurrent checks |
| `working-directory` | `.` | Directory to run in |
| `args` | — | Escape hatch for other flags |

## Outputs

| Output | Meaning |
| --- | --- |
| `version` | Resolved triage CLI version installed |
| `exit-code` | Raw exit code from `triage` |

## Version resolution

The action tag selects the CLI version via the committed root `VERSION` file.
Override with the `version` input only when you need a different CLI than the
action release pins. See
[`specs/action.md` §4](https://github.com/lolay/triage/blob/main/specs/action.md#4-cli-version-resolution-the-crux).

## Developing

```bash
make init      # verify layout
make ci        # actionlint + shellcheck (same gate as CI)
make doctor    # check for actionlint, shellcheck, gh
```

## License

Apache-2.0 — see [`LICENSE`](./LICENSE).
