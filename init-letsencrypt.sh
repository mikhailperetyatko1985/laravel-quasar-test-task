#!/bin/bash

# Скрипт инициализации Let's Encrypt для IP адреса

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Инициализация Let's Encrypt ===${NC}"

# Проверка наличия docker compose
if ! docker compose version > /dev/null 2>&1; then
  echo -e "${RED}Error: docker compose is not installed.${NC}" >&2
  exit 1
fi

# Получение IP адреса сервера
read -p "Введите IP адрес вашего сервера: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo -e "${RED}IP адрес не может быть пустым${NC}"
    exit 1
fi

echo -e "${YELLOW}IP адрес сервера: $SERVER_IP${NC}"

# Проверка существующих данных
if [ -d "./certbot/conf/live/cert" ]; then
  read -p "Существующие сертификаты найдены. Удалить их? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

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

# Создание временного самоподписанного сертификата
echo -e "${YELLOW}Создание временного самоподписанного сертификата...${NC}"

mkdir -p "./certbot/conf/live/cert"

docker compose $COMPOSE_FILES run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
    -keyout '/etc/letsencrypt/live/cert/privkey.pem' \
    -out '/etc/letsencrypt/live/cert/fullchain.pem' \
    -subj '/CN=localhost'" certbot

echo -e "${GREEN}Временный сертификат создан${NC}"

# Запуск nginx
echo -e "${YELLOW}Запуск nginx...${NC}"
docker compose $COMPOSE_FILES up --force-recreate -d nginx

# Удаление временного сертификата
echo -e "${YELLOW}Удаление временного сертификата...${NC}"
docker compose $COMPOSE_FILES run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/cert && \
  rm -Rf /etc/letsencrypt/archive/cert && \
  rm -Rf /etc/letsencrypt/renewal/cert.conf" certbot

# Примечание: Let's Encrypt не поддерживает выдачу сертификатов для IP адресов
# Для работы HTTPS с IP нужно использовать самоподписанные сертификаты
echo -e "
${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${RED}ВАЖНО: Let's Encrypt не выдает сертификаты для IP адресов!${NC}

Для работы HTTPS с IP адресом доступны следующие варианты:

1. ${GREEN}Использовать самоподписанный сертификат${NC} (текущая реализация)
   Запустите: ./create-self-signed-cert.sh

2. ${GREEN}Получить бесплатный домен${NC} (например, на freenom.com или noip.com)
   и использовать Let's Encrypt с доменом

3. ${GREEN}Купить домен${NC} и настроить DNS на ваш IP адрес

${YELLOW}Для тестирования можно использовать самоподписанный сертификат.${NC}
${YELLOW}Браузеры будут показывать предупреждение о небезопасном соединении,${NC}
${YELLOW}которое можно пропустить для локального/тестового окружения.${NC}
${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
"

read -p "Создать самоподписанный сертификат сейчас? (y/N) " create_cert
if [ "$create_cert" = "Y" ] || [ "$create_cert" = "y" ]; then
    ./create-self-signed-cert.sh
fi

echo -e "${GREEN}Инициализация завершена!${NC}"
