# agent-dotfiles

One source for the instructions and skills that Claude Code, pi and codex read on this machine.

```
agents/.agents/instructions/   common.md + claude.md | pi.md | codex.md, build.sh, project-template/
agents/.agents/skills/         every shared skill, one copy (npx skills installs land here)
claude/.claude/                CLAUDE.md (two @imports), agents/, hooks/
pi/.pi/agent/AGENTS.md         generated: common.md + pi.md
codex/.codex/AGENTS.md         generated: common.md + codex.md
```

Edit under `agents/.agents/instructions/`, run `./install.sh` (renders, stows, relinks skills), commit.
Per project, a single `AGENTS.md` is read by all three harnesses; see `project-template/`.
Not in the repo: `~/.claude/settings.json`, pi and codex settings, permission lists.
