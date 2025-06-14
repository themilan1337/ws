#!/bin/bash

# =============================================================================
# Скрипт автоматического развертывания Laravel приложения SereneAI
# Требования: Ubuntu/Debian сервер
# Веб-сервер: Apache2
# База данных: SQLite
# =============================================================================

set -e  # Остановить выполнение при любой ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   error "Этот скрипт должен быть запущен с правами root (используйте sudo)"
fi

log "Начинаем развертывание Laravel приложения SereneAI..."

# =============================================================================
# 1. ОБНОВЛЕНИЕ СИСТЕМЫ
# =============================================================================
log "Обновление системы..."
sudo apt update -y
sudo apt upgrade -y

# =============================================================================
# 2. УСТАНОВКА ОСНОВНЫХ ПАКЕТОВ
# =============================================================================
log "Установка основных пакетов..."
sudo apt install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    sqlite3 \
    libsqlite3-dev

# =============================================================================
# 3. УСТАНОВКА PHP 8.2
# =============================================================================
log "Установка PHP 8.2 и необходимых расширений..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

sudo apt install -y \
    php8.2 \
    php8.2-cli \
    php8.2-common \
    php8.2-mysql \
    php8.2-zip \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-xml \
    php8.2-bcmath \
    php8.2-sqlite3 \
    php8.2-pdo \
    php8.2-pdo-sqlite \
    php8.2-intl \
    php8.2-tokenizer \
    php8.2-fileinfo \
    php8.2-fpm

# Проверка версии PHP
php_version=$(php -v | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)
log "Установлена версия PHP: $php_version"

if [[ "$php_version" != "8.2" ]]; then
    warn "Ожидалась версия PHP 8.2, но установлена $php_version"
fi

# =============================================================================
# 4. УСТАНОВКА COMPOSER
# =============================================================================
log "Установка Composer..."
cd /tmp
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Проверка установки Composer
composer --version
log "Composer успешно установлен"

# =============================================================================
# 5. УСТАНОВКА NODE.JS И NPM
# =============================================================================
log "Установка Node.js и npm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Проверка версий
node_version=$(node --version)
npm_version=$(npm --version)
log "Установлена версия Node.js: $node_version"
log "Установлена версия npm: $npm_version"

# =============================================================================
# 6. УСТАНОВКА APACHE2
# =============================================================================
log "Установка Apache2..."
sudo apt install -y apache2

# Включение необходимых модулей Apache
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enmod php8.2

# Запуск и включение автозапуска Apache
sudo systemctl start apache2
sudo systemctl enable apache2

log "Apache2 успешно установлен и запущен"

# =============================================================================
# 7. СОЗДАНИЕ ДИРЕКТОРИИ ПРОЕКТА
# =============================================================================
log "Создание директории проекта..."
PROJECT_DIR="/var/www/serene"
sudo mkdir -p $PROJECT_DIR
sudo chown -R www-data:www-data $PROJECT_DIR
sudo chmod -R 755 $PROJECT_DIR

# =============================================================================
# 8. КЛОНИРОВАНИЕ ИЛИ КОПИРОВАНИЕ ПРОЕКТА
# =============================================================================
log "Настройка проекта..."

# Если скрипт запускается из директории проекта, копируем файлы
if [[ -f "composer.json" && -f "artisan" ]]; then
    log "Копирование файлов проекта..."
    sudo cp -r . $PROJECT_DIR/
    sudo chown -R www-data:www-data $PROJECT_DIR
else
    error "Файлы проекта не найдены. Убедитесь, что скрипт запускается из корневой директории проекта."
fi

cd $PROJECT_DIR

# =============================================================================
# 9. УСТАНОВКА ЗАВИСИМОСТЕЙ PHP
# =============================================================================
log "Установка зависимостей PHP через Composer..."
sudo -u www-data composer install --no-dev --optimize-autoloader

# =============================================================================
# 10. УСТАНОВКА ЗАВИСИМОСТЕЙ NODE.JS
# =============================================================================
log "Установка зависимостей Node.js..."
sudo -u www-data npm install

# =============================================================================
# 11. НАСТРОЙКА ОКРУЖЕНИЯ
# =============================================================================
log "Настройка файла окружения..."

# Копирование .env файла
if [[ -f ".env.fordeploy" ]]; then
    sudo -u www-data cp .env.fordeploy .env
    log "Файл .env.fordeploy скопирован в .env"
else
    sudo -u www-data cp .env.example .env
    log "Файл .env.example скопирован в .env"
fi

# Генерация ключа приложения
sudo -u www-data php artisan key:generate

# =============================================================================
# 12. НАСТРОЙКА БАЗЫ ДАННЫХ SQLITE
# =============================================================================
log "Настройка базы данных SQLite..."

