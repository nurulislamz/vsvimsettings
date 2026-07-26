# tmux tips

Workflow notes — not config, just things worth remembering.

## Scrolling into Claude Code's history via copy-mode

Claude Code (like vim/less) runs in the terminal's **alternate screen buffer**.
Alt-screen apps don't push their output into tmux's real scrollback — so
`prefix + [` (copy-mode) only sees the currently visible screen, not
anything scrolled past.

Fix — dump the conversation into regular scrollback first:

1. Inside Claude Code: `Ctrl+O` — toggles transcript mode
2. `[` — writes the full conversation into regular terminal scrollback
   (escapes the alt-screen limitation)
3. `prefix + [` — tmux copy-mode, now scrolls through full history
4. `hjkl` to move, `v` to start selection, `y` to yank
5. `prefix + ]` — paste

## Copy-mode basics (vi-mode, already on via oh-my-tmux)

- `prefix + [` — enter copy-mode
- `hjkl` — move
- `v` — start visual selection (char-wise)
- `y` — yank selection, exits copy-mode
- `q` — cancel without yanking
- `prefix + ]` — paste last yank
- `k` / `Ctrl+u` — scroll up (line / half-page)
- `j` / `Ctrl+d` — scroll down (line / half-page)
- `g` / `G` — jump to top / bottom
- `?` — search backward (regex)

`set -g set-clipboard on` (already in oh-my-tmux defaults) means `y` also
lands in the macOS system clipboard, not just tmux's internal buffer.

## Pane navigation gotcha

`prefix + h/j/k/l` selects panes vim-style. Don't hold Ctrl through the
whole combo — release Ctrl after `prefix` (Ctrl+b), then tap plain h/j/k/l.
Holding Ctrl the whole time sends Ctrl+h/j/k/l (backspace / linefeed /
kill-line / clear-screen bytes), which never matches the plain-key binds.
