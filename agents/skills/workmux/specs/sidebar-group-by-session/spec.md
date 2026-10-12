# Feature Specification: Sidebar grouped by worktree/session

**Feature Branch**: `n/a` (dotfiles / workmux skill, no feature branch)
**Created**: 2026-10-11
**Status**: Draft
**Owner**: workmux skill (`~/.config/agents/skills/workmux`)
**Input**: Sidebar should be organised by worktree/session.

## Problem

The left workmux sidebar is a flat recency list. Agents from different
tmux sessions (each session = one worktree on this machine) interleave.
Window indexes collide (`1` and `2` from different sessions sit next to
each other), so the compact row `{window_index} │ {pane_title}` is
ambiguous.

Live capture (`tmux capture-pane` on a sidebar pane, 2026-10-11):

```
 ⠋⠙ 2 │ Worktree Session Plan…     # "config
    2 │ Execute e2e spawn pla…     # "config
 󰄴  1 │ agy --dangerously-ski…     # improve-frontend-stuff
 󰒲  2 │ Agent Feature Test -…      # "config
 󰒲  1 │ nvim                       # review-backend
```

No group headers. Three sessions, one blob.

`~/.config/workmux/config.yaml` already has `sidebar.group_by: session`.
`~/.local/state/workmux/settings.json` has `"sidebar_group_by": "none"`.
Workmux persists the last `t` / `workmux sidebar group` choice and that
runtime value overrides config until `workmux sidebar group --clear`.

## Goal

One labeled section per worktree/session. A row never leaves its
section. `next` / `prev` / `jump` follow that grouped order.

On this machine (`mode: session`) worktree ≡ tmux session. `group_by:
session` is the grouping mode. There is no `group_by: worktree` in
workmux 0.1.271.

## User Scenarios & Testing

### User Story 1 — Scan by worktree (Priority: P1)

An operator with several session-mode worktrees open looks at the left
sidebar and sees one header per session, then only that session's
agent rows.

**Why this priority**: This is the reported defect. Flat recency is the
thing to stop.

**Independent Test**: With ≥2 live tmux sessions that each have a
tracked agent, enable the sidebar and capture a pane. Headers must
match `tmux list-sessions` (one header per session that has a visible
agent). No agent row may sit under another session's header.

**Acceptance Scenarios**:

1. **Given** sessions `"config`, `improve-frontend-stuff`, and
   `review-backend` each have ≥1 sidebar row, **When** the sidebar
   renders, **Then** there are three group headers and every row sits
   under its own session.
2. **Given** two sessions both have a window index `1`, **When** the
   sidebar is grouped, **Then** both `1` rows remain, each under its
   own header (indexes are not unique globally and MUST NOT be used as
   a group key).
3. **Given** `sidebar.layout: compact`, **When** grouping is on,
   **Then** rows keep the compact template
   `{status_icon} {window_index} │ {pane_title}` and headers use
   `{group} {fill} {group_count}`.

### User Story 2 — Config is machine policy (Priority: P1)

`sidebar.group_by: session` in `~/.config/workmux/config.yaml` is the
intended default. A leftover runtime `none` must not silently flatten
the sidebar after a restart.

**Why this priority**: Config already states the requirement; the
override is why it is not visible.

**Independent Test**: Read `settings.json` `sidebar_group_by` and the
live sidebar. After the fix, either the setting is `session` or it is
cleared (`null` / missing) so config applies. Capture still shows
headers.

**Acceptance Scenarios**:

1. **Given** config `group_by: session` and settings
   `sidebar_group_by: none`, **When** the operator restores grouping,
   **Then** every sidebar pane shows session headers without editing
   the published workmux binary.
2. **Given** the operator runs `workmux sidebar group --clear`,
   **When** the daemon refreshes, **Then** grouping follows
   `config.yaml` (`session`).
3. **Given** the operator runs `workmux sidebar group session`,
   **When** tmux is restarted, **Then** grouping is still `session`
   (persisted runtime value).

### User Story 3 — Explicit flatten only (Priority: P2)

Flattening (`t`, `workmux sidebar group`, `workmux sidebar group none`)
stays available. It is a conscious override, not the default, and
`--clear` returns to config.

