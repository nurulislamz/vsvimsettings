# tmux config

Based on [oh-my-tmux](https://github.com/gpakosz/.tmux). All personal tweaks live in
`.tmux.conf.local` (theme, plugins, status bar) — the upstream `.tmux.conf` is never edited.

## What's customised

- **Theme**: oh-my-tmux repainted with the Catppuccin Mocha palette (17 colour slots).
- **Tabs**: rounded (Chrome-tab) separators via the semicircle Powerline glyphs.
- **Status right**: stripped to flag indicators only (prefix / mouse / pairing / sync) —
  no battery, clock, date, user, or hostname.
- **Plugins**: which-key (`prefix + Space`), tmux-fzf (`prefix + F`), sessionx,
  smooth-scroll, resurrect + continuum (auto-save 15m, restore on server start),
  assistant-resurrect. nvim buffers come back via persistence.nvim, not Session.vim.

## Install

`scripts/bootstrap` clones oh-my-tmux, links this file, and installs plugins.
Links only:

```sh
python3 ~/vsvimsettings/scripts/install.py
```

Needs a Nerd/Powerline font for the rounded tab glyphs (JetBrains Mono Nerd works).
