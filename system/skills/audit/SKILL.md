---
name: audit
description: Audit every installed skill for overlapping triggers, missing "Not for" clauses and drift from the routing table, then propose merges and deletions.
disable-model-invocation: true
---

# Audit skills

Report only. Change nothing until the user approves specific items.

1. **Inventory.** List every skill with its source and description:
   - Ensō: `$ENSO_HOME/system/skills/*/SKILL.md`
   - Personal (non-Ensō): other folders in `<config dir>/skills/` and `<config dir>/commands/`, where `<config dir>` is `$CLAUDE_CONFIG_DIR` if set, else `~/.claude` (skip `synced/` and `.trash/`)
   - Project: `./.claude/skills/*/SKILL.md` and `./.claude/commands/*.md`
   - Plugins and claude.ai-synced skills: ask the user to paste the `/skills` list if they want those included.
2. **Find overlap.** Group skills whose descriptions would match the same request. For each group, name the one to keep and what to fold into it.
3. **Check descriptions.** Flag any that lack a clear trigger ("Use when…") or a near-miss exclusion ("Not for…").
4. **Check routing drift.**
   - Rows in `$ENSO_HOME/system/ROUTING.md` that point to skills that don't exist. Claude Code built-ins (`/code-review`, `/simplify`, `/verify`, `/run`, `/debug`, `/doctor`, `/batch`, `/loop`, `/schedule`, `/deep-research`, `/update-config`, `/fewer-permission-prompts`, plan mode) are valid even though they have no files.
   - Ensō skills that have no row.
5. **Report** as one table, `Skill | Source | Issue | Proposal (keep / merge into X / delete / rewrite description)`, followed by a short list of the routing-table edits needed.
6. Apply only the items the user approves, using `skill-forge` for any rewrites.
