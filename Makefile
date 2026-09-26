# triage-action Makefile
#
# Repo dev/release verbs for the lolay/triage-action composite action.
# Runtime install/run on consumer runners use install.sh/run.sh — never make.

SHELL := bash

.DEFAULT_GOAL := help

.PHONY: help init install-tools aw-compile aw-check build lint format shellcheck test ci pre-commit doctor clean tag promote \
        gh-runs-list gh-runs-watch gh-runs-status

define confirm
$(if $(CONFIRM_$(1)),,$(error Set CONFIRM_$(1)=1 to run $@))
endef

# Pinned tool versions — the single source of truth. CI installs both via
# `make install-tools` (gh-aw via `make aw-compile`); Renovate bumps these lines (custom managers in
# lolay/triage .github/renovate-shared.json). Keep the `NAME ?= X.Y.Z` shape.
ACTIONLINT_VERSION ?= 1.7.12
SHELLCHECK_VERSION ?= v0.11.0
GH_AW_VERSION ?= v0.74.8

# Repo-local tool dir (gitignored). lint/shellcheck prefer it over PATH so the
# pinned versions win once `make install-tools` has run.
TOOLS_BIN ?= $(CURDIR)/.tools/bin
export PATH := $(TOOLS_BIN):$(PATH)

# Maximum recent runs to fetch for gh-runs-list / gh-runs-watch.
GH_LIMIT ?= 50

##@ Develop

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*?##/ {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2} /^##@/ {printf "\n\033[1m%s\033[0m\n", substr($$0,5)}' $(MAKEFILE_LIST)

init: ## Verify repo layout (no dependencies to download)
	@test -f action.yml && test -f install.sh && test -f run.sh && test -f VERSION

install-tools: ## Install pinned actionlint + shellcheck into .tools/bin (no-op if already pinned)
	@set -euo pipefail; \
	mkdir -p "$(TOOLS_BIN)"; \
	case "$$(uname -s)" in Linux) os=linux ;; Darwin) os=darwin ;; *) echo "unsupported OS: $$(uname -s)" >&2; exit 1 ;; esac; \
	case "$$(uname -m)" in x86_64|amd64) al_arch=amd64; sc_arch=x86_64 ;; arm64|aarch64) al_arch=arm64; sc_arch=aarch64 ;; *) echo "unsupported arch: $$(uname -m)" >&2; exit 1 ;; esac; \
	tmp="$$(mktemp -d)"; trap 'rm -rf "$$tmp"' EXIT; \
	if [ "$$("$(TOOLS_BIN)/actionlint" -version 2>/dev/null | head -1)" = "$(ACTIONLINT_VERSION)" ]; then \
	  echo "actionlint $(ACTIONLINT_VERSION) already installed"; \
	else \
	  echo "Installing actionlint $(ACTIONLINT_VERSION)..."; \
	  base="https://github.com/rhysd/actionlint/releases/download/v$(ACTIONLINT_VERSION)"; \
	  tarball="actionlint_$(ACTIONLINT_VERSION)_$${os}_$${al_arch}.tar.gz"; \
	  curl -sSfL -o "$$tmp/$$tarball" "$$base/$$tarball"; \
	  curl -sSfL -o "$$tmp/checksums.txt" "$$base/actionlint_$(ACTIONLINT_VERSION)_checksums.txt"; \
	  (cd "$$tmp" && grep " $$tarball\$$" checksums.txt | { command -v sha256sum >/dev/null && sha256sum -c - || shasum -a 256 -c -; }); \
	  tar -xzf "$$tmp/$$tarball" -C "$$tmp" actionlint; \
	  mv "$$tmp/actionlint" "$(TOOLS_BIN)/actionlint"; \
	fi; \
	if "$(TOOLS_BIN)/shellcheck" --version 2>/dev/null | grep -qx "version: $(SHELLCHECK_VERSION:v%=%)"; then \
	  echo "shellcheck $(SHELLCHECK_VERSION) already installed"; \
	else \
	  echo "Installing shellcheck $(SHELLCHECK_VERSION)..."; \
	  curl -sSfL "https://github.com/koalaman/shellcheck/releases/download/$(SHELLCHECK_VERSION)/shellcheck-$(SHELLCHECK_VERSION).$${os}.$${sc_arch}.tar.xz" \
	    | tar -xJf - -C "$$tmp"; \
	  mv "$$tmp/shellcheck-$(SHELLCHECK_VERSION)/shellcheck" "$(TOOLS_BIN)/shellcheck"; \
	fi

