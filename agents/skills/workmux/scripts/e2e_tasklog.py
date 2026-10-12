#!/usr/bin/env python3
"""Boxed workmux tasklog regression. Set E2E_{CURSOR,CODEX,AGY,OPENCODE}_BOX.

Run --self-check without boxes; E2E_TIMEOUT controls each live step (default 120s).
All live fixtures are disposable; no repository instructions override global rules.
"""

import json
import os
from pathlib import Path
import re
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import time


def checklist(text):
    tasks = text.split("## Tasks\n", 1)[-1].split("## Notes", 1)[0]
    return [(state, marker) for state, _, marker in
            re.findall(r"^- \[([ >x!])\] T([1-9]\d*) (.+)$", tasks, re.M)]


def validate(text, expected, complete=False):
    assert "## Tasks\n" in text and "## Notes\n" in text, "missing sections"
    tasks, notes = text.split("## Tasks\n", 1)[1].split("## Notes\n", 1)
    numbered = re.findall(r"^- \[([ >x!])\] T([1-9]\d*) (.+)$", tasks, re.M)
    assert len(re.findall(r"^- \[", tasks, re.M)) == len(numbered), tasks
    assert [int(n) for _, n, _ in numbered] == list(range(1, len(expected) + 1)), numbered
    rows = checklist(text)
    markers = [marker for _, marker in rows]
    assert len(markers) == len(set(markers)), f"duplicate markers: {rows}"
    assert markers == list(expected), f"wrong markers: {rows}, expected {expected}"
    if complete:
        assert all(state == "x" for state, _ in rows), f"incomplete: {rows}"
        assert all(f"tasklog marker {marker}" in notes.splitlines() for marker in expected), notes


def cursor_ready(screen):
    # shortcut: current Cursor footer text, update when its CLI status labels change.
    return bool(re.search(r"(?m)^\s*→", screen)) and not re.search(
        r"(?mi)^\s*[^\w\s]+\s*(Working|Running|Thinking)\b", screen)


