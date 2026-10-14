---
name: wrap
description: End a work session by summarising what changed, saving the insights worth keeping and writing resume state for next time.
disable-model-invocation: true
---

# Wrap

1. **Summarise the work** from this conversation plus git (`git status --short`, `git diff --stat`, `git log --oneline` for commits made this session). Keep it to 3–5 bullets.
2. **Propose memories.** List up to 5 candidates. Only include things that are *not* derivable from the code or git history: decisions and their reasons, user corrections, non-obvious fixes, external references. For each, show the type and a one-line description. Save only the ones the user approves, following the Memory protocol. Update existing memories rather than duplicating them.
3. **Write state** to `<memory dir>/sessions/<slug>.md` (slug = git top-level folder name, or the working directory's):
   ```markdown
   last_task: <what we were doing>
   last_branch: <current branch or "-">
   stopped_at: <ISO 8601 timestamp>
   one_liner: <where we stopped and what's next, ≤ 120 chars>
   ```
4. **Flag loose ends**: uncommitted changes, failing tests, unpushed commits. Don't commit or push the project for the user.
5. Suggest `/sync` if memories or state changed and the user works on more than one device.
