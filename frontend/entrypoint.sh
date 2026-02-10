#!/bin/sh
set -e

echo "Инициализация Quasar приложения..."

# Проверка наличия node_modules и важных зависимостей
if [ ! -d "node_modules" ] || [ ! -d "node_modules/@quasar" ] || [ ! -f "node_modules/.bin/quasar" ]; then
    echo "Установка зависимостей npm..."
    rm -f node_modules/.installed
    
    # Очистка и установка зависимостей
    echo "Очистка node_modules..."
    rm -rf node_modules
    
    echo "Чистая установка зависимостей (npm ci)..."
    npm ci || {
        echo "npm ci не удалось, пробуем npm install..."
        npm install
    }
    
    # Проверка успешности установки
    if [ ! -f "node_modules/.bin/quasar" ]; then
        echo "ОШИБКА: node_modules/.bin/quasar не найден после установки!"
        echo "Список файлов в node_modules/.bin:"
        ls -la node_modules/.bin/ 2>/dev/null || echo "node_modules/.bin/ не существует"
        echo ""
        echo "Проверка наличия @quasar/app-vite:"
        ls -d node_modules/@quasar/app-vite 2>/dev/null || echo "@quasar/app-vite не установлен"
        echo ""
        echo "Количество установленных пакетов:"
        ls -1 node_modules | wc -l
        exit 1
    fi
    
    # Создаём файл-флаг
    touch node_modules/.installed
    echo "Зависимости успешно установлены"
else
    echo "node_modules уже установлены"
fi

# Запуск cron для logrotate (если используется)
if command -v crond > /dev/null 2>&1; then
    echo "Запуск cron..."
    crond
fi

echo "Инициализация завершена!"

# Запуск переданной команды
exec "$@"