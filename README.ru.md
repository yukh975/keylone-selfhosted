# Keylone — Self-Hosted

Самостоятельное развёртывание [Keylone](https://keylone.app) — открытого зашифрованного менеджера паролей.

Использует готовый Docker-образ. Исходный код не требуется.

## Требования

- Docker 24+ с плагином Compose
- Linux-сервер (VPS, выделенный или Raspberry Pi)
- Доменное имя (опционально, но рекомендуется для HTTPS)

## Быстрый старт

```bash
git clone https://github.com/yukh975/keylone-selfhosted.git
cd keylone-selfhosted
chmod +x setup.sh update.sh
./setup.sh
```

Скрипт выполнит следующие шаги:
1. Запросит доменное имя
2. Сгенерирует случайный пароль базы данных и JWT-секрет
3. Скачает Docker-образ
4. Запустит Keylone + PostgreSQL

Откройте **http://localhost:3000** (или ваш домен) для регистрации первого аккаунта.

---

## Варианты развёртывания

### Встроенный PostgreSQL (рекомендуется)

Использует включённый контейнер PostgreSQL. Всё работает в Docker.

```bash
./setup.sh          # первый запуск
./update.sh         # обновление до последней версии
docker compose logs -f
docker compose down
```

### Внешний PostgreSQL

Если у вас уже есть экземпляр PostgreSQL:

```bash
chmod +x setup.external.sh
./setup.external.sh
```

Скрипт сгенерирует `.env` со случайным JWT-секретом и запросит доменное имя.
**После паузы отредактируйте `.env` и укажите `DATABASE_URL` для подключения к вашему PostgreSQL:**

```env
DATABASE_URL=postgresql://user:password@host:5432/keylone
```

Если PostgreSQL запущен на хост-машине (не в Docker):
```env
DATABASE_URL=postgresql://user:password@host.docker.internal:5432/keylone
```

Затем нажмите Enter — скрипт скачает образ и запустит Keylone.

---

## Caddy + HTTPS (рекомендуется)

Caddy автоматически получает и обновляет сертификаты Let's Encrypt.

Установка Caddy: https://caddyserver.com/docs/install

Добавьте в `/etc/caddy/Caddyfile`:

```caddy
vault.example.com {
    reverse_proxy localhost:3000
}
```

```bash
systemctl reload caddy
```

Готово — никаких дополнительных команд для сертификата не нужно. Caddy сам управляет HTTPS и редиректом HTTP→HTTPS.

---

## Nginx + HTTPS (Let's Encrypt)

Пример конфигурации nginx (поместите в `/etc/nginx/sites-available/keylone`):

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

Получите бесплатный сертификат:
```bash
certbot --nginx -d vault.example.com
```

При работе через HTTPS укажите в `.env`:
```
WEBAUTHN_RP_ID=vault.example.com
WEBAUTHN_ORIGIN=https://vault.example.com
```

---

## Обновление

```bash
./update.sh
```

Скачивает последний образ и перезапускает контейнер. Данные PostgreSQL сохраняются.

---

## Резервное копирование

Данные хранятся в Docker-томе `keylone-postgres-data`.

```bash
# Резервная копия
./backup.sh
# или вручную:
docker exec keylone-postgres pg_dump -U keylone keylone | gzip > keylone-backup-$(date +%Y%m%d).sql.gz

# Восстановление
gunzip -c keylone-backup-20260406.sql.gz | docker exec -i keylone-postgres psql -U keylone keylone
```

Также сохраните файл `.env` — он содержит учётные данные базы данных и JWT-секрет.

---

## Переменные окружения

| Переменная | Описание |
|---|---|
| `POSTGRES_PASSWORD` | Пароль PostgreSQL |
| `JWT_SECRET` | Секрет для подписи JWT (минимум 32 символа) |
| `WEBAUTHN_RP_ID` | Домен для passkeys (например, `vault.example.com`) |
| `WEBAUTHN_ORIGIN` | Полный URL источника (например, `https://vault.example.com`) |
| `TELEGRAM_PROXY` | SOCKS5/HTTP прокси для Telegram (опционально) |

---

## Лицензия

Keylone является проприетарным программным обеспечением. Этот репозиторий содержит только конфигурацию для развёртывания.
