#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Путь к сертификатам
CERT_PATH="/etc/letsencrypt/live/cert"
CERT_FILE="$CERT_PATH/fullchain.pem"
KEY_FILE="$CERT_PATH/privkey.pem"

echo -e "${GREEN}=== Nginx Entrypoint ===${NC}"

# Проверка наличия сертификатов
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo -e "${YELLOW}SSL сертификаты не найдены. Создание самоподписанного сертификата...${NC}"
    
    # Создание директории для сертификатов
    mkdir -p "$CERT_PATH"
    
    # Генерация самоподписанного сертификата
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=RU/ST=Moscow/L=Moscow/O=Development/OU=IT/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Самоподписанный сертификат успешно создан${NC}"
        echo -e "${YELLOW}  Местоположение: $CERT_PATH${NC}"
        
        # Установка правильных прав доступа
        chmod 644 "$KEY_FILE"
        chmod 644 "$CERT_FILE"
        echo -e "${GREEN}✓ Права доступа установлены${NC}"
    else
        echo -e "${RED}✗ Ошибка при создании сертификата${NC}"
        echo -e "${YELLOW}  Попытка запуска без SSL...${NC}"
    fi
else
    echo -e "${GREEN}✓ SSL сертификаты найдены${NC}"
    
    # Проверка и исправление прав доступа
    if [ ! -r "$KEY_FILE" ]; then
        echo -e "${YELLOW}Исправление прав доступа для privkey.pem...${NC}"
        chmod 644 "$KEY_FILE"
    fi
fi

# Проверка конфигурации nginx
echo -e "${YELLOW}Проверка конфигурации nginx...${NC}"
nginx -t

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Конфигурация nginx корректна${NC}"
else
    echo -e "${RED}✗ Ошибка в конфигурации nginx${NC}"
    exit 1
fi

echo -e "${GREEN}=== Запуск nginx ===${NC}"

# Запуск crond для logrotate
crond

# Запуск nginx
exec nginx -g "daemon off;"
