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

Если у вас уже есть экземпляр PostgreSQL на хосте или удалённом сервере:

```bash
chmod +x setup.external.sh
./setup.external.sh
```

Скрипт запросит домен, данные для подключения к PostgreSQL и параметры Docker-сети, затем сгенерирует `.env` и запустит Keylone.

#### Подсеть Docker-сети

Keylone использует выделенную Docker bridge-сеть с фиксированной адресацией — чтобы контейнер всегда получал одни и те же IP-адреса. По умолчанию используется подсеть `192.168.222.0/30`. Если она конфликтует с существующей сетью в вашем окружении, измените `DOCKER_SUBNET` и `DOCKER_GATEWAY` в `.env` до запуска:

```env
DOCKER_SUBNET=192.168.222.0/30
DOCKER_GATEWAY=192.168.222.1
```

#### PostgreSQL: разрешение подключений из Docker

Когда Keylone работает в контейнере, а PostgreSQL — на хосте, подключения приходят с адресов Docker bridge-сети. Необходимо разрешить их в `pg_hba.conf` (обычно `/etc/postgresql/*/main/pg_hba.conf` или `/var/lib/pgsql/data/pg_hba.conf`):

```
host    keylone    keylone    192.168.222.0/30    md5
```

После изменения перезагрузите PostgreSQL:
```bash
systemctl reload postgresql
```

Если вы изменили `DOCKER_SUBNET` — используйте свою подсеть вместо `192.168.222.0/30`.

#### Firewall

Если на сервере строгий firewall (политика iptables INPUT DROP), необходимо явно разрешить порт 5432 с адресов Docker-сети:

```bash
iptables -I INPUT -s 192.168.222.0/30 -p tcp --dport 5432 -j ACCEPT
iptables-save > /etc/sysconfig/iptables    # сохранить после перезагрузки (RHEL/CentOS)
# или:
iptables-save > /etc/iptables/rules.v4     # сохранить после перезагрузки (Debian/Ubuntu)
```

Если используете `firewalld`:
```bash
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.222.0/30" port port="5432" protocol="tcp" accept'
firewall-cmd --reload
```

> **Примечание:** Если вы изменили `DOCKER_SUBNET`, замените `192.168.222.0/30` на свою подсеть во всех командах выше.

> **Встроенный PostgreSQL** не требует никаких из этих настроек — оба контейнера находятся в одной Docker-сети и общаются напрямую.

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
