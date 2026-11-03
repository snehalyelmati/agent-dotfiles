#!/usr/bin/env bash
# Launch a delegated session as a pane in the shared `subagents` window of the
# current tmux session. Creates the window if missing. Prints the pane id.
#
# usage: launch-pane.sh <title> <repo> '<command>'
# The command is one string, run by the pane's shell, so "$(cat brief.md)"
# inside it expands there and reaches the program as a single argument.
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 <title> <repo> '<command>'" >&2
  exit 2
fi
title=$1
repo=$2
cmd=$3

[ -n "${TMUX:-}" ] || { echo "not inside tmux" >&2; exit 1; }

win=$(tmux list-windows -F '#{window_id} #{window_name}' | awk '$2=="subagents"{print $1; exit}')

if [ -z "$win" ]; then
  pane=$(tmux new-window -d -n subagents -c "$repo" -P -F '#{pane_id}' "$cmd")
  win=$(tmux display -p -t "$pane" '#{window_id}')
else
  pane=$(tmux split-window -d -t "$win" -c "$repo" -P -F '#{pane_id}' "$cmd")
fi

[ -n "$pane" ] || { echo "failed to create pane" >&2; exit 1; }

tmux select-pane -t "$pane" -T "$title"
tmux select-layout -t "$win" tiled >/dev/null
echo "$pane"
