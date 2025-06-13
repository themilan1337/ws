# Используем официальный образ PHP с Apache
FROM php:8.2-apache

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Включаем Apache mod_rewrite
RUN a2enmod rewrite

# Настраиваем рабочую директорию
WORKDIR /var/www/html

# Копируем файлы composer и устанавливаем PHP зависимости
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction

# Копируем package.json и устанавливаем Node.js зависимости
COPY package.json package-lock.json ./
RUN npm ci --only=production --silent

# Копируем все файлы проекта
COPY . .

# Завершаем установку composer зависимостей
RUN composer dump-autoload --optimize

# Устанавливаем права доступа
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Создаем директорию для SQLite базы данных
RUN mkdir -p /var/www/html/database \
    && touch /var/www/html/database/database.sqlite \
    && chown www-data:www-data /var/www/html/database/database.sqlite \
    && chmod 664 /var/www/html/database/database.sqlite

# Копируем .env файл из примера если .env не существует
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Генерируем ключ приложения
RUN php artisan key:generate --force

# Создаем символическую ссылку для storage
RUN php artisan storage:link

# Запускаем миграции
RUN php artisan migrate --force

# Собираем фронтенд ресурсы
RUN npm run build

# Удаляем node_modules после сборки для уменьшения размера образа
RUN rm -rf node_modules

# Настраиваем Apache Virtual Host
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Очищаем кеш
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Открываем порт 80
EXPOSE 80

# Запускаем Apache
CMD ["apache2-foreground"]