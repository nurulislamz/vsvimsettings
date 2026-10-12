# tmux config

Based on [oh-my-tmux](https://github.com/gpakosz/.tmux). All personal tweaks live in
`.tmux.conf.local` (theme, plugins, status bar) — the upstream `.tmux.conf` is never edited.

## What's customised

- **Theme**: oh-my-tmux repainted with the Catppuccin Mocha palette (17 colour slots).
- **Tabs**: rounded (Chrome-tab) separators via the semicircle Powerline glyphs.
- **Status right**: stripped to flag indicators only (prefix / mouse / pairing / sync) —
  no battery, clock, date, user, or hostname.
- **Plugins**: which-key (`prefix + Space`), tmux-fzf (`prefix + F`),
  smooth-scroll, resurrect + continuum (auto-save 15m, restore on server start).
  nvim buffers come back via persistence.nvim, not Session.vim.

## Install

```sh
# 1. clone oh-my-tmux
git clone --depth 1 https://github.com/gpakosz/.tmux.git ~/.tmux-omt

# 2. symlink its .tmux.conf into home (never edit this file)
ln -sf ~/.tmux-omt/.tmux.conf ~/.tmux.conf

# 3. drop this repo's local config into home
python3 ~/vsvimsettings/scripts/install.py

# 4. start tmux, install plugins
tmux
#   prefix + I   (install)   prefix + u  (update)
```

Needs a Nerd/Powerline font for the rounded tab glyphs (JetBrains Mono Nerd works).
