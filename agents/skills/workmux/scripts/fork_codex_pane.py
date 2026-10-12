#!/usr/bin/env python3
"""Fork the current Codex conversation into a workmux-tracked sibling pane."""

import argparse
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import time
import uuid


def run(argv, **kwargs):
    result = subprocess.run(argv, capture_output=True, text=True, timeout=10, **kwargs)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"Command failed: {argv[0]}")
    return result.stdout


def metadata(path):
    try:
        with path.open() as stream:
            record = json.loads(stream.readline())
        return record.get("payload", {}) if record.get("type") == "session_meta" else {}
    except (OSError, ValueError):
        return {}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--direction", choices=("below", "right"), default="below")
    parser.add_argument("--session-id", help="Exact parent ID; defaults to the current Codex environment")
    parser.add_argument("--dry-run", action="store_true", help="Validate and print the plan without creating a pane")
    args = parser.parse_args()

    pane = None
    try:
        source = os.environ.get("TMUX_PANE")
        instance = os.environ.get("TMUX", "").split(",")[0]
        if not source or not instance:
            raise RuntimeError("Run this helper inside the source tmux pane")
        parent = args.session_id or os.environ.get("CODEX_THREAD_ID") or os.environ.get("CODEX_SESSION_ID")
        if not parent:
            raise RuntimeError("No current conversation ID; provide --session-id with the exact ID")
        uuid.UUID(parent)
        if not args.session_id:
            identifiers = {os.environ[key] for key in ("CODEX_THREAD_ID", "CODEX_SESSION_ID") if os.environ.get(key)}
            if len(identifiers) > 1:
                raise RuntimeError("Current conversation IDs disagree; verify the transcript and use --session-id")

        home = Path.home()
        account = os.environ.get("CODEX_ACCOUNT")
        if account:
            if account in (".", "..") or "/" in account:
                raise RuntimeError("Invalid CODEX_ACCOUNT")
            codex_home = home / ".codex-containers" / account / ".codex"
            launcher = [str(home / ".local/bin/codex-box"), account]
        else:
            codex_home = Path(os.environ.get("CODEX_HOME") or home / ".codex").expanduser()
            launcher = [shutil.which("codex") or str(home / ".local/bin/codex")]
        if not os.access(launcher[0], os.X_OK):
            raise RuntimeError(f"Launcher is unavailable: {launcher[0]}")
        workmux = home / ".local/libexec/workmux"
        if not os.access(workmux, os.X_OK):
            raise RuntimeError(f"Native workmux binary is unavailable: {workmux}")
        if "WORKMUX_DISABLE_SET_WINDOW_STATUS" in os.environ:
            raise RuntimeError("Workmux tracking is disabled in this environment")

        sessions = codex_home / "sessions"
        parents = [p for p in sessions.rglob(f"*{parent}*.jsonl") if metadata(p).get("id") == parent]
        if len(parents) != 1:
            raise RuntimeError(f"Expected one transcript for {parent} in {sessions}; found {len(parents)}")
        known = set(sessions.rglob("*.jsonl"))

        def tmux(*command):
            return run(["tmux", "-S", instance, *command]).removesuffix("\n")

        def pane_info(target):
            fields = tmux(
                "display-message", "-p", "-t", target,
                "#{pane_id}\t#{window_id}\t#{session_id}\t#{pane_active}\t#{pane_dead}\t#{pane_top}\t#{pane_left}",
            ).split("\t")
            if len(fields) != 7:
                raise RuntimeError("Cannot read source pane information")
            info = dict(zip(("pane", "window", "session", "active", "dead", "top", "left"), fields))
            # This tmux escapes dollar signs in display output; decode them once.
            info["cwd"] = tmux("display-message", "-p", "-t", target, "#{pane_current_path}").replace("\\$", "$") if info["dead"] == "0" else ""
            return info

        before = pane_info(source)
        if before["dead"] != "0":
            raise RuntimeError("Source pane is no longer alive")
        unset = (
            "CODEX_THREAD_ID", "CODEX_SESSION_ID", "CODEX_BOX_RENAME_SOCKET",
            "WORKMUX_STATUS_BACKEND", "WORKMUX_STATUS_INSTANCE", "WORKMUX_STATUS_PANE_ID",
        )
        command = ["env"]
        for name in unset:
            command.extend(["-u", name])
        command.extend([*launcher, "fork", "--no-daemon", parent])
        plan = {
            "source_pane": source, "parent_conversation_id": parent,
            "direction": args.direction, "workdir": before["cwd"], "command": shlex.join(command),
        }
        if args.dry_run:
            print(json.dumps(plan))
            return 0

        flag = "-v" if args.direction == "below" else "-h"
        cwd_argument = before["cwd"].replace("#", "##")  # -c expands tmux formats.
        # Stage the pane so remain-on-exit is installed before Codex can fail.
        pane = tmux("split-window", flag, "-d", "-t", source, "-c", cwd_argument, "-P", "-F", "#{pane_id}", "sleep 300")
        tmux("set-option", "-p", "-t", pane, "remain-on-exit", "on")
        tmux("respawn-pane", "-k", "-t", pane, "-c", cwd_argument, "exec " + shlex.join(command))

        deadline = time.monotonic() + 30
        fork = None
        while time.monotonic() < deadline:
            after = pane_info(pane)
            if after["dead"] != "0":
                raise RuntimeError("Codex exited during startup; inspect its preserved output")
            candidates = [
                metadata(path) for path in set(sessions.rglob("*.jsonl")) - known
            ]
            forks = [m for m in candidates if m.get("forked_from_id") == parent and m.get("id") != parent]
            if len(forks) > 1:
                raise RuntimeError("Multiple new forks found; cannot identify this pane's conversation safely")
            if forks:
                fork = forks[0]
                break
            time.sleep(0.25)
        if not fork:
            raise RuntimeError("Timed out waiting for verified native fork metadata")

        after = pane_info(pane)
        if after["window"] != before["window"] or after["session"] != before["session"] or after["cwd"] != before["cwd"]:
            raise RuntimeError("Fork did not retain the source window, session, and directory")
        coordinate = "top" if args.direction == "below" else "left"
        if int(after[coordinate]) <= int(before[coordinate]):
            raise RuntimeError("Fork pane is not in the requested direction")

        env = os.environ.copy()
        env.update(
            TMUX_PANE=pane, WORKMUX_STATUS_BACKEND="tmux",
            WORKMUX_STATUS_INSTANCE=instance, WORKMUX_STATUS_PANE_ID=pane,
        )

        def tracked():
            status = json.loads(run([str(workmux), "status", "--all", "--json"], env=env))
            return any(agent.get("pane_id") == pane for agent in status.get("agents", []))

        if not tracked():
            run([str(workmux), "register-agent"], input=json.dumps({"session_id": fork["id"]}), env=env)
        if not tracked():
            raise RuntimeError("Fork is alive but is absent from workmux's agent list")
        if pane_info(pane)["dead"] != "0":
            raise RuntimeError("Codex exited after registration; inspect its preserved output")

        print(json.dumps({
            "pane": pane, "direction": args.direction, "workdir": after["cwd"],
            "parent_conversation_id": parent, "fork_conversation_id": fork["id"],
            "workmux_tracked": True,
            "source_focus_preserved": pane_info(source)["active"] == before["active"],
        }))
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        suffix = f"; pane {pane} has been kept for inspection" if pane else "; no pane was created"
        print(f"Fork failed: {error}{suffix}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
