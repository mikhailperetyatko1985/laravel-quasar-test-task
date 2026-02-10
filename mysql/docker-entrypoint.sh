#!/bin/bash
set -e

# Копирование .env файла если он не существует
if [ ! -f "/tmp/mysql-env/.env" ] && [ -f "/tmp/mysql-env/.env.example" ]; then
    echo "Копирование .env файла для MySQL..."
    cp /tmp/mysql-env/.env.example /tmp/mysql-env/.env
fi

# Загрузка переменных окружения из .env файла
if [ -f "/tmp/mysql-env/.env" ]; then
    export $(grep -v '^#' /tmp/mysql-env/.env | xargs)
fi

# Запуск стандартного MySQL entrypoint
exec docker-entrypoint.sh "$@"
