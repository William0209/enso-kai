# Memory guide

Memory lives in the `autoMemoryDirectory` (`system/memory/`), shared by every project and synced across devices. It is plain markdown: Claude finds a memory through its index line and Grep, not by meaning. **A memory nobody can find is the same as no memory**, so the index line matters as much as the fact.

## What to save
Save it only if all three are true:
1. **It would change what you do** in a future session.
2. **It can't be derived** from the code, git history or a CLAUDE.md.
3. **It's confirmed**: the user said it, or it was verified. No guesses.

| Type | Save | Example |
|---|---|---|
| `user` | Role, expertise, preferences | "Prefers short answers, tables over prose" |
| `feedback` | Corrections and approaches the user confirmed, with the reason | "Don't mock the DB in integration tests: a mock hid a broken migration" |
| `project` | Decisions and why, constraints, deadlines, current direction | "EcoStay: schema + webhooks next; planning frozen" |
| `reference` | Where things live outside the repo | "Bugs tracked in Linear project INGEST" |

**Never save:** secrets, code structure, how a bug was fixed (that's in the commit), task progress (use `/wrap`), raw conversation, or anything already in a CLAUDE.md.

## When to save
- **Right away:** when the user says "remember…", corrects you, or confirms a non-obvious approach.
- **At a decision:** when a choice is made along with its reason.
- **At `/wrap`:** sweep for anything missed. Don't save the same thing twice.

## Writing a memory
- **Search first:** Grep the memory dir for the subject. If it already exists, **update** it; don't create a near-duplicate.
- **File:** `<slug>.md`, one fact, at most ~30 lines. Split anything bigger.
  ```markdown
  ---
  name: <slug>
  description: <one line: what it is and when it matters>
  type: user | feedback | project | reference
  project: <repo-name>          # omit when it applies everywhere
  ---
  <The fact, first line.>
  **Why:** <reason>             # feedback and project
  **How to apply:** <rule>      # feedback and project
  ```
- **Dates are absolute** (2026-10-14, not "next Friday"). Link related memories with `[[slug]]`.
- **Contradictions:** the newer confirmed fact wins. Rewrite the memory; don't append "UPDATE:".

## Writing the index line (this is what makes recall work)
`- [Title](file.md) — hook`
- The **hook names the words a future question would use**, including synonyms: `JWT auth: 15-min access + 7-day refresh tokens (login, session, token expiry)`.
- Put the project name first for project memories: `EcoStay — …`.
- Keep it under ~150 characters, one line per memory, grouped under `## User`, `## Feedback`, `## Project` and `## Reference`.

## Reading
- The index loads every session. Open a memory file when its line is relevant to the task.
- If the index finds nothing but the topic feels familiar, **Grep the memory files' contents** before concluding there's no memory.
- **Verify before acting:** if a memory names a file, function, flag or command, check that it still exists. If what you observe now contradicts a memory, trust the observation and fix the memory.

## Keeping it healthy
- **Limits:** index at most 150 lines (only 200 load); memory files at most ~30 lines.
- **Run `/prune`** about monthly, or when the index passes 120 lines. `/begin` reminds you when it's due.
- **Archive** finished or dormant project memories (it's reversible). **Delete** only memories that are wrong or duplicated.
- `sessions/` holds per-project resume state, written by `/wrap` and read by `/begin`. `archive/` holds retired memories. Neither is indexed.
- **Sync conflicts** (after `/sync`): keep both sides' facts, let the newer one win where they disagree, and keep exactly one index line per file.
