# Changelog

## [1.0.0] — 2026-04-06

First stable release.

### New Features
- **Password vault** — store logins, cards, secure notes, SSH keys
- **Zero-knowledge encryption** — server never sees your passwords; all data encrypted client-side with AES-256-GCM
- **Two-factor authentication** — TOTP (Google Authenticator, Authy, 2FAS)
- **Passkeys** — sign in with Face ID, Touch ID, YubiKey, or Windows Hello
- **Recovery key** — backup access to your vault if you forget your master password
- **Password generator** — passwords, passphrases (EFF wordlist), PINs with entropy indicator
- **Import** — Keylone JSON, Bitwarden JSON, Chrome/Edge, Firefox, Safari, 1Password, LastPass, KeePass XML, Dashlane, NordPass
- **Export** — Keylone JSON, with optional password protection
- **Breach check** — check passwords against HaveIBeenPwned database anonymously
- **Folders** — unlimited nesting, drag & drop
- **File attachments** — attach files to any item (up to 10 MB, encrypted)
- **Telegram notifications** — login alerts and password reset links via Telegram bot
- **Admin panel** — user management, registration control, password history policy, SMTP/Telegram setup
- **Browser extensions** — Chrome, Firefox, Safari with autofill
- **Desktop app** — macOS and Windows (Tauri)
- **Dark / Light theme**
- **Russian and English UI** — browser locale auto-detected

### Infrastructure
- Pre-built Docker image at `ghcr.io/yukh975/keylone:latest`
- Bundled PostgreSQL option (quickstart) and external PostgreSQL option
- Automated image build on every release via GitHub Actions
- `setup.sh` / `setup.external.sh` — one-command deployment with auto-generated secrets
- `update.sh` — pull latest image without touching the database
- `backup.sh` — database dump with restore instructions
