#!/usr/bin/env python3
"""Self-check: skip hooks.json copy when source and dest are the same file."""

import os
import pathlib
import subprocess
import tempfile
import unittest

LAUNCHER = pathlib.Path.home() / ".local/bin/codex-box"


def _sync(home: pathlib.Path, profile: pathlib.Path) -> subprocess.CompletedProcess[str]:
    script = r"""
set -euo pipefail
if [ -f "$HOME/.codex/hooks.json" ]; then
  if [ ! "$HOME/.codex/hooks.json" -ef "$PROFILE_DIR/.codex/hooks.json" ]; then
    cp -u "$HOME/.codex/hooks.json" "$PROFILE_DIR/.codex/hooks.json"
  fi
fi
"""
    env = os.environ.copy()
    env["HOME"] = str(home)
    env["PROFILE_DIR"] = str(profile)
    return subprocess.run(
        ["bash", "-c", script],
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )


class CodexBoxHooksSyncTests(unittest.TestCase):
    def test_launcher_skips_same_inode(self):
        text = LAUNCHER.read_text()
        self.assertIn(
            '[ ! "$HOME/.codex/hooks.json" -ef "$PROFILE_DIR/.codex/hooks.json" ]',
            text,
        )

        with tempfile.TemporaryDirectory() as td:
            home = pathlib.Path(td) / "home"
            profile = pathlib.Path(td) / "box"
            src_dir = home / ".codex"
            dest_dir = profile / ".codex"
            src_dir.mkdir(parents=True)
            dest_dir.mkdir(parents=True)
            src = src_dir / "hooks.json"
            dest = dest_dir / "hooks.json"
            src.write_text('{"hooks":[]}\n')
            os.link(src, dest)
            self.assertTrue(src.samefile(dest))

            failed = subprocess.run(
                ["cp", "-u", str(src), str(dest)],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(failed.returncode, 0)
            self.assertIn("same file", failed.stderr)

            synced = _sync(home, profile)
            self.assertEqual(synced.returncode, 0, synced.stderr)
            self.assertEqual(src.read_text(), '{"hooks":[]}\n')
            self.assertTrue(src.samefile(dest))

            other = pathlib.Path(td) / "other" / ".codex"
            other.mkdir(parents=True)
            copied = _sync(home, other.parent)
            self.assertEqual(copied.returncode, 0, copied.stderr)
            self.assertEqual((other / "hooks.json").read_text(), '{"hooks":[]}\n')
            self.assertFalse(src.samefile(other / "hooks.json"))


if __name__ == "__main__":
    unittest.main()
