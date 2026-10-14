# Secrets

Your system repo can carry your API keys, but **only encrypted**. A private repo is not a safe place for plaintext keys: they live on in git history, clones and backups, and one leaked GitHub token exposes them all.

The recommended setup is **sops + age**. The repo holds the encrypted file, and the only key that decrypts it stays outside the repo, with you.

## One-time setup

1. Install [sops](https://github.com/getsops/sops) and [age](https://github.com/FiloSottile/age):
   - Windows: `winget install Mozilla.SOPS FiloSottile.age`
   - macOS: `brew install sops age`
2. Create your age key. It is **never** committed; store a copy in your password manager.
   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt        # prints your public key: age1...
   ```
   On Windows, sops reads the key from `%APPDATA%\sops\age\keys.txt`. You can also point `SOPS_AGE_KEY_FILE` at the file.
3. Create `.sops.yaml` in the repo root with your **public** key (safe to commit):
   ```yaml
   creation_rules:
     - path_regex: secrets/.*\.enc\.env$
       age: age1yourpublickey...
   ```
4. Fill in your keys and encrypt them:
   ```bash
   cp secrets/env.example secrets/.env              # edit secrets/.env (gitignored)
   sops -e secrets/.env > secrets/secrets.enc.env   # commit this one
   ```

## On a new device

```bash
# restore ~/.config/sops/age/keys.txt from your password manager, then:
sops -d secrets/secrets.enc.env > secrets/.env
```

Load the variables into your shell profile, or reference them as `${VAR}` in MCP server configs, so Claude Code's tools can use them.

## Rules

- `secrets/.env` and any `*.dec.*` file are gitignored. `/sync` refuses to commit plaintext secrets.
- The installer adds deny rules so Claude can't read `.env`, `*.pem`, `*.key` or decrypted files.
- Never paste a key into chat or into a memory. If one leaks, rotate it.
