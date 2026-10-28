# The scroll: a multi-stage build for a PHP web app with a React frontend.
#
# One file produces two images. The "php" stage runs the app under PHP-FPM,
# the "nginx" stage serves the static files and proxies PHP requests to it.
# Build either one with --target:
#   docker build --target php   -t myapp/php   .
#   docker build --target nginx -t myapp/nginx .
#
# This file is for reading. The app it refers to is not in this repo.

ARG BUILD_MODE=prod

# ---- stage 1: pin the Node version once, so the next stage can reuse it ---
FROM node:24-alpine AS node

# ---- stage 2: build the frontend --------------------------------------------
FROM node AS frontend-build
WORKDIR /src/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
ARG BUILD_MODE
RUN npm run build -- --mode "$BUILD_MODE"

# ---- stage 3: install PHP dependencies and assemble the app -----------------
FROM php:8.5-cli-alpine AS build
RUN apk add --no-cache git unzip
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /src/app
COPY app/composer.json app/composer.lock ./
ARG BUILD_MODE
RUN if [ "$BUILD_MODE" = "prod" ]; then \
        composer install --no-dev --no-scripts --prefer-dist; \
    else \
        composer install --no-scripts --prefer-dist; \
    fi
COPY app/ ./
COPY --from=frontend-build /src/frontend/dist ./public/assets
RUN composer dump-autoload --optimize

# ---- stage 4: the PHP runtime image -----------------------------------------
FROM php:8.5-fpm-alpine AS php
RUN apk add --no-cache icu-libs libzip \
    && docker-php-ext-install pdo_mysql opcache
WORKDIR /var/www/app
COPY --from=build --chown=www-data:www-data /src/app ./
COPY docker/php/app.ini /usr/local/etc/php/conf.d/app.ini
COPY docker/php/entrypoint.sh /usr/local/bin/app-entrypoint
ARG BUILD_MODE
ENV APP_ENV=${BUILD_MODE}
EXPOSE 9000
USER www-data
ENTRYPOINT ["app-entrypoint"]
CMD ["php-fpm"]

# ---- stage 5: the web server image ------------------------------------------
FROM nginx:1.31-alpine-slim AS nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/app/public /var/www/app/public
WORKDIR /var/www/app
EXPOSE 80
