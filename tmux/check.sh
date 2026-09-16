#!/bin/sh
# Verify the tmux config loads clean on a throwaway server.
# A single bad line (e.g. an unknown key) makes oh-my-tmux fail silently,
# leaving .tmux.conf.local unapplied. This catches that.
set -e
SOCK=configcheck
trap 'tmux -L $SOCK kill-server 2>/dev/null || true' EXIT
tmux -L $SOCK kill-server 2>/dev/null || true

tmux -L $SOCK -f /dev/null new-session -d -x 200 -y 50
errs=$(tmux -L $SOCK source-file -v "$HOME/.tmux.conf.local" 2>&1 \
       | grep -viE '^/.*: (set|bind|setw|if-shell|run-shell|source)' || true)
[ -z "$errs" ] || { echo "FAIL: .tmux.conf.local has errors:"; echo "$errs"; exit 1; }

check() { # label expected actual
  [ "$2" = "$3" ] || { echo "FAIL: $1 expected $2, got $3"; exit 1; }
  echo "ok: $1 ($3)"
}
check "smart Ctrl-hjkl binds" 4 "$(tmux -L $SOCK list-keys -T root | grep -cE 'C-[hjkl] +if-shell')"
check "prefix hjkl binds"     4 "$(tmux -L $SOCK list-keys -T prefix | grep -cE '^bind-key -r +-T prefix +[hjkl] ')"
check "C-\\ pane-last bind"   1 "$(tmux -L $SOCK list-keys -T root | grep -cF 'C-\')"
check "swap-window { }"       2 "$(tmux -L $SOCK list-keys -T prefix | grep -cE 'prefix +.\{|prefix +.\}')"
check "join-pane < >"         2 "$(tmux -L $SOCK list-keys -T prefix | grep -cE 'prefix +[<>] +command-prompt')"
check "mode-keys"           vi "$(tmux -L $SOCK show -gwv mode-keys)"
check "escape-time"          0 "$(tmux -L $SOCK show -sv escape-time)"
check "history-limit"    10000 "$(tmux -L $SOCK show -gv history-limit)"
echo "all checks passed"
