# Changelog

All notable changes to `bb` are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versioning is semver-ish.

## [0.4.0] - 2026-06-23

### Added — Pipelines + completion (Tier 4)
- `bb pipeline list [--json]` — list recent pipelines (newest first, up to 20). Columns: build number, state/result (colored: green=SUCCESSFUL, red=FAILED, yellow=IN_PROGRESS/PENDING, gray=STOPPED/other), ref name, created date.
- `bb pipeline view <id> [--json]` — show pipeline details (build number, state, result, ref, creator, created, duration) and a step table including step UUIDs (needed for `pipeline logs`).
- `bb pipeline logs <pipeline_id> <step_uuid>` — fetch raw text/plain log for a pipeline step; uses `bb_api_raw` to bypass JSON Content-Type (same pattern as `pr diff`).
- `bb pipeline run [--branch B] [--pattern CUSTOM] [--yes]` — trigger a pipeline; prompts for confirmation before POSTing; `--yes`/`-y` bypasses for scripting. Branch defaults to current git branch then repo mainbranch. `--pattern` triggers a named custom pipeline defined in `bitbucket-pipelines.yml`.
- `bb completion bash|zsh` — print a static shell completion script to stdout for subcommand-level tab completion. Fast-path (no deps, no creds). Source or eval: `eval "$(bb completion bash)"`.

## [0.3.0] - 2026-06-23

### Added — PR visibility (Tier 2)
- `bb pr status [--json]` — show open PR(s) for the current branch with reviewer approval state (✓ approved, ✗ changes requested, ? pending). Uses server-side `q` filter with client-side fallback.
- `bb pr commits <id> [--json]` — list commits in a PR (short hash, author, first line of message).
- `bb pr files <id> [--json]` — list files changed in a PR with status (added/modified/removed/renamed), line deltas, and path.
- `bb pr create --fill` — derive PR title from `git log -1 --format=%s` and body from `git log <dest>..HEAD --format='- %s'` when not explicitly provided.
- `bb pr create --web` — open the Bitbucket compare page in browser instead of creating via API; encodes branch names for URL safety.

### Added — Repo + browse (Tier 3)
- `bb repo view [ws/repo] [--json]` — show repository details (full_name, description, visibility, main branch, size, updated date, HTML link). Defaults to current repo via `detect_repo`.
- `bb repo list [ws] [--json]` — list repositories in a workspace (name, public/private, updated date, truncated description). Workspace from arg, auto-detected, or required error.
- `bb repo clone <ws/repo> [--ssh]` — resolve clone URL from API and run `git clone`; defaults to HTTPS, `--ssh` picks the SSH URL.
- `bb repo create <name> [--workspace WS] [--private] [--project KEY] [--description D] [--yes]` — POST to create a repository; shows a confirmation prompt before mutating; `--yes`/`-y` bypasses for scripting.
- `bb browse [path] [--branch B]` — open the current repo (or a file path within it) in the browser; branch defaults to current git branch then repo mainbranch; path segments are URL-encoded individually.

## [0.2.0] - 2026-06-23

### Added — PR review loop + escape hatch (Tier 1)
- `bb pr approve <id> [--undo] [--json]` — approve a PR or remove your approval.
- `bb pr request-changes <id> [--undo] [--json]` — request changes or remove the request.
- `bb pr checkout <id> [--branch NAME]` — check out a PR's source branch locally (same-repo + cross-fork).
- `bb pr edit <id> [--title|--body|--body-file|--dest|--reviewers]` — edit an open PR; GET-first then PUT so unspecified fields are preserved.
- `bb api <METHOD> <PATH> [--data JSON|--input FILE] [--json]` — call any Bitbucket API endpoint directly; pretty-prints JSON, raw fallback for non-JSON.

## [0.1.0] - initial

### Added
- `bb auth login | status | logout`.
- `bb pr create | list | view | comment | diff | checks | open | merge | decline | reviewers`.
