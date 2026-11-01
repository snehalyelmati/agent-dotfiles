#!/usr/bin/env bash
# Renders the per-harness instruction files for tools that cannot import.
# Claude Code imports common.md and claude.md directly from its CLAUDE.md.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../../.." && pwd)"
render() { # render <tool-file> <target>
  {
    echo "<!-- GENERATED from ~/.agents/instructions (common.md + $1). Edit there and run build.sh. -->"
    echo
    cat "$here/common.md"
    echo
    cat "$here/$1"
  } > "$2"
}
render pi.md    "$repo/pi/.pi/agent/AGENTS.md"
render codex.md "$repo/codex/.codex/AGENTS.md"
echo "rendered pi and codex instruction files"
