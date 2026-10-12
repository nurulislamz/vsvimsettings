# Implementation Plan: Sidebar grouped by worktree/session

**Branch**: n/a | **Date**: 2026-10-11 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/sidebar-group-by-session/spec.md`

## Summary

Workmux already groups the sidebar by session. Config already asks for
it. A persisted runtime override (`settings.json` →
`sidebar_group_by: "none"`) flattens every pane.

Fix = put grouping back to `session` (or `--clear` so config wins),
confirm a live capture, and write the policy in the workmux skill so
agents do not toggle `t` / `workmux sidebar group` unasked.

No new code in the workmux binary. No new `group_by` mode.

## Technical Context

**Language/Version**: n/a (CLI + YAML + JSON settings)
**Primary Dependencies**: workmux 0.1.271, tmux
**Storage**: `~/.config/workmux/config.yaml`,
`~/.local/state/workmux/settings.json`
**Testing**: live `tmux capture-pane` + `workmux sidebar group --help`
**Target Platform**: this machine (WSL2, tmux, session-mode worktrees)
**Project Type**: operator config / skill docs
**Constraints**: do not change `window-status-format` or tab theme;
do not patch the published workmux crate
**Scale/Scope**: 3 sessions today; any future session-mode worktree

## Constitution Check

AGENTS.md (lazy senior) / this skill:

| Gate | Result |
|---|---|
| Does it need to exist? | Yes — sidebar is flat against stated policy |
| Already in the product? | Yes — `group_by: session`, `sidebar group` |
| Smallest complete change? | One CLI restore + skill sentence |
| New binary / wrapper / lock? | No |
| New tests for non-trivial logic? | No new logic. Verify by capture |

Re-check after implement: still no workmux source edits.

## Project Structure

```text
~/.config/workmux/config.yaml                 # already group_by: session
~/.local/state/workmux/settings.json          # sidebar_group_by override
~/.config/agents/skills/workmux/SKILL.md      # policy for agents
~/.config/agents/skills/workmux/specs/sidebar-group-by-session/
├── spec.md
└── plan.md
```

No `src/`, contracts, or data-model. Not a new app.

**Structure Decision**: keep the existing skill + global config. Do not
add a helper script that wraps `workmux sidebar group`.

## Complexity Tracking

None. No constitution violations.

## Research (Phase 0)

- Docs: https://workmux.raine.dev/guide/sidebar/ — grouping modes are
  `project` | `session`; unset / `none` is a flat list. `t` and
  `workmux sidebar group` persist and override config until `--clear`.
- `workmux sidebar group --help` (0.1.271): modes
  `none`/`off`, `project`, `session`; `--clear` drops the override.
- Config already documents the intent:
  `sidebar.group_by: session` + `templates.grouped.header`.
- `group_by: project` is wrong here: `jobby` has two worktrees.
- There is no `group_by: worktree`. Session mode makes session the
  worktree key.

## Implementation

### Phase 1 — Restore grouping (does the job)

```bash
workmux sidebar group session
# or, to follow config.yaml with no runtime pin:
# workmux sidebar group --clear
```

Prefer `session` (explicit pin) so a later config typo cannot flatten
the list. `--clear` is enough if we want config as the only source.

Do **not** hand-edit `settings.json` while the daemon is up.

### Phase 2 — Verify

```bash
python3 -c 'import json; print(json.load(open("/home/nurul/.local/state/workmux/settings.json")).get("sidebar_group_by"))'
tmux list-sessions -F '#{session_name}'
tmux capture-pane -t "$(tmux list-panes -a -F '#{pane_id} #{pane_width} #{pane_current_command}' | awk '$2<=50 && $3=="workmux"{print $1; exit}')" -p
```

Pass: `sidebar_group_by` is `session` (or null after `--clear`);
capture has one header per session that has rows; compact rows
unchanged.

### Phase 3 — Skill policy (FR-008)

In `SKILL.md`, under This machine / sidebar, one short block:

- Sidebar MUST stay `group_by: session` (worktree ≡ session).
- Do not run `workmux sidebar group` or rely on `t` unless the user
  asked. Restore with `workmux sidebar group session`.

No new Cursor rule file. Skill is enough.

### Phase 4 — Optional only if Phase 1 fails

If headers still missing after `session` and a sidebar restart
(`workmux sidebar off && workmux sidebar on`):

1. Confirm daemon picked up settings (re-read `settings.json`).
2. Confirm not filtered to one session (`sidebar filter`).
3. Stop. Do not add a worktree grouping patch to workmux.

## Tasks

- [ ] T1. `workmux sidebar group session` (or `--clear`)
- [ ] T2. Confirm `settings.json` and a sidebar capture (SC-001, SC-002)
- [ ] T3. Add the one-block policy to `SKILL.md` (FR-008)

T3 is the only file edit. T1–T2 are operator commands.

## Risks

- Pressing `t` in the sidebar pane will flatten again and persist.
  Skill text is the mitigation; no lock.
- Session headers include nerd-font prefixes (``). Cosmetic only.
- `--clear` vs `session`: `--clear` dies if someone later deletes
  `group_by` from config. Pinning `session` is safer on this machine.
