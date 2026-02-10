FROM mysql:8.0

# Копируем init скрипт
COPY init-db.sql /docker-entrypoint-initdb.d/

# Копируем конфигурацию для логирования
COPY my.cnf /etc/mysql/conf.d/

# Создаем директорию для логов
RUN mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /var/log/mysql

# Создаем директорию для env файлов
RUN mkdir -p /tmp/mysql-env

# Копируем .env.example (для использования как шаблон)
COPY .env.example /tmp/mysql-env/.env.example

# Копируем и делаем исполняемым entrypoint скрипт
COPY docker-entrypoint.sh /usr/local/bin/mysql-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/mysql-entrypoint-wrapper.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mysql-entrypoint-wrapper.sh"]
CMD ["mysqld"]
