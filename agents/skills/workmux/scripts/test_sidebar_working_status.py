#!/usr/bin/env python3
"""Regression for specs/sidebar-working-status.md (R1, R3, R4, R5)."""

import importlib.machinery
import importlib.util
import json
import os
import tempfile
import pathlib
import subprocess
import unittest
from unittest import mock

HOOK_PATH = pathlib.Path(__file__).with_name("workmux-agent-hook")
loader = importlib.machinery.SourceFileLoader("workmux_agent_hook", str(HOOK_PATH))
spec = importlib.util.spec_from_loader(loader.name, loader)
hook = importlib.util.module_from_spec(spec)
loader.exec_module(hook)


class SidebarWorkingStatusTests(unittest.TestCase):
    def setUp(self):
        self.commands = []

        def fake_tmux(args):
            self.commands.append(args)
            stdout = ""
            if args[0] == "display-message":
                stdout = "@42\n"
            elif args[0] == "show-option" and args[-1] == "@agent_status":
                stdout = "working"
            elif args[0] == "show-option" and args[-1] == "@workmux_colour_theme_loaded":
                stdout = "1\n"
            return subprocess.CompletedProcess(args, 0, stdout, "")

        self.tmux_mock = mock.patch.object(hook, "tmux", side_effect=fake_tmux)
        self.tmux_mock.start()
        self.addCleanup(self.tmux_mock.stop)
        self.run_patch = mock.patch.object(
            hook.subprocess, "run",
            return_value=subprocess.CompletedProcess([], 0, "", ""),
        )
        self.run_mock = self.run_patch.start()
        self.addCleanup(self.run_patch.stop)

    def test_r1_repeated_working_without_prompt_reaches_workmux(self):
        self.assertEqual(hook.apply_host_event("working", {}, "%7", "@42"), 0)
        self.run_mock.assert_called_once()
        self.assertEqual(self.run_mock.call_args.args[0][1:], ["set-window-status", "working"])
        self.assertEqual(json.loads(self.run_mock.call_args.kwargs["input"]), {})
        self.assertEqual(self.run_mock.call_args.kwargs["env"]["WORKMUX_STATUS_PANE_ID"], "%7")

    def test_r3_dead_relay_falls_back_to_host_event(self):
        env = {
            "CODEX_BOX_RENAME_SOCKET": "/tmp/missing-workmux-relay.sock",
            "TMUX_PANE": "%7",
            "CODEX_ACCOUNT": "mohammed",
        }
        with mock.patch.object(hook.sys, "argv", ["workmux-agent-hook", "set-window-status", "working"]):
            with mock.patch.object(hook, "read_hook_input", return_value={}):
                with mock.patch.dict(hook.os.environ, env, clear=True):
                    with mock.patch.object(hook, "send_relay_event", side_effect=ConnectionRefusedError("refused")):
                        self.assertEqual(hook.main(), 0)
        self.run_mock.assert_called_once()
        self.assertEqual(self.run_mock.call_args.args[0][1:], ["set-window-status", "working"])

    def test_r4_tmp_relay_socket_is_allowed(self):
        import importlib.machinery
        import importlib.util
        path = pathlib.Path(__file__).with_name("codex-box-rename-bridge")
        loader = importlib.machinery.SourceFileLoader("rename_bridge", str(path))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        bridge = importlib.util.module_from_spec(spec)
        loader.exec_module(bridge)
        self.assertTrue(bridge.socket_path_allowed("/tmp/codex-box-rename-123.sock"))
        self.assertTrue(bridge.socket_path_allowed(str(pathlib.Path.home() / ".codex-containers/mohammed/tmp/codex-box-rename-123.sock")))
        self.assertFalse(bridge.socket_path_allowed(str(pathlib.Path.home() / ".codex-containers/mohammed/tmp/other.sock")))
        self.assertFalse(bridge.socket_path_allowed("/etc/codex-box-rename-123.sock"))

    def test_r5_codex_stop_stays_done(self):
        env = {"TMUX_PANE": "%7"}
        with mock.patch.object(hook.sys, "argv", ["workmux-agent-hook", "set-window-status", "done"]):
            with mock.patch.object(hook, "read_hook_input", return_value={"hook_event_name": "Stop", "background_working": "true"}):
                with mock.patch.dict(hook.os.environ, env, clear=True):
                    self.assertEqual(hook.main(), 0)
        self.run_mock.assert_called_once()
        self.assertEqual(self.run_mock.call_args.args[0][1:], ["set-window-status", "done"])


class HookStartupTests(unittest.TestCase):
    def test_first_run_creates_log_directory(self):
        with tempfile.TemporaryDirectory() as home:
            result = subprocess.run(
                ["python3", str(HOOK_PATH), "set-window-status", "working"],
                env={**os.environ, "HOME": home, "WORKMUX_DISABLE_SET_WINDOW_STATUS": "1"},
                input="{}", capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((pathlib.Path(home) / ".local/state/workmux/hooks.log").is_file())


if __name__ == "__main__":
    unittest.main()
