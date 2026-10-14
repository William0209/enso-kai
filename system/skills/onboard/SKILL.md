---
name: onboard
description: First-run interview that seeds a new Ensō brain with the user's profile, preferences and active projects.
disable-model-invocation: true
---

# Onboard

This seeds the brain: a few good memories beat many vague ones.

1. **Check the install.** `ENSO_HOME` should be set and the memory directory should exist. If `MEMORY.md` already has entries, show them and ask whether to extend or start over (starting over means archiving, not deleting).
2. **Interview in 3 short rounds** with `AskUserQuestion`, letting the user skip anything:
   - **Who:** name and how to address them, role, experience level, main languages and stacks.
   - **How:** preferred answer length and tone, things Claude should always or never do, and how much autonomy to take (ask first vs. just do it).
   - **What:** active projects (name, one-line goal, repo or folder) and external references they rely on (issue tracker, dashboards, docs).
3. **Write memories** following the Memory protocol in the system CLAUDE.md:
   - one `user` memory for the profile,
   - one `feedback` memory per working rule (with **Why:** and **How to apply:**),
   - one `project` memory per active project (`project:` set to the repo name),
   - one `reference` memory per external resource.
   Add an index line to `MEMORY.md` for each.
4. **Secrets.** Ask whether they use API keys with Claude (MCP servers, CLIs). If they do, point them to `$ENSO_HOME/secrets/README.md`. Never ask them to paste a key into chat.
5. **Close** with a short summary of what was saved and the 3 rituals: `/begin` at the start of a session, `/wrap` at the end, and `/sync` to carry the brain to other devices.
