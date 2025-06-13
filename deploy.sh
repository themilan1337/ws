#!/bin/bash

# Скрипт автоматического развертывания SereneAI с Docker

set -e  # Остановка при ошибке

echo "🚀 Начинаем развертывание SereneAI..."

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Пожалуйста, установите Docker Desktop."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен."
    exit 1
fi

echo "✅ Docker и Docker Compose найдены"

# Создание .env файла если его нет
if [ ! -f .env ]; then
    echo "📝 Создаем .env файл из примера..."
    cp .env.example .env
    echo "⚠️  Пожалуйста, отредактируйте .env файл при необходимости"
else
    echo "✅ .env файл уже существует"
fi

# Создание директории для SSL сертификатов
if [ ! -d "ssl" ]; then
    echo "📁 Создаем директорию для SSL сертификатов..."
    mkdir -p ssl
    echo "⚠️  Поместите ваши SSL сертификаты в папку ssl/ для HTTPS"
fi

# Остановка существующих контейнеров
echo "🛑 Остановка существующих контейнеров..."
docker-compose down 2>/dev/null || true

# Выбор режима развертывания
echo ""
echo "Выберите режим развертывания:"
echo "1) Разработка (только приложение, debug включен)"
echo "2) Продакшен (полный стек с Nginx и Redis)"
read -p "Введите номер (1 или 2): " mode

case $mode in
    1)
        echo "🔧 Запуск в режиме разработки..."
        COMPOSE_FILE="docker-compose.dev.yml"
        ;;
    2)
        echo "🏭 Запуск в режиме продакшен..."
        COMPOSE_FILE="docker-compose.yml"
        ;;
    *)
        echo "❌ Неверный выбор. Используем режим разработки."
        COMPOSE_FILE="docker-compose.dev.yml"
        ;;
esac

# Сборка и запуск контейнеров
echo "🔨 Сборка Docker образов..."
docker-compose -f $COMPOSE_FILE build --no-cache

echo "🚀 Запуск контейнеров..."
docker-compose -f $COMPOSE_FILE up -d

# Ожидание запуска контейнеров
echo "⏳ Ожидание запуска сервисов..."
sleep 10

# Проверка статуса
echo "📊 Статус контейнеров:"
docker-compose -f $COMPOSE_FILE ps

# Вывод информации о доступе
echo ""
echo "🎉 Развертывание завершено!"
echo ""
echo "📱 Доступ к приложению:"

if [ "$COMPOSE_FILE" = "docker-compose.dev.yml" ]; then
    echo "   🔗 Приложение: http://localhost:8080"
else
    echo "   🔗 Приложение (прямой): http://localhost:8080"
    echo "   🔗 Nginx (proxy): http://localhost:80"
    echo "   🔗 Redis: localhost:6379"
fi

echo ""
echo "📋 Полезные команды:"
echo "   Просмотр логов: docker-compose -f $COMPOSE_FILE logs -f"
echo "   Вход в контейнер: docker-compose -f $COMPOSE_FILE exec app bash"
echo "   Остановка: docker-compose -f $COMPOSE_FILE down"
echo ""
echo "📖 Подробная документация в DOCKER_README.md"

# Проверка доступности приложения
echo "🔍 Проверка доступности приложения..."
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null; then
        echo "✅ Приложение успешно запущено и доступно!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  Приложение может еще запускаться. Проверьте логи: docker-compose -f $COMPOSE_FILE logs -f app"
    fi
    sleep 2
done

echo "🏁 Развертывание завершено успешно!"