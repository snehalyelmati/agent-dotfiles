## Model roster

One roster for every harness. Pick the row for the task; run the first choice if this harness can, otherwise the fallback, and say which ran in the report. Sub-agent work runs in Claude Code or pi; codex is used interactively only.

| Task | First choice | Fallback |
|---|---|---|
| Main thread, orchestration | Claude Code, Fable, high | pi, gpt-6-astra, high |
| Implementation slice | Claude Code, Opus, high, separate session | pi, gpt-6-astra, high |
| Code review | pi, gpt-6-astra, high | Claude Code, Opus, high, fresh session |
| Codebase exploration, read-only | Claude Code, opus-explorer agent | pi, gpt-6.1-sol, medium |
| Grunt work: mechanical edits, searches, data munging | Claude Code, Opus, medium | pi, gpt-6.1-sol, medium |
| Hard analysis, design questions | Claude Code, Fable, high | pi, gpt-6-astra, high |
| Web research, synthesis and judgment | the current thread's model | none |
| Web research, high-volume fetch and scan | pi, gpt-6.1-sol, medium | Claude Code, Sonnet, medium |
| Visual, artifacts, UI design | Claude Code, Fable or Opus | none |

- Review runs on a different vendor from the implementer.
- "Sol" means `gpt-6.1-sol`; "astra" means `gpt-6-astra`. In pi both are reached through the `openai-codex` provider.
