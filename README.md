# Keylone — Self-Hosted

Self-hosted deployment for [Keylone](https://keylone.app) — an open, encrypted password manager.

Uses a pre-built Docker image. No source code required.

## Requirements

- Docker 24+ with the Compose plugin
- A Linux server (VPS, dedicated, or Raspberry Pi)
- A domain name (optional, but recommended for HTTPS)

## Quickstart

```bash
git clone https://github.com/yukh975/keylone-selfhosted.git
cd keylone-selfhosted
chmod +x setup.sh update.sh
./setup.sh
```

The script will:
1. Ask for your domain name
2. Generate random database password and JWT secret
3. Pull the Docker image
4. Start Keylone + PostgreSQL

Open **http://localhost:3000** (or your domain) to register the first account.

---

## Options

### Bundled PostgreSQL (recommended)

Uses an included PostgreSQL container. Everything runs in Docker.

```bash
./setup.sh          # first run
./update.sh         # update to latest version
docker compose logs -f
docker compose down
```

### External PostgreSQL

If you already have a PostgreSQL instance:

```bash
chmod +x setup.external.sh
./setup.external.sh
```

The script will generate `.env` with a random JWT secret and ask for your domain.
**After the script pauses — edit `.env` and set `DATABASE_URL` to your PostgreSQL connection string:**

```env
DATABASE_URL=postgresql://user:password@host:5432/keylone
```

If PostgreSQL is running on the host machine (not in Docker):
```env
DATABASE_URL=postgresql://user:password@host.docker.internal:5432/keylone
```

Then press Enter to continue — the script will pull the image and start Keylone.

---

## Caddy + HTTPS (recommended)

Caddy obtains and renews Let's Encrypt certificates automatically.

Install Caddy: https://caddyserver.com/docs/install

Add to your `/etc/caddy/Caddyfile`:

```caddy
vault.example.com {
    reverse_proxy localhost:3000
}
```

```bash
systemctl reload caddy
```

That's it — no certificate commands needed. Caddy handles HTTPS and HTTP→HTTPS redirect automatically.

---

## Nginx + HTTPS (Let's Encrypt)

Example nginx config (place in `/etc/nginx/sites-available/keylone`):

```nginx
server {
    listen 80;
    server_name vault.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name vault.example.com;

    ssl_certificate     /etc/letsencrypt/live/vault.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/vault.example.com/privkey.pem;

    location / {
        proxy_pass         http://127.0.0.1:3000;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

Get a free certificate:
```bash
certbot --nginx -d vault.example.com
```

When running behind HTTPS, set in `.env`:
```
WEBAUTHN_RP_ID=vault.example.com
WEBAUTHN_ORIGIN=https://vault.example.com
```

---

## Updating

```bash
./update.sh
```

Pulls the latest image and restarts the container. PostgreSQL data is preserved.

---

## Backup

Your data lives in the Docker volume `keylone-postgres-data`.

```bash
# Backup
docker exec keylone-postgres pg_dump -U keylone keylone | gzip > keylone-backup-$(date +%Y%m%d).sql.gz

# Restore
gunzip -c keylone-backup-20240101.sql.gz | docker exec -i keylone-postgres psql -U keylone keylone
```

Also back up your `.env` file — it contains the database credentials and JWT secret.

---

## Environment Variables

| Variable | Description |
|---|---|
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `JWT_SECRET` | JWT signing secret (min 32 chars) |
| `WEBAUTHN_RP_ID` | Domain for passkeys (e.g. `vault.example.com`) |
| `WEBAUTHN_ORIGIN` | Full origin URL (e.g. `https://vault.example.com`) |
| `TELEGRAM_PROXY` | SOCKS5/HTTP proxy for Telegram (optional) |

---

## License

Keylone is proprietary software. This repository contains only deployment configuration.
