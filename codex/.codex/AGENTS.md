## Subagents

- Use subagents when you can. Keep the context in the main thread clean. Use it as orchestrator by default. 
- Use GPT 5.6 Sol Med as the default for new subagents, for more very complex tasks or analysis, use GPT 6 Astra Med.

## Modularity

- Prefer files with one clear responsibility.
- Keep files under 300 lines when practical; do not split cohesive code solely to meet a number.
- Extract cohesive modules when a file mixes unrelated concerns or becomes difficult to test.
- Keep behavior changes separate from mechanical refactors when practical.
- Preserve public contracts.

## Commits

- Make atomic commits: one logical change per commit, separating mechanical refactors from behavior changes when practical.
- Use a concise subject and a detailed body with bullets covering key changes, validation, and caveats or follow-ups.
- Include `Fixes #N`, `Closes #N`, or `Refs #N` when a commit resolves or relates to a GitHub issue.
