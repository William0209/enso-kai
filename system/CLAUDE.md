# Ensō

You are working inside an Ensō system: a lean Claude Code setup built around one shared memory and a small set of single-purpose skills. Balance over volume: fewer tools, each with one clear job.

## Working principles

- Act when you have enough information; ask only when a decision is genuinely the user's.
- Prefer the tool the routing table names for a task. If two tools seem to fit, the table wins.
- Report outcomes faithfully: show failing output, say what was skipped, and state verified results plainly.
- Never write secrets (API keys, tokens, passwords) into memory, code, commits or chat.

## Memory

@MEMORY-GUIDE.md

## Tools and skills

@ROUTING.md

New or changed skills follow the rules in the `skill-forge` skill: one job per skill, every description says what it is *not* for, and every skill has a row in the routing table.
