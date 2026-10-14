---
name: onboard
description: First-run interview that seeds a new Ensō brain with the user's profile, preferences and active projects, and reviews any imported memories.
disable-model-invocation: true
---

# Onboard

This seeds the brain: a few good memories beat many vague ones.

1. **Check the install.** `ENSO_HOME` should be set and the memory directory should exist. If `MEMORY.md` already has entries, show them and ask whether to extend or start over (starting over means archiving, not deleting).
2. **Review imported memories** if `<memory dir>/inbox/` has any. The installer copies them there from the user's old per-project folders when run with `-ImportMemories`. For each source folder:
   - Name the project it belongs to (the folder name encodes its path, e.g. `C--Users-ana-Code-shop-api` → `shop-api`) and the number of memories.
   - Ask whether to bring it in. Work or client projects may not belong in a brain that syncs to a personal GitHub; skipping is fine.
   - For the folders the user approves, rewrite each memory to the guide's format (frontmatter, `project:` tag, absolute dates). Merge it with an existing memory if they overlap, and drop anything that fails the save test. Write a good index line for each.
   - Delete each processed inbox folder afterwards, whether approved or skipped. The originals stay in `~/.claude/projects/`.
3. **Interview in 3 short rounds** (skip anything the imported memories already answer) with `AskUserQuestion`, letting the user skip anything:
   - **Who:** name and how to address them, role, experience level, main languages and stacks.
   - **How:** preferred answer length and tone, things Claude should always or never do, and how much autonomy to take (ask first vs. just do it).
   - **What:** active projects (name, one-line goal, repo or folder) and external references they rely on (issue tracker, dashboards, docs).
4. **Write memories** following `MEMORY-GUIDE.md`:
   - one `user` memory for the profile,
   - one `feedback` memory per working rule (with **Why:** and **How to apply:**),
   - one `project` memory per active project (`project:` set to the repo name),
   - one `reference` memory per external resource.
   Add an index line to `MEMORY.md` for each.
5. **Secrets.** Ask whether they use API keys with Claude (MCP servers, CLIs). If they do, point them to `$ENSO_HOME/secrets/README.md`. Never ask them to paste a key into chat.
6. **Close** with a short summary of what was saved and the 3 rituals: `/begin` at the start of a session, `/wrap` at the end, and `/sync` to carry the brain to other devices.
