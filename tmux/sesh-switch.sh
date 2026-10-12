#!/usr/bin/env bash
set -euo pipefail

session=$(
	sesh list -t --icons | fzf-tmux -p 90%,80% \
		--no-sort --ansi --reverse \
		--border-label ' sessions ' \
		--prompt '> ' \
		--header '  j/k move   type to filter   enter switch   x close' \
		--bind 'j:down,k:up' \
		--bind "x:execute-silent(tmux kill-session -t '{2..}' || true; sesh cache refresh)+reload(sesh list -t --icons)" \
		--preview-window 'right:60%' \
		--preview 'sesh preview --watch {}'
) || exit 0

[[ -z "${session}" ]] && exit 0
sesh connect "${session}"
