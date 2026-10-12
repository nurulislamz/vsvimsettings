# Workmux spawn E2E checkpoint

Selected matrix complete. 29 PASS, 9 FAIL, 0 pending. Preliminary unauthenticated boxes and retired harness attempts are excluded.

| Requirement | Tool / box | Result | Evidence |
|---|---|---|---|
| R1 | cursor / nurulz | FAIL | Placement and marker passed, but native call audit shows cursor.Subagent, not the exact cursor.Task required by AC1.1. generalPurpose/composer-2.5-fast; $0 @0 %0; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl |
| R1 | cursor / physics | PASS | Native Task 38c2688c-70d8-41db-be5f-5a13566253a5 composer-2.5-fast; unchanged $0 @0 %0; cwd/toplevel=/home/nurul/.cache/e2e-spawn-wt_s0azl; e2e-spawn-c1-944664 checked. |
| R2 | cursor / nurulz | PASS | $0 @0 %1; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-948766; tracked=True; c2.ok=True |
| R2 | cursor / physics | PASS | $0 @0 %2; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-950704; tracked=True; c2.ok=True |
| R2 | agy / chaos | PASS | $0 @0 %3; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-950705; tracked=True; c2.ok=True |
| R2 | agy / mohammed | PASS | $0 @0 %4; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-950706; tracked=True; c2.ok=True |
| R2 | agy / nurulz | PASS | $0 @0 %5; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-950707; tracked=True; c2.ok=True |
| R2 | agy / physics | PASS | $0 @0 %6; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-950708; tracked=True; c2.ok=True |
| R2 | omp / default | PASS | $0 @0 %7; cwd=/home/nurul/.cache/e2e-spawn-wt_s0azl; marker=e2e-spawn-c2-950709; tracked=True; c2.ok=True |
| R2 | codex / mohammed | FAIL | Boxed dispatcher startup failed before session creation: cp reports hooks.json source and destination are the same file; no child. |
| R2 | codex / nurulz | FAIL | Fork failed: Timed out waiting for verified native fork metadata; pane %8 has been kept for inspection; panes=['%8']; startup hook dialog blocked native metadata; parent also reported gpt-6.1-sol unsupported for ChatGPT account. |
| R3 | cursor / nurulz | PASS | $1 @1 %9; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-cursor-nurulz; marker=e2e-spawn-c3-955086; tracked=True; c3.ok=True |
| R3 | cursor / physics | PASS | $2 @2 %10; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-cursor-physics; marker=e2e-spawn-c3-955087; tracked=True; c3.ok=True |
| R3 | codex / mohammed | FAIL | $3 @3 %11; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-codex-mohammed; marker=e2e-spawn-c3-955088; tracked=False; c3.ok=False; check_for_update_on<br>_startup=false' -a never -s workspace-write --add-dir /home/nurul/.cache/e2e-spa<br>wn-wt_s0azl -c 'shell_environment_policy.inherit=all' 'You are the assigned chil<br>d for R3. Work only in your current fixture tree. Do not spawn agents, commit, p<br>ush, merge, use gh, or edit app.py. In ONE shell resolve exactly TASK_FILE=$(tmu<br>x-tasklog path), read it, append exactly one - [ ] e2e-spawn-c3-955088 line, cre<br>ate c3.ok containing your cwd, git rev-parse --show-toplevel, and tmux display-m<br>essage -p -t "$TMUX_PANE" '"'#{session_id} #{window_id} #{pane_id}', then check<br>off that marker. Preserve other task entries. Stop." -- "$(cat .workmux/PROMPT-e<br>2e-spawn-c3-codex-mohammed.md)"<br> ~/.ca/e2e-spawn-wt_s0azl/.w/e2e-spawn-c3-codex-mohammed  e2e-spawn-c3-codex-m<br>ohammed<br>❯  exec env -u TASK_FILE -u CODEX_THREAD_ID -u CODEX_SESSION_ID -u CODEX_ACCOUNT<br> -u CODEX_BOX_RENAME_SOCKET codex-box mohammed --no-daemon -c 'check_for_update_<br>on_startup=false' -a never -s workspace-write --add-dir /home/nurul/.cache/e2e-s<br>pawn-wt_s0azl -c 'shell_environment_policy.inherit=all' 'You are the assigned ch<br>ild for R3. Work only in your current fixture tree. Do not spawn agents, commit,<br> push, merge, use gh, or edit app.py. In ONE shell resolve exactly TASK_FILE=$(t<br>mux-tasklog path), read it, append exactly one - [ ] e2e-spawn-c3-955088 line, c<br>reate c3.ok containing your cwd, git rev-parse --show-toplevel, and tmux display<br>-message -p -t "$TMUX_PANE" '"'#{session_id} #{window_id} #{pane_id}', then chec<br>k off that marker. Preserve other task entries. Stop." -- "$(cat .workmux/PROMPT<br>-e2e-spawn-c3-codex-mohammed.md)"<br>cp: '/home/nurul/.codex/hooks.json' and '/home/nurul/.codex-containers/mohammed/<br>.codex/hooks.json' are the same file<br><br>Pane is dead (status 1, Sun Oct 11 01:07:49 2026) |
| R3 | codex / nurulz | FAIL | $4 @4 %12; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-codex-nurulz; marker=e2e-spawn-c3-955089; tracked=False; c3.ok=False; oks can run outside the sandbox after you trust them.<br><br><br>› 1. Review hooks<br>  2. Trust all and continue<br>  3. Continue without trusting (hooks won't run)<br><br>  enter confirm · esc skip<br><br>  >_ OpenAI Codex (v0.162.0)<br>     ~/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-codex-nurulz<br><br><br>› Ask Codex to do anything<br><br>  gpt-6.1-sol default · ~/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-cod…<br><br><br>  >_ OpenAI Codex (v0.162.0)<br>     ~/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-codex-nurulz<br><br>  Tip: Use /archive to archive the current session.<br><br><br>› You are the assigned child for R3. Work only in your current fixture tree. Do<br>  not spawn agents, commit, push, merge, use gh, or edit app.py. In ONE shell<br>  resolve exactly TASK_FILE=$(tmux-tasklog path), read it, append exactly one -<br>  [ ] e2e-spawn-c3-955089 line, create c3.ok containing your cwd, git rev-parse<br>  --show-toplevel, and tmux display-message -p -t "$TMUX_PANE" '#{session_id}<br>  #{window_id} #{pane_id}', then check off that marker. Preserve other task<br>  entries. Stop.<br><br><br>■ {"type":"error","status":400,"error":<br>{"type":"invalid_request_error","message":"The 'gpt-6.1-sol' model is not<br>supported when using Codex with a ChatGPT account."}}<br>To continue this session, run:<br>  codex resume 01a1284a-307f-74d3-b73e-d19999c87d37<br>Or run codex resume and select Complete e2e-spawn-c3-955089.<br><br><br>Pane is dead (status 0, Sun Oct 11 01:09:07 2026) |
| R3 | agy / chaos | PASS | $5 @5 %13; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-agy-chaos; marker=e2e-spawn-c3-955090; tracked=True; c3.ok=True |
| R3 | agy / mohammed | PASS | $6 @6 %14; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-agy-mohammed; marker=e2e-spawn-c3-955091; tracked=True; c3.ok=True |
| R3 | agy / nurulz | PASS | $7 @7 %15; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-agy-nurulz; marker=e2e-spawn-c3-955092; tracked=True; c3.ok=True |
| R3 | agy / physics | PASS | $8 @8 %16; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-agy-physics; marker=e2e-spawn-c3-955093; tracked=True; c3.ok=True |
| R3 | omp / default | PASS | $9 @9 %17; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c3-omp-default; marker=e2e-spawn-c3-955094; tracked=True; c3.ok=True |
| R4 | cursor / nurulz | PASS | $10 @11 %19; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-cursor-nurulz; windows=['@10 nvim', '@11 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-955086; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R4 | cursor / physics | PASS | $11 @13 %21; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-cursor-physics; windows=['@12 nvim', '@13 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-955087; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R4 | codex / mohammed | FAIL | $12 @15 %23; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-codex-mohammed; windows=['@14 nvim', '@15 codex']; both defects=False; app.py diff empty=True; marker=e2e-spawn-c4-955088; overlay=boxed copy of ~/.config/workmux/review.yaml; No spawning, commits, pushes, merges, or gh.<br>Resolve exactly TASK_FILE=$(tmux-tasklog path), read it, append exactly one - [<br>] e2e-spawn-c4-955088 line and check it off when REVIEW.md is written. No writes<br> outside your current worktree. Stop.'<br> ~/.ca/e2e-spawn-wt_s0azl/.w/e2e-spawn-c4-codex-mohammed  e2e-spawn-c4-codex-m<br>ohammed<br>❯ exec env -u TASK_FILE -u CODEX_THREAD_ID -u CODEX_SESSION_ID -u CODEX_ACCOUNT<br>-u CODEX_BOX_RENAME_SOCKET PATH=/home/nurul/.cache/e2e-spawn-wt_s0azl/bin:"$PATH<br>" codex-box mohammed --no-daemon -c check_for_update_on_startup=false -a never -<br>s workspace-write --add-dir /home/nurul/.cache/e2e-spawn-wt_s0azl -c shell_envir<br>onment_policy.inherit=all 'You are an adversarial REVIEWER in a disposable fixtu<br>re worktree. Review app.py and test_app.py ONLY. Find both planted defects; writ<br>e REVIEW.md with one finding per line including exact app.py:line and what is wr<br>ong. Do NOT edit app.py or fix code. No spawning, commits, pushes, merges, or gh<br>. Resolve exactly TASK_FILE=$(tmux-tasklog path), read it, append exactly one -<br>[ ] e2e-spawn-c4-955088 line and check it off when REVIEW.md is written. No writ<br>es outside your current worktree. Stop.'<br>cp: '/home/nurul/.codex/hooks.json' and '/home/nurul/.codex-containers/mohammed/<br>.codex/hooks.json' are the same file |
| R4 | codex / nurulz | FAIL | $13 @17 %25; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-codex-nurulz; windows=['@16 nvim', '@17 codex']; both defects=False; app.py diff empty=True; marker=e2e-spawn-c4-955089; overlay=boxed copy of ~/.config/workmux/review.yaml; t them.<br><br><br>› 1. Review hooks<br>  2. Trust all and continue<br>  3. Continue without trusting (hooks won't run)<br><br>  enter confirm · esc skip<br><br>  >_ OpenAI Codex (v0.162.0)<br>     ~/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-codex-nurulz<br><br><br>› Ask Codex to do anything<br><br>  gpt-6.1-sol default · ~/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-cod…<br><br><br>  >_ OpenAI Codex (v0.162.0)<br>     ~/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-codex-nurulz<br><br>  Tip: Use /subagents to switch between this session’s subagents.<br><br><br>› You are an adversarial REVIEWER in a disposable fixture worktree. Review<br>  app.py and test_app.py ONLY. Find both planted defects; write REVIEW.md with<br>  one finding per line including exact app.py:line and what is wrong. Do NOT<br>  edit app.py or fix code. No spawning, commits, pushes, merges, or gh. Resolve<br>  exactly TASK_FILE=$(tmux-tasklog path), read it, append exactly one - [ ]<br>  e2e-spawn-c4-955089 line and check it off when REVIEW.md is written. No<br>  writes outside your current worktree. Stop.<br><br><br>■ {"type":"error","status":400,"error":<br>{"type":"invalid_request_error","message":"The 'gpt-6.1-sol' model is not<br>supported when using Codex with a ChatGPT account."}}<br><br><br>› Ask Codex to do anything<br><br>  gpt-6.1-sol xhigh · ~/.cache/e2e-spawn-wt_s0azl/.w…  ⚠ 1 warning · f2 to view |
| R4 | agy / chaos | PASS | $14 @19 %27; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-agy-chaos; windows=['@18 nvim', '@19 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-955090; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R4 | agy / mohammed | PASS | $15 @21 %29; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-agy-mohammed; windows=['@20 nvim', '@21 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-955091; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R4 | agy / physics | PASS | $17 @25 %33; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-agy-physics; windows=['@24 nvim', '@25 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-955093; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R4 | omp / default | PASS | $18 @27 %35; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-omp-default; windows=['@26 nvim', '@27 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-955094; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R4 | agy / nurulz | PASS | $19 @29 %37; path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c4-agy-nurulz; windows=['@28 nvim', '@29 codex']; both defects=True; app.py diff empty=True; marker=e2e-spawn-c4-1026556; overlay=boxed copy of ~/.config/workmux/review.yaml |
| R5 | cursor / nurulz | PASS | $20 @30 %38 path=/home/nurul/.cache/e2e-spawn-wt_s0azl/.worktrees/e2e-spawn-c5-cursor-nurulz; exactly one native Subagent fixer 3e87c3d3-f9c4-4f1f-9473-d8e107fc8a90; audited parent commands only wrote fixture/task files, no gh; task marker corrected by actor; 2 passed; replies and both comments checked; seed/test file unchanged |
| R5 | cursor / physics | PASS | $2 @2 %2 path=/home/nurul/.cache/e2e-spawn-UO7x/.worktrees/e2e-spawn-c5-cursor-physics; exactly one native Task fixer ed4b4fdd-3552-4426-b80e-0e2b332cebaa; generalPurpose/composer-2.5-fast; parent wrote only fixture/task/report (initial auditor false-positive on reply text mentioning app.py); 2 passed; replies and both comments checked; marker e2e-spawn-c5-1079473-cursor-physics |
| R5 | codex / mohammed | FAIL | session created then no report; startup failure class retained (hooks.json source and destination are the same file). No fixer, pytest, or comments. path=/home/nurul/.cache/e2e-spawn-UO7x/.worktrees/e2e-spawn-c5-codex-mohammed |
| R5 | codex / nurulz | FAIL | session created then no report; startup failure class retained (gpt-6.1-sol unsupported for ChatGPT account). No fixer, pytest, or comments. path=/home/nurul/.cache/e2e-spawn-UO7x/.worktrees/e2e-spawn-c5-codex-nurulz |
| R5 | agy / chaos | PASS | $5 @5 %5 orch / fixer %6; boxed agy-box chaos pane; parent wrote report/replies only; 2 passed; both comments checked; marker e2e-spawn-c5-1079473-agy-chaos |
| R5 | agy / mohammed | PASS | $6 @6 %7 orch / fixer %12; boxed agy-box mohammed pane; 2 passed; replies and both comments checked |
| R5 | agy / nurulz | PASS | $7 @7 %13; boxed fixer pane in same session/window/worktree; 2 passed; replies and both comments checked |
| R5 | agy / physics | PASS | $8 @8 %15; boxed fixer pane in same session/window/worktree; 2 passed; replies and both comments checked |
| R5 | omp / default | PASS | $9 @9 %17; one native task fixer FixerAppPy after one rejected task call missing `context`; parent wrote fixture/task only (read app.py); cwd row in session JSONL; 2 passed; replies and both comments checked |

## R6 aggregate (selected 38)

Continuation fixture: `/home/nurul/.cache/e2e-spawn-UO7x` seed `e19b86f064705860306a309c02da6a831ff6d88d`; isolated dispatcher `$0 @0 %0`. First-segment fixture `/home/nurul/.cache/e2e-spawn-wt_s0azl` is historical.

| Requirement | Result |
|---|---|
| R1 | Cursor physics PASS; Cursor nurulz FAIL (`Subagent` not literal `Task`) |
| R2 | Seven PASS; both Codex profiles FAIL |
| R3 | Seven PASS; both Codex profiles FAIL |
| R4 | Seven PASS; both Codex profiles FAIL |
| R5 | Seven PASS (Cursor nurulz+physics, four AGY, OMP); both Codex profiles FAIL |
| R6 | **29 PASS, 9 FAIL, 0 pending.** Preliminary unauthenticated Cursor boxes and retired harness attempts stay excluded. |

Cleanup: isolated server killed (`list-sessions` fails); fixture root deleted; no `~/.cache/e2e-spawn-*` leftover. New evidence: `/tmp/e2e-r5-evidence` archived as `e2e_spawn_r5_evidence.tar.gz`.

## Leftover Codex retest (2026-10-11)

Closed selected matrix unchanged (29/9). This section is Codex-only R2–R5 after the `hooks.json` same-file skip. Fixture `/home/nurul/.cache/e2e-spawn-1GUz` seed `5d39672e7c4ae4d2638f94bee104ed4a9d89db78`; isolated dispatcher `$0 @0 %0`; `-f /dev/null`. `workmux add` from pane `%0`. No model pin in `~/.config/workmux/config.yaml`. Did not treat `Subagent` as `Task`. Driver: `/tmp/e2e-codex-leftover.py`. Evidence: `e2e_spawn_leftover_evidence.tar.gz`.

| Requirement | Tool / box | Result | Evidence |
|---|---|---|---|
| R2 | codex / mohammed | FAIL | Nested `codex-box … fork`: child died in TUI bootstrap (`thread history projection … is behind durable rollout`). Not hooks.json same-file. pane %2 kept then cleaned. |
| R2 | codex / nurulz | FAIL | Fork timed out waiting for native fork metadata; update dialog + folder-trust on child. Sol 400 not seen on this fork. |
| R3 | codex / mohammed | PASS | $1 @1 %5 path=…/e2e-spawn-c3-codex-mohammed; tracked=True; c3.ok + marker. Same-file skip held. |
| R3 | codex / nurulz | FAIL | $2 @2 %6; startup gpt-6.1-sol ChatGPT 400. No replacement model. |
| R4 | codex / mohammed | PASS | $3 @3 %7; windows=['@3 nvim', '@4 codex']; both defects in REVIEW.md; app.py diff empty. |
| R4 | codex / nurulz | FAIL | $4 @5 %9; startup gpt-6.1-sol ChatGPT 400. |
| R5 | codex / mohammed | PASS | $5 @7 %11; orchestrator-report + fixer in-tree; tracked=True. |
| R5 | codex / nurulz | FAIL | $6 @8 %12; startup gpt-6.1-sol ChatGPT 400. |

Cleanup: kill-server rc=0; list-sessions rc=1; fixture root gone; no `~/.cache/e2e-spawn-*`.

R1 AC1.1 still open: Cursor/nurulz used `Subagent` not literal `Task`. Not rejudged.

## Leftover Codex luna retest (2026-10-11)

After `codex-box nurulz` default → `gpt-6-luna`. Fixture `/home/nurul/.cache/e2e-spawn-2v61` seed `368d5fed5e9563cde7cdb8e675028b5444d18604`; isolated `$0 @0 %0`; `workmux add` from pane. No workmux config.yaml pin. Evidence: `e2e_spawn_luna_evidence.tar.gz`.

| Requirement | Tool / box | Result | Evidence |
|---|---|---|---|
| R2 | codex / mohammed | FAIL | Composer up (GPT-6.1-Sol); harness never found parent session id for `fork_codex_pane.py`. |
| R2 | codex / nurulz | FAIL | Composer up (GPT-6-Luna); same session-id lookup miss. No ChatGPT 400. |
| R3 | codex / mohammed | PASS | $1 @1 %3; tracked; c3.ok + marker. |
| R3 | codex / nurulz | FAIL | $2 @2 %4; tracked; luna ran (no 400); marker unchecked. |
| R4 | codex / mohammed | PASS | $3 @3 %5; windows nvim+codex. |
| R4 | codex / nurulz | PASS | $4 @5 %7; windows nvim+codex. Luna; no Sol 400. |
| R5 | codex / mohammed | PASS | $5 @7 %9; orchestrator-report; pytest 2 passed. |
| R5 | codex / nurulz | PASS | $6 @8 %10; fixer `app_fixer` via `collaboration.spawn_agent`; pytest 2 passed. |

Cleanup: kill-server rc=0; list-sessions rc=1; fixture gone.


## Codex R2 seeded-parent fix (2026-10-11)

Executed `e2e_spawn_r2_fix.md` using `/tmp/e2e-codex-leftover.py --r2-only`. Final fixture `/home/nurul/.cache/e2e-spawn-2i8T`, seed `da7c3d64820059794feb7bc2db63c1521dc02258`, isolated `tmux -f /dev/null`, dispatcher `$0 @0 %0`. Seed prompt: `Reply with the single word ping and wait.` Parent selection requires first-line `session_meta`, exact fixture cwd, UUID, completed seed turn and stable mtime/size for one second. Native helper invoked with `--direction below --session-id <exact parent>`; helper source unchanged. Named-box model/effort defaults preserved; no workmux config pin, `workmux add`, or rollout migration.

| Requirement | Tool / box | Result | Evidence |
|---|---|---|---|
| R2 | codex / mohammed | PASS | $0 @0 %2 /home/nurul/.cache/e2e-spawn-2i8T; parent=01a12af8-e094-75b1-a229-b89bdd57e216; fork=01a12af9-05d1-70d3-ae15-5da1d0895ee1; forked_from_id=01a12af8-e094-75b1-a229-b89bdd57e216; tracked=True; new_worktrees=0; c2=True; marker_checked=True |
| R2 | codex / nurulz | PASS | $0 @0 %4 /home/nurul/.cache/e2e-spawn-2i8T; parent=01a12afe-2ea2-7580-8f5c-4666fab97bbf; fork=01a12afe-d473-7c20-b1e8-c171423b21bb; forked_from_id=01a12afe-2ea2-7580-8f5c-4666fab97bbf; tracked=True; new_worktrees=0; c2=True; marker_checked=True |

Both strict final rows verify AC2.1–2.5: native `forked_from_id` matches parent, child has dispatcher session/window, zero new worktrees, exact child pane in parsed `workmux status --all --json`, checked numbered marker, and `c2.ok` equals the exact tmux tuple followed by fixture cwd/toplevel. Evidence: `e2e_spawn_r2_evidence.tar.gz`; includes acceptance JSON, pane captures, helper output, `c2.ok`, final driver source and cleanup checks.

Observed attempts retained, not counted as final passes:

- `e2e-spawn-CBQ4`: scrollback-based trust detection typed old choices into the composer. Interrupted and cleaned. Dismissal now reads only visible screen and guards idle composers.
- `e2e-spawn-OVLn`: provisional body-only passes rejected after stronger output validation exposed blank tmux tuple; host-measured fork/placement was correct.
- `e2e-spawn-Xbb7`: native fork succeeded, but child shell reported `error connecting to .../socket (Operation not permitted)`; empty `c2.ok`, pending numbered marker. Interrupted after captured terminal child failure; cleaned. R2 prompt now explicitly authorizes one fixture-scoped `require_escalated` shell.
- Final native fork resets parent `approval_policy=never` to child `approval_policy=on-request`. Nursery child waited on visible `Yes, proceed` approval. Its pending native tool command was reviewed (only resolved fixture task.md, tmux read, c2.ok and marker); accepted once under existing task authorization. Generic driver dismissal remains limited to folder/hook trust and updates; a child shell approval must be reviewed before accepting it. Idle composer is explicitly guarded against dialog keys. No projection-behind or model 400 reproduced on final run.

Checks: seed wait rejects idle/no transcript, wrong cwd, stale transcript and invalid UUID; settled temp `session_meta` is found. Numbered and legacy completed markers accepted; pending/other markers rejected. `py_compile` passes. Source cleanup stops swallowing rmtree errors, retries bounded deletion for late shutdown logs, and asserts the root is absent.

Initial finally cleanup: kill-server rc=0, list-sessions rc=1, root remained only because a shutdown hook recreated user-owned `state/workmux/workmux.log`. Corrected cleanup: root gone, isolated server absent, no `~/.cache/e2e-spawn-*` left. Removed only trust stanzas automatically saved by this task's known CBQ4/OVLn/Xbb7/2i8T fixtures (four in mohammed, two in nurulz); remaining TOML and all unrelated config bytes verified unchanged. No live pane/session/fixture remains.

Closed historical 38-case matrix remains unchanged. R1 AC1.1 (`Task` versus `Subagent`), R3–R5 and live gh/PR were not rerun. Remaining final R2 failures: none.
