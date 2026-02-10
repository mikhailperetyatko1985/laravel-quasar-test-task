#!/bin/bash
# Скрипт для перезагрузки nginx после обновления сертификатов
# Вызывается certbot через --deploy-hook

echo "Обновление сертификатов завершено, перезагрузка nginx..."

# Найти compose файлы
COMPOSE_FILES="-f /var/lib/docker/volumes/docker-compose.yml"

# Попытка перезагрузить nginx
if command -v docker &> /dev/null; then
    docker exec laravel_nginx nginx -s reload 2>/dev/null || \
    docker-compose restart nginx 2>/dev/null || \
    echo "Не удалось перезагрузить nginx автоматически. Перезапустите вручную: docker compose restart nginx"
else
    echo "Docker не найден. Перезапустите nginx вручную."
fi

exit 0
