#!/bin/bash

# Скрипт создания самоподписанного SSL сертификата

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Создание самоподписанного SSL сертификата ===${NC}"

# Получение IP адреса
read -p "Введите IP адрес вашего сервера (или оставьте пустым для localhost): " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    SERVER_IP="localhost"
fi

echo -e "${YELLOW}Создание сертификата для: $SERVER_IP${NC}"

# Создание директорий
mkdir -p ./certbot/conf/live/cert

# Определение конфигурации Docker Compose
COMPOSE_FILES="-f docker-compose.yml"
if [ -f "docker-compose.prod.yml" ]; then
    read -p "Использовать продакшен конфигурацию? (y/N) " use_prod
    if [ "$use_prod" = "Y" ] || [ "$use_prod" = "y" ]; then
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.prod.yml"
        echo -e "${YELLOW}Используется продакшен конфигурация${NC}"
    fi
elif [ -f "docker-compose.dev.yml" ]; then
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.dev.yml"
    echo -e "${YELLOW}Используется dev конфигурация${NC}"
fi

# Создание самоподписанного сертификата со сроком действия 365 дней
docker compose $COMPOSE_FILES run --rm --entrypoint "\
  openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout '/etc/letsencrypt/live/cert/privkey.pem' \
    -out '/etc/letsencrypt/live/cert/fullchain.pem' \
    -subj '/C=RU/ST=Moscow/L=Moscow/O=Development/OU=IT/CN=$SERVER_IP' \
    -addext 'subjectAltName=IP:$SERVER_IP'" certbot

echo -e "${GREEN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Самоподписанный сертификат успешно создан!

Срок действия: 365 дней
IP/Домен: $SERVER_IP

${YELLOW}ВАЖНО:${NC}
- Браузеры будут показывать предупреждение
- Для production используйте настоящий домен и Let's Encrypt
- Для обновления сертификата запустите скрипт снова
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${NC}"

# Перезапуск nginx
echo -e "${YELLOW}Перезапуск nginx...${NC}"
docker compose $COMPOSE_FILES restart nginx

echo -e "${GREEN}Готово!${NC}"
