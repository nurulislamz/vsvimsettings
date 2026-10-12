# Workmux live verification results

Executed 2026-10-11, approximately 19:04–19:24 BST. **C1–C6 PASS; isolated sidebar interactions PASS. Overall acceptance BLOCKED:** historical Loading could not be reproduced, live monitor failure paths were not exercised, and the originating pane disappeared during execution without confirmed provenance.

Evidence: [live archive](../scripts/e2e_spawn_live_evidence.tar.gz). Archive contains `dispatcher/` case artifacts plus controller assertions, actual native tool inputs/completed events, sidebar captures/context/logs, and cleanup records. No credentials or account configuration copies. No implementation changes, commits, pushes, binary upgrades/patches, real PRs, full 38-case rerun, or real-server restart.

## Context

Launcher-selected box `mohammed`, independently verified by `CODEX_ACCOUNT` and launcher script; box list inspected without repeating selection. No model/effort/service override. Live configured UI showed GPT-6.1-Sol, medium, Fast off.

Real executor dynamically resolved as socket `/tmp/tmux-1000/default`, session `config`, window `@50`, pane `%113`. Exact helper resolved `/home/nurul/.local/state/workmux/tasklogs/config/task.md`; existing T1 was already marked working by the originating monitor, so no duplicate was inserted. Original conversation initially occupied `%93`/`@2` in `review-backend`; its existing sidebar was `%112`.

Owned root `/home/nurul/.cache/e2e-live-lg0r3had`, seed commit `90f7952`; dispatcher socket `ROOT/tmux.sock`. Separate sidebar socket `ROOT/sidebar-fixture/tmux.sock`; state/config/cache isolated. Sidebar repository was a local shared clone of the seed, with no additional commits. All fixture worktrees were under `.worktrees/`.

## Sequential cases

| Case | Result | Acceptance evidence |
|---|---|---|
| C1 | PASS | Native `/root/c1`, fixture cwd/git root, `%0/$0/@0` only; numbered T1 `e2e-spawn-c1-1599427` completed, generated random fact in parent Notes, `c1.ok`. `dispatcher/c1-{task.md,panes.txt}`, `c1.ok`. |
| C2 | PASS | Exact native fork verified parent `01a12c26-e3e1-7830-99b2-900bee067d69` → child `01a12c27-eace-7f83-b30d-b1e17c5c0cae`; registered `%1` in same `$0/@0`, no worktree. T3 `e2e-spawn-c2-1604841` completed; exact C1 fact reused in output/Notes without prompt disclosure. `dispatcher/c2-{fork.txt,status.json,task.md,capture.txt}`, `c2.ok`. |
| C3 | PASS | New worktree/session `%2/$1/@1`, own `.workmux/task.md`, completed T1 `e2e-spawn-c3-1611216`; parent tasklog byte-identical. Path/list/status/capture identify child. `dispatcher/c3-*`, independent byte comparison. |
| C4 | PASS | Review overlay `$2`, nvim `%3/@2`, reviewer `%4/@3`; completed T1 `e2e-spawn-c4-1615379`. REVIEW and Notes identify both subtraction and ignored-name defects; empty app/test diff. `dispatcher/c4-*`. |
| C5 | PASS | Coordinator `%5/$3/@4`, T1 `e2e-spawn-c5-1618827`; exactly one native fixer `/root/c5_fixer`, T2 `e2e-spawn-c5-fixer-1620613`, both completed with Notes. Sole native app.py FileChange belongs to fixer `01a12c2b-831e-7bd1-91c7-94dc56d88265`; coordinator wrote replies/checks/report. Both pytest runs exit 0, two tests pass. `dispatcher/c5-*`, `actual-native-completed-tools.json`, `independent-acceptance-assertions.json`. |
| C6 | PASS, success path | One initially idle worker `%6/$4/@5`, dispatcher monitor only. Exact T1→T2→T3→T4 assignments; all completed with unchanged titles/IDs. T4 appended while T1 visibly working. Pre-send snapshots prove later tasks pending and outputs absent; native completed commands prove working→done transitions. T2 exactly reused T1 Notes; T4 verified earlier completion and ran last. `dispatcher/c6-assignment-T*.txt`, `c6-before-T*`, `c6-T4-appended-during-T1.md`, `c6-native-transitions.json`, `c6-final-task.md`, `c6-outputs/`. |

C6 **live blocked-task, worker failure/crash, and stalled-working branches NOT RUN**. No `[!]` or stalled `[>]` occurred. Guard inspection is not live failure-path coverage. Unattended failure recovery remains unverified despite the success-path PASS.

Tool audit uses actual calls after removing inherited call IDs and native `FileChange`/`CommandExecution` completion records. The dispatcher's `native-tool-targets.json` is a mention index: embedded prompts/audit code can mention `apply_patch` and app.py without performing edits. Use `actual-native-completed-tools.json` and `dispatcher/actual-file-change-events.json` for edit attribution.

## Observed setup failures and recovery

