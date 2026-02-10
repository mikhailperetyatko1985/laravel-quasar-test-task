FROM php:8.3-fpm

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libmemcached-dev \
    zlib1g-dev \
    libzip-dev \
    libicu-dev \
    zip \
    unzip \
    logrotate \
    cron \
    libfcgi-bin \
    && rm -rf /var/lib/apt/lists/*

# Установка PHP расширений
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Установка расширения memcached
RUN pecl install memcached && docker-php-ext-enable memcached

# Установка Redis (опционально, на будущее)
RUN pecl install redis && docker-php-ext-enable redis

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка рабочей директории
WORKDIR /var/www/html

# Копирование конфигурации PHP
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Копирование конфигурации PHP-FPM pool
COPY fpm-pool.conf /usr/local/etc/php-fpm.d/zz-custom.conf

# Копирование конфигурации logrotate
COPY logrotate-laravel /etc/logrotate.d/laravel

# Установка прав доступа
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Копирование entrypoint скрипта
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Копирование healthcheck скрипта
COPY php-fpm-healthcheck /usr/local/bin/php-fpm-healthcheck
RUN chmod +x /usr/local/bin/php-fpm-healthcheck

# Настройка cron для logrotate
RUN echo "0 0 * * * /usr/sbin/logrotate /etc/logrotate.conf" >> /var/spool/cron/crontabs/root

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
