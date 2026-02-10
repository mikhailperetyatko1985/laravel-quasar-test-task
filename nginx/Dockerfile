FROM nginx:1.25-alpine

# Установка необходимых утилит
RUN apk add --no-cache \
    bash \
    openssl \
    logrotate \
    dcron \
    curl

# Удаление дефолтной конфигурации
RUN rm /etc/nginx/conf.d/default.conf

# Копирование конфигурации logrotate
COPY logrotate-nginx /etc/logrotate.d/nginx

# Копирование entrypoint скрипта
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Создание директории для логов
RUN mkdir -p /var/log/nginx

# Настройка cron для logrotate
RUN echo "0 0 * * * /usr/sbin/logrotate /etc/logrotate.conf" > /var/spool/cron/crontabs/root

# Установка entrypoint
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443
