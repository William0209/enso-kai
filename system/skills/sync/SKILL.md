---
name: sync
description: Sync this Ensō system repo across devices — pull, secret-check, commit and push memory, skills and settings changes.
disable-model-invocation: true
---

# Sync

Works on the system repo at `$ENSO_HOME`, never on the current project.

1. **Locate.** If `ENSO_HOME` is unset, stop and tell the user to re-run the installer. Run all git commands with `git -C "$ENSO_HOME"`.
2. **Pull first:** `git pull --rebase --autostash`. On a conflict in a memory file, merge both versions by hand (they're plain markdown), keep the newer fact when they disagree, then continue the rebase. For any other conflict, stop and show it to the user.
3. **Secret check before committing.** Review `git status --short` and the diff of changed files:
   - No plaintext secrets files staged (`.env`, `*.dec.*`, `*.pem`, `*.key`).
   - No key-like strings in the diff: `sk-`/`sk_`, `pk_`/`rk_`, `ghp_`/`gho_`/`github_pat_`, `glpat-`, `xox[bpa]-`, `AKIA`, `AIza`, `-----BEGIN`, `Bearer `, or a long random string after `key`/`token`/`secret`/`password`.
   If anything matches, **stop**, unstage it and tell the user. Never commit it, even to a private repo.
4. **Commit:** `git add -A`, then `git commit -m "sync: <hostname> <YYYY-MM-DD>"`, listing changed memories or skills in the body. Skip this step if nothing changed.
5. **Push:** `git push`. Report what was pulled in and what was pushed, one line each.
