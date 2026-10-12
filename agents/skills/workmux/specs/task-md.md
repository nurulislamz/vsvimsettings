# Spec: workmux `task.md`

Status: requirements (not an implementation plan).
Owner: workmux skill (`~/.config/agents/skills/workmux`).
UI: prefix+t / prefix+. popup. Agents: `TASK_FILE=$(tmux-tasklog path)`.

## Problem

Session notes live outside workmux as `{session}.md` (this session:
`config.md`). Agents treat the file as a private checklist and skip
`## Notes`. Context does not survive a handoff to another agent in the
same worktree. The filename tracks the tmux session, so rename and
worktree isolation both break.

## Goal

One file named `task.md` owns Tasks + Notes. Workmux owns resolve,
init, and open. Agents fill both sections when appropriate. Notes are
the inter-agent bus for durable facts.

Tasks are numbered (`T<n>`) so a monitor can run the backlog
unattended: append work, watch for completion, tell the worker the
next ID.

## Non-goals

- A new `workmux task` subcommand on the published binary
- A notes-append CLI, new Cursor skill, task database, or second notes store
- Cross-worktree shared notes (handoff across trees stays in the
  child prompt)
- Task dependencies, parallel workers on one file, or auto-renumber
- A new workmux wait/watch daemon; the monitor is an agent role
- Live `gh` / real PRs in the e2e prompt
- Deleting historical `{session}.md` files in bulk

## Terms

| Term | Meaning |
|---|---|
| `task.md` | The only notes/tasks file. Never `{session}.md`. |
| Workmux worktree | Path matches `*/.worktrees/*`, or current branch has `branch.<name>.workmux-base`. Do not treat "any workmux-base in the repo" as a match (main checkouts share git config with worktrees). |
| Session fallback | Non-workmux pane: state-dir file, still named `task.md`. |
| Helper | `tmux-tasklog` on PATH. Source of truth under this skill's `scripts/`. |
| Note | One durable fact another agent in the **same** `task.md` needs. |
| Task ID | Stable handle `T<n>` (`n` ≥ 1). Unique in the file. Never reused. Never renumbered. |
| Worker | Agent that executes exactly one assigned Task ID, then waits. |
| Monitor | Agent that does **not** do the work. Reads `task.md`, assigns the next pending ID, tells the worker. |

## Requirements

### R1 — Location

1. Workmux worktree → `<worktree>/.workmux/task.md`.
2. Else → `${XDG_STATE_HOME:-~/.local/state}/workmux/tasklogs/<safe-session>/task.md`.
3. `<safe-session>` is the tmux session name with `'"'` stripped and
   spaces/`/` mapped to `_`.
4. Agents MUST NOT construct either path. Only
   `TASK_FILE=$(tmux-tasklog path)`.
5. `.workmux/task.md` MUST be globally gitignored.

### R2 — Lifecycle

1. `path` and `init` create the file if missing, then `path` prints
   the absolute path only.
2. `open` inits and opens `$EDITOR` (default nvim). No path on stdout.
3. `after-new-session` hook calls `tmux-tasklog init`.
4. Workmux `post_create` calls `tmux-tasklog init` with cwd = worktree
   (pane may not exist yet).
5. Prefix+t and prefix+. MUST open the resolved `task.md` for the
   current pane.
6. First init of a session MAY copy
   `~/.local/state/tmux/tasklogs/<safe-session>.md` onto the new path
   if the destination is missing. MUST NOT delete the old file.

### R3 — Shape

New files MUST contain:

```
# Session: <session>
Worktree: <path>
Branch: <branch|none>
Created: <YYYY-MM-DD HH:MM>

## Tasks

## Notes
```

Existing migrated files keep their body. No extra sections.

Each task is exactly one line under `## Tasks`:

```
- [ ] T1 short title
- [>] T2 short title
- [x] T3 short title
- [!] T4 short title
```

| Mark | Status |
|---|---|
| `[ ]` | pending |
| `[>]` | working (exactly one per worker) |
| `[x]` | done |
| `[!]` | blocked (not done; monitor must not treat as finish) |

1. ID is `T` + integer. Next new ID is `max(existing)+1`, or `T1` if
   none. Inserts and appends MUST NOT renumber older IDs.
2. Title is the rest of the line. No nested lists. No wrapping.
3. Migrated unnumbered `- [ ] foo` lines MAY keep their checkbox
   until an agent next touches that line; new lines MUST be numbered.
   A monitor MUST ignore unnumbered lines (not assignable).

### R4 — Agent behavior

Applies to every agent (dispatcher, in-process child, boxed pane).

1. At task start: resolve, read Tasks **and** Notes.
2. If a monitor assigned an ID: work only that ID. Set `[>]` when
   starting, `[x]` when done, `[!]` if blocked. Do not start another
   ID until told.
3. If no monitor (interactive): append `- [ ] T<n> …` for the current
   work (next free `n`), set `[>]` while doing it, `[x]` when done.
4. Preserve every existing line except the status mark on the
   assigned ID. Do not rewrite titles. Do not reorder.
5. Anyone MAY append new `- [ ] T<n> …` lines (next free `n`) while a
   run is in progress. That is how work is added to an automated run.
6. Notes: read before acting. Append a short fact when a later agent
   on this same file will need it (decision, path, blocker, id,
   marker, what was tried). Newest at the bottom.
7. Notes MUST NOT contain transcripts, secrets, or prompt dumps.
8. Bare "add/create tasks …" with no other domain targets this file
   (append numbered pending lines).
9. Window rename (tmux) stays independent of `task.md`.

### R8 — Monitor and automated runs

One monitor per `task.md`. One worker per `task.md` in v1.

