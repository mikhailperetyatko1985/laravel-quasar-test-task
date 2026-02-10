#!/bin/bash

# Скрипт получения Let's Encrypt сертификата для IP адреса
# Работает с 2026 года - Let's Encrypt поддерживает публичные IP

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Получение Let's Encrypt сертификата для IP ===${NC}"

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

# Проверка наличия docker compose
if ! docker compose version > /dev/null 2>&1; then
  echo -e "${RED}Error: docker compose is not installed.${NC}" >&2
  exit 1
fi

# Получение IP адреса сервера
read -p "Введите публичный IP адрес вашего сервера: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo -e "${RED}IP адрес не может быть пустым${NC}"
    exit 1
fi

# Проверка формата IP
if ! [[ $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${RED}Неверный формат IP адреса${NC}"
    exit 1
fi

echo -e "${YELLOW}IP адрес сервера: $SERVER_IP${NC}"

# Email для уведомлений Let's Encrypt
read -p "Введите email для уведомлений Let's Encrypt: " EMAIL

if [ -z "$EMAIL" ]; then
    echo -e "${RED}Email не может быть пустым${NC}"
    exit 1
fi

# Проверка существующих данных
if [ -d "./certbot/conf/live/cert" ]; then
  read -p "Существующие сертификаты найдены. Удалить их? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
  rm -rf ./certbot/conf/live/cert
  rm -rf ./certbot/conf/archive/cert
  rm -rf ./certbot/conf/renewal/cert.conf
fi

# Создание временного самоподписанного сертификата
echo -e "${YELLOW}Создание временного самоподписанного сертификата...${NC}"

mkdir -p "./certbot/conf/live/cert"

docker compose $COMPOSE_FILES run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
    -keyout '/etc/letsencrypt/live/cert/privkey.pem' \
    -out '/etc/letsencrypt/live/cert/fullchain.pem' \
    -subj '/CN=$SERVER_IP'" certbot

echo -e "${GREEN}Временный сертификат создан${NC}"

# Запуск/перезапуск nginx для HTTP-01 challenge
echo -e "${YELLOW}Запуск nginx...${NC}"
docker compose $COMPOSE_FILES up --force-recreate -d nginx

# Ожидание запуска nginx
echo -e "${YELLOW}Ожидание запуска nginx (10 сек)...${NC}"
sleep 10

# Удаление временного сертификата
echo -e "${YELLOW}Удаление временного сертификата...${NC}"
docker compose $COMPOSE_FILES run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/cert && \
  rm -Rf /etc/letsencrypt/archive/cert && \
  rm -Rf /etc/letsencrypt/renewal/cert.conf" certbot

# Получение настоящего сертификата от Let's Encrypt
echo -e "${YELLOW}Запрос сертификата Let's Encrypt для IP $SERVER_IP...${NC}"

# Используем certonly с webroot для HTTP-01 валидации
docker compose $COMPOSE_FILES run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  --cert-name cert \
  -d "$SERVER_IP"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Сертификат Let's Encrypt успешно получен!

IP адрес: $SERVER_IP
Email: $EMAIL

${YELLOW}ВАЖНО:${NC}
- Сертификаты для IP имеют короткий срок действия (~160 часов)
- Автоматическое обновление настроено в контейнере certbot
- Перезапустите nginx для применения нового сертификата
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${NC}"

    # Перезапуск nginx
    echo -e "${YELLOW}Перезапуск nginx для применения сертификата...${NC}"
    docker compose $COMPOSE_FILES restart nginx
    
    echo -e "${GREEN}Готово! Сертификат установлен и nginx перезапущен.${NC}"
else
    echo -e "
${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ошибка получения сертификата Let's Encrypt!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

Возможные причины:
1. ${YELLOW}IP адрес недоступен из интернета${NC}
2. ${YELLOW}Порт 80 закрыт файрволом${NC}
3. ${YELLOW}Nginx не отвечает на HTTP запросы${NC}
4. ${YELLOW}Путь /.well-known/acme-challenge/ недоступен${NC}

Проверьте:
- Файрвол: sudo ufw allow 80/tcp && sudo ufw allow 443/tcp
- Nginx логи: docker compose $COMPOSE_FILES logs nginx
- Доступность: curl http://$SERVER_IP/.well-known/acme-challenge/test

${YELLOW}Для временного решения используйте самоподписанный сертификат:${NC}
./create-self-signed-cert.sh
"
    exit 1
fi
