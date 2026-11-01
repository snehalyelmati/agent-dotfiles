---
name: orchestrate
description: Run a multi-slice implementation from this thread as orchestrator, with implementers and reviewers in separate tmux sessions. Use when the user asks to orchestrate, to use subagents for implementation with review, or names a model for implementers or reviewers.
---

The orchestrator plans with the user, delegates each slice with a pre-approved brief, waits on report files, runs the full validation tier, and commits. It never implements in its own context.

## Layout

- The orchestrator runs in a tmux window. Implementer and reviewer sessions open as panes beside it with `tmux split-window -h -t <session>:<window>.<pane> -c <repo> -d "<command>"`.
- Every delegated session writes its final report to `<scratchpad>/report-<slice>.md`. The orchestrator waits on that file, not on the pane, and reads the pane only to diagnose a stall.
- One pane per role at a time. Kill a finished reviewer pane before opening the next; never send a new review into an old session.
- Check the pane every 10 minutes while waiting on a report file. Prompt covered by the brief: answer it there. Anything else, or no progress: tell the user, leave the session running.

## Implementer

```
claude --model opus --permission-mode auto "$(cat <scratchpad>/task-<slice>.md)"
```

The task file is the brief (template below). The model comes from the Model roster's implementation row; the Agent tool's model override is not honoured from a Fable session, hence a separate session.

## Reviewer

```
pi --provider openai-codex --model <newest astra id>:high --name review-<slice> '<brief>'
```

Model from the roster's code-review row, on a different vendor from the implementer, using the newest Astra id pi lists (`pi --list-models astra`); the `openai-codex` provider is the Codex subscription, not the OpenAI API. The brief names the fixed point (commit or `HEAD` plus uncommitted tree), the files in scope, asks for the `code-review` skill, and names the report file. A follow-up review of a fix is a new session with a brief scoped to the findings it checks.

## Brief template

```
The plan is already approved by the owner. Do not present a plan or wait; start implementing.
Report deviations in your final report. Stop only for destructive actions or a change to a documented decision.

Goal: <one sentence>
Scope: <files or crates in scope; what is out of scope>
Fixed point: <commit>; branch <name>; work in the main checkout, no worktrees, no commits.
Read first: AGENTS.md sections <...>, docs <...>
Validation while iterating: <narrow checks>. Do not run the full suite or E2E; the orchestrator does.
Report: write <scratchpad>/report-<slice>.md with: what changed (paths), checks run and results, deviations, open questions. Keep it under 80 lines.
```

## Loop per slice

1. Brief the implementer; wait for its report file.
2. Open a fresh reviewer on the uncommitted tree; wait for its report.
3. Send findings back to the implementer with decisions (fix, defer, reject); fresh reviewer on the fix.
4. After two rounds, run the slice's full validation tier, commit atomically, carry residual nits as follow-ups.
5. Report status to the user unprompted when a run stalls or a slice lands.
