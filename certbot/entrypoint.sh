#!/bin/sh
set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Certbot Entrypoint ===${NC}"

# Функция создания самоподписанного сертификата
create_self_signed() {
    echo -e "${YELLOW}Создание самоподписанного сертификата...${NC}"
    
    local cn="${SERVER_IP:-${SERVER_DOMAIN:-localhost}}"
    
    mkdir -p /etc/letsencrypt/live/cert
    
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout "/etc/letsencrypt/live/cert/privkey.pem" \
        -out "/etc/letsencrypt/live/cert/fullchain.pem" \
        -subj "/C=RU/ST=Moscow/L=Moscow/O=Development/OU=IT/CN=${cn}"
    
    echo -e "${GREEN}Самоподписанный сертификат создан для: ${cn}${NC}"
}

# Функция получения Let's Encrypt сертификата для IP
get_letsencrypt_ip() {
    echo -e "${YELLOW}Получение Let's Encrypt сертификата для IP: ${SERVER_IP}${NC}"
    
    if [ -z "$LETSENCRYPT_EMAIL" ]; then
        echo -e "${RED}Ошибка: LETSENCRYPT_EMAIL не указан${NC}"
        return 1
    fi
    
    if [ -z "$SERVER_IP" ]; then
        echo -e "${RED}Ошибка: SERVER_IP не указан${NC}"
        return 1
    fi
    
    # Ожидание доступности nginx
    echo -e "${YELLOW}Ожидание доступности nginx...${NC}"
    for i in $(seq 1 30); do
        if wget -q --spider "http://${SERVER_IP}/" 2>/dev/null; then
            echo -e "${GREEN}Nginx доступен${NC}"
            break
        fi
        echo "Попытка $i/30..."
        sleep 2
    done
    
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "${LETSENCRYPT_EMAIL}" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        --cert-name cert \
        -d "${SERVER_IP}" \
        --non-interactive
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Let's Encrypt сертификат успешно получен${NC}"
        return 0
    else
        echo -e "${RED}Ошибка получения Let's Encrypt сертификата${NC}"
        return 1
    fi
}

# Функция получения Let's Encrypt сертификата для домена
get_letsencrypt_domain() {
    echo -e "${YELLOW}Получение Let's Encrypt сертификата для домена: ${SERVER_DOMAIN}${NC}"
    
    if [ -z "$LETSENCRYPT_EMAIL" ]; then
        echo -e "${RED}Ошибка: LETSENCRYPT_EMAIL не указан${NC}"
        return 1
    fi
    
    if [ -z "$SERVER_DOMAIN" ]; then
        echo -e "${RED}Ошибка: SERVER_DOMAIN не указан${NC}"
        return 1
    fi
    
    # Ожидание доступности nginx
    echo -e "${YELLOW}Ожидание доступности nginx...${NC}"
    for i in $(seq 1 30); do
        if wget -q --spider "http://${SERVER_DOMAIN}/" 2>/dev/null; then
            echo -e "${GREEN}Nginx доступен${NC}"
            break
        fi
        echo "Попытка $i/30..."
        sleep 2
    done
    
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "${LETSENCRYPT_EMAIL}" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        --cert-name cert \
        -d "${SERVER_DOMAIN}" \
        --non-interactive
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Let's Encrypt сертификат успешно получен${NC}"
        return 0
    else
        echo -e "${RED}Ошибка получения Let's Encrypt сертификата${NC}"
        return 1
    fi
}

# Проверка типа существующего сертификата
has_valid_letsencrypt_cert() {
    # Проверяем, есть ли настоящий Let's Encrypt сертификат
    if [ -d "/etc/letsencrypt/renewal" ] && [ -n "$(ls -A /etc/letsencrypt/renewal 2>/dev/null)" ]; then
        return 0
    fi
    return 1
}

# Проверка наличия сертификатов
if [ ! -f "/etc/letsencrypt/live/cert/fullchain.pem" ]; then
    echo -e "${YELLOW}Файл сертификата не найден${NC}"
    need_init=1
elif ! has_valid_letsencrypt_cert && [ "$SSL_MODE" != "self-signed" ]; then
    echo -e "${YELLOW}Найден самоподписанный сертификат, но требуется Let's Encrypt (SSL_MODE=$SSL_MODE)${NC}"
    # Удаляем самоподписанный для создания нового
    rm -rf /etc/letsencrypt/live/cert
    need_init=1
else
    need_init=0
fi

if [ "$need_init" = "1" ]; then
    if [ "$AUTO_INIT_SSL" = "yes" ]; then
        echo -e "${GREEN}AUTO_INIT_SSL=yes, автоматическое создание сертификата (режим: $SSL_MODE)...${NC}"
        
        case "$SSL_MODE" in
            ip)
                if ! get_letsencrypt_ip; then
                    echo -e "${YELLOW}Fallback к самоподписанному сертификату${NC}"
                    create_self_signed
                fi
                ;;
            domain)
                if ! get_letsencrypt_domain; then
                    echo -e "${YELLOW}Fallback к самоподписанному сертификату${NC}"
                    create_self_signed
                fi
                ;;
            self-signed|*)
                create_self_signed
                ;;
        esac
    else
        echo -e "${YELLOW}AUTO_INIT_SSL=no, создание временного самоподписанного сертификата${NC}"
        create_self_signed
    fi
else
    echo -e "${GREEN}Сертификаты найдены: /etc/letsencrypt/live/cert/${NC}"
    if has_valid_letsencrypt_cert; then
        echo -e "${GREEN}Тип: Let's Encrypt${NC}"
        certbot certificates
    else
        echo -e "${YELLOW}Тип: Самоподписанный${NC}"
    fi
fi

# Запуск основного процесса обновления сертификатов
echo -e "${GREEN}Запуск процесса автоматического обновления (каждые 6 часов)...${NC}"

trap exit TERM

while :; do
    echo -e "${YELLOW}[$(date)] Проверка обновлений сертификатов...${NC}"
    certbot renew --quiet
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[$(date)] Обновление выполнено${NC}"
    fi
    
    sleep 6h & wait ${!}
done
