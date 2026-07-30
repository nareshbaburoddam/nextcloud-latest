# ---------- Stage 1: Build extensions ----------
FROM php:8.2-apache AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
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
    && rm -rf /tmp/imagick

# ---------- Stage 2: Final runtime image ----------
FROM php:8.2-apache

# Only RUNTIME libraries here (no -dev, no build tools, no git/vim)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16t64 \
    libzip5 \
    libxml2 \
    libicu76 \
    libmagickwand-7.q16-10 \
    libonig5 \
    libcurl4 \
    libbz2-1.0 \
    libpq5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled PHP extensions from the builder stage
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

RUN docker-php-ext-enable imagick gd zip curl xml mbstring intl bz2 opcache pdo pdo_mysql

# Enable Apache mods
RUN a2enmod rewrite headers env dir mime

# --chown here avoids a separate full-tree chown layer (which was doubling image size)
COPY --chown=www-data:www-data ./nextcloud/ /var/www/html/nextcloud/
