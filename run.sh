#!/usr/bin/env bash
set -uo pipefail
cmd=(triage)
[[ -n "${INPUT_PROFILE:-}" ]]       && cmd+=(--profile "$INPUT_PROFILE")
[[ "${INPUT_STRICT:-}"   == true ]] && cmd+=(--strict)
[[ "${INPUT_SEVERITY:-}" == true ]] && cmd+=(--severity)
[[ "${INPUT_JSON:-}"     == true ]] && cmd+=(--json)
[[ "${INPUT_QUIET:-}"    == true ]] && cmd+=(--quiet)
[[ "${INPUT_VERBOSE:-}"  == true ]] && cmd+=(--verbose)
[[ -n "${INPUT_COMMAND_LOG:-}" ]]   && cmd+=(--command-log "$INPUT_COMMAND_LOG")
[[ -n "${INPUT_JOBS:-}" ]]          && cmd+=(--jobs "$INPUT_JOBS")
# shellcheck disable=SC2206  # intentional word-split for the escape-hatch flags
[[ -n "${INPUT_ARGS:-}" ]]          && cmd+=($INPUT_ARGS)
[[ -n "${INPUT_CONFIG:-}" ]]        && cmd+=("$INPUT_CONFIG")   # optional positional, LAST
"${cmd[@]}"; code=$?
echo "exit-code=$code" >> "$GITHUB_OUTPUT"
exit "$code"
