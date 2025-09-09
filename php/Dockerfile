# syntax=docker/dockerfile:1.7
ARG PHP_VERSION
FROM php:${PHP_VERSION}

# APT behavior tweaks
RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom \
    && echo "Acquire::http::No-Cache true;"    >> /etc/apt/apt.conf.d/99custom \
    && echo "Acquire::BrokenProxy true;"       >> /etc/apt/apt.conf.d/99custom

# System dependencies
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
    mariadb-client \
    default-mysql-client \
    curl iputils-ping \
    locales zip unzip \
    libzip-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libxml2-dev \
    libgmp-dev \
    libmemcached11 libmemcached-dev \
    build-essential

# Other tools
RUN set -eux; \
    yes '' | pecl install memcached; \
    docker-php-ext-enable memcached; \
    pecl install mcrypt || true; \
    docker-php-ext-enable mcrypt || true

# Core PHP extensions
RUN set -eux; \
    docker-php-ext-install -j"$(nproc)" \
    pdo_mysql \
    mysqli \
    exif \
    pcntl \
    bcmath \
    gmp \
    zip \
    soap

# GD
RUN set -eux; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" gd

# Composer
RUN set -eux; \
    curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# php-fpm listens on 9000
EXPOSE 9000
CMD ["php-fpm"]