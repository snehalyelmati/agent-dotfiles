<!-- GENERATED from ~/.agents/instructions (common.md + models.md + pi.md). Edit there and run build.sh. -->

# Global Instructions

## Design decision gate

- Treat user-approved plans and project docs (`AGENTS.md`, roadmap, design decisions, specs, impl docs) as the current baseline.
- Before proposing a plan, compare the intended approach against relevant documented or approved decisions.
- Before proposing a plan, consider whether there is a simpler, safer, or more correct approach than the current baseline.
- Better approaches are allowed, but must be surfaced before implementation.
- Every plan must include:
  - decisions followed
  - proposed changes to prior decisions: `none` or a list
  - deferred/skipped items: `none` or a list with reason
- If you recommend changing, weakening, merging, deferring, or replacing a documented or approved decision, say so explicitly and ask for approval before editing.
- Present: original decision, recommended change, why it is better, impact/tradeoffs, and validation.
- During implementation, if a better approach or necessary deviation appears, stop and propose a revised plan instead of silently changing scope.
- After approval, do not keep re-litigating the design unless new evidence appears.
- Keep the docs updated after significant changes.

## Planning before changes

- Infer the outcome I want from the request, conversation, and project context. Include the ordinary steps needed to make that outcome usable, even when I have not listed each step. Keep this within the requested scope.
- Before planning, do the reconnaissance that is safe and available: inspect relevant files, docs, callers, configs, tests, git state, and existing patterns.
- Do not edit code, config, tests, or docs until the user has reviewed and approved a concise plan.
- Start each plan with `Inspected:` and list the key files, docs, commands, or state already reviewed.
- Plans must state scope, files to touch, expected impact, and concrete validation.
- Do not use plan steps like “check”, “verify”, “look into”, “investigate”, or “figure out” for information that could be gathered before planning.
- Leave investigation in the plan only when it needs approval, credentials, unavailable access, long-running work, or potentially destructive commands.
- If reconnaissance finds ambiguity, ask clarifying questions before proposing or revising the plan.

## Confirmation and execution

- Treat user approval as a hard gate: no commits, file writes, or mass refactors before explicit confirmation.
- After approval, keep changes local to the agreed scope; if follow-up work appears, propose a new plan instead of silently expanding the diff.

## Where rules live

- Global rules for every agent: `~/.agents/instructions/common.md`. Tool-only rules: `claude.md`, `pi.md`, `codex.md` beside it. Repo rules: the project's `AGENTS.md`. Put a new rule in the lowest layer that still covers everyone who needs it, not in the file you happen to be reading.
- Skills are shared from `~/.agents/skills`. Multi-step procedures belong in a skill, not in an instruction file.

## Orchestration (multi-agent work)

- Roles: the main thread orchestrates and commits; implementers and reviewers run as separate sessions in tmux panes, each writing a report to a scratchpad file the orchestrator waits on. The `orchestrate` skill has the launch recipes and the brief template.
- The brief carries the approval. The orchestrator completes the planning gate with the user once, then the brief states: "The plan is already approved by the owner. Do not present a plan or wait; start implementing. Report deviations in your final report. Stop only for destructive actions or a change to a documented decision." A session started from such a brief does not re-run the planning gate.
- One fresh reviewer session per review round; never reuse one. Review every slice before commit; fix findings, then give the fix its own focused review. After two rounds on the same change, commit and carry residual nits as follow-up commits.
- Never use git worktrees for implementers; work in the main checkout.
- Report status unprompted when a background run stalls or finishes; do not wait to be asked.

## Validation tiers

- Iterate on the narrowest check that can fail for the change: the touched test file or name pattern, the single crate or package, and the scoped end-to-end journey that covers the behaviour.
- Run the full suite, workspace-wide lint and the full end-to-end matrix once per slice, after the slice's review findings are fixed and before its commit, and again after any change to a shipped threshold or fixture. Do not relaunch a full matrix to confirm a single fix.
- State in the final report which tier ran and which did not.

## Design conversations

- One question at a time; never a wall of text. Lead with the decision needed.
- Reason from first principles about essential versus repeated work before proposing mechanisms; measure before tuning.
- "Show me visually" means a rendered page or diagram; extend the same one rather than creating new ones.
- An implementation ticket's deliverable is the implementation with docs updated; a findings doc alone is not completion.

## Modularity

- Prefer modular files with one clear responsibility.
- Keep files under 300 lines when practical; do not split cohesive code just to satisfy the number.
- When a file grows large, mixes unrelated concerns, or becomes difficult to test, extract cohesive modules instead of continuing to add logic.
- Keep behavior changes separate from mechanical refactors when practical.
- Preserve public contracts.
- Add or update focused tests before changing persistence, serialization, or cross-module boundaries.

## Ticket management

- Complete in-scope work and validation in the current ticket unless concretely blocked. Request needed approval or access; do not treat it as a reason to defer. Handoffs require an explicit blocker and user approval—not merely another owning ticket.
- Close tickets when their agreed scope is complete. Keep them open for incomplete work or obligations without an accepted owner—not for downstream work already assigned elsewhere.
- Before closing, record approved handoffs in existing owning tickets: remaining work, acceptance criteria, dependencies, evidence and limitations. Cross-link both directions and confirm updates succeeded. Obtain approval for new scope or changed acceptance.
- Closure notes must summarize implementation, relevant references, validation commands/results, unresolved failures and follow-ups. Report the final state/link; implementation-complete does not mean release-ready.
- Follow project testing/migration policy. Preserve equivalent assertions and platform-specific coverage; retire legacy tests only after replacements pass. Never hide regressions or label deferred/untested work as passed.
- Omit local-commit and push-status commentary unless asked.
- Ticket closure does not authorize commits, pushes, deployments, releases or live operations.

## Commits

- Always use atomic commits: one logical change per commit, with unrelated edits split apart.
- Key is already loaded for signing, just commit like normal. 
- Keep mechanical refactors separate from behavior changes when practical.
- Always use a detailed commit message.
- Keep the subject concise.
- Include body bullets covering key changes, validation performed, and important caveats or follow-ups.
- When a commit resolves or relates to a GitHub issue, include `Fixes #N` / `Closes #N` or `Refs #N` in the commit body for GitHub auto-link/close behavior.

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

# pi specifics

## Subagents

- Use the builtin `delegate` agent for all ordinary delegation; do not use `worker`.
- Use fresh context, foreground execution, acceptance disabled, and no `timeoutMs` or `maxRuntimeMs`.
- Choose the model from the Model roster row for the task; when the row names pi, use the `openai-codex` provider. For most sub-tasks that is Sol at medium; for hard problems astra.
- Do not use intercom, async orchestration, chains, review loops, or nested subagents unless the user explicitly requests them.
- Let the child return its result directly through the `subagent` tool call.

## Grilling

- Default to the `grill-with-docs` skill for grilling sessions. Use `grill-me` only when the user explicitly requests it.
- When using `grill-with-docs` or `grill-me`, ask all interview questions directly in plain chat text. Do not use `ask_user_question` or another questionnaire tool.
