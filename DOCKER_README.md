# Docker Setup для SereneAI

Этот проект настроен для полного развертывания с помощью Docker и Docker Compose. Все зависимости (PHP, Node.js, SQLite) будут автоматически установлены и настроены.

## Требования

- Docker Desktop (для Windows/Mac) или Docker Engine (для Linux)
- Docker Compose

## Быстрый старт

### 1. Клонирование и подготовка

```bash
git clone <your-repo-url>
cd ws
```

### 2. Создание .env файла

```bash
cp .env.example .env
```

Отредактируйте `.env` файл при необходимости. Основные настройки уже корректны для Docker окружения.

### 3. Запуск для разработки

```bash
# Сборка и запуск контейнеров
docker-compose -f docker-compose.dev.yml up --build
```

Приложение будет доступно по адресу: http://localhost:8080

### 4. Запуск для продакшена

```bash
# Сборка и запуск всех сервисов (включая Nginx и Redis)
docker-compose up --build -d
```

- Приложение: http://localhost:8080 (прямой доступ)
- Nginx: http://localhost:80 (с reverse proxy)
- Redis: localhost:6379

## Структура Docker файлов

### Dockerfile
Основной образ содержит:
- PHP 8.2 с Apache
- Node.js и npm
- SQLite
- Все необходимые PHP расширения
- Composer
- Автоматическая настройка Laravel

### docker-compose.yml (Продакшен)
Включает:
- **app**: Основное Laravel приложение
- **redis**: Кеширование и сессии
- **nginx**: Reverse proxy с SSL поддержкой

### docker-compose.dev.yml (Разработка)
Упрощенная версия для разработки:
- Только основное приложение
- Volume mapping для live reload
- Debug режим включен

## Полезные команды

### Управление контейнерами

```bash
# Просмотр логов
docker-compose logs -f app

# Вход в контейнер
docker-compose exec app bash

# Остановка сервисов
docker-compose down

# Пересборка образов
docker-compose build --no-cache

# Очистка всех данных
docker-compose down -v
```

### Laravel команды в контейнере

```bash
# Миграции
docker-compose exec app php artisan migrate

# Очистка кеша
docker-compose exec app php artisan cache:clear

# Генерация ключа
docker-compose exec app php artisan key:generate

# Просмотр маршрутов
docker-compose exec app php artisan route:list
```

### Frontend команды

```bash
# Сборка ассетов
docker-compose exec app npm run build

# Разработка с hot reload
docker-compose exec app npm run dev

# Установка новых пакетов
docker-compose exec app npm install <package-name>
```

## База данных

Проект использует SQLite базу данных, которая:
- Автоматически создается при первом запуске
- Сохраняется в `database/database.sqlite`
- Монтируется как volume для персистентности данных

## SSL/HTTPS настройка

Для включения HTTPS:

1. Поместите SSL сертификаты в папку `ssl/`:
   - `ssl/cert.pem`
   - `ssl/key.pem`

2. Раскомментируйте SSL строки в `nginx.conf`

3. Перезапустите контейнеры:
   ```bash
   docker-compose restart nginx
   ```

## Переменные окружения

Основные переменные в `.env`:

```env
# Приложение
APP_NAME=SereneAI
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8080

# База данных
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite

# Cloudflare Turnstile (опционально)
CLOUDFLARE_TURNSTILE_SECRET_KEY=your_secret_key

# Redis (если используется)
REDIS_HOST=redis
REDIS_PORT=6379
```

## Мониторинг и логи

```bash
# Просмотр всех логов
docker-compose logs -f

# Логи конкретного сервиса
docker-compose logs -f app
docker-compose logs -f nginx
docker-compose logs -f redis

# Статус контейнеров
docker-compose ps

# Использование ресурсов
docker stats
```

## Troubleshooting

### Проблемы с правами доступа
```bash
# Исправление прав на storage и cache
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Проблемы с базой данных
```bash
# Пересоздание базы данных
docker-compose exec app rm -f database/database.sqlite
docker-compose exec app touch database/database.sqlite
docker-compose exec app php artisan migrate --force
```

### Очистка Docker
```bash
# Удаление неиспользуемых образов
docker image prune -f

# Полная очистка Docker
docker system prune -a --volumes
```

## Производительность

Для оптимальной производительности:

1. **Продакшен режим**: Используйте `docker-compose.yml`
2. **Кеширование**: Redis включен по умолчанию
3. **Оптимизация Laravel**:
   ```bash
   docker-compose exec app php artisan config:cache
   docker-compose exec app php artisan route:cache
   docker-compose exec app php artisan view:cache
   ```

## Безопасность

- Все секретные ключи должны быть в `.env` файле
- SSL сертификаты в папке `ssl/` (не коммитить в git)
- Регулярно обновляйте Docker образы
- Используйте strong passwords для production

## Поддержка

Если возникают проблемы:
1. Проверьте логи: `docker-compose logs -f`
2. Убедитесь что все порты свободны
3. Попробуйте пересборку: `docker-compose build --no-cache`
4. Проверьте `.env` конфигурацию