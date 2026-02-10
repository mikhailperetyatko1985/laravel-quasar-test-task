#!/bin/bash
set -e

echo "Начало инициализации Laravel приложения..."

# Установка правильных прав доступа ЗАРАНЕЕ
echo "Установка прав доступа..."
mkdir -p storage/framework/{sessions,views,cache}
mkdir -p storage/logs
mkdir -p bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Проверка наличия .env файла
if [ ! -f ".env" ]; then
    echo "Копирование .env файла..."
    cp .env.example .env
fi

# Установка прав на .env
chmod 666 .env

# Проверка наличия vendor директории - СНАЧАЛА устанавливаем зависимости
if [ ! -d "vendor" ]; then
    echo "Установка зависимостей Composer..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Генерация ключа приложения, если его нет (ПОСЛЕ установки зависимостей)
# Используем файл-флаг в storage/logs (гарантированно существует)
KEY_GENERATED_FLAG="storage/logs/.app_key_generated"

if [ ! -f "$KEY_GENERATED_FLAG" ] && ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    echo "Генерация APP_KEY..."
    
    # Попытка генерации ключа с обработкой ошибок
    echo "Выполнение команды: php artisan key:generate --force"
    OUTPUT=$(php artisan key:generate --force 2>&1)
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -ne 0 ]; then
        echo "ОШИБКА: Не удалось сгенерировать APP_KEY"
        echo "Код выхода: $EXIT_CODE"
        echo "Вывод команды:"
        echo "$OUTPUT"
        echo ""
        echo "Содержимое .env:"
        cat .env | head -20
        echo ""
        echo "Попытка запустить php artisan:"
        php artisan --version 2>&1 || echo "Не удалось запустить artisan"
        exit 1
    fi
    echo "$OUTPUT"
    
    # Создаём файл-флаг, чтобы не генерировать повторно
    touch "$KEY_GENERATED_FLAG"
    chmod 666 "$KEY_GENERATED_FLAG"
    echo "APP_KEY успешно сгенерирован. Флаг создан: $KEY_GENERATED_FLAG"
else
    echo "APP_KEY уже установлен (найден флаг или ключ в .env)"
fi

# Ожидание готовности MySQL с таймаутом
echo "Ожидание MySQL..."
TIMEOUT=60
ELAPSED=0
until php artisan db:show 2>/dev/null; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "Превышено время ожидания MySQL ($TIMEOUT сек)"
        echo "Проверьте настройки подключения к базе данных"
        exit 1
    fi
    echo "MySQL не готов - ожидание... ($ELAPSED/$TIMEOUT сек)"
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

echo "MySQL готов!"

# Еще раз убедимся в правах доступа перед миграциями
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Очистка кеша
echo "Очистка кеша..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Запуск миграций
echo "Запуск миграций..."
php artisan migrate --force

# Кеширование конфигурации для production
if [ "$APP_ENV" = "production" ]; then
    echo "Кеширование конфигурации..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Запуск cron для logrotate
echo "Запуск cron..."
cron

echo "Инициализация завершена!"

# Запуск переданной команды
exec "$@"
