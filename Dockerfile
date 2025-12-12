FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev libpng-dev libonig-dev libxml2-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:$PORT", "-t", "public"]
