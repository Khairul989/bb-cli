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

**Open & inspect PRs**

```bash
bb pr list                                   # open PRs in the current repo
bb pr create --title "Fix login" --fill      # title + body auto-filled from commits
bb pr create --web                           # or just open the compare page in browser
bb pr status                                 # PR(s) for your current branch + approval state
bb pr view 42                                # details
bb pr commits 42                             # commits in the PR
bb pr files 42                               # files changed (+/- per file)
bb pr diff 42                                # raw diff
bb pr checks 42                              # CI build statuses
```

**Review loop**

```bash
bb pr checkout 42                            # check the PR branch out locally
bb pr approve 42                             # approve   (bb pr approve 42 --undo to retract)
bb pr request-changes 42                     # request changes (--undo to retract)
bb pr comment 42 --body "LGTM after nits"
bb pr edit 42 --title "New title"            # edit title/body/dest/reviewers (other fields preserved)
bb pr reviewers 42 --add alice,bob           # manage reviewers on an open PR
bb pr merge 42 --squash --delete-branch
```

**Repos**

```bash
bb repo view                                 # current repo (or: bb repo view workspace/other-repo)
bb repo list myworkspace                     # repos in a workspace
bb repo clone myworkspace/some-repo          # --ssh for the SSH URL
bb repo create new-repo --private --yes      # create (prompts unless --yes)
bb browse                                    # open the repo in your browser
bb browse src/index.ts                       # ...or a specific file on the current branch
```

**Pipelines (CI)**

```bash
bb pipeline list                             # recent pipelines
bb pipeline view 123                         # pipeline #123 + its steps (with step UUIDs)
bb pipeline logs 123 <step_uuid>             # raw log for one step
bb pipeline run --branch main --yes          # trigger a run (prompts unless --yes)
```

**Escape hatch & shell completion**

```bash
bb api GET /user                             # call any Bitbucket API endpoint directly
bb api POST /repositories/ws/repo/... --input body.json
eval "$(bb completion bash)"                 # tab-completion (or: bb completion zsh)
```

---

## Command reference

| Command | Description |
|---------|-------------|
| `bb auth login` | Interactive token setup |
| `bb auth status` | Verify current credentials and show user identity |
| `bb auth logout` | Remove saved credentials from `~/.config/bb/config` |
| `bb pr create --title TITLE [--body BODY \| --body-file FILE] [--dest BRANCH] [--draft] [--reviewers user1,user2] [--fill] [--web]` | Open a new pull request |
| `bb pr list [--state open\|merged\|declined\|all] [--json]` | List pull requests |
| `bb pr view <id> [--json]` | Show PR details |
| `bb pr comment <id> (--body BODY \| --body-file FILE)` | Post a comment |
| `bb pr diff <id>` | Show raw diff |
| `bb pr checks <id>` | Show build statuses |
| `bb pr open <id>` | Open PR URL in browser |
| `bb pr merge <id> [--merge\|--squash\|--fast-forward] [--delete-branch] [--message MSG] [--json]` | Merge a pull request |
| `bb pr decline <id> [--json]` | Decline a pull request |
| `bb pr reviewers <id> [--add user1,user2] [--remove user3] [--set user1,user2]` | Manage reviewers on an existing PR |
| `bb pr approve <id> [--undo] [--json]` | Approve a PR (or remove your approval with `--undo`) |
| `bb pr request-changes <id> [--undo] [--json]` | Request changes on a PR (or remove with `--undo`) |
| `bb pr checkout <id> [--branch NAME]` | Check out the PR source branch locally |
| `bb pr edit <id> [--title T] [--body B \| --body-file F] [--dest BRANCH] [--reviewers user1,user2]` | Edit PR title, description, destination, or reviewers |
| `bb pr status [--json]` | Show open PR(s) for current branch with reviewer approval state |
| `bb pr commits <id> [--json]` | List commits in a pull request |
| `bb pr files <id> [--json]` | List files changed in a pull request |
| `bb api <METHOD> <PATH> [--data JSON \| --input FILE] [--json]` | Call any Bitbucket API endpoint directly |
| `bb repo view [ws/repo] [--json]` | Show repository details (defaults to current repo) |
| `bb repo list [ws] [--json]` | List repositories in a workspace |
| `bb repo clone <ws/repo> [--ssh]` | Clone a repository (HTTPS by default, `--ssh` for SSH URL) |
| `bb repo create <name> [--workspace WS] [--private] [--project KEY] [--description D] [--yes]` | Create a new repository (prompts for confirmation) |
| `bb pipeline list [--json]` | List recent pipelines (newest first) |
| `bb pipeline view <id> [--json]` | Show pipeline details and step list (step UUIDs shown for use with `logs`) |
| `bb pipeline logs <pipeline_id> <step_uuid>` | Fetch raw log output for a pipeline step |
| `bb pipeline run [--branch B] [--pattern CUSTOM] [--yes]` | Trigger a pipeline (prompts for confirmation; `--yes` bypasses) |
| `bb browse [path] [--branch B]` | Open repo (or file path) in browser |
| `bb completion bash\|zsh` | Print shell completion script (source or eval) |
| `bb help` | Show usage |
| `bb version` | Print version |

### Flags

**`bb pr create`**
- `--title` — PR title (required unless `--fill` or `--web`)
- `--body` — PR description (inline)
- `--body-file` — PR description from file
- `--dest` — destination branch (defaults to repo mainbranch from API)
- `--draft` — mark PR as draft
- `--reviewers` — comma-separated Bitbucket usernames
- `--fill` — derive title from latest commit subject; derive body from `git log <dest>..HEAD`
- `--web` — open the Bitbucket compare page in browser instead of creating via API

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

List commands show the first 50 results per state (20 for `pipeline list`). Full pagination is on the roadmap.

---

## Limitations

- `--mine` filter is not supported — Atlassian removed the cross-workspace `/2.0/user` endpoint (CHANGE-2770, Feb 2026). Author filtering via `--author USERNAME` is on the roadmap.
- Inline (diff-anchored) PR comments are not yet supported — `bb pr comment` posts top-level comments only.

---

## Requirements

- `bash` (macOS built-in 3.2+ works)
- `curl` — `brew install curl`
- `jq` — `brew install jq` (auto-installed by `make install` if missing)
- `git`
