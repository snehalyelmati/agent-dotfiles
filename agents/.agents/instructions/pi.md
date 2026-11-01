# pi specifics

## Subagents

- Use the builtin `delegate` agent for all ordinary delegation; do not use `worker`.
- Use fresh context, foreground execution, acceptance disabled, and no `timeoutMs` or `maxRuntimeMs`.
- For most sub-tasks, inherit the parent model with lower reasoning.
- For exploration or grunt work, use `openai-codex/gpt-6.1-sol`. For harder problems use `openai-codex/gpt-6-astra`.
- Use reasoning depending on the task's complexity, default for `astra` is `low` and `gpt-6.1-sol` is `med`.
- Do not use intercom, async orchestration, chains, review loops, or nested subagents unless the user explicitly requests them.
- Let the child return its result directly through the `subagent` tool call.

## Grilling

- Default to the `grill-with-docs` skill for grilling sessions. Use `grill-me` only when the user explicitly requests it.
- When using `grill-with-docs` or `grill-me`, ask all interview questions directly in plain chat text. Do not use `ask_user_question` or another questionnaire tool.
