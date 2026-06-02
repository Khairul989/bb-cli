# bb — Bitbucket Cloud CLI

A `gh`-style command-line interface for Bitbucket Cloud, written in pure bash. Uses `curl` + `jq` against the Bitbucket REST API v2. No Python, Node, or Ruby required.

---

## Install

    git clone <this repo>
    cd bb-cli
    make install
    bb auth login

That's it. `make install` checks deps (auto-installs `jq` via brew if missing), symlinks to `~/.local/bin`, and tells you what to do next. `bb auth login` opens the token page, walks you through scopes, verifies the token, and saves credentials to `~/.config/bb/config` (mode 600).

To uninstall:

```bash
make uninstall
```

---

## Auth

> **Note:** Atlassian app passwords are deprecated as of June 2026. Use scoped API tokens only.

`bb auth login` handles the full setup interactively:

1. Opens `https://id.atlassian.com/manage-profile/security/api-tokens` in your browser.
2. Prompts for your email and the token.
3. Verifies the token against the Bitbucket API (only when run from inside a Bitbucket-hosted repo — we use the workspace slug from `git remote`). Otherwise creds are saved unverified and tested by your first command. This is a constraint imposed by Atlassian's CHANGE-2770 (Feb 2026 API removal).
4. Saves credentials to `~/.config/bb/config` (mode 600).

Required token scopes:
- `read:repository:bitbucket`
- `read:pullrequest:bitbucket`
- `write:pullrequest:bitbucket`

In Atlassian's friendly scope picker UI, these correspond to:
- "Repositories: Read" → `read:repository:bitbucket`
- "Pull requests: Read+Write" → `read:pullrequest:bitbucket` + `write:pullrequest:bitbucket`

Do NOT tick "Account: Read" — that maps to a non-Bitbucket scope and isn't needed.

Credentials are resolved in priority order: environment variables (`BB_EMAIL`, `BB_TOKEN`) win over the config file. This lets you override for a single session without touching the saved config.

---

## Quick start

```bash
# List open PRs in the current repo
bb pr list

# Create a PR from current branch
bb pr create --title "Fix login bug" --body "Fixes the login timeout issue."

# View PR #42
bb pr view 42

# Open PR #42 in your browser
bb pr open 42
```

---

## Command reference

| Command | Description |
|---------|-------------|
| `bb auth login` | Interactive token setup |
| `bb auth status` | Verify current credentials and show user identity |
| `bb auth logout` | Remove saved credentials from `~/.config/bb/config` |
| `bb pr create --title TITLE [--body BODY \| --body-file FILE] [--dest BRANCH] [--draft] [--reviewers user1,user2]` | Open a new pull request |
| `bb pr list [--state open\|merged\|declined\|all] [--json]` | List pull requests |
| `bb pr view <id> [--json]` | Show PR details |
| `bb pr comment <id> (--body BODY \| --body-file FILE)` | Post a comment |
| `bb pr diff <id>` | Show raw diff |
| `bb pr checks <id>` | Show build statuses |
| `bb pr open <id>` | Open PR URL in browser |
| `bb pr merge <id> [--merge\|--squash\|--fast-forward] [--delete-branch] [--message MSG] [--json]` | Merge a pull request |
| `bb pr decline <id> [--json]` | Decline a pull request |
| `bb help` | Show usage |
| `bb version` | Print version |

### Flags

**`bb pr create`**
- `--title` — PR title (required)
- `--body` — PR description (inline)
- `--body-file` — PR description from file
- `--dest` — destination branch (defaults to repo mainbranch from API)
- `--draft` — mark PR as draft
- `--reviewers` — comma-separated Bitbucket usernames

**`bb pr list`**
- `--state` — filter by state: `open` (default), `merged`, `declined`, `all`
- `--json` — print raw API JSON

**`bb pr view`**
- `--json` — print raw API JSON

### Auto-detection

`bb` reads your git remote to determine workspace and repo — no flags needed in 90% of cases:
- `git@bitbucket.org:WORKSPACE/REPO.git`
- `https://user@bitbucket.org/WORKSPACE/REPO.git`

Source branch for `pr create` is detected from `git branch --show-current`. Default destination branch is fetched from the Bitbucket API (not hardcoded to `main`/`master`).

### Colors

State colors in output: open=yellow, merged=green, declined=red, superseded/draft=gray. Set `NO_COLOR=1` to disable, or pipe to a file.

### Pagination

v0.1 shows the first 50 results per state. Full pagination is on the roadmap.

---

## Limitations (v0.1)

- `--mine` filter is not supported — Atlassian removed the cross-workspace `/2.0/user` endpoint (CHANGE-2770, Feb 2026). Use `--author USERNAME` if you need author filtering (planned for v0.2).

---

## Requirements

- `bash` (macOS built-in 3.2+ works)
- `curl` — `brew install curl`
- `jq` — `brew install jq` (auto-installed by `make install` if missing)
- `git`
