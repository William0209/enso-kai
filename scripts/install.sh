#!/usr/bin/env sh
# Install or uninstall this Enso system into Claude Code (macOS / Linux / WSL).
#   - Symlinks each folder in system/skills into $CLAUDE_HOME/skills
#   - Adds an @import of system/CLAUDE.md to $CLAUDE_HOME/CLAUDE.md
#   - Merges autoMemoryDirectory, env.ENSO_HOME and secret-file deny rules into settings.json (needs python3)
#   - Finds existing per-project memories (Claude Code stops reading them once Enso is active) and, with
#     --import-memories, copies them into system/memory/inbox (gitignored) for /onboard to review.
# Non-destructive: anything it would replace is moved to $CLAUDE_HOME/.enso-backup/<timestamp>/ first.
#
# Usage: scripts/install.sh [--uninstall] [--import-memories] [--dry-run]      (CLAUDE_HOME defaults to ~/.claude)
set -eu

UNINSTALL=0; DRY=0; IMPORT=0
for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=1 ;;
    --dry-run)   DRY=1 ;;
    --import-memories) IMPORT=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
SYSTEM="$REPO/system"
CLAUDE_HOME=${CLAUDE_HOME:-"$HOME/.claude"}
BACKUP="$CLAUDE_HOME/.enso-backup/$(date +%Y%m%d-%H%M%S)"
MARKER='<!-- enso: system instructions -->'

