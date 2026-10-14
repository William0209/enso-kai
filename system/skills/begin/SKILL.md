---
name: begin
description: Start a work session by loading where you left off in this project and the memories relevant to the task.
argument-hint: "[task]"
disable-model-invocation: true
---

# Begin

Fast and quiet: load context, show a few lines, get to work.

1. **Project slug** = folder name of `git rev-parse --show-toplevel`, or of the working directory outside git.
2. **Last state.** Read `<memory dir>/sessions/<slug>.md` if it exists. It has 4 fields: `last_task`, `last_branch`, `stopped_at` and `one_liner`.
3. **Git context** (skip outside git): `git branch --show-current`, `git status --short`, `git log -3 --oneline`.
4. **Recall.** From `MEMORY.md`, pick the entries whose index line starts with `<slug>` or whose `metadata.project` is `<slug>`, plus any whose descriptions match `$ARGUMENTS` or the last task. Read at most 5. Verify any file, flag or command they name still exists, and flag the ones that don't.
5. **Show**, in under 10 lines:
   ```
   Last time: <one_liner>  (<stopped_at>, branch <last_branch>)
   Now: branch <current>, <n> uncommitted files
   Context: <one line per memory used>
   Task: <$ARGUMENTS or "none given — what are we doing?">
   ```
6. **Memory health check (one line, only when due).** Read `<memory dir>/sessions/_health.md`. If `last_prune` is more than 30 days ago or missing while the index has 20+ entries, or `MEMORY.md` is over 120 lines, add: `Memory: last pruned <date>, index <n> lines — run /prune when convenient.`
7. If the branch differs from `last_branch` or there are uncommitted changes from before, mention it once. Then start the task.
