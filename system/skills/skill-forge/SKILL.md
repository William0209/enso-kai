---
name: skill-forge
description: Create a new skill or change an existing one so it follows Ensō's house rules and gets a routing-table row. Use when the user wants a new skill, slash command or reusable workflow, or wants to edit one. Not for auditing all skills at once (use /audit) or for settings and hooks (use /update-config).
---

# Skill forge

A skill earns its place only if it does one job no other tool already does.

## 1. Check for overlap first
- Read `ROUTING.md` and the `description` of every skill in `$ENSO_HOME/system/skills/`.
- Compare against Claude Code's built-ins (`/code-review`, `/simplify`, `/verify`, `/run`, `/deep-research`, `/batch`, `/loop`, plan mode).
- If something already covers most of the job, **extend it** or propose doing that instead. Two skills that match the same request make routing random.

## 2. Decide where it lives
| Scope | Location |
|---|---|
| Useful in every project | `$ENSO_HOME/system/skills/<name>/SKILL.md` (synced) |
| Only this project | `<project>/.claude/skills/<name>/SKILL.md` |

## 3. Decide who triggers it
- **Capability** (Claude picks it when relevant): default frontmatter.
- **Ritual** (only the user runs it as `/name`): add `disable-model-invocation: true`.

## 4. Write it
```markdown
---
name: kebab-case-verb-or-noun
description: <Does X>. Use when <trigger situation>. Not for <near miss> (use <other tool>).
---

# Title
Numbered steps. Concrete commands. A stop rule where the work could loop.
```
- The description is the routing rule, so put the key use case first and keep it under ~300 characters.
- Keep the body under ~80 lines. Move long reference material into a sibling file and link it.
- Refer to the system repo as `$ENSO_HOME`, never as a hard-coded path.

## 5. Register it
- Add one row to the right section of `ROUTING.md`, and add the skill to the "Not" column of any rows it now displaces.
- Tell the user the skill's name, how it's triggered and the routing row you added.
