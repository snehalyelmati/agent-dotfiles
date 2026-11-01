## Model roster

One roster for every harness. Pick the row for the task; run the first choice if this harness can, otherwise the fallback, and say which ran in the report. Sub-agent work runs in Claude Code or pi; codex is used interactively only.

Live providers: Anthropic through the Claude Max subscription (Claude Code); OpenAI through the Codex subscription (pi, provider `openai-codex`).

Names are model families. Use the latest version of the family the harness offers: in Claude Code the aliases `fable`, `opus` and `sonnet` resolve to it; in pi pick the newest id the provider lists.

| Task | First choice | Fallback |
|---|---|---|
| Main thread, orchestration | Claude Code, Fable, high | pi, Astra, high |
| Implementation slice | Claude Code, Opus, high, separate session | pi, Astra, high |
| Code review | pi, Astra, high | Claude Code, Opus, high, fresh session |
| Codebase exploration, read-only | Claude Code, opus-explorer agent | pi, Sol, medium |
| Grunt work: mechanical edits, searches, data munging | Claude Code, Opus, medium | pi, Sol, medium |
| Hard analysis, design questions | Claude Code, Fable, high | pi, Astra, high |
| Web research, synthesis and judgment | the current thread's model | none |
| Web research, high-volume fetch and scan | pi, Sol, medium | Claude Code, Sonnet, medium |
| Visual, artifacts, UI design | Claude Code, Fable or Opus | none |

- Review runs on a different vendor from the implementer.
