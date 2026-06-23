# Changelog

All notable changes to `bb` are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versioning is semver-ish.

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
