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
| Index quality | Check **every** index line: the hook needs the subject plus 2+ words or synonyms a future question would use, and project memories must start with the project slug. Hooks of 1–3 generic words (`— hosting`, `— ci`) fail → rewrite per the guide |
| Duplicates | Memories with the same subject, or near-identical descriptions → merge |
| Wrong facts | Memories naming files, flags, commands or repos: check that each still exists → fix or delete |
| Stale | `project` memories untouched (`modified`) for 90+ days, or about finished work → archive |
| Format | Missing `name`, `description` or `metadata.type`, or a `project` memory without `metadata.project` → repair |
| Secrets | Grep for key-like strings (`sk-`/`sk_`, `pk_`/`rk_`, `ghp_`/`gho_`/`github_pat_`, `glpat-`, `xox[bpa]-`, `AKIA`, `AIza`, `-----BEGIN`, `Bearer `, or a long random string after `key`/`token`/`secret`/`password`) → **remove immediately**, then tell the user to rotate the key |

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
