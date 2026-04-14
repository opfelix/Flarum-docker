FROM nginx:alpine

ARG PHP_VERSION=84

RUN apk add --no-cache \ 
        php${PHP_VERSION} \ 
        php${PHP_VERSION}-fpm \ 
        php${PHP_VERSION}-mbstring \ 
        php${PHP_VERSION}-opcache \ 
        php${PHP_VERSION}-pdo \ 
        php${PHP_VERSION}-pdo_mysql \ 
        php${PHP_VERSION}-xml \ 
        php${PHP_VERSION}-curl \ 
        php${PHP_VERSION}-dom \ 
        php${PHP_VERSION}-fileinfo \ 
        php${PHP_VERSION}-gd \ 
        php${PHP_VERSION}-phar \ 
        php${PHP_VERSION}-tokenizer \ 
        php${PHP_VERSION}-zip \ 
        php${PHP_VERSION}-session \ 
        ca-certificates
COPY flarum.conf /etc/nginx/conf.d

ARG FLARUM_VERSION=2.0.0-beta.8

RUN mkdir -p /opt/flarum \ 
    && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \ 
    && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum:^2.0.0 --stability=beta /opt/flarum --no-install \ 
    && COMPOSER_CACHE_DIR="/tmp" composer require --working-dir /opt/flarum flarum/core:${FLARUM_VERSION} \ 
    && composer  clear-cache \ 
    && chown -R nginx:nginx /opt/flarum \ 
    && sed -i 's/^user = nobody/user = nginx/' /etc/php${PHP_VERSION}/php-fpm.d/www.conf \ 
    && sed -i 's/^group = nobody/group = nginx/' /etc/php${PHP_VERSION}/php-fpm.d/www.conf \ 
    && rm -rf /tmp/* /etc/nginx/conf.d/default.conf \ 
    && printf '#!/bin/sh\nphp-fpm%s -D\nexec nginx -g "daemon off;"\n' "$PHP_VERSION" > /opt/start.sh && chmod +x /opt/start.sh

EXPOSE 8000
WORKDIR /opt/flarum

CMD ["/opt/start.sh"]
