# Laravel + Quasar + Docker

REST API (Laravel 12) + Frontend (Quasar SSR) с автоматической настройкой SSL.

## Требования

- Docker >= 20.10
- Docker Compose >= 2.0

## Продакшен (по умолчанию)

По умолчанию проект настроен на продакшен среду:

```bash
# Настройте MySQL
nano mysql/.env

# Настройте Laravel API
cd api && cp .env.example .env && nano .env
# Укажите: APP_URL=https://ваш-ip
cd ..

# Настройте переменные окружения (опционально)
cp .env.prod.example .env

# Запустите (простая команда для продакшена)
chmod +x start-prod.sh
./start-prod.sh

# Или напрямую через Docker Compose
docker compose up -d --build
```

Откройте порты: `sudo ufw allow 80/tcp && sudo ufw allow 443/tcp`

Сайт доступен: https://ваш-ip

## Локальная разработка

Для разработки используйте конфигурационный файл `docker-compose.dev.yml`:

```bash
# Настройте MySQL
nano mysql/.env

# Настройте Laravel API
cd api && cp .env.example .env && nano .env
cd ..

# Запустите в режиме разработки
chmod +x start-dev.sh
./start-dev.sh

# Или напрямую через Docker Compose
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

Сайт доступен: https://localhost:8096

## Основные отличия режимов

### Продакшен (по умолчанию)
- Порты: 80, 443
- SSL: Let's Encrypt с IP
- Frontend: Production build
- NODE_ENV: production

### Разработка (с docker-compose.dev.yml)
- Порты: 8095, 8096
- SSL: Самоподписанные сертификаты
- Frontend: Development с HMR
- NODE_ENV: development

## Команды

```bash
# Логи
docker compose logs -f

# Логи конкретного сервиса
docker compose logs -f nginx

# Остановка
docker compose down

# Перезапуск
docker compose restart nginx

# Пересборка конкретного сервиса
docker compose up -d --build nginx
```

## Структура проекта

- `docker-compose.yml` - основная конфигурация (продакшен)
- `docker-compose.dev.yml` - переопределения для разработки
- `start-prod.sh` - скрипт запуска продакшена
- `start-dev.sh` - скрипт запуска разработки
