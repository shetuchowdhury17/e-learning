FROM php:8.2-fpm

# Force full rebuild
RUN echo "rebuild-laravel-railway-final"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libpq-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Setup environment
RUN cp .env.example .env || true
RUN php artisan key:generate || true
RUN php artisan storage:link || true

# Clear cache
RUN php artisan config:clear || true
RUN php artisan route:clear || true
RUN php artisan view:clear || true

# Expose port 8000 internally
EXPOSE 8000

# FINAL FIX:
# Use PHP's built-in web server instead of Artisan Serve
# This ALWAYS works and avoids the port bug completely.
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8000} -t public"]
