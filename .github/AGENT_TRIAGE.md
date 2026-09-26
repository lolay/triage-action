# Agent triage — state machine (stub)

This repo runs the triage-estate agent state machine ported from
`lolay/nowline`. The canonical reference, with the label glossary, override
paths, empty-PR ban, workflow table, repo-settings checklist, and
troubleshooting, lives in **[`lolay/triage` `.github/AGENT_TRIAGE.md`](https://github.com/lolay/triage/blob/main/.github/AGENT_TRIAGE.md)**.
Phase prompts and the shared prelude tell agents to read it.

What is local to this repo:

- The workflows, prompts (`.github/agent-prompts/`), and label runbooks
  (`.github/agent-actions/`) are copies of `lolay/triage`'s. Keep them in sync
  when either side changes; runbook links in agent comments point at this
  repo's copies.
- `make aw-compile` / `make aw-check` regenerate and verify the gh-aw lock
  files with the pinned `GH_AW_VERSION` in this repo's `Makefile`.
- Hard rules for this repo are in [`AGENTS.md`](../AGENTS.md) and
  [`AI_POLICY.md`](../AI_POLICY.md). The action's contract is
  [`lolay/triage` `specs/action.md`](https://github.com/lolay/triage/blob/main/specs/action.md).
- Renovate PRs (including the `VERSION` follower bump) are assigned to the
  Copilot coding agent, and `renovate-autofix.yml` asks Copilot to fix a
  failing one after turning off its auto-merge.
