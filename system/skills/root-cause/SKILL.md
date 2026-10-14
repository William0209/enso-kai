---
name: root-cause
description: Find the proven root cause of a bug, failing test, crash or unexpected behaviour before changing any code. Use when something is broken and the cause isn't already known. Not for problems with Claude Code itself (use /debug) or for reviewing a diff (use /code-review).
---

# Root cause

Prove the cause first, then fix it. A fix without a proven cause is a guess.

1. **Reproduce.** Get the exact failing command, input or steps and run them. If you can't reproduce it, say so and gather more information before going further.
2. **Read the whole error.** Read the full message, stack trace and logs, not just the first line. Note the exact file and line.
3. **Narrow it down.** Check what changed (`git log -p`, `git diff`, recent dependency bumps). Bisect when the history is long. Shrink the input until the smallest failing case remains.
4. **One hypothesis at a time.** State it, predict what you would observe if it's true, then check. Don't stack speculative changes.
5. **Prove it.** The cause is proven when you can explain the failure end to end *and* a targeted check confirms it, such as a log line, a debugger value or a minimal repro.
6. **Fix minimally.** Change only what the cause requires. Then re-run the original repro and the related tests, and show the output.
7. **Record what's worth keeping.** If the lesson is non-obvious and would help next time, offer to save it as a `project` or `feedback` memory.

**Stop rule:** after 3 disproven hypotheses, stop. Report what you ruled out and what you would check next, then ask the user before continuing.
