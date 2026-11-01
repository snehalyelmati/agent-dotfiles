Copy AGENTS.md into a new repo and fill the placeholders. All three harnesses read it.

Add a CLAUDE.md only if the project has a Claude-only rule that is truly project-specific:

    @AGENTS.md

    ## Claude Code specifics
    - ...

Without a CLAUDE.md, Claude Code reads AGENTS.md directly (v2.1.277+). A CLAUDE.local.md also switches Claude to CLAUDE.md-only mode, so prefer AGENTS.override.md-free, single-file projects.
