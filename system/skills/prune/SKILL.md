---
name: prune
description: Run a memory health check (index drift, duplicates, stale or wrong facts, leaked secrets) and apply the approved cleanup.
disable-model-invocation: true
---

# Prune

A memory is only useful if it's still true. This keeps the brain small and correct.

## 1. Health report
Follow the rules in `MEMORY-GUIDE.md`. Run these checks on the memory directory and show the results as one table, `Check | Finding | Proposed action`:

| Check | How |
|---|---|
| Index drift | Files with no `MEMORY.md` line, and index lines pointing to missing files |
| Index size | `MEMORY.md` line count. Warn above 150 lines (only 200 load) |
| Index quality | Hooks too vague to be found (no subject words or synonyms, no project name) → rewrite per the guide |
| Duplicates | Memories with the same subject, or near-identical descriptions → merge |
| Wrong facts | Memories naming files, flags, commands or repos: check that each still exists → fix or delete |
| Stale | `project` memories untouched (`modified`) for 90+ days, or about finished work → archive |
| Format | Missing frontmatter fields (`name`, `description`, `type`) → repair |
| Secrets | Grep for key-like strings (`sk-`, `ghp_`, `gho_`, `xox`, `AKIA`, `-----BEGIN`, long base64) → **remove immediately**, then tell the user to rotate the key |

## 2. Apply what the user approves
- **Merge:** fold content into the better memory, delete the other, and fix any `[[links]]` that pointed to it.
- **Archive:** move the file to `archive/` and remove its index line. Archived memories can be restored by moving them back.
- **Delete:** only for facts that are wrong or duplicated.
- Rewrite `MEMORY.md` grouped by type, one line per memory.

## 3. Close
- Write `sessions/_health.md`, which `/begin` reads:
  ```markdown
  last_prune: <YYYY-MM-DD>
  memories: <count>
  index_lines: <count>
  ```
- Show before/after counts (memories, index lines) and suggest `/sync`.
