FROM node:20-alpine

# Установка необходимых утилит
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    logrotate \
    dcron \
    curl

# Не устанавливаем глобальный @quasar/cli, используем локальный через npx

# Установка рабочей директории
WORKDIR /app

# Копирование package.json и package-lock.json
COPY package*.json ./

# Установка зависимостей
RUN npm install

# Копирование остальных файлов приложения
COPY . .

# Копирование конфигурации logrotate
COPY logrotate-frontend /etc/logrotate.d/frontend

# Настройка cron для logrotate
RUN echo "0 0 * * * /usr/sbin/logrotate /etc/logrotate.conf" > /var/spool/cron/crontabs/root

# Создание директории для логов
RUN mkdir -p /app/logs

# Копирование и установка прав на entrypoint скрипт
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Открытие порта
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Команда по умолчанию для запуска dev сервера
CMD ["npm", "run", "dev"]
