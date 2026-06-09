# triage-action Makefile
#
# Repo dev/release verbs for the lolay/triage-action composite action.
# Runtime install/run on consumer runners use install.sh/run.sh — never make.

SHELL := bash

.DEFAULT_GOAL := help

.PHONY: help init lint shellcheck test ci pre-commit doctor clean tag promote \
        gh-runs-list gh-runs-watch gh-runs-status

define confirm
$(if $(CONFIRM_$(1)),,$(error Set CONFIRM_$(1)=1 to run $@))
endef

ACTIONLINT_VERSION ?= 1.7.7

# Maximum recent runs to fetch for gh-runs-list / gh-runs-watch.
GH_LIMIT ?= 50

##@ Develop

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2} /^##@/ {printf "\n\033[1m%s\033[0m\n", substr($$0,5)}' $(MAKEFILE_LIST)

init: ## Verify repo layout (no dependencies to download)
	@test -f action.yml && test -f install.sh && test -f run.sh && test -f VERSION

lint: ## actionlint on action.yml and workflow files
	@set -o pipefail; \
	if command -v actionlint >/dev/null 2>&1; then \
	  actionlint; \
	else \
	  echo "actionlint not found — install: brew install actionlint (CI always runs it)"; \
	  exit 1; \
	fi

shellcheck: ## Shellcheck install.sh and run.sh
	@set -o pipefail; \
	if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck install.sh run.sh; \
	else \
	  echo "shellcheck not found — install: brew install shellcheck (CI always runs it)"; \
	  exit 1; \
	fi

test: lint shellcheck ## Lint plus local script sanity (install smoke runs in CI)

ci: test ## Full pre-push gate (what CI runs locally)

pre-commit: ci ## Local gate before committing or pushing (alias of ci)

doctor: ## Check dev tools (actionlint, shellcheck, gh). MODE=default|release
	@set -o pipefail; \
	missing=0; \
	for tool in actionlint shellcheck gh; do \
	  if command -v "$$tool" >/dev/null 2>&1; then \
	    echo "[✓] $$tool"; \
	  else \
	    echo "[✗] $$tool not found"; missing=1; \
	  fi; \
	done; \
	exit $$missing

clean: ## Remove local temp artifacts
	rm -rf .tmp

##@ GitHub

gh-runs-list: ## List this repo's in-flight Actions runs (status != completed)
	@out=$$(gh run list --limit $(GH_LIMIT) \
	  --json status,workflowName,headBranch,event,url \
	  --jq '.[] | select(.status != "completed") | "  \(.status)\t\(.workflowName)\t\(.headBranch)\t\(.event)\t\(.url)"' 2>&1) \
	  || { printf '  \033[33m⚠\033[0m gh run list failed (auth? run `gh auth login`)\n'; exit 0; }; \
	if [ -z "$$out" ]; then printf '  \033[2mno active runs\033[0m\n'; \
	else printf '%s\n' "$$out" | column -t -s "$$(printf '\t')"; fi

gh-runs-watch: ## Watch this repo's in-flight Actions runs until each completes
	@ids=$$(gh run list --limit $(GH_LIMIT) --json status,databaseId \
	  --jq '.[] | select(.status != "completed") | .databaseId' 2>/dev/null); \
	if [ -z "$$ids" ]; then printf '  \033[2mno active runs\033[0m\n'; exit 0; fi; \
	for id in $$ids; do \
	  gh run watch "$$id" --compact || printf '  \033[33m⚠\033[0m watch failed for run %s\n' "$$id"; \
	done

gh-runs-status: ## Show pass/fail of the last completed run per workflow
	@out=$$(gh run list --limit $(GH_LIMIT) \
	  --json conclusion,workflowName,headBranch,url,status,updatedAt \
	  --jq '[.[] | select(.status == "completed")] | group_by(.workflowName) | .[] | (sort_by(.updatedAt) | last) | "\(.conclusion)\t\(.workflowName)\t\(.headBranch)\t\(.url)"' \
	  2>&1) \
	  || { printf '  \033[33m⚠\033[0m gh run list failed (auth? run `gh auth login`)\n'; exit 0; }; \
	if [ -z "$$out" ]; then printf '  \033[2mno completed runs\033[0m\n'; exit 0; fi; \
	printf '%s\n' "$$out" | while IFS=$$'\t' read -r conclusion name branch url; do \
	  if [ "$$conclusion" = "success" ]; then icon="\033[32m✓\033[0m"; \
	  else icon="\033[31m✗\033[0m"; fi; \
	  printf "  $$icon  %-24s  %-14s  %s\n" "$$name" "$$branch" "$$url"; \
	done

##@ Release

tag: ## Create and push git tag VERSION=x.y.z (triggers release workflow)
	$(call confirm,TAG)
	@test -n "$(VERSION)" || { echo "VERSION=x.y.z required" >&2; exit 1; }
	git tag "v$(VERSION)"
	git push origin "v$(VERSION)"

promote: ## Force-push floating tags vX.Y and vX for VERSION=x.y.z (CONFIRM_PROMOTE=1)
	$(call confirm,PROMOTE)
	@test -n "$(VERSION)" || { echo "VERSION=x.y.z required" >&2; exit 1; }
	@set -euo pipefail; \
	MAJOR="$${VERSION%%.*}"; \
	MINOR="$${VERSION%.*}"; \
	git tag --force "v$${MINOR}"; \
	git tag --force "v$${MAJOR}"; \
	git push --force origin "v$${MINOR}"; \
	git push --force origin "v$${MAJOR}"