def run():
    if "--self-check" in sys.argv:
        assert not cursor_ready("Cursor Agent\n")
        assert cursor_ready("→ Plan, search, build anything\n")
        assert cursor_ready("Tasklog updated.\n→ Add a follow-up\n")
        assert cursor_ready("Running the same tasklog update for T3 now.\n→ Add a follow-up\n")
        assert not cursor_ready("⠀⠞ Running 2.49k tokens\n→ Tasklog T1 draft\n")
        assert not cursor_ready(" ⠰⠳ Working 60 tokens\n→ Add a follow-up\n")
        validate("## Tasks\n- [x] T1 e2e-one\n- [x] T2 e2e-two\n## Notes\n"
                 "tasklog marker e2e-one\ntasklog marker e2e-two\n",
                 ["e2e-one", "e2e-two"], True)
        for tasks in ("- [x] T1 e2e-one\n- [x] T1 e2e-one\n", "- [ ] T1 e2e-one\n",
                      "- [>] T1 e2e-one\n", "- [!] T1 e2e-one\n", "",
                      "- [x] e2e-one\n", "- [x] T2 e2e-one\n",
                      "- [x] T1 e2e-other\n", "- [x] T1 e2e-one\n- [x] T2 e2e-other\n"):
            try:
                validate("## Tasks\n" + tasks + "## Notes\n", ["e2e-one"], True)
            except AssertionError:
                pass
            else:
                raise AssertionError(f"accepted invalid checklist: {tasks!r}")
        print("PASS checklist and Cursor readiness self-check")
        return

    tools = []
    for name, binary in (("cursor", "cursor-box"), ("codex", "codex-box"),
                         ("agy", "agy-box"), ("opencode", "opencode-box")):
        box = os.environ.get(f"E2E_{name.upper()}_BOX")
        if not box or not shutil.which(binary):
            print(f"SKIP {name}: box unset or wrapper missing", flush=True)
            continue
        listing = subprocess.check_output([binary, "list"], text=True)
        print(listing, end="", flush=True)
        if name == "opencode":
            auth = Path.home() / ".opencode-containers" / box / "share/auth.json"
            authenticated = auth.is_file() and bool(json.loads(auth.read_text()))
        else:
            authenticated = bool(re.search(rf"^\s*{re.escape(box)}\s+Authenticated\s", listing, re.M))
        if not authenticated:
            print(f"SKIP {name}: {box} not authenticated", flush=True)
            continue
        tools.append((name, binary, box))
    if not tools:
        print("SKIP live matrix: no authenticated boxes selected")
        return

    # OpenCode hides /tmp; home-cache fixtures remain visible inside every box.
    root = Path(tempfile.mkdtemp(prefix=f"e2e-tasklog-{os.getpid()}-", dir=Path.home() / ".cache"))
    repo, state, shim = root / "repo", root / "state", root / "bin"
    for directory in (repo, state, shim):
        directory.mkdir()
    env = dict(os.environ, XDG_STATE_HOME=str(state), PATH=f"{shim}:{os.environ['PATH']}")
    for key in ("TASK_FILE", "TMUX", "TMUX_PANE", "CODEX_THREAD_ID", "CODEX_SESSION_ID",
                "CODEX_ACCOUNT", "CODEX_BOX_RENAME_SOCKET", "CURSOR_ACCOUNT", "AGENT_ACCOUNT",
                "AGY_ACCOUNT", "WORKMUX_STATUS_BACKEND", "WORKMUX_STATUS_INSTANCE",
                "WORKMUX_STATUS_PANE_ID", "WORKMUX_DISABLE_SET_WINDOW_STATUS"):
        env.pop(key, None)
    socket = str(root / "socket")
    timeout = float(os.environ.get("E2E_TIMEOUT", "120"))
    prefix = f"e2e-tasklog-{os.getpid()}-"
    nonce = root.name.rsplit("-", 1)[-1]
    handles = []
    logs, expected_by_log = {}, {}
    launch_env = {}
    audit = root / "helper-calls"
    real_helper = str(Path.home() / ".local/bin/tmux-tasklog")
    (shim / "tmux-tasklog").write_text(
        "#!/bin/sh\n"
        f"printf '%s|%s|%s\\n' \"$TMUX_PANE\" \"${{1:-}}\" \"${{TASK_FILE+set}}\" >> {shlex.quote(str(audit))}\n"
        f"exec {shlex.quote(real_helper)} \"$@\"\n")
    (shim / "tmux-tasklog").chmod(0o755)

    def cmd(*args, check=True, cwd=repo):
        result = subprocess.run(args, cwd=cwd, env=env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
        if check and result.returncode:
            raise RuntimeError(f"{shlex.join(args)}: {result.stdout}")
        return result.stdout.strip()

    def tmux(*args, **kwargs):
        return cmd("tmux", "-S", socket, *args, **kwargs)

    def log_path(session):
        actual = tmux("display-message", "-t", session, "-p", "#{session_name}")
        worktree = tmux("display-message", "-t", session, "-p", "#{pane_current_path}")
        return Path(cmd(real_helper, "path", actual, worktree))

    def helper_calls(pane):
        rows = audit.read_text().splitlines() if audit.exists() else []
        return [row for row in rows if row.startswith(f"{pane}|path|")]

    def inspect_agent_env(pane):
        if pane in launch_env:
            return
        descendants = {int(tmux("display-message", "-t", pane, "-p", "#{pane_pid}"))}
        processes = [line.split(maxsplit=2) for line in cmd("ps", "-eo", "pid=,ppid=,comm=").splitlines()]
        for pid, parent, name in processes:
            if int(parent) in descendants:
                descendants.add(int(pid))
            if int(pid) in descendants:
                try:
                    executable = Path(f"/proc/{pid}/exe").resolve().name
                    if executable not in ("agent", "node", "codex", "agy", "opencode", "bun"):
                        continue
                    values = Path(f"/proc/{pid}/environ").read_bytes().split(b"\0")
                except FileNotFoundError:
                    continue
                launch_env[pane] = any(value.startswith(b"TASK_FILE=") for value in values)
                assert not launch_env[pane], f"boxed agent {name} ({pid}) inherited TASK_FILE"
                print(f"ENV boxed-process {name} pid={pid} pane={pane} TASK_FILE=unset", flush=True)
                return

    def assert_clean():
        garbage = [p for p in root.rglob("*.md") if re.search(r"_home_.*tasklogs.*\.md$", p.name)]
        assert not garbage, f"garbage path files: {garbage}"
        for handle in handles:
            assert not cmd("git", "status", "--porcelain", "--untracked-files=normal",
                           cwd=repo / ".worktrees" / handle), f"agent edited repo: {handle}"
        for path, expected in expected_by_log.items():
            validate(path.read_text(), expected)

    def prompt(marker, complete=False, assigned=None):
        action = (f"Use the assigned T{assigned} ({marker}); do not append or self-pick another ID. "
                  if assigned else
                  f"Insert exactly one numbered task with title {marker} under ## Tasks, "
                  "using max existing ID + 1 (T1 if none). ")
        action += ("Mark it [>] now, then [x] when done. "
                   if complete else "Leave its mark pending (checking it off is also acceptable). ")
        return ("Tasklog I/O only; do not edit repo files or launch other agents. "
                "Read /home/nurul/.config/agents/AGENTS.md. "
                f"In the same shell, first export PATH={shlex.quote(str(shim))}:\"$PATH\" "
                "for the audit shim, which delegates unchanged to the installed helper. "
                "Resolve by running exactly TASK_FILE=$(tmux-tasklog path), "
                "read Tasks and Notes, and preserve all existing lines and titles. "
                + action + f"Append exactly tasklog marker {marker} under ## Notes. "
                "Then stop and wait for the next instruction.")

    def launch(tool, initial=""):
        name, binary, box = tool
        args = [binary, box]
        if name == "codex":
            args += ["--no-daemon", "-c", "check_for_update_on_startup=false", "-a", "never",
                     "-s", "workspace-write", "--add-dir", str(state), "--add-dir", str(root),
                     "-c", "shell_environment_policy.inherit=all"]
        elif name == "opencode":
            args += ["--auto"]
        if initial:
            args += (["--prompt-interactive", initial] if name == "agy" else
                     ["--prompt", initial] if name == "opencode" else [initial])
        script = root / f"launch-{len(list(root.glob('launch-*')))}.sh"
        script.write_text("#!/bin/bash\n"
                          "unset TASK_FILE\n"
                          f"export PATH={shlex.quote(env['PATH'])}\n"
                          "workmux register-agent >/dev/null 2>&1\n"
                          f"exec {shlex.join(args)}\n")
        script.chmod(0o755)
        return f"exec {shlex.quote(str(script))}"

    def create(case, command="", initial=""):
        handle = prefix + case
        handles.append(handle)
        config = root / f"{case}.yaml"
        config.write_text("worktree_dir: .worktrees\nmode: session\npost_create: []\npre_remove: []\n"
                          "files: {copy: [], symlink: []}\n"
                          f"agent: {json.dumps(command or 'exec bash --noprofile --norc')}\n"
                          "panes:\n  - command: <agent>\n    focus: true\n")
        args = ["workmux", "add", handle, "-b", "--config", str(config), "-H", "-F"]
        if initial:
            file = root / f"{case}-prompt.md"
            file.write_text(initial)
            args += ["-P", str(file)]
        cmd(*args)
        print(cmd("workmux", "list"), flush=True)
        # Discover the real session via its worktree pane path, never a guessed wm- handle.
        listing = tmux("list-panes", "-a", "-F", "#{session_name}\t#{pane_id}\t#{pane_current_path}")
        matches = [line.split("\t") for line in listing.splitlines()
                   if line.split("\t")[-1] == str(repo / ".worktrees" / handle)]
        assert len(matches) == 1, f"cannot identify first pane: {listing}"
        session, pane, _ = matches[0]
        logs[handle] = log_path(session)
        expected_by_log[logs[handle]] = []
        print(f"SESSION {session} first-pane {pane} log {logs[handle]}", flush=True)
        return handle, session, pane

    def poll(handle, pane, markers, previous_calls=0, complete=False, backlog=None):
        deadline, heartbeat = time.monotonic() + timeout, time.monotonic() + 20
        observed_pending = False
        while time.monotonic() < deadline:
            inspect_agent_env(pane)
            path = log_path(pane)
            text = path.read_text() if path.exists() else ""
            rows = checklist(text)
            if any(state == "!" for state, _ in rows):
                with path.open("a") as notes:
                    notes.write("\nMonitor stopped: worker marked a task blocked.\n")
                raise RuntimeError(f"BLOCKED: {rows}")
            if backlog:
                assert all(state == " " for state, marker in rows if marker not in markers), rows
            observed_pending |= (" ", markers[-1]) in rows
            calls = helper_calls(pane)
            ready = markers[-1] in [marker for _, marker in rows]
            if ready and complete:
                ready = all(("x", marker) in [(s.lower(), m) for s, m in rows] for marker in markers)
            if ready and len(calls) > previous_calls:
                validate(text, backlog or markers, complete and backlog is None)
                assert pane in launch_env, "boxed process environment was not observed"
                expected_by_log[path] = list(backlog or markers)
                assert_clean()
                print(f"PASS {markers[-1]} helper-calls={len(calls)} pending-observed={observed_pending}", flush=True)
                return
            # Capture is diagnostic/control only; success always comes from the tasklog + helper audit.
            screen = tmux("capture-pane", "-t", pane, "-p")
            if "trust this directory" in screen.lower() or "trust this folder" in screen.lower():
                tmux("send-keys", "-t", pane, "Enter")
            if screen.lower().rstrip().endswith(("esc close", "esc skip")):
                tmux("send-keys", "-t", pane, "Escape")
            if time.monotonic() >= heartbeat:
                print(f"WAIT {markers[-1]} log-exists={path.exists()} helper-calls={len(calls)}", flush=True)
                heartbeat += 20
            time.sleep(0.2)
        print(cmd("workmux", "capture", handle, "-n", "80", check=False), flush=True)
        print(tmux("capture-pane", "-t", pane, "-p", "-S", "-80", check=False), flush=True)
        raise TimeoutError(f"BLOCKED {markers[-1]}: tasklog/helper audit timeout ({timeout}s); status left intact")

    def interrupted(signum, frame):
        raise KeyboardInterrupt(f"signal {signum}")

    signal.signal(signal.SIGTERM, interrupted)
    try:
        cmd("git", "init", "-b", "main")
        (repo / ".gitignore").write_text(".worktrees/\n.workmux/\n")
        cmd("git", "add", ".gitignore")
        cmd("git", "-c", "user.name=E2E", "-c", "user.email=e2e@localhost", "commit", "-m", "fixture")
        tmux("-f", "/dev/null", "new-session", "-d", "-s", "isolated-root", "-c", str(repo), "-x", "160", "-y", "48")
        tmux("set-option", "-g", "@workmux_colour_theme_loaded", "1")
        env["TMUX"] = f"{socket},{tmux('display-message', '-p', '#{pid}')},0"
        root_log = Path(cmd(real_helper, "path", "isolated-root", str(repo)))
        expected_by_log[root_log] = []
        chosen = tools[0]
        m1 = f"e2e-case1-{nonce}"
        instruction = prompt(m1)
        handle, session, pane = create("spawn", launch(chosen, instruction), instruction)
        poll(handle, pane, [m1])

        for tool in tools:
            marker = f"e2e-case2a-{tool[0]}-{nonce}"
            handle, session, pane = create(f"isolated-{tool[0]}")
            tmux("respawn-pane", "-k", "-t", pane, launch(tool, prompt(marker)))
            poll(handle, pane, [marker])

        handle, session, first_pane = create("shared")
        shared = []
        for index, tool in enumerate(tools):
            marker = f"e2e-case2b-{tool[0]}-{nonce}"
            if index == 0:
                pane = first_pane
                tmux("respawn-pane", "-k", "-t", pane, launch(tool, prompt(marker)))
            else:
                pane = tmux("split-window", "-d", "-P", "-F", "#{pane_id}", "-t", session,
                            "-c", str(repo / ".worktrees" / handle), launch(tool, prompt(marker)))
                tmux("select-layout", "-t", session, "tiled")
            shared.append(marker)
            poll(handle, pane, shared)
        print(f"PASS shared-session {len(tools)} panes, {len(shared)} markers", flush=True)

        handle, session, pane = create("sequential", launch(chosen))
        markers = []
        backlog = [f"e2e-case3-T{number}-{nonce}" for number in range(1, 4)]
        path = logs[handle]
        path.write_text(path.read_text().replace("## Tasks\n", "## Tasks\n" +
                        "".join(f"- [ ] T{n} {marker}\n" for n, marker in enumerate(backlog, 1))))
        expected_by_log[path] = list(backlog)
        for number in range(1, 5):
            deadline = time.monotonic() + timeout
            while (cmd("workmux", "capture", handle, "-n", "10", check=False).startswith("Error:")
                   or (chosen[0] == "cursor" and not cursor_ready(tmux("capture-pane", "-t", pane, "-p")))):
                if time.monotonic() >= deadline:
                    raise TimeoutError("sequential agent did not become ready for input")
                if chosen[0] == "cursor":
                    # Cursor can leave completed spinner text onscreen until a redraw.
                    tmux("send-keys", "-t", pane, "C-l")
                time.sleep(0.5)
            marker = f"e2e-case3-T{number}-{nonce}"
            calls = len(helper_calls(pane))
            markers.append(marker)
            instruction = (f"Do T{number}: {marker}\n"
                           "TASK_FILE=$(tmux-tasklog path). Read Tasks and Notes.\n"
                           f"Mark T{number} [>] now. Mark [x] when done, [!] if blocked.\n"
                           "Write Notes if the next ID will need a fact. Then stop and wait.\n" +
                           prompt(marker, True, number))
            if number == 1:
                instruction += " After marking T1 [>], wait up to 30s for T4 to appear before finishing T1."
            if chosen[0] == "cursor":
                tmux("send-keys", "-t", pane, "C-a", "C-k")
                instruction = "\x1b[200~" + instruction + "\x1b[201~"
            cmd("workmux", "send", handle, instruction)
            if chosen[0] == "cursor":
                # Cursor can debounce a paste past workmux's immediate Enter.
                time.sleep(0.5)
                screen = tmux("capture-pane", "-t", pane, "-p")
                if (cursor_ready(screen) and marker in screen.rsplit("→", 1)[-1]
                        and len(helper_calls(pane)) == calls):
                    tmux("send-keys", "-t", pane, "Enter")
            if number == 1:
                deadline = time.monotonic() + timeout
                while True:
                    path = log_path(pane)
                    rows = checklist(path.read_text())
                    if (">", marker) in rows:
                        break
                    assert ("x", marker) not in rows, "T1 finished before T4 append"
                    if any(state == "!" for state, _ in rows):
                        with path.open("a") as notes:
                            notes.write("\nMonitor stopped: worker blocked before T4 append.\n")
                        raise RuntimeError(f"BLOCKED: {rows}")
                    if time.monotonic() >= deadline:
                        raise TimeoutError("BLOCKED: worker did not mark T1 working; status left intact")
                    time.sleep(0.1)
                backlog.append(f"e2e-case3-T4-{nonce}")
                path.write_text(path.read_text().replace("## Notes\n",
                                f"- [ ] T4 {backlog[-1]}\n\n## Notes\n"))
                expected_by_log[path] = list(backlog)
            poll(handle, pane, markers, calls, complete=True, backlog=backlog)
        validate(path.read_text(), backlog, complete=True)
        assert_clean()
        print("PASS all configured cases; parent isolation, no garbage files, repo unchanged", flush=True)
    finally:
        try:
            for handle in reversed(handles):
                cmd("workmux", "remove", "--force", handle, check=False)
        finally:
            try:
                tmux("kill-server", check=False)
            finally:
                shutil.rmtree(root)
                print(f"CLEANUP removed disposable repo, worktrees, socket and state: {root}", flush=True)


if __name__ == "__main__":
    run()
