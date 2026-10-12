# Workmux tasklog E2E regression

Test: [scripts/e2e_tasklog.py](../scripts/e2e_tasklog.py).

## Requirement

Every boxed agent must resolve its session tasklog with
`TASK_FILE=$(tmux-tasklog path)`, read it, and preserve existing checklist
items when adding or completing a task. This must work in the first pane
of a new workmux session with `TASK_FILE` absent from the agent's environment.
Agents must resolve the path again on subsequent tasks, even when tmux has
set a session environment variable. Sanitizing the full path is forbidden.

The test uses the installed helper's path, so it supports the current
`<worktree>/.workmux/task.md` layout without constructing a log filename.
The disposable repository contains no `AGENTS.md` or `CLAUDE.md`; agents read
the machine's global instructions at `~/.config/agents/AGENTS.md`.

## Coverage

| Requirement | Case and assertion |
|---|---|
| First-pane discovery works without inherited `TASK_FILE`. | Case 1 launches a boxed agent using `workmux add -b -P`. Its session log must contain exactly one unique checklist marker. |
| Each tool resolves its own session log. | Case 2a creates one shell/worktree/session per configured tool, then launches that boxed CLI. Each log must contain only that tool's marker. |
| All panes share the session log and call the helper independently. | Case 2b launches the configured tools in separate panes of one worktree/session. The shared log must contain every tool's marker exactly once. |
| Progress survives five sequential tasks. | Case 3 sends T1–T5 individually using `workmux send`. Each task appends an unchecked marker, sleeps one second, then checks it off. Polling must observe the unchecked state and then all previous and current markers checked, without drops or duplicates. |
| Evidence comes from the agent and the file. | A PATH shim records each pane's `tmux-tasklog path` calls and delegates unchanged to the installed helper. The harness reads the actual boxed process's `/proc/.../environ` to assert `TASK_FILE` is unset. Parent environment values and tmux's session environment are never proof of agent resolution. |
| Logs stay isolated. | The isolated root log must remain free of test markers. Every case checks exact marker sets, rejects `_home_*tasklogs*.md` garbage files within the fixture, and checks worktree git status. |
| Runs are disposable and bounded. | Each step has a timeout. A `finally` block removes workmux handles, kills the isolated tmux server, and deletes the fixture and state; SIGTERM also triggers teardown. A failed step stops the run before subsequent tasks are sent. |

## Regression being prevented

Cursor previously received T1 and T2 concatenated in its composer and
repeated T1. File completion could precede the CLI becoming idle, and a
completed spinner could remain onscreen until redraw. The harness now waits
for readiness, redraws stale output, clears the entire draft with Ctrl+A /
Ctrl+K, and sends each single-line prompt using bracketed paste through
`workmux send`. It submits again only when the current marker remains in an
idle draft and no new helper call has occurred. No-op prompts prescribe one
shell append; sequential prompts prescribe append → sleep → check off.

The `--self-check` mode exercises the same checklist validator and readiness
parser used by the live test. It rejects duplicate, missing, unexpected, and
incomplete markers, rejects active spinners, and accepts ordinary assistant
text beginning with “Running” as idle when the composer is ready. Live tests
are required to verify input delivery and real helper/file behavior; the
self-check alone does not establish those requirements.

## Run

From `~/.config/agents`, without accounts or a live tmux session:

```bash
python3 skills/workmux/scripts/e2e_tasklog.py --self-check
```

List boxes using `cursor-box list`, `codex-box list`, `agy-box list`, and
`opencode-box list`. Select authenticated boxes explicitly, then run:

```bash
E2E_CURSOR_BOX=<authenticated-cursor-box> \
E2E_CODEX_BOX=<authenticated-codex-box> \
E2E_AGY_BOX=<authenticated-agy-box> \
E2E_OPENCODE_BOX=<authenticated-opencode-box> \
E2E_TIMEOUT=180 \
python3 -u skills/workmux/scripts/e2e_tasklog.py
```

Replace the placeholders before running. An unset box, missing wrapper, or
unauthenticated box skips that tool. With no configured tools, the live
matrix reports SKIP and exits successfully; that is not live coverage.
`E2E_TIMEOUT` defaults to 120 seconds per step. Run Python without `-O`,
because the checks use assertions.

Prerequisites: Linux `/proc`, git, tmux, workmux, the installed
`~/.local/bin/tmux-tasklog`, and the selected boxed CLIs. The harness creates
a throwaway git repository under `~/.cache` because OpenCode hides host
`/tmp`. Worktrees live under that repository's `.worktrees/`; the tmux socket,
helper audit, and `XDG_STATE_HOME` are inside the same disposable fixture.
No bare agent CLI is launched. Agent prompts prohibit repo edits and other
agents. Models use inexpensive/low-effort settings where supported; Codex
startup update checks are disabled.

All four configured tools yield 14 marker checks: one first-pane check,
four isolated checks, four shared-pane checks, and five sequential checks.
Case 1 and Case 3 use the first available tool, preferring Cursor. Success
requires `PASS all configured cases` and `CLEANUP`; any assertion or timeout
exits nonzero. TUI captures control startup dialogs and readiness only;
success is determined by tasklog polling and the helper audit.

## Verification and limits

The repaired harness passed all 14 live checks with Cursor, Codex, Agy, and
OpenCode configured. All five sequential tasks showed pending progress,
called the helper separately, and completed without duplicate markers.
Cursor's saved user messages were also checked to confirm five separate
prompts, each containing only its own task marker. Disposable fixtures were
removed.

Sequential coverage was exercised on Cursor. Its readiness parser depends
on the current CLI footer labels; update the parser and captured self-check
fixtures if those labels change. Box authentication and supported model IDs
must be available on the machine running the live matrix.
