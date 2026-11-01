# pi specifics

## Subagents

- Use the builtin `delegate` agent for all ordinary delegation; do not use `worker`.
- Use fresh context, foreground execution, acceptance disabled, and no `timeoutMs` or `maxRuntimeMs`.
- Choose the model from the Model roster row for the task; when the row names pi, use the `openai-codex` provider. For most sub-tasks that is Sol at medium; for hard problems Astra. Use the newest id of the family the provider lists.
- Do not use intercom, async orchestration, chains, review loops, or nested subagents unless the user explicitly requests them.
- Let the child return its result directly through the `subagent` tool call.

## Grilling

- Default to the `grill-with-docs` skill for grilling sessions. Use `grill-me` only when the user explicitly requests it.
- When using `grill-with-docs` or `grill-me`, ask all interview questions directly in plain chat text. Do not use `ask_user_question` or another questionnaire tool.
