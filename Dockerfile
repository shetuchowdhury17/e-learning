FROM php:8.2-fpm

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

# Copy all files
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Generate optimized Laravel cache
RUN php artisan config:clear
RUN php artisan route:clear
RUN php artisan view:clear

# Expose port for PHP server
EXPOSE 8000

# Start Laravel using PHP's server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
