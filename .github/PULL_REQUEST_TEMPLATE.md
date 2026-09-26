<!--
Thanks for opening a PR. Quick reminders:

- One logical change per PR.
- Run `make pre-commit` (actionlint + shellcheck) before pushing.
- Changes to inputs, outputs, version resolution, or exit codes are discuss-first
  and must match lolay/triage specs/action.md.
-->

## Summary

<!-- What does this change do, in one or two sentences? -->

## Motivation

<!-- Why is this change needed? Link the issue. -->

Closes #

## How I tested this

<!-- e.g. `make pre-commit` passes; dogfood job output; a test workflow run. -->

## AI assistance

<!--
Required. Name the specific agent + version, one per line, or "None" if the PR is entirely hand-written.
Each AI-assisted commit also needs an Assisted-by: trailer. See AI_POLICY.md.
-->

Assisted-by: <e.g. Claude Opus 5.5, GPT-5.5, or "None">

## Checklist

- [ ] I ran `make pre-commit` locally.
- [ ] I updated `CHANGELOG.md` (and `specs/action.md` in lolay/triage) where behavior changed.
- [ ] I disclosed any AI assistance above with an `Assisted-by:` line (see [AI_POLICY.md](../AI_POLICY.md)).
