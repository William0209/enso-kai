# Routing table

One task, one tool. When a request matches a row, use that tool; don't reach for a lookalike.

## Code and debugging

| Task | Use | Not |
|---|---|---|
| Find code, files, symbols | `Grep` / `Glob`, then `Read` | Bash `grep`/`find`; an Explore agent for a single lookup |
| Broad sweep across many files | Explore agent | Doing it inline when it would flood context |
| Something is broken, cause unknown | `root-cause` skill | Guess-and-patch |
| Problems with Claude Code itself | `/debug`, `/doctor` | `root-cause` |
| Review a diff for bugs | `/code-review` | `/simplify` |
| Clean up a diff (reuse, simplicity) | `/simplify` | `/code-review` |
| Prove a change works in the real app | `/verify`, `/run` | Claiming success from type checks alone |
| Same change across many files | `/batch` | Editing files one by one |
| Non-trivial multi-step work | Plan mode, then implement | Starting edits before the approach is agreed |

## Web and research

| Task | Use | Not |
|---|---|---|
| Quick fact or doc lookup | `WebSearch`, then `WebFetch` on the best hit | `/deep-research` |
| Read a known URL | `WebFetch` | Search |
| Cited multi-source report | `/deep-research` | A pile of ad-hoc searches |

## Memory and sessions

| Task | Use | Not |
|---|---|---|
| "Remember this…" | Built-in auto memory (see Memory protocol) | A new skill or a CLAUDE.md edit |
| "Add this rule to CLAUDE.md" | Edit the relevant CLAUDE.md | Memory |
| First run on a new machine or for a new user | `/onboard` | — |
| Start of a work session | `/begin [task]` | Re-explaining context by hand |
| End of a work session | `/wrap` | — |
| Memory health: dedupe, archive, verify | `/prune` | Ad-hoc edits to `MEMORY.md` |
| Pull/push the system across devices | `/sync` | Raw `git push` of the system repo |

## The system itself

| Task | Use | Not |
|---|---|---|
| Create or change a skill | `skill-forge` skill | Writing `SKILL.md` freehand |
| Check skills for overlap and routing drift | `/audit` | — |
| Change settings, hooks, permissions | `/update-config` | Hand-editing JSON blind |
| Reduce permission prompts | `/fewer-permission-prompts` | Blanket allow rules |
| Recurring or scheduled work | `/loop`, `/schedule` | Sleep loops |

<!-- Add a row whenever you add a skill. Project-specific tools go in that project's CLAUDE.md, not here. -->