# Prefer ~/ paths so values read the same on every device.
claude_path() { case "$1" in "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;; *) printf '%s' "$1" ;; esac; }
MEMORY_DIR=$(claude_path "$SYSTEM/memory")
IMPORT_LINE="@$(claude_path "$SYSTEM/CLAUDE.md" | sed 's/ /\\ /g')"

say()  { printf '  %s\n' "$1"; }
step() { msg=$1; shift; if [ "$DRY" -eq 1 ]; then say "[dry-run] $msg"; else "$@"; say "$msg"; fi; }
backup() { mkdir -p "$BACKUP"; mv "$1" "$BACKUP/"; }

echo "Enso $([ $UNINSTALL -eq 1 ] && echo uninstall || echo install): $REPO -> $CLAUDE_HOME"

# ---------------------------------------------------------------- skills
echo "Skills"
[ "$UNINSTALL" -eq 1 ] || mkdir -p "$CLAUDE_HOME/skills"
for src in "$SYSTEM"/skills/*/; do
  src=${src%/}; name=$(basename "$src"); dest="$CLAUDE_HOME/skills/$name"
  ours=0; [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ] && ours=1
  if [ "$UNINSTALL" -eq 1 ]; then
    [ "$ours" -eq 1 ] && step "unlinked $name" rm "$dest"
    continue
  fi
  if [ "$ours" -eq 1 ]; then say "ok        $name"; continue; fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then step "backed up existing $name" backup "$dest"; fi
  step "linked    $name" ln -s "$src" "$dest"
done

# ---------------------------------------------------------------- CLAUDE.md import
echo "CLAUDE.md"
CLAUDE_MD="$CLAUDE_HOME/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && grep -qxF "$IMPORT_LINE" "$CLAUDE_MD"; then has=1; else has=0; fi
remove_import() { tmp="$CLAUDE_MD.tmp"; grep -vxF -e "$MARKER" -e "$IMPORT_LINE" "$CLAUDE_MD" > "$tmp" || true; mv "$tmp" "$CLAUDE_MD"; }
add_import() { mkdir -p "$CLAUDE_HOME"; { [ -s "$CLAUDE_MD" ] && printf '\n'; printf '%s\n%s\n' "$MARKER" "$IMPORT_LINE"; } >> "$CLAUDE_MD"; }
if [ "$UNINSTALL" -eq 1 ]; then
  [ "$has" -eq 1 ] && step "removed Enso import" remove_import
elif [ "$has" -eq 1 ]; then
  say "ok        import present"
else
  step "added     $IMPORT_LINE" add_import
fi

# ---------------------------------------------------------------- existing memories
if [ "$UNINSTALL" -eq 0 ]; then
  echo "Existing memories"
  found=0
  for dir in "$CLAUDE_HOME"/projects/*/memory; do
    [ -d "$dir" ] || continue
    n=$(find "$dir" -maxdepth 1 -type f -name '*.md' ! -name MEMORY.md | wc -l | tr -d ' ')
    [ "$n" -gt 0 ] || continue
    found=1; proj=$(basename "$(dirname "$dir")")
    say "$(printf '%4s' "$n") memories in projects/$proj"
    if [ "$IMPORT" -eq 1 ]; then
      step "copied    projects/$proj -> memory/inbox" sh -c 'mkdir -p "$2" && cp -R "$1"/. "$2"/' _ "$dir" "$SYSTEM/memory/inbox/$proj"
    fi
  done
  if [ "$found" -eq 0 ]; then say "none found"
  elif [ "$IMPORT" -eq 1 ]; then say "Run /onboard to review them into your brain. memory/inbox is gitignored until then."
  else
    say "Claude Code stops reading these once Enso is active (they are not deleted)."
    say "Re-run with --import-memories to copy them into memory/inbox for /onboard to review."
  fi
fi

# ---------------------------------------------------------------- settings.json
echo "settings.json"
if ! command -v python3 >/dev/null 2>&1; then
  say "python3 not found: add these to $CLAUDE_HOME/settings.json by hand:"
  say "  \"autoMemoryDirectory\": \"$MEMORY_DIR\", \"env\": {\"ENSO_HOME\": \"$REPO\"}"
  exit 0
fi
[ "$DRY" -eq 1 ] && { say "[dry-run] would merge autoMemoryDirectory, ENSO_HOME, deny rules"; exit 0; }
mkdir -p "$CLAUDE_HOME"
UNINSTALL=$UNINSTALL MEMORY_DIR=$MEMORY_DIR REPO=$REPO SETTINGS="$CLAUDE_HOME/settings.json" BACKUP=$BACKUP python3 - <<'PY'
import json, os, shutil
path, backup = os.environ["SETTINGS"], os.environ["BACKUP"]
uninstall, memory, repo = os.environ["UNINSTALL"] == "1", os.environ["MEMORY_DIR"], os.environ["REPO"]
deny_rules = ["Read(**/.env)", "Read(**/.env.local)", "Read(**/*.pem)", "Read(**/*.key)", "Read(**/secrets/*.dec.*)"]
s = json.load(open(path)) if os.path.exists(path) and open(path).read().strip() else {}
before = json.dumps(s, sort_keys=True)
env, perms = s.setdefault("env", {}), s.setdefault("permissions", {})
deny = perms.get("deny", [])
if uninstall:
    if s.get("autoMemoryDirectory") == memory: s.pop("autoMemoryDirectory")
    if env.get("ENSO_HOME") == repo: env.pop("ENSO_HOME")
    deny = [d for d in deny if d not in deny_rules]
else:
    s["autoMemoryDirectory"], env["ENSO_HOME"] = memory, repo
    deny = deny + [d for d in deny_rules if d not in deny]
if deny: perms["deny"] = deny
else: perms.pop("deny", None)
for key in ("env", "permissions"):
    if not s[key]: s.pop(key)
if json.dumps(s, sort_keys=True) == before:
    print("  ok        no changes")
else:
    if os.path.exists(path):
        os.makedirs(backup, exist_ok=True); shutil.copy(path, os.path.join(backup, "settings.json"))
    json.dump(s, open(path, "w"), indent=2); open(path, "a").write("\n")
    print("  autoMemoryDirectory, ENSO_HOME, deny rules " + ("removed" if uninstall else "set"))
PY

if [ "$UNINSTALL" -eq 0 ]; then
  printf '\nDone. Restart Claude Code, then run /onboard.\n'
  [ -d "$BACKUP" ] && echo "Backups: $BACKUP"
fi
exit 0
