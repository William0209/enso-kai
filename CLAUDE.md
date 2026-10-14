# Ensō-kai — repo instructions

This repo is the **template** for an Ensō system: a lean Claude Code setup built from one shared memory, a routing table and a few single-purpose skills. People create their own system from it with GitHub's "Use this template" button. This file covers working *on* the template. The system's runtime instructions live in `system/CLAUDE.md`.

## Layout

| Path | What it is |
|---|---|
| `system/CLAUDE.md` | Global instructions, imported into `~/.claude/CLAUDE.md` by the installer |
| `system/MEMORY-GUIDE.md` | How memory is saved, indexed, read and maintained; imported by `system/CLAUDE.md` |
| `system/ROUTING.md` | Task → tool table, imported by `system/CLAUDE.md` |
| `system/skills/<name>/SKILL.md` | Baseline skills, linked into `~/.claude/skills/` |
| `system/memory/` | Memory directory (`autoMemoryDirectory`). **Stays empty in this template** |
| `scripts/install.ps1`, `scripts/install.sh` | Installers for Windows and macOS/Linux; `-Uninstall` / `--uninstall` reverses them |
| `secrets/` | Secrets guide and `env.example`. Plaintext secrets are gitignored |

## Rules for changes

- **Keep the template personal-data-free.** No memories, names, keys or machine paths. `system/memory/` holds only an empty `MEMORY.md` index (section headings only) and the `sessions/` and `archive/` placeholders. `inbox/` is gitignored and must never be committed.
- **Never install this template as a live system** while developing it. The installer would point `autoMemoryDirectory` here and real memories would land in the template. Test against a throwaway home instead:
  - Windows: `./scripts/install.ps1 -ClaudeHome <temp dir>`, then `-Uninstall`
  - macOS/Linux/WSL: `CLAUDE_HOME=<temp dir> sh scripts/install.sh`, then `--uninstall`
  Check that both installers stay idempotent and that uninstall restores the original state.
- **Skills follow `system/skills/skill-forge/SKILL.md`**: one job each, a "Not for…" clause, and a row in `ROUTING.md`.
- **Don't add skills that duplicate Claude Code built-ins** (`/code-review`, `/simplify`, `/verify`, `/run`, `/deep-research`, `/batch`, `/loop`, plan mode). Route to them in `ROUTING.md` instead. Skill names must not clash with built-in commands; for example, `/resume` is taken, which is why the session-start skill is `/begin`.
- Keep `system/CLAUDE.md` short. It loads in every session for every user.
- Keep the PowerShell installer compatible with Windows PowerShell 5.1 (no `-AsHashtable`, no ternaries, ASCII-only output).
