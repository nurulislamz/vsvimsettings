# Plan: fix Codex R2 (same window fork)

Date: 2026-10-11\
Spec: [e2e_spawn_plan.md](e2e_spawn_plan.md) AC2.1–2.5\
Harness: `/tmp/e2e-codex-leftover.py` `run_r2`\
Helper: `scripts/fork_codex_pane.py`\
Evidence: `e2e_spawn_luna_evidence.tar.gz` (R2-*-screen.txt)

Do not pin model/effort in `~/.config/workmux/config.yaml`.
nurulz default stays `gpt-6-luna`; mohammed stays `gpt-6.1-sol`.

## Problem

R2 is not a Sol/`hooks.json` failure. Boxed Codex reaches
`Ask Codex to do anything`. The leftover driver never obtains a parent
conversation UUID, so it never calls `fork_codex_pane.py`.

Luna retest (fixture `e2e-spawn-2v61`, 11:30–11:33): **FAIL no parent
session id**. No `rollout-*.jsonl` exists in that window. Jsonl only
appears for R3–R5, which pass a prompt on argv.

## Why

AC2.1 for Codex is `fork_codex_pane.py --direction below`. That helper
requires a parent UUID (`CODEX_THREAD_ID` / `CODEX_SESSION_ID` /
`--session-id`) and exactly one matching transcript under
`~/.codex-containers/<box>/.codex/sessions/`.

The leftover dispatcher is a **host shell** on an isolated tmux socket,
not a live Codex chat. The stand-in was:

1. `split-window` + idle `codex-box <box> --no-daemon` (no prompt)
2. Wait for composer text
3. Scrape newest jsonl with first line `type=session_meta`

Codex CLI 0.162 does **not** flush `session_meta` until the first turn.
An empty composer is not a conversation. Scrape stays empty for 90s.

When a fork *did* run on an earlier attempt:

- mohammed child died: `thread history projection … is behind durable rollout`
- nurulz: helper 30s timeout while folder-trust / update dialogs blocked
  new jsonl (`forked_from_id`)

Those are the second failure class, after an id exists.

## Non-goals

- Relax AC2.1 to “Else: split-window + boxed” (that is R3-shaped; does
  not prove fork)
- Change Codex CLI / app-server
- Pin models in workmux config
- Full 38-case rerun, live gh/PR, R1 AC1.1 (`Task` vs `Subagent`)
- Treat a host-shell split as a Codex parent

## Rejected

| Option | Why not |
|---|---|
| Else-branch split + boxed pane command | Passes placement without `fork_codex_pane.py` |
| Parse TUI for a UUID | No id on screen for an idle composer |
| Patch Codex to write jsonl on TUI start | Out of scope; not our binary |
| `codex exec` as the R2 child | Not a same-window fork |

## Fix (smallest)

Make the parent a real conversation, then fork it. Change only leftover
`run_r2` (and dismiss rules already in that driver). Do not change
`fork_codex_pane.py` unless a second run still dies on projection-behind
after a settled parent jsonl.

### 1. Seed the parent (flush `session_meta`)

Launch boxed Codex in the dispatcher window with **one first turn**,
same flags as R3 (`-a never`, `--no-daemon`,
`-c check_for_update_on_startup=false`). Seed prompt must not do R2
work, e.g. `Reply with the single word ping and wait.`

Wait until a jsonl exists whose `payload.cwd` is `$ROOT` and
`payload.id` is a UUID, created after `t0`. Require first line
`type=session_meta`. Do not proceed on composer text alone.

If size is still growing, wait until mtime/size is stable for ~1s
(avoids forking mid-write → projection-behind).

### 2. Fork from the isolated mux

```
TMUX=<isolated-socket>,<pid>,0
TMUX_PANE=<parent pane>
CODEX_ACCOUNT=<box>
python3 …/fork_codex_pane.py --direction below --session-id <id>
```

Host-side helper is correct: it launches `codex-box <box> fork --no-daemon <id>`.
Nested same-inode `hooks.json` skip already lives in `codex-box`.

### 3. Child dialogs, then R2 prompt

Dismiss only while the dialog is on screen:

- folder trust → `1` + Enter
- hook-trust → `2` + Enter (already hashed on nurulz)
- update → Esc

Do not send `n`/`1`/`3` into an idle composer.

Once composer is idle (no dialog), inject the R2 child prompt
(`c2.ok` + marker). Prefer `workmux send` if the pane is registered;
else one `send-keys` + Enter.

### 4. Pass / fail (do not paper over)

PASS only if all of AC2.1–2.5 hold:

- helper returned a pane with `forked_from_id` == parent
- same `#{session_id}` and `#{window_id}` as dispatcher
- no new `.worktrees/` entry
- `workmux status --all --json` lists the child pane
- `$ROOT/c2.ok` + checked marker

FAIL and keep the pane capture if:

- no jsonl after seed (parent never became a conversation)
- fork helper errors (startup same-file, projection-behind, 30s
  metadata timeout, ChatGPT model 400)
- child does the work but in a new session/window/worktree

Record rows in `e2e_spawn_results.md`. Do not mark PASS on composer-up
alone.

### 5. Only if projection-behind reproduces

After a stable parent jsonl, if `codex fork` still dies with
`thread history projection … behind durable rollout`:

1. Confirm parent jsonl finished writing (stable size).
2. Wait longer (few seconds), retry once.
3. If still failing: that is a Codex fork bug on 0.162 — record FAIL
   with the error; do not switch R2 to split-window.

Do not run `codex migrate-rollouts` on live boxes from the harness.

## Verify

Codex-only R2 for **mohammed** and **nurulz** on a fresh
`~/.cache/e2e-spawn-*`, isolated tmux `-f /dev/null`. `workmux add`
stays unused for R2. Fixture deleted in `finally`.

One self-check on the seed→jsonl wait (assert a temp rollout with
`session_meta` is found; idle TUI is not). Existing
`test_codex_box_hooks_sync.py` stays as-is.

## Done when

- Plan executed: leftover `run_r2` seeds a turn, forks with
  `--session-id`, judges AC2.1–2.5
- New leftover rows recorded; remaining FAILs quoted, not skipped
- R1 AC1.1 still untouched unless the user decides Task vs Subagent
