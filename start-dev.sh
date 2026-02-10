#!/bin/bash

# Скрипт для запуска dev окружения

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Запуск development окружения ===${NC}"

# Проверка наличия .env файла
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}.env файл не найден, создание из .env.example...${NC}"
    
    if [ -f ".env.example" ]; then
        cp .env.example .env
        
        # Установка dev значений
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/SSL_MODE=self-signed/SSL_MODE=self-signed/g" .env
        else
            # Linux
            sed -i "s/SSL_MODE=self-signed/SSL_MODE=self-signed/g" .env
        fi
        
        echo -e "${GREEN}.env файл создан (режим: self-signed)${NC}"
    else
        echo -e "${RED}.env.example не найден!${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}.env файл найден${NC}"
fi

# Остановка существующих контейнеров
echo -e "${YELLOW}Остановка существующих контейнеров...${NC}"
docker compose down

# Запуск контейнеров в dev режиме
echo -e "${GREEN}Запуск контейнеров в dev режиме...${NC}"
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

# Проверка статуса
if [ $? -eq 0 ]; then
    echo -e "
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Контейнеры успешно запущены (development)!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

Проверьте логи:
  ${YELLOW}docker compose logs -f${NC}

Проверьте статус:
  ${YELLOW}docker compose ps${NC}

Сайт будет доступен по адресу:
  ${GREEN}https://localhost:8096/${NC}
  ${GREEN}http://localhost:8095/${NC}

Hot Module Replacement (HMR):
  ${GREEN}ws://localhost:9000${NC}

${YELLOW}Примечание: Самоподписанный сертификат создается автоматически${NC}
"
else
    echo -e "${RED}Ошибка при запуске контейнеров!${NC}"
    exit 1
fi
