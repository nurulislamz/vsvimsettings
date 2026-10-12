# Personal dotfiles

`vsvimsettings` is the source of truth for Neovim, tmux customizations, shared
agent instructions, the workmux skill, lifecycle hooks and box launchers.
Installed paths point here; edit and commit files in this repo.

## Restore

Clone this repo into `~/vsvimsettings` (another location also works), then:

```sh
git clone git@github.com:nurulislamz/vsvimsettings.git ~/vsvimsettings
python3 ~/vsvimsettings/scripts/install.py
```

The installer links Neovim, tmux's local config, workmux config, shared rules,
skills and helper commands. It merges tracked lifecycle hooks into Codex,
Claude and Antigravity, retaining custom hooks and other settings. Re-run it
after changing hook templates. Replaced files and directories are preserved in
`~/.local/state/vsvimsettings/backups/<timestamp>/`, with their original paths.
Running it again leaves correct links and unchanged hooks alone.

Keep `~/.local/bin` on PATH. Install Python 3, Git, Neovim, tmux, and the agent
CLIs you use. Box launchers also require bubblewrap. Install the native workmux
binary at `~/.local/libexec/workmux` **before** using this repo's `workmux`
wrapper. On a fresh machine with a native workmux already on PATH:

```sh
install -Dm755 "$(command -v workmux)" ~/.local/libexec/workmux
python3 ~/vsvimsettings/scripts/install.py
```

The wrapper provides grouped dashboards and routes lifecycle events through the
host relay for boxed Codex. Agent credentials and account profiles are local;
authenticate separately. Codex needs `hooks = true` under `[features]` in
`~/.codex/config.toml`; review and trust installed hooks when Codex asks. This
repo does not copy credentials or hook trust hashes. Existing Codex and AGY
boxes sync host rules/hooks on their next launch.

For tmux's upstream config and plugin installation, see [tmux/README.md](tmux/README.md).
`workmux/review.yaml` is a template: replace its agent pane command in a temporary
overlay with the box you chose, including Codex's update-prompt flag. No account
or model is selected by the installer.

## Neovim

All configuration lives under `nvim/`, including `lazy-lock.json` and Tree-sitter
queries. The installer restores `~/.config/nvim` as a link. Start Neovim to
bootstrap lazy.nvim; run `:Lazy restore` to install plugin commits from the
lockfile. Mason installs configured language servers. Install language tools
for the projects you edit, and a Nerd Font for icons.

Plugins, Mason downloads, sessions, caches and machine-specific authentication
are regenerated or kept locally, rather than committed. Older copies of the
config are available in Git; restore the complete directory from one commit:

```sh
git restore --source=<commit> -- nvim
git add nvim
git commit -m 'Restore Neovim configuration'
```

The other existing folders (`shell`, `ideavim`, `ghostty-settings`, `wezterm`,
`zed`) are stored settings; the installer does not apply them.

## Check

```sh
python3 -m unittest discover -s scripts -p 'test_*.py'
python3 -m unittest discover -s agents/skills/workmux/scripts -p 'test_*.py'
"agents/skills/workmux/scripts/tmux-tasklog" --self-check
```