**Why this priority**: Workmux already has this CLI. Do not remove it.
Do not invent a lock.

**Independent Test**: `workmux sidebar group none` then `--clear`.
Capture goes flat, then grouped again.

**Acceptance Scenarios**:

1. **Given** grouped sidebars, **When** `workmux sidebar group none`
   runs, **Then** headers disappear (current workmux behavior).
2. **Given** a runtime override, **When** `workmux sidebar group
   --clear` runs, **Then** config `session` applies again.

### Edge Cases

- Session with no tracked agent: no header (empty groups are omitted).
- Session filter (`f` / `workmux sidebar filter session`): only the
  current session's header + rows. Still grouped, not a second flat
  list.
- All-stale group: `collapse_stale` (workmux default true) may fold
  that group under a `STALE` rule. Header still exists.
- Non-workmux session (`"config`): still a group. Header is the tmux
  session name, including any nerd-font prefix (` …`).
- Top-bar sidebar (`position: top`): headers are not drawn; grouping
  only orders chips. This machine uses left + compact. Out of scope
  to change position.
- Same project, two worktrees (`jobby` × `improve-frontend-stuff` and
  `review-backend`): MUST be two groups. `group_by: project` is wrong
  here.

## Requirements

### Functional Requirements

- **FR-001**: The left sidebar MUST render one section per tmux
  session that has at least one visible agent row.
- **FR-002**: On this machine, grouping mode MUST be `session`
  (`workmux sidebar group` accepts `session` | `project` | `none`).
  MUST NOT use `project` (collapses sibling worktrees) or `none`.
- **FR-003**: `~/.config/workmux/config.yaml` MUST keep
  `sidebar.group_by: session` and a `templates.grouped.header`.
- **FR-004**: After the fix, `~/.local/state/workmux/settings.json`
  `sidebar_group_by` MUST be `"session"` or cleared so config applies.
  It MUST NOT remain `"none"`.
- **FR-005**: Sort (`recency` / `priority` / `window`) MUST apply
  inside a group only. A row MUST NOT move to another group when its
  status changes.
- **FR-006**: `workmux sidebar next|prev|jump` MUST use the grouped
  order (headers are not jump targets; workmux already skips them).
- **FR-007**: Compact row template MUST stay
  `{status_icon} #[bold]{window_index}#[default] #[fg=cyan]│#[default] {pane_title}`.
  Do not change `window-status-format` or Catppuccin tab theme.
- **FR-008**: Agents and hooks MUST NOT toggle grouping unless the
  user asked. SKILL.md MUST state the machine policy.

### Key Entities

- **Session / worktree**: In `mode: session`, one tmux session per
  worktree handle. Group key = tmux `session_name`.
- **Group header**: Non-selectable row. Tokens: `{group}`,
  `{group_count}`, `{fill}`. `{group}` is the session name.
- **Agent row**: One tracked pane. Belongs to exactly one session.
- **Runtime override**: `settings.json` `sidebar_group_by`. Wins over
  config until `--clear`.

## Success Criteria

- **SC-001**: A sidebar capture contains exactly one header line per
  session that has a visible agent, and zero agent rows between the
  wrong headers.
- **SC-002**: Two worktrees of the same git project appear as two
  sections.
- **SC-003**: Restoring grouping does not require a workmux upgrade,
  a new binary flag, or a new `group_by: worktree` mode.
- **SC-004**: After restore, a new tmux window still shows grouped
  sidebars (runtime or config still `session`).
- **SC-005**: Window-index collisions across sessions remain
  readable because the header names the session.

## Assumptions

- Workmux 0.1.271 sidebar grouping is correct once mode is `session`.
- This machine stays `mode: session`. Window-mode grouping is out of
  scope (session grouping would then mix worktrees).
- Header text is the raw session name (nerd-font prefix included).
- No change to the published workmux crate.

## Non-goals

- Adding `group_by: worktree` to workmux
- Changing the workmux binary, daemon, or `{status_icon}` map
- Dashboard sort/group (different surface)
- Forcing grouping (lock / disable `t`)
- Renaming the `"config` session
- Cleaning stale `codex-box-rename-*.sock` or status-icon bugs
  (see `../sidebar-working-status.md`)
