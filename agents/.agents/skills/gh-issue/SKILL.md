---
name: gh-issue
description: Create a well-scoped GitHub issue in the current repository using gh. Use when the user asks to create, file, open, or draft a GitHub issue with enough implementation context for future work.
---

# GitHub Issue

Create a GitHub issue in the current repository with the minimum useful detail.

## Rules

- Do not edit project files or commit anything.
- Use the current repository unless the user names another repo.
- Inspect enough context first: `gh repo view --json nameWithOwner,url`, `git status --short`, and relevant files/conversation notes.
- If the issue scope is ambiguous, ask one concise question before creating it.
- Prefer one focused issue over a roadmap dump.
- Do not include secrets, tokens, local-only paths, or private scratch notes.

## Issue shape

Title:
- Imperative and specific.
- Example: `Enforce repo-readonly /fanout-plan with packet-only writer`

Body:
```markdown
## Problem
<what is wrong or missing>

## Proposed design
<the smallest design that solves it>

## Scope
- <concrete implementation item>
- <concrete implementation item>

## Files likely touched
- `<path>` — <why>

## Acceptance criteria
- <observable behavior>
- <observable behavior>

## Validation
- `<command>`

## Notes / non-goals
- <what is intentionally skipped>
```

## Command

After the draft is ready and the user has not asked for draft-only, create it:

```bash
gh issue create --repo <owner/name> --title "<title>" --body-file <temp-body-file>
```

Use a temp file for the body to avoid shell quoting bugs.

## Final response

Return only:

```text
Created: <issue-url>
```

If draft-only:

```text
Drafted issue; not created.
```
