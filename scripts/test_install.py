#!/usr/bin/env python3
"""Exercise restore in a disposable home, including backups and custom hooks."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "scripts/install.py"


class RestoreTests(unittest.TestCase):
    def run_install(self, home):
        return subprocess.run(
            ["python3", str(INSTALLER)], env={**os.environ, "HOME": str(home)},
            capture_output=True, text=True, check=False,
        )

    def test_restore_preserves_files_hooks_and_is_repeatable(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            nvim = home / ".config/nvim"
            nvim.mkdir(parents=True)
            (nvim / "init.lua").write_text("original config\n")
            skill = home / ".config/agents/skills/workmux"
            skill.mkdir(parents=True)
            (skill / "local.txt").write_text("local skill\n")
            claude = home / ".claude/settings.json"
            claude.parent.mkdir()
            custom = {"type": "command", "command": "custom-check"}
            claude.write_text(json.dumps({"permissions": {"allow": []}, "hooks": {
                "SessionStart": [{"hooks": [custom, {"command": "workmux register-agent"}]}]
            }}))
            agy = home / ".gemini/config/hooks.json"
            agy.parent.mkdir(parents=True)
            agy.write_text(json.dumps({"custom": {"Stop": []}}))
            result = self.run_install(home)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(nvim.resolve(), ROOT / "nvim")
            self.assertEqual(skill.resolve(), ROOT / "agents/skills/workmux")
            self.assertEqual((home / ".codex/skills/workmux").resolve(), skill.resolve())
            self.assertEqual((home / ".local/bin/workmux-agent-hook").resolve(), ROOT / "agents/skills/workmux/scripts/workmux-agent-hook")
            backups = list((home / ".local/state/vsvimsettings/backups").iterdir())
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / ".config/nvim/init.lua").read_text(), "original config\n")
            self.assertEqual((backups[0] / ".config/agents/skills/workmux/local.txt").read_text(), "local skill\n")
            settings = json.loads(claude.read_text())
            self.assertEqual(settings["permissions"], {"allow": []})
            self.assertEqual(settings["hooks"]["SessionStart"][0]["hooks"], [custom])
            self.assertIn("custom", json.loads(agy.read_text()))
            first = claude.read_text()
            result = self.run_install(home)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(claude.read_text(), first)
            self.assertEqual(list(backups[0].parent.iterdir()), backups)

    def test_invalid_hooks_abort_before_replacing_config(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            hooks = home / ".codex/hooks.json"
            hooks.parent.mkdir()
            hooks.write_text("invalid JSON")
            result = self.run_install(home)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(hooks.read_text(), "invalid JSON")
            self.assertFalse((home / ".config/nvim").exists())


if __name__ == "__main__":
    unittest.main()
