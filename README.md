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

If you already have a PostgreSQL instance running on the host or a remote server:

```bash
chmod +x setup.external.sh
./setup.external.sh
```

The script asks for your domain, PostgreSQL credentials, and Docker network settings, then generates `.env` and starts Keylone.

#### Docker network subnet

Keylone uses a dedicated Docker bridge network to ensure the container always gets the same IP range. The default subnet is `192.168.222.0/30`. If this conflicts with an existing network in your environment, change `DOCKER_SUBNET` and `DOCKER_GATEWAY` in `.env` before starting:

```env
DOCKER_SUBNET=192.168.222.0/30
DOCKER_GATEWAY=192.168.222.1
```

#### PostgreSQL: allow connections from Docker

When Keylone runs in Docker and PostgreSQL is on the host, connections arrive from the Docker bridge subnet. You must allow this in `pg_hba.conf` (usually `/etc/postgresql/*/main/pg_hba.conf` or `/var/lib/pgsql/data/pg_hba.conf`):

```
host    keylone    keylone    192.168.222.0/30    md5
```

Reload PostgreSQL after editing:
```bash
systemctl reload postgresql
```

If you changed `DOCKER_SUBNET` — use that subnet in `pg_hba.conf` instead.

#### Firewall

If your server uses a restrictive firewall (iptables INPUT policy DROP), you must explicitly allow port 5432 from the Docker subnet:

```bash
iptables -I INPUT -s 192.168.222.0/30 -p tcp --dport 5432 -j ACCEPT
iptables-save > /etc/sysconfig/iptables    # persist across reboots (RHEL/CentOS)
# or:
iptables-save > /etc/iptables/rules.v4     # persist across reboots (Debian/Ubuntu)
```

If you use `firewalld`:
```bash
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.222.0/30" port port="5432" protocol="tcp" accept'
firewall-cmd --reload
```

> **Note:** If you changed `DOCKER_SUBNET`, replace `192.168.222.0/30` in the commands above with your custom subnet.

> **Bundled PostgreSQL** does not require any of these steps — both containers share the same Docker network and communicate directly.

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
