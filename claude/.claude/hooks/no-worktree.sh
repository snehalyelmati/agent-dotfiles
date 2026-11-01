#!/usr/bin/env bash
# PreToolUse hook: blocks git worktrees for implementers (see common.md, Orchestration).
# Exit 2 = block the tool call and show the message to the model.
input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
iso="$(printf '%s' "$input" | jq -r '.tool_input.isolation // empty')"
if [ "$tool" = "EnterWorktree" ] || { [ "$tool" = "Agent" ] && [ "$iso" = "worktree" ]; }; then
  echo "Worktrees are not used here (common.md, Orchestration). Work in the main checkout." >&2
  exit 2
fi
exit 0
