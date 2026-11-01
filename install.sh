#!/usr/bin/env bash
# Links this repo into the home directory with GNU stow and wires the skill links.
# Safe to re-run. Moves nothing it did not create; stops on a conflict.
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"
cd "$repo"
agents/.agents/instructions/build.sh
stow -v -t "$HOME" agents claude pi codex
# Claude reads skills from ~/.claude/skills; point it straight at the shared tree.
ln -sfn "$HOME/.agents/skills" "$HOME/.claude/skills"
# pi reads ~/.pi/agent/skills; keep its per-skill relative links, add any missing.
mkdir -p "$HOME/.pi/agent/skills"
for d in "$HOME/.agents/skills"/*/; do
  n="$(basename "$d")"
  t="$HOME/.pi/agent/skills/$n"
  if [ -L "$t" ] || [ ! -e "$t" ]; then ln -sfn "../../../.agents/skills/$n" "$t"; fi
done
echo "installed; verify with: ls -la ~/.claude/CLAUDE.md ~/.agents ~/.pi/agent/AGENTS.md ~/.codex/AGENTS.md"
