#!/usr/bin/env python3
"""Restore dotfiles links and merge Workmux hooks; preserve replaced files."""

import json
import os
from pathlib import Path
import shutil
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]


def link(source, destination, backup):
    if destination.is_symlink() and destination.resolve() == source.resolve():
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    if os.path.lexists(destination):
        saved = backup / destination.relative_to(Path.home())
        saved.parent.mkdir(parents=True, exist_ok=True)
        destination.rename(saved)
        print(f"Backed up {destination} -> {saved}")
    destination.symlink_to(source, target_is_directory=source.is_dir())


def merge_hooks(current, template, agent):
    if agent == "agy":
        return {**current, **template}
    merged = dict(current)
    hooks = dict(current.get("hooks", {}))
    for event, groups in hooks.items():
        kept = []
        for group in groups:
            entries = [entry for entry in group["hooks"] if not entry.get("command", "").startswith(
                ("workmux register-agent", "workmux set-window-status ")
            )]
            if entries:
                kept.append({**group, "hooks": entries})
        hooks[event] = kept
    for event, groups in template["hooks"].items():
        hooks[event] = hooks.get(event, []) + groups
    merged["hooks"] = hooks
    return merged


def install():
    home = Path.home()
    # Validate every hook config before replacing any installed files.
    updates = []
    for agent, target in (
        ("codex", ".codex/hooks.json"),
        ("claude", ".claude/settings.json"),
        ("agy", ".gemini/config/hooks.json"),
    ):
        destination = home / target
        current = json.loads(destination.read_text()) if destination.exists() else {}
        template = json.loads((ROOT / f"agents/hooks/{agent}.json").read_text())
        merged = merge_hooks(current, template, agent)
        updates.append((destination, current, merged))

    backup = home / ".local/state/vsvimsettings/backups" / str(time.time_ns())
    paths = {
        ".config/nvim": "nvim",
        ".tmux.conf.local": "tmux/.tmux.conf.local",
        ".config/agents/AGENTS.md": "agents/AGENTS.md",
        ".config/agents/skills/workmux": "agents/skills/workmux",
        ".config/workmux/config.yaml": "workmux/config.yaml",
        ".config/workmux/review.yaml": "workmux/review.yaml",
    }
    for target in (
        ".codex/AGENTS.md", ".claude/CLAUDE.md", ".config/opencode/AGENTS.md",
        ".cursor/rules/session-tasks.md", ".gemini/config/rules/session-tasks.md",
    ):
        paths[target] = "agents/AGENTS.md"
    for directory in (
        ".agents/skills", ".codex/skills", ".claude/skills", ".cursor/skills",
        ".config/opencode/skills", ".gemini/config/skills",
    ):
        paths[f"{directory}/workmux"] = "agents/skills/workmux"
    for source in sorted((ROOT / "agents/bin").iterdir()):
        paths[f".local/bin/{source.name}"] = str(source.relative_to(ROOT))
    for name in ("tmux-tasklog", "workmux-agent-hook", "codex-box-rename-bridge"):
        paths[f".local/bin/{name}"] = f"agents/skills/workmux/scripts/{name}"
    paths[".local/bin/cursor-box"] = "agents/bin/agent-box"
    for target, source in paths.items():
        link(ROOT / source, home / target, backup)

    (home / ".local/state/workmux").mkdir(parents=True, exist_ok=True)
    for destination, current, merged in updates:
        if destination.exists() and current == merged:
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            saved = backup / destination.relative_to(home)
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(destination, saved)
        # Replace atomically; a local symlink must not write into the tracked template.
        with tempfile.NamedTemporaryFile(mode="w", dir=destination.parent, delete=False) as stream:
            json.dump(merged, stream, indent=2)
            stream.write("\n")
        try:
            os.replace(stream.name, destination)
        finally:
            Path(stream.name).unlink(missing_ok=True)
    print(f"Restored links and hooks from {ROOT}")


if __name__ == "__main__":
    install()