1. Monitor MUST NOT edit `app` / repo files and MUST NOT execute a
   Task ID's work. It only edits `task.md` status if the worker
   failed to set `[>]` on accept (prefer: worker sets `[>]`).
2. Next task = lowest pending `T<n>` (`[ ]`). No other priority.
3. When the worker has no `[>]` line and a pending ID exists,
   monitor tells the worker (same channel it already uses:
   `workmux send`, pane inject, or in-process follow-up) exactly:

   ```
   Do T<n>: <title>
   TASK_FILE=$(tmux-tasklog path). Read Tasks and Notes.
   Mark T<n> [>] now. Mark [x] when done, [!] if blocked.
   Write Notes if the next ID will need a fact. Then stop and wait.
   ```

4. "Finished" = that ID's mark is `[x]`. Then assign the next
   pending ID. `[!]` is not finished: write a Note, do not assign
   that ID again, stop the run (v1 is sequential; no skip).
5. Run starts when a monitor is asked to run this file. Run ends
   when zero `[ ]` and zero `[>]` remain, or on first `[!]`.
6. Mid-run appends of new `T<n>` MUST be picked up on the next
   assign (they get a higher `n`, so they run after current pending).
7. Monitor MUST re-resolve via `tmux-tasklog path` each loop. Do not
   cache a stale path across `workmux rename`.
8. Worker crash / no status change: monitor MUST NOT invent
   completion. Report BLOCKED after a wait budget; leave the `[>]`
   line.

### R5 — Sharing

1. Two agents in the same worktree (or same non-workmux session)
   MUST read/write the same `task.md`.
2. A `workmux add` worktree MUST get its own `task.md`. Markers and
   notes from that child MUST NOT appear in the parent file.
3. Session rename MUST NOT change a worktree file path (worktree-keyed).
   Session-fallback files MAY move with the session name.

### R6 — Helper API

```
tmux-tasklog {init|open|path|--self-check} [session] [worktree]
```

1. Public command name stays `tmux-tasklog` (AGENTS.md + tmux binds).
2. Implementation lives in this skill; `~/.local/bin/tmux-tasklog`
   is a symlink or wrapper.
3. `--self-check` MUST prove session fallback ends in
   `…/workmux/tasklogs/<session>/task.md` and a `*/.worktrees/*` path
   ends in `<root>/.workmux/task.md`.
4. Boxed agent processes MUST NOT inherit a pre-set `TASK_FILE`.

### R7 — E2E prompt (not a runner)

One paste-ready prompt. Dispatcher only: spawn, assert, report.
Disposable fixture under `~/.cache`. No commits on real repos.

Gate (stop if unmet): list boxes and ask; do not invent
model/effort/`fast`; Cursor children = `generalPurpose` +
`grok-4.7-medium` or `composer-2.5-fast` only.

Cases (in order, no overlap):

| ID | Placement | Extra assert |
|---|---|---|
| C1 | In-process Task, same worktree | Marker + Notes fact in **parent** task.md; no new pane |
| C2 | Same session+window split/fork | Child **reads** C1 Notes fact; writes its own; `workmux status` lists pane |
| C3 | `workmux add` new session | Own worktree task.md; parent file unchanged; `path`/`list`/`status`/`capture` work |
| C4 | Review overlay | Finds both planted bugs; Notes + REVIEW.md; does not edit `app.py` |
| C5 | Orchestrator (fixture CI + comments, no `gh`) | Spawns one fixer; orchestrator does not patch `app.py`; both use task.md |
| C6 | Monitor loop on one worker | Backlog `T1`–`T3` numbered; monitor assigns T1 then T2 then T3; mid-run append of `T4` is executed last; worker never self-picks the next ID |

Pass = correct `task.md` **and** placement assert. Wrong file is fail.
Final output: 6-row PASS/FAIL table + cleanup. BLOCKED if no box /
no Codex session id; continue.

## Acceptance

- Helper `--self-check` exits 0.
- Prefix+t in this session opens a file named `task.md`.
- Prefix+t in a workmux worktree opens that tree's `.workmux/task.md`.
- An agent that only gets AGENTS.md + SKILL.md writes numbered Tasks
  and Notes without being told the path.
- C2 fails if the child ignores Notes and invents the C1 secret.
- C3 fails if the child marker lands in the parent task.md.
- C6 fails if the worker starts T2 before the monitor sends T2, or
  if mid-run `T4` is skipped, or if IDs are renumbered.
- No `task.md` in `git status` of a normal repo.
- A monitor can complete a 3-item backlog using only `task.md` +
  `workmux send` / in-process follow-up (no second notes file).

## File plan (when implementing)

Only these may change:

- `~/.config/agents/skills/workmux/scripts/tmux-tasklog`
- `~/.local/bin/tmux-tasklog` (symlink)
- `~/.config/agents/AGENTS.md` (session task tracking)
- `~/.config/agents/skills/workmux/SKILL.md` (short pointer here)
- `~/.config/workmux/config.yaml` (`post_create`)
- `~/.config/git/ignore` (`.workmux/task.md`)
- `~/.config/agents/skills/workmux/scripts/e2e_tasklog.py`
- `~/.config/agents/skills/workmux/scripts/e2e_spawn_prompt.md` (path wording)
- `~/.config/agents/skills/workmux/scripts/e2e_workmux_prompt.md` (R7)
- `~/vsvimsettings/tmux/.tmux.conf.local` (binds/hook only if the
  command name changes — it must not)

## Open

- Parallel workers on one `task.md` (more than one `[>]`) — out of
  v1; do not implement.
- Optional C3 extra (`--mode window --parent-session`) is not
  required for accept.
