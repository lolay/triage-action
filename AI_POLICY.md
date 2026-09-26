# AI Policy

`lolay/triage-action` follows the triage estate's AI policy:
**[`lolay/triage` `AI_POLICY.md`](https://github.com/lolay/triage/blob/main/AI_POLICY.md)**.
In short: an `Assisted-by: <agent + version>` trailer on every AI-assisted
commit, the same line under `## AI assistance` in the PR, and a human
maintainer approves and merges every PR.

Additions for this repo:

- **Discuss first** (issue before code) for any change to action inputs,
  outputs, CLI version resolution, asset mapping, or exit-code handling. Those
  are defined by [`lolay/triage` `specs/action.md`](https://github.com/lolay/triage/blob/main/specs/action.md),
  which must change in the same breath.
- **`VERSION` is not hand-edited.** It follows `lolay/triage` releases through
  Renovate and is set by the release workflow.
- **Scripts stay portable bash** that passes the pinned shellcheck
  (`make pre-commit`).