# Создание директории для базы данных
sudo mkdir -p $PROJECT_DIR/database
sudo chown -R www-data:www-data $PROJECT_DIR/database
sudo chmod -R 775 $PROJECT_DIR/database

# Создание файла базы данных SQLite
sudo -u www-data touch $PROJECT_DIR/database/database.sqlite
sudo chmod 664 $PROJECT_DIR/database/database.sqlite

# Запуск миграций
sudo -u www-data php artisan migrate --force

log "База данных SQLite настроена и миграции выполнены"

# =============================================================================
# 13. СБОРКА ФРОНТЕНДА
# =============================================================================
log "Сборка фронтенда..."
sudo -u www-data npm run build

# =============================================================================
# 14. НАСТРОЙКА ПРАВ ДОСТУПА
# =============================================================================
log "Настройка прав доступа..."

# Установка владельца
sudo chown -R www-data:www-data $PROJECT_DIR

# Установка прав на директории
sudo find $PROJECT_DIR -type d -exec chmod 755 {} \;

# Установка прав на файлы
sudo find $PROJECT_DIR -type f -exec chmod 644 {} \;

# Специальные права для storage и bootstrap/cache
sudo chmod -R 775 $PROJECT_DIR/storage
sudo chmod -R 775 $PROJECT_DIR/bootstrap/cache
sudo chmod -R 775 $PROJECT_DIR/database

# Права на artisan
sudo chmod +x $PROJECT_DIR/artisan

# =============================================================================
# 15. НАСТРОЙКА APACHE VIRTUAL HOST
# =============================================================================
log "Настройка Apache Virtual Host..."

# Создание конфигурации виртуального хоста
sudo tee /etc/apache2/sites-available/serene.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName serene.ws
    ServerAlias www.serene.ws
    DocumentRoot $PROJECT_DIR/public
    
    <Directory $PROJECT_DIR/public>
        AllowOverride All
        Require all granted
        Options -Indexes
    </Directory>
    
    <Directory $PROJECT_DIR>
        Options -Indexes
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/serene_error.log
    CustomLog \${APACHE_LOG_DIR}/serene_access.log combined
    
    # Безопасность
    ServerTokens Prod
    ServerSignature Off
    
    # Заголовки безопасности
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://challenges.cloudflare.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://challenges.cloudflare.com;"
EOF

# Отключение дефолтного сайта
sudo a2dissite 000-default

# Включение нового сайта
sudo a2ensite serene.conf

# Перезапуск Apache
sudo systemctl reload apache2

log "Apache Virtual Host настроен"

# =============================================================================
# 16. НАСТРОЙКА КЭШИРОВАНИЯ
# =============================================================================
log "Настройка кэширования Laravel..."

sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache

# =============================================================================
# 17. НАСТРОЙКА CRON ДЛЯ LARAVEL SCHEDULER
# =============================================================================
log "Настройка cron для Laravel Scheduler..."

# Добавление задачи в crontab для www-data
(sudo -u www-data crontab -l 2>/dev/null; echo "* * * * * cd $PROJECT_DIR && php artisan schedule:run >> /dev/null 2>&1") | sudo -u www-data crontab -

log "Cron задача для Laravel Scheduler добавлена"

# =============================================================================
# 18. НАСТРОЙКА FIREWALL (UFW)
# =============================================================================
log "Настройка firewall..."

sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

log "Firewall настроен"

# =============================================================================
# 19. ОПТИМИЗАЦИЯ PHP
# =============================================================================
log "Оптимизация настроек PHP..."

# Создание резервной копии php.ini
sudo cp /etc/php/8.2/apache2/php.ini /etc/php/8.2/apache2/php.ini.backup

# Оптимизация настроек PHP
sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 100M/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/max_input_vars = .*/max_input_vars = 3000/' /etc/php/8.2/apache2/php.ini

# Перезапуск Apache для применения изменений
sudo systemctl restart apache2

log "PHP настройки оптимизированы"

# =============================================================================
# 20. УСТАНОВКА SSL СЕРТИФИКАТА (Let's Encrypt)
# =============================================================================
log "Установка Certbot для SSL сертификатов..."

sudo apt install -y certbot python3-certbot-apache

log "Certbot установлен. Для получения SSL сертификата выполните:"
log "sudo certbot --apache -d serene.ws -d www.serene.ws"

# =============================================================================
# 21. СОЗДАНИЕ СКРИПТА ОБНОВЛЕНИЯ
# =============================================================================
log "Создание скрипта обновления..."

sudo tee /usr/local/bin/update-serene.sh > /dev/null <<'EOF'
#!/bin/bash

PROJECT_DIR="/var/www/serene"

echo "Обновление приложения SereneAI..."

cd $PROJECT_DIR

# Включение режима обслуживания
sudo -u www-data php artisan down

# Обновление зависимостей
sudo -u www-data composer install --no-dev --optimize-autoloader
sudo -u www-data npm install
sudo -u www-data npm run build

