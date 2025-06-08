# Description: Dockerfile to install essential PHP dependencies for the environment
#
# Copyright (c) 2025 The p8 Ops Team
# Copyright (c) 2025 honeok <honeok@disroot.org>
#
# SPDX-License-Identifier: MIT

FROM php:8.1.32-fpm-alpine3.21
LABEL maintainer="honeok <honeok@disroot.org>"
RUN set -ex \
    && wget -qO /usr/local/bin/install-php-extensions "https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions" \
    && chmod +x /usr/local/bin/install-php-extensions \
    && /usr/local/bin/install-php-extensions \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        gettext \
        gmp \
        ldap \
        mbstring \
        mysqli \
        mysqlnd \
        odbc \
        opcache \
        pdo_mysql \
        soap \
        shmop \
        sysvmsg \
        sysvsem \
        sysvshm \
        xml \
        xmlrpc \
        xsl \
    && cp -f /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && sed -i 's/^;\s*\(date\.timezone\s*=\).*/\1 Asia\/Shanghai/' /usr/local/etc/php/php.ini \
    && rm -f /usr/local/bin/install-php-extensions \
    && rm -rf /var/cache/apk/*