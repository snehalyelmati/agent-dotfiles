# Claude Code specifics

## Agents

- Use the `opus-explorer` agent for codebase exploration instead of the built-in `Explore` agent.
- The Agent tool's `model` override is not honoured in a Fable session. When implementation must run on a specific model, launch a separate `claude` session as the `orchestrate` skill describes instead of using the Agent tool.

## Artifacts

- Before writing any HTML artifact, load the `artifact-design` and `frontend-design` skills and follow them, even for reports and summaries.
- Show the content visually first: use charts, diagrams and interactive elements wherever they explain something better than prose, and keep prose short.
- Base the visual concept on the subject, and label anything schematic or derived so it can't be mistaken for measured data.
- Render the page and check it at desktop and phone widths before publishing. If you can't, say so.
- Artifact types with their own instructions, such as Docs and Slides, follow those instructions instead.
