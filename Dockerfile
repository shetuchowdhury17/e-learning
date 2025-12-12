# Use official PHP 8.2 image with all tools
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy all project files
COPY . .

# Install project dependencies
RUN composer install --no-dev --optimize-autoloader --prefer-dist

# Create required Laravel folders
RUN mkdir -p storage/framework/{views,cache,sessions} \
    && mkdir -p storage/logs \
    && chmod -R 777 storage bootstrap/cache

# Clear caches
RUN php artisan config:clear || true
RUN php artisan route:clear || true
RUN php artisan view:clear || true

# Expose port (Railway will override anyhow)
EXPOSE 8080

# Serve Laravel using PHP's built-in web server (NOT artisan serve)

CMD ["php", "-S", "0.0.0.0:$PORT", "-t", "public"]
