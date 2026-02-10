#!/bin/bash

# Скрипт инициализации Quasar приложения

echo "Создание Quasar приложения..."

# Переход в директорию frontend
cd "$(dirname "$0")"

# Инициализация Quasar проекта
if [ ! -f "quasar.config.js" ]; then
    echo "Создание нового Quasar проекта..."
    npm create quasar@latest . -- \
        --branch next \
        --preset ssr \
        --package-manager npm \
        --css scss \
        --eslint standard \
        --typescript
else
    echo "Quasar проект уже существует"
fi

echo "Установка зависимостей..."
npm install

echo "Инициализация завершена!"
