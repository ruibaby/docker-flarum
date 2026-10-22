FROM alpine:3.24

LABEL description="Simple forum software for building great communities" \
      maintainer="Magicalex <magicalex@mondedie.fr>"

ARG VERSION=v1.8.19
ARG CORE_VERSION=1.8.20
ARG COMPOSER_VERSION=2.10.3
ARG COMPOSER_SHA256=7a2d379d5b8ffdaa028580ef26494c36d2feef4b178d3dd1473a4dbc5e17c8d6

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128 \
    DB_HOST=mariadb \
    DB_USER=flarum \
    DB_NAME=flarum \
    DB_PORT=3306 \
    FLARUM_TITLE=Docker-Flarum \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    GITHUB_TOKEN_AUTH=false \
    FLARUM_PORT=8888

RUN apk add --no-progress --no-cache \
    ca-certificates \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    'php83>=8.3.36' \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-fpm \
    php83-gd \
    php83-gmp \
    php83-iconv \
    php83-intl \
    php83-mbstring \
    php83-mysqlnd \
    php83-opcache \
    php83-pecl-apcu \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-phar \
    php83-session \
    php83-tokenizer \
    php83-xmlwriter \
    php83-zip \
    php83-zlib \
    su-exec \
    s6 \
  && cd /tmp \
  && ln -s /usr/bin/php83 /usr/local/bin/php \
  && curl -fsSL "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" -o /usr/local/bin/composer \
  && echo "${COMPOSER_SHA256}  /usr/local/bin/composer" | sha256sum -c - \
  && sed -i 's/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/' /etc/php83/php.ini \
  && chmod +x /usr/local/bin/composer \
  && mkdir -p /run/php /flarum/app \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx

COPY rootfs/usr/local/lib/flarum /usr/local/lib/flarum
COPY tests/flysystem-paths.php /tmp/flysystem-paths.php
RUN export COMPOSER_CACHE_DIR=/tmp \
  && composer create-project --no-install --no-interaction --no-plugins --no-scripts "flarum/flarum:${VERSION}" /flarum/app \
  && cd /flarum/app \
  && composer require --no-update --no-interaction "flarum/core:${CORE_VERSION}" \
  # The backport keeps the upstream version, so retain the advisory in audit reports.
  && composer config --json audit.ignore '{"GHSA-cxf4-7mrp-vvpr":{"apply":"block","reason":"Backported by /usr/local/lib/flarum/patch-flysystem.php after Composer install/update; upstream 1.x has no patched release."}}' \
  && composer config scripts.post-install-cmd '@php /usr/local/lib/flarum/patch-flysystem.php' \
  && composer config scripts.post-update-cmd '@php /usr/local/lib/flarum/patch-flysystem.php' \
  && composer config scripts.post-autoload-dump '@php /usr/local/lib/flarum/patch-flysystem.php' \
  && composer install --no-dev --no-interaction --no-plugins --prefer-dist --optimize-autoloader \
  && php /tmp/flysystem-paths.php \
  && composer clear-cache \
  && rm -rf /root/.composer /flarum/.composer /tmp/*

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/run /etc/s6.d/.s6-svscan/*
VOLUME /etc/nginx/flarum /flarum/app/extensions /flarum/app/public/assets /flarum/app/storage/logs
CMD ["/usr/local/bin/startup"]