# The compiler runs with GitHub API lookups blocked on purpose: it then uses the
# action pins built into GH_AW_VERSION instead of resolving floating tags live,
# so the same sources always compile to byte-identical lock files (aw-check can
# diff them). Bumping GH_AW_VERSION is how the pins move.
aw-compile: ## Recompile gh-aw agent workflows (agent-*.md -> .lock.yml) with the pinned GH_AW_VERSION
	@set -euo pipefail; \
	bin="$(TOOLS_BIN)/gh-aw"; \
	if [ "$$("$$bin" version 2>/dev/null | awk '{print $$NF}')" != "$(GH_AW_VERSION)" ]; then \
	  case "$$(uname -s)" in Linux) os=linux ;; Darwin) os=darwin ;; *) echo "unsupported OS: $$(uname -s)" >&2; exit 1 ;; esac; \
	  case "$$(uname -m)" in x86_64|amd64) arch=amd64 ;; arm64|aarch64) arch=arm64 ;; *) echo "unsupported arch: $$(uname -m)" >&2; exit 1 ;; esac; \
	  echo "Installing gh-aw $(GH_AW_VERSION) into $(TOOLS_BIN)..."; \
	  tmp="$$(mktemp -d)"; trap 'rm -rf "$$tmp"' EXIT; \
	  base="https://github.com/github/gh-aw/releases/download/$(GH_AW_VERSION)"; \
	  curl -sSfL -o "$$tmp/$$os-$$arch" "$$base/$$os-$$arch"; \
	  curl -sSfL -o "$$tmp/checksums.txt" "$$base/checksums.txt"; \
	  (cd "$$tmp" && grep " $$os-$$arch\$$" checksums.txt | { command -v sha256sum >/dev/null && sha256sum -c - || shasum -a 256 -c -; }); \
	  mkdir -p "$(TOOLS_BIN)"; install -m 0755 "$$tmp/$$os-$$arch" "$$bin"; \
	fi; \
	HTTPS_PROXY=http://127.0.0.1:9 HTTP_PROXY=http://127.0.0.1:9 NO_PROXY= \
	  "$$bin" compile --no-check-update

aw-check: aw-compile ## Fail if the gh-aw lock files are stale (CI runs this)
	@changes="$$(git status --porcelain --untracked-files=all -- .github/workflows .github/aw)"; \
	if [ -n "$$changes" ]; then \
	  echo "$$changes"; \
	  echo "gh-aw lock files are out of date — run 'make aw-compile' and commit the result" >&2; exit 1; \
	fi

build: ## No-op: composite action ships bash + action.yml, nothing to compile
	@echo "nothing to build (composite action — bash + action.yml)"

lint: ## actionlint on action.yml and workflow files
	@set -o pipefail; \
	if command -v actionlint >/dev/null 2>&1; then \
	  actionlint; \
	else \
	  echo "actionlint not found — run: make install-tools"; \
	  exit 1; \
	fi

shellcheck: ## Shellcheck install.sh and run.sh
	@set -o pipefail; \
	if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck install.sh run.sh; \
	else \
	  echo "shellcheck not found — run: make install-tools"; \
	  exit 1; \
	fi

format: ## No-op: no shell formatter configured (shellcheck via lint is the gate)
	@echo "nothing to format (no formatter configured)"

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

clean: ## Remove local temp artifacts and installed tools
	rm -rf .tmp .tools

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
	  --jq '[.[] | select(.status == "completed")] | group_by(.workflowName) | map(sort_by(.updatedAt) | last) | sort_by(.updatedAt) | .[] | (now - (.updatedAt | fromdateiso8601)) as $$age | "\(.conclusion)\t\(.workflowName)\t\(.headBranch)\t\(.url)\t\($$age | floor)"' \
	  2>&1) \
	  || { printf '  \033[33m⚠\033[0m gh run list failed (auth? run `gh auth login`)\n'; exit 0; }; \
	if [ -z "$$out" ]; then printf '  \033[2mno completed runs\033[0m\n'; exit 0; fi; \
	esc=$$(printf '\033'); \
	printf '%s\n' "$$out" | while IFS=$$'\t' read -r conclusion name branch url age_secs; do \
	  if [ "$$conclusion" = "success" ]; then mark="ok"; \
	  elif [ "$$conclusion" = "skipped" ] || [ "$$conclusion" = "neutral" ]; then mark="skip"; \
	  else mark="fail"; fi; \
	  if [ "$$age_secs" -lt 60 ]; then age="$${age_secs}s"; \
	  elif [ "$$age_secs" -lt 3600 ]; then age="$$((age_secs / 60))m"; \
	  elif [ "$$age_secs" -lt 86400 ]; then age="$$((age_secs / 3600))h"; \
	  else age="$$((age_secs / 86400))d"; fi; \
	  printf '%s\t%s\t%s\t%s\t%s\n' "$$mark" "$$name" "$$branch" "$$age" "$$url"; \
	done | column -t -s "$$(printf '\t')" \
	| sed -e "s/^ok  /$${esc}[32m✓$${esc}[0m   /" \
	      -e "s/^skip/$${esc}[2m-$${esc}[0m   /" \
	      -e "s/^fail/$${esc}[31m✗$${esc}[0m   /" \
	      -e 's/^/  /'

##@ Release

tag: ## Create and push git tag VERSION=x.y.z (triggers release workflow)
	$(call confirm,TAG)
	@test -n "$(VERSION)" || { echo "VERSION=x.y.z required" >&2; exit 1; }
	git tag "v$(VERSION)"
	git push origin "v$(VERSION)"

##@ Danger

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
