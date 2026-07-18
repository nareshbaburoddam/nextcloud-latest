FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    vim \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    libxml2-dev \
    libicu-dev \
    libmagickwand-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    libpq-dev \
    git \
    autoconf \
    pkg-config \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    zip \
    curl \
    xml \
    mbstring \
    intl \
    bz2 \
    opcache \
    pdo \
    pdo_mysql \
    && git clone --depth 1 --branch 3.7.0 https://github.com/Imagick/imagick.git /tmp/imagick \
    && cd /tmp/imagick \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/imagick \
    && apt-get purge -y autoconf pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mods
RUN a2enmod rewrite headers env dir mime

COPY ../nextcloud/ /var/www/html/nextcloud/
RUN chown -R www-data:www-data /var/www/html/nextcloud
