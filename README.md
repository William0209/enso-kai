# Ensō-kai 円相

**The open circle.** A starter for growing your own AI agent system on top of [Claude Code](https://code.claude.com).

In Zen painting, an ensō drawn with a gap is deliberately unfinished: it leaves room to grow. This template is that circle. It gives you the structure (memory, routing, a few sharp skills), and your own brain grows into it as you work.

## Philosophy

- **Balance over volume.** A small set of tools, each with one clear job, and no lookalikes competing for the same task.
- **One memory, everywhere.** Claude Code's built-in auto memory is pointed at this repo, so every project and every device shares one brain.
- **Memory is maintained.** Facts are verified before use and pruned when stale. Good forgetting is half of good memory.
- **Built-ins first.** Where Claude Code already has a tool (`/code-review`, `/verify`, `/deep-research`, …), the routing table points to it instead of reinventing it.

## What's inside

```
system/
├── CLAUDE.md        # global instructions + memory protocol (imported into ~/.claude/CLAUDE.md)
├── ROUTING.md       # task → tool table: one task, one tool
├── memory/          # your brain (Claude Code autoMemoryDirectory) — starts empty
│   ├── MEMORY.md    # index, one line per memory
│   ├── sessions/    # per-project resume state
│   └── archive/     # retired memories
└── skills/          # 8 baseline skills, linked into ~/.claude/skills/
scripts/             # install.ps1 (Windows) · install.sh (macOS / Linux / WSL)
secrets/             # how to keep API keys encrypted in your repo
```

### Baseline skills

| Skill | Triggered by | Job |
|---|---|---|
| `root-cause` | Claude, when something is broken | Prove the cause before fixing |
| `skill-forge` | Claude, when you want a new skill | Create or edit skills under the house rules and register them in the routing table |
| `/onboard` | You, once | Interview that seeds your brain with your profile, preferences and projects |
| `/begin [task]` | You, at session start | Load where you left off, plus the relevant memories |
| `/wrap` | You, at session end | Summarise, save what's worth keeping, write resume state |
| `/prune` | You, now and then | Memory health check: duplicates, stale or wrong facts, leaked secrets |
| `/sync` | You, across devices | Pull, secret-check, commit and push your system repo |
| `/audit` | You, now and then | Find overlapping skills and routing drift |

Saving memories needs no skill: say "remember this: …" and Claude Code's auto memory writes it into `system/memory/`.

## Grow your own brain

1. Click **Use this template** → create a **private** repo of your own (e.g. `enso`).
2. Clone it somewhere permanent, for example `~/enso`.
3. Install:
   ```powershell
   ./scripts/install.ps1            # Windows (add -DryRun to preview)
   ```
   ```bash
   sh scripts/install.sh            # macOS / Linux / WSL (add --dry-run to preview)
   ```
   The installer is non-destructive. It links skills alongside any you already have, adds a single import line to `~/.claude/CLAUDE.md`, and merges three settings keys (`autoMemoryDirectory`, `env.ENSO_HOME`, and deny rules for secret files). Anything it would replace is backed up to `~/.claude/.enso-backup/`.
4. Restart Claude Code and run `/onboard`.
5. Work normally, using `/begin` and `/wrap` around sessions and `/sync` to carry your brain to other devices.

To remove it, run `./scripts/install.ps1 -Uninstall` or `sh scripts/install.sh --uninstall`.

### Get template updates

```bash
git remote add upstream https://github.com/<owner>/enso-kai.git
git pull upstream main
```

Updates flow **from** the template **into** your system, never the other way round. That keeps your memories and keys out of the template.

## Requirements

- Claude Code (recent version, for `autoMemoryDirectory` and skills)
- Git
- Windows PowerShell 5.1+ / PowerShell 7+, or `sh` + `python3` on macOS / Linux
- Optional: [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age) for encrypted secrets (see `secrets/README.md`)
