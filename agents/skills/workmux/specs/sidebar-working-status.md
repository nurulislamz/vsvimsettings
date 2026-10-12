# Spec: sidebar working status for boxed Codex

Status: requirements + regression test.
Owner: workmux skill (`~/.config/agents/skills/workmux`).
Test: `python3 scripts/test_sidebar_working_status.py`

## Problem

A live `codex-box` pane (example: mohammed, title `Fix task log path res…`)
showed workmux sidebar `󰒲` (sleep / stale) while Codex was working.

Workmux `{status_icon}` is the pane's `set-window-status` state, not the
Codex TUI spinner. Null status + `stale_after` (default 1h) renders sleep.

## Cause

1. `codex-box-rename-bridge` sets tmux `@agent_status=working` at launch.
2. `workmux-agent-hook` skipped `workmux set-window-status working` when
   that window flag already matched and the hook payload had no prompt.
   Boxed `PostToolUse` events are usually empty, so pane `status` stayed
   `null` and `activity_ts` never refreshed.
3. `CODEX_BOX_RENAME_SOCKET` lived under `~/.codex-containers/*/tmp`.
   Codex `workspace-write` landlock cannot `connect()` that path
   (`ECONNREFUSED` in `hooks.log`). Stop never reached workmux, so a
   finished pane stayed `working`. `/tmp/codex-box-rename-*.sock` is
   visible to the sandbox.
4. `fullyIdle: false` remapped `done` → `working`. Codex Stop does not
   send `fullyIdle`; a Cursor background-task remap must not override
   `hook_event_name=Stop`.

## Goal

A boxed Codex pane shows a spinner while the turn is running, and
`done` (checkmark) when the turn stops. Sleep/`󰒲` is only for stale
or manually slept rows.

## Requirements

| ID | Requirement | Test |
|---|---|---|
| R1 | `apply_host_event("working", {})` MUST call `workmux set-window-status working` even when `@agent_status` is already `working`. | `test_r1_repeated_working_without_prompt_reaches_workmux` |
| R2 | Bridge start MUST write pane status `working` (`workmux-agent-hook --host working`), not only the window `@agent_status` flag. | Launch-time; not unit-tested (needs a live tmux pane + workmux). |
| R3 | If the rename relay raises `OSError` (including `ECONNREFUSED`), the hook MUST apply the event for `$TMUX_PANE` on the host. A boxed agent with `CODEX_ACCOUNT` set must not no-op. | `test_r3_dead_relay_falls_back_to_host_event` |
| R4 | The rename socket MUST be creatable under `/tmp/codex-box-rename-*.sock` so Codex `workspace-write` can connect. Profile-dir sockets stay allowed. | `test_r4_tmp_relay_socket_is_allowed` |
| R5 | `set-window-status done` with `hook_event_name=Stop` MUST stay `done` even if `background_working` is set. Codex Stop never includes `fullyIdle`; it must not be remapped to working. | `test_r5_codex_stop_stays_done` |

## What the test does

Loads the committed `scripts/workmux-agent-hook` (not a second copy).
Mocks `tmux` and `subprocess.run` so no live multiplexer or workmux
binary is required.

- **R1:** `@agent_status` is already `working`, payload is `{}`. Asserts
  one `set-window-status working` call with `WORKMUX_STATUS_PANE_ID=%7`.
  Regression: the old short-circuit returned 0 without calling workmux.
- **R3:** `CODEX_BOX_RENAME_SOCKET` is set, `send_relay_event` raises
  `ConnectionRefusedError`, `CODEX_ACCOUNT=mohammed`. Asserts the same
  workmux call. Regression: `CODEX_ACCOUNT` used to force `return 0`
  after a failed relay.
- **R4:** `/tmp/codex-box-rename-123.sock` is allowed; a non-matching
  name under the profile tmp dir is not. Regression: the bridge only
  accepted `~/.codex-containers/*/tmp`, which Codex landlock cannot
  `connect()` (ECONNREFUSED). Stop then never reached workmux, so a
  finished pane stayed `working`.
- **R5:** `done` + `hook_event_name=Stop` + `background_working=true`
  still calls `set-window-status done`. Regression: `fullyIdle: false`
  remapped every done event to working.

## Non-goals

- Changing the published workmux binary or `{status_icon}` mapping
- Cleaning leftover `codex-box-rename-*.sock` files
- Inferring status from Codex pane-title spinners
- The older `~/.local/share/workmux-flow/tests/test_task_titles.py`
  launcher probe (host `/tmp` + relay visibility)

## Run

```bash
python3 ~/.config/agents/skills/workmux/scripts/test_sidebar_working_status.py -q
```