# Выполнение миграций
sudo -u www-data php artisan migrate --force

# Очистка и обновление кэша
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache

# Выключение режима обслуживания
sudo -u www-data php artisan up

echo "Обновление завершено!"
EOF

sudo chmod +x /usr/local/bin/update-serene.sh

log "Скрипт обновления создан: /usr/local/bin/update-serene.sh"

# =============================================================================
# 22. СОЗДАНИЕ СКРИПТА РЕЗЕРВНОГО КОПИРОВАНИЯ
# =============================================================================
log "Создание скрипта резервного копирования..."

sudo tee /usr/local/bin/backup-serene.sh > /dev/null <<'EOF'
#!/bin/bash

PROJECT_DIR="/var/www/serene"
BACKUP_DIR="/var/backups/serene"
DATE=$(date +"%Y%m%d_%H%M%S")

mkdir -p $BACKUP_DIR

echo "Создание резервной копии..."

# Резервная копия базы данных
cp $PROJECT_DIR/database/database.sqlite $BACKUP_DIR/database_$DATE.sqlite

# Резервная копия файлов проекта
tar -czf $BACKUP_DIR/project_$DATE.tar.gz -C /var/www serene

# Удаление старых резервных копий (старше 30 дней)
find $BACKUP_DIR -name "*.sqlite" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Резервная копия создана: $BACKUP_DIR"
EOF

sudo chmod +x /usr/local/bin/backup-serene.sh

# Добавление задачи резервного копирования в cron (ежедневно в 2:00)
(sudo crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-serene.sh >> /var/log/serene-backup.log 2>&1") | sudo crontab -

log "Скрипт резервного копирования создан: /usr/local/bin/backup-serene.sh"

# =============================================================================
# 23. ФИНАЛЬНАЯ ПРОВЕРКА
# =============================================================================
log "Выполнение финальной проверки..."

# Проверка статуса Apache
if sudo systemctl is-active --quiet apache2; then
    log "✓ Apache2 запущен"
else
    error "✗ Apache2 не запущен"
fi

# Проверка доступности приложения
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302"; then
    log "✓ Приложение доступно"
else
    warn "⚠ Приложение может быть недоступно"
fi

# Проверка базы данных
if [[ -f "$PROJECT_DIR/database/database.sqlite" ]]; then
    log "✓ База данных SQLite создана"
else
    error "✗ База данных SQLite не найдена"
fi

# Проверка прав доступа
if [[ $(stat -c "%U" $PROJECT_DIR) == "www-data" ]]; then
    log "✓ Права доступа настроены корректно"
else
    warn "⚠ Проверьте права доступа"
fi

# =============================================================================
# 24. ВЫВОД ИНФОРМАЦИИ О ЗАВЕРШЕНИИ
# =============================================================================
echo -e "\n${GREEN}==============================================================================${NC}"
echo -e "${GREEN}                    РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО УСПЕШНО!${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${BLUE}Приложение SereneAI развернуто и готово к использованию!${NC}\n"

echo -e "${YELLOW}Информация о развертывании:${NC}"
echo -e "• Директория проекта: ${BLUE}$PROJECT_DIR${NC}"
echo -e "• Веб-сервер: ${BLUE}Apache2${NC}"
echo -e "• База данных: ${BLUE}SQLite${NC}"
echo -e "• PHP версия: ${BLUE}$(php -v | head -n1 | cut -d' ' -f2)${NC}"
echo -e "• Node.js версия: ${BLUE}$(node --version)${NC}"
echo -e "• Composer версия: ${BLUE}$(composer --version --no-ansi | cut -d' ' -f3)${NC}\n"

echo -e "${YELLOW}Полезные команды:${NC}"
echo -e "• Обновление приложения: ${BLUE}sudo /usr/local/bin/update-serene.sh${NC}"
echo -e "• Резервное копирование: ${BLUE}sudo /usr/local/bin/backup-serene.sh${NC}"
echo -e "• Просмотр логов Apache: ${BLUE}sudo tail -f /var/log/apache2/serene_error.log${NC}"
echo -e "• Перезапуск Apache: ${BLUE}sudo systemctl restart apache2${NC}"
echo -e "• Статус Apache: ${BLUE}sudo systemctl status apache2${NC}\n"

echo -e "${YELLOW}Следующие шаги:${NC}"
echo -e "1. Настройте DNS записи для домена serene.ws"
echo -e "2. Получите SSL сертификат: ${BLUE}sudo certbot --apache -d serene.ws -d www.serene.ws${NC}"
echo -e "3. Проверьте работу приложения в браузере"
echo -e "4. Настройте мониторинг и алерты\n"

echo -e "${GREEN}Развертывание завершено! Ваше приложение готово к работе.${NC}"

log "Скрипт развертывания завершен успешно!"