#!/bin/bash

# Скрипт для запуска продакшен окружения

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Запуск продакшен окружения ===${NC}"

# Проверка наличия .env файла
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}.env файл не найден, создание из .env.prod.example...${NC}"
    
    # Приоритет: сначала .env.prod.example, потом .env.example
    if [ -f ".env.prod.example" ]; then
        cp .env.prod.example .env
        echo -e "${GREEN}.env файл создан из .env.prod.example${NC}"
    elif [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}.env файл создан из .env.example${NC}"
    else
        echo -e "${RED}.env.prod.example и .env.example не найдены!${NC}"
        exit 1
    fi
    
    # Запрос email для Let's Encrypt
    echo ""
    read -p "Введите email для уведомлений Let's Encrypt: " user_email
    
    if [ -n "$user_email" ]; then
        # Замена email в .env файле
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/your-email@example.com/$user_email/g" .env
        else
            # Linux
            sed -i "s/your-email@example.com/$user_email/g" .env
        fi
        echo -e "${GREEN}Email установлен: $user_email${NC}"
    else
        echo -e "${YELLOW}Email не указан, используется значение по умолчанию${NC}"
    fi
    
    # Запрос IP адреса сервера
    echo ""
    read -p "Введите IP адрес вашего сервера (оставьте пустым для использования 78.140.243.138): " server_ip
    
    if [ -n "$server_ip" ]; then
        # Замена IP в .env файле
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/SERVER_IP=.*/SERVER_IP=$server_ip/g" .env
        else
            # Linux
            sed -i "s/SERVER_IP=.*/SERVER_IP=$server_ip/g" .env
        fi
        echo -e "${GREEN}IP адрес установлен: $server_ip${NC}"
    else
        echo -e "${YELLOW}Используется IP по умолчанию из примера${NC}"
    fi
else
    echo -e "${GREEN}.env файл найден${NC}"
fi

# Остановка существующих контейнеров
echo -e "${YELLOW}Остановка существующих контейнеров...${NC}"
docker compose down

# Запуск контейнеров в продакшен режиме
echo -e "${GREEN}Запуск контейнеров в продакшен режиме...${NC}"
docker compose up -d --build

# Проверка статуса
if [ $? -eq 0 ]; then
    echo -e "
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Контейнеры успешно запущены!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

Проверьте логи:
  ${YELLOW}docker compose logs -f${NC}

Проверьте статус:
  ${YELLOW}docker compose ps${NC}

Проверьте создание сертификатов:
  ${YELLOW}docker compose logs certbot${NC}

Сайт будет доступен по адресу:
  ${GREEN}https://$(grep SERVER_IP .env | cut -d '=' -f2)/${NC}
"
else
    echo -e "${RED}Ошибка при запуске контейнеров!${NC}"
    exit 1
fi
