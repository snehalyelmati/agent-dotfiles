---
name: orchestrate
description: Run a multi-slice implementation from this thread as orchestrator, with implementers and reviewers in separate agent sessions in tmux panes. Use when the user asks to orchestrate, to use subagents for implementation with review, or names a model for implementers or reviewers.
---

The orchestrator plans with the user, delegates each slice with a pre-approved brief, waits on report files, runs the full validation tier, and commits. It never implements in its own context.

## Layout

- All delegated sessions run as panes in one window named `subagents`, shared by every orchestrator in the tmux session. Launch each one with `~/.agents/skills/orchestrate/launch-pane.sh <title> <repo> '<command>'` (the command as one single-quoted string, so `"$(cat …)"` expands in the pane), which finds or creates the window, adds the pane detached, titles it (`impl-<slice>`, `review-<slice>-rN`), re-tiles, and prints the pane id. Never call `new-window` or `split-window` yourself: a pane in the orchestrator's window is a bug.
- Keep the printed pane id and target the pane by id only. An orchestrator kills only panes it created; the window needs no cleanup, tmux removes it when its last pane exits.
- Every delegated session writes its report to the orchestrator's absolute scratchpad path, `report-<role>-<slice>-rN.tmp` (`role` is `impl` or `review`), and renames it to `.md` as its last action. The orchestrator deletes any stale report before launching, waits on the `.md` (Claude Code: Monitor on the path; pi: `until [ -f "$f" ]; do sleep 30; done` in Bash), each wait bounded at 10 minutes, and reads the pane only to diagnose a stall.
- One pane per role at a time. The implementer pane lives for the whole slice and is killed after the commit. Each review round is a fresh reviewer; never send a new review into an old session.
- Findings go back to the implementer as a file: write `<scratchpad>/findings-<slice>-rN.md` with a decision per finding (fix, defer, reject), then `tmux send-keys -t <impl_pane_id> "Read <path>, apply each decision, then report as before to <scratchpad>/report-impl-<slice>-rN.tmp, mv to .md last" Enter`.
- Check the pane every 10 minutes while waiting on a report file. Prompt covered by the brief: answer it there. Anything else, or no progress: tell the user, leave the session running.

## Implementer

```
launch-pane.sh impl-<slice> <repo> 'claude --model opus --permission-mode auto "$(cat <scratchpad>/task-<slice>.md)"'
```

The task file is the brief (template below). The model comes from the Model roster's implementation row; the Agent tool's model override is not honoured from a Fable session, hence a separate session.

## Reviewer

```
launch-pane.sh review-<slice>-rN <repo> 'pi -p --provider openai-codex --model <newest astra id>:high --name review-<slice>-rN "$(cat <scratchpad>/review-<slice>-rN.md)"'
```

Model from the roster's code-review row, on a different vendor from the implementer, using the newest Astra id pi lists (`pi --list-models astra`); the `openai-codex` provider is the Codex subscription, not the OpenAI API. `-p` runs non-interactively, so the pane exits once the report is written. The brief names the fixed point (commit or `HEAD` plus uncommitted tree), the exact `git diff <fixed point>` to review, the files in scope, asks for the `code-review` skill, and names the report file. A follow-up review of a fix is a new session with a brief scoped to the findings it checks.

## Brief template

```
The plan is already approved by the owner. Do not present a plan or wait; start implementing.
Report deviations in your final report. Stop only for destructive actions or a change to a documented decision.

Goal: <one sentence>
Scope: <files or crates in scope; what is out of scope>
Fixed point: <commit>; branch <name>; work in the main checkout, no worktrees, no commits.
Read first: AGENTS.md sections <...>, docs <...>
Validation while iterating: <narrow checks>. Do not run the full suite or E2E; the orchestrator does.
Report: write <scratchpad>/report-impl-<slice>-r1.tmp with: what changed (paths), checks run and results, deviations, open questions. Keep it under 80 lines. As your last action, mv it to <scratchpad>/report-impl-<slice>-r1.md.
```

`<scratchpad>` is one absolute directory per run: the orchestrator harness's scratchpad if it has one, else `mktemp -d -t orch-<repo>` created once at the start. Delegated sessions have their own scratchpads, which the orchestrator is not watching, so briefs always carry this path.

## Loop per slice

1. Brief the implementer in the `subagents` window; wait for `report-impl-<slice>-r1.md`.
2. Open a fresh reviewer on the uncommitted tree; wait for its report.
3. Send the findings file to the implementer with decisions (fix, defer, reject); fresh reviewer on the fix.
4. After two rounds, run the slice's full validation tier, commit atomically, kill the implementer pane, carry residual nits as follow-ups.
5. Report status to the user unprompted when a run stalls or a slice lands.
