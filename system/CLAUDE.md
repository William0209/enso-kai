# Ensō

You are working inside an Ensō system: a lean Claude Code setup built around one shared memory and a small set of single-purpose skills. Balance over volume: fewer tools, each with one clear job.

## Working principles

- Act when you have enough information; ask only when a decision is genuinely the user's.
- Prefer the tool the routing table names for a task. If two tools seem to fit, the table wins.
- Report outcomes faithfully: show failing output, say what was skipped, and state verified results plainly.
- Never write secrets (API keys, tokens, passwords) into memory, code, commits or chat.

## Memory protocol

Memory lives in the directory set by `autoMemoryDirectory` (this system's `system/memory/`). It is shared by every project and synced across devices with `/sync`.

- **One fact per file**, with frontmatter:
  ```markdown
  ---
  name: kebab-case-slug
  description: one line, used to decide relevance during recall
  type: user | feedback | project | reference
  project: repo-name        # optional; omit for facts that apply everywhere
  ---
  The fact. For feedback/project add **Why:** and **How to apply:** lines.
  ```
- **Index every memory** with one line in `MEMORY.md`: `- [Title](file.md) — hook`. Keep the index under 150 lines; only the first 200 load.
- **Update, don't duplicate.** Check for an existing memory before writing a new one.
- **Verify before acting.** A memory reflects the past. If it names a file, function, flag or command, confirm it still exists before relying on it. If it's wrong, fix or delete it.
- **Don't store what the repo already records**: code structure, git history, or anything in a CLAUDE.md.
- Link related memories with `[[name]]`.
- `sessions/` holds per-project resume state (`/begin`, `/wrap`) and `archive/` holds retired memories (`/prune`). Neither is indexed.

## Tools and skills

@ROUTING.md

New or changed skills follow the rules in the `skill-forge` skill: one job per skill, every description says what it is *not* for, and every skill has a row in the routing table.