- Sandbox denied the inherited real tmux socket, causing the initial read-only helper call to resolve stale `default`; escalation recovered the actual config context.
- T1 claim initially raced the originating monitor; setup assertion stopped before a duplicate/mutation. Existing working T1 was retained.
- Multiline shell injection left the disposable dispatcher in a quoting prompt; corrected to short launch command reading its prompt file. No child case had started.
- Dispatcher shell initially stripped XDG_STATE_HOME and briefly edited an existing fallback `e2e-dispatcher` tasklog outside the owned root. Its added task/blank line were reverted; case children explicitly exported isolated state before resolving. This is an isolation deviation, not a clean launcher-default isolation pass. The existing fallback file was preserved.
- Detached `workmux open` reported no current client for C3/C6; their created sessions remained live and were inspected without substituting placement.
- C6's seed hook resolved the source pane's parent tasklog; assertion prevented writing. Seed moved to the actual fresh worktree pane before worker assignment. No helper change was justified.
- Initial sidebar registration from short-lived shell commands was reconciled away when the foreground command changed. Replaced with actual idle selected-box agents.
- Controller assertions initially confused agent titles with headers, used a fixed source pane for navigation, and equated a dead socket file with a live server. Corrected checks use header rows, the actual client pane and server query return codes. Original failed probe evidence is retained; final assertions reflect observed output.

## Sidebar checks

| Check | Result | Evidence |
|---|---|---|
| Existing actual-window rendering | PASS now | `%112` and `%114` baseline grouped captures. |
| Temporary actual-window/fresh-window clients | PASS now | Owned `%115` in origin `@2`, `%116` in config `@50`, fresh `@51/%117`; captures after >30 seconds all rendered. `*-after30.txt`, `fresh-after30.txt`. Removed at ~19:09; layouts restored then. |
| Historical Loading cause/recovery | BLOCKED | Symptom absent in baseline and fresh clients; no red reproduction. Historical report only observed Loading after a one-second refresh/scoped restart. Cannot distinguish delayed refresh, stale registration or socket mismatch retrospectively. No evidence supports a code/binary/config fix or a causal recovery claim. |
| Isolated rendering/group ownership | PASS | Two same-project worktrees, four real boxed tracked agents, sessions `sidebar-alpha`/`sidebar-beta`, colliding indexes 0/1. `sidebar-grouped.txt`, `sidebar-initial-status.json`. |
| `none` → `--clear` → explicit `session` | PASS | Actual flat then grouped refresh; isolated config already specifies session. `sidebar-flat.txt`, `sidebar-clear.txt`, CLI history. |
| Session filter/restore | PASS | Only alpha header/rows visible under session filter; both groups restored. `sidebar-filtered.txt`, `sidebar-filter-restored.txt`. |
| Status sorting within groups | PASS | done/waiting/working changes reordered rows within beta while keeping every row in its session. `sidebar-statuses.txt`, `sidebar-statuses.json`. Only configured/default sorting exercised, not every sort mode. |
| next/prev/jump | PASS | Six assertions against the preceding rendered order, using each command's dynamically resolved active client pane; headers skipped. Focus clears done/waiting and can reorder rows. `sidebar-navigation-corrected.json`, `sidebar-navigation-assertions.json`. |
| New-window grouping | PASS | Disposable `@4` created; grouped capture with both headers. `sidebar-new-window-render.txt`. |
| Disposable-server persistence | PASS | Stopped only sidebar fixture server; recreated same socket with same isolated settings, relaunched boxed agent, enabled sidebar without reapplying group. Persisted session preference and actual grouped rendering verified. `sidebar-settings-{before,after}-restart.json`, `sidebar-after-restart-render.txt`. No claim about restarting the real server. |

Logs/context: `real-sidebar-log.txt`, `real-sidebar-historical-log.txt`, `isolated-sidebar-log.txt`, `sidebar-process-context.json`, `real-baseline.json`. Runtime process environment inspection was partial; log instance IDs and tmux pane/socket measurements supply the context evidence.

## Cleanup and real-session preservation

Owned C2 pane and C3–C6 sessions/worktrees/branches removed after snapshots. Sidebar clone worktrees removed; both owned servers stopped; exact root removed and checked absent after shutdown delays. Removed only generated trust tables for exact owned root and sidebar clone repository from the selected account configuration, preserving retained stanza bytes. No unrelated trust/config tables removed. `cleanup-history.json`, `cleanup-assertions.json`, `trust-cleanup.json`.

Real settings remained byte-identical; grouping stayed explicit session. Theme status formats/styles unchanged. Temporary real panes/windows were only `%115`, `%116`, and `@51`; config layout restored and `%113`/`%114` remain live. Real tmux server PID 2012 remained running. All three original real session names remain open. No checkout/worktree/branch change was made to the real configuration repository.

**Origin-pane preservation FAIL / cause unconfirmed:** `%93` and window `@2` disappeared around 19:16, approximately seven minutes after this executor removed its temporary real clients. No executor cleanup command targeted `%93`, `%112` or `@2`. Other unrelated windows also changed during the run. User clarification was requested; no response was received before completion. The originating conversation was not recreated without confirmation. This final-state requirement cannot be claimed PASS. `real-origin-disappearance.json`, baseline/final inventories.

Config task T1 is blocked with a durable Note referencing this report: historical Loading diagnosis, live C6 failure paths, and origin-pane preservation remain unresolved. No additional task was created.
