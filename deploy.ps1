# PowerShell скрипт автоматического развертывания SereneAI с Docker

# Включаем строгий режим
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "🚀 Начинаем развертывание SereneAI..." -ForegroundColor Green

# Проверка наличия Docker
try {
    docker --version | Out-Null
    Write-Host "✅ Docker найден" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker не установлен. Пожалуйста, установите Docker Desktop." -ForegroundColor Red
    exit 1
}

try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose найден" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose не установлен." -ForegroundColor Red
    exit 1
}

# Создание .env файла если его нет
if (-not (Test-Path ".env")) {
    Write-Host "📝 Создаем .env файл из примера..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "⚠️  Пожалуйста, отредактируйте .env файл при необходимости" -ForegroundColor Yellow
} else {
    Write-Host "✅ .env файл уже существует" -ForegroundColor Green
}

# Создание директории для SSL сертификатов
if (-not (Test-Path "ssl")) {
    Write-Host "📁 Создаем директорию для SSL сертификатов..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "ssl" | Out-Null
    Write-Host "⚠️  Поместите ваши SSL сертификаты в папку ssl\ для HTTPS" -ForegroundColor Yellow
}

# Остановка существующих контейнеров
Write-Host "🛑 Остановка существующих контейнеров..." -ForegroundColor Yellow
try {
    docker-compose down 2>$null
} catch {
    # Игнорируем ошибки если контейнеры не запущены
}

# Выбор режима развертывания
Write-Host ""
Write-Host "Выберите режим развертывания:" -ForegroundColor Cyan
Write-Host "1) Разработка (только приложение, debug включен)" -ForegroundColor White
Write-Host "2) Продакшен (полный стек с Nginx и Redis)" -ForegroundColor White
$mode = Read-Host "Введите номер (1 или 2)"

switch ($mode) {
    "1" {
        Write-Host "🔧 Запуск в режиме разработки..." -ForegroundColor Blue
        $ComposeFile = "docker-compose.dev.yml"
    }
    "2" {
        Write-Host "🏭 Запуск в режиме продакшен..." -ForegroundColor Blue
        $ComposeFile = "docker-compose.yml"
    }
    default {
        Write-Host "❌ Неверный выбор. Используем режим разработки." -ForegroundColor Yellow
        $ComposeFile = "docker-compose.dev.yml"
    }
}

# Сборка и запуск контейнеров
Write-Host "🔨 Сборка Docker образов..." -ForegroundColor Blue
docker-compose -f $ComposeFile build --no-cache

Write-Host "🚀 Запуск контейнеров..." -ForegroundColor Blue
docker-compose -f $ComposeFile up -d

# Ожидание запуска контейнеров
Write-Host "⏳ Ожидание запуска сервисов..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Проверка статуса
Write-Host "📊 Статус контейнеров:" -ForegroundColor Cyan
docker-compose -f $ComposeFile ps

# Вывод информации о доступе
Write-Host ""
Write-Host "🎉 Развертывание завершено!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Доступ к приложению:" -ForegroundColor Cyan

if ($ComposeFile -eq "docker-compose.dev.yml") {
    Write-Host "   🔗 Приложение: http://localhost:8080" -ForegroundColor White
} else {
    Write-Host "   🔗 Приложение (прямой): http://localhost:8080" -ForegroundColor White
    Write-Host "   🔗 Nginx (proxy): http://localhost:80" -ForegroundColor White
    Write-Host "   🔗 Redis: localhost:6379" -ForegroundColor White
}

Write-Host ""
Write-Host "📋 Полезные команды:" -ForegroundColor Cyan
Write-Host "   Просмотр логов: docker-compose -f $ComposeFile logs -f" -ForegroundColor White
Write-Host "   Вход в контейнер: docker-compose -f $ComposeFile exec app bash" -ForegroundColor White
Write-Host "   Остановка: docker-compose -f $ComposeFile down" -ForegroundColor White
Write-Host ""
Write-Host "📖 Подробная документация в DOCKER_README.md" -ForegroundColor Cyan

# Проверка доступности приложения
Write-Host "🔍 Проверка доступности приложения..." -ForegroundColor Yellow

for ($i = 1; $i -le 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Приложение успешно запущено и доступно!" -ForegroundColor Green
            break
        }
    } catch {
        if ($i -eq 30) {
            Write-Host "⚠️  Приложение может еще запускаться. Проверьте логи: docker-compose -f $ComposeFile logs -f app" -ForegroundColor Yellow
        }
    }
    Start-Sleep -Seconds 2
}

Write-Host "🏁 Развертывание завершено успешно!" -ForegroundColor Green

# Открытие браузера
$openBrowser = Read-Host "Открыть приложение в браузере? (y/n)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process "http://localhost:8080"
}