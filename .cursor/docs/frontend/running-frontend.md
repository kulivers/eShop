# Запуск фронтенд-приложения

Фронтенд-приложение Password Manager можно запустить двумя способами: в standalone режиме или через Aspire AppHost.

## Предварительные требования

- Node.js (версия 20.x или выше)
- npm или yarn
- Установленные зависимости: `npm install` или `yarn install` в папке `frontend/`

## Способ 1: Standalone запуск

Запуск фронтенда отдельно от остальных сервисов.

### Шаги

1. Перейдите в папку фронтенда:
```bash
cd frontend
```

2. Установите зависимости (если еще не установлены):
```bash
npm install
```

3. Запустите dev-сервер:
```bash
npm start
```

### Результат

- Приложение будет доступно на `http://localhost:8080`
- Webpack dev-server запустится в режиме разработки с hot-reload
- API запросы будут проксироваться на `http://localhost:5000` (настройка в `webpack.config.js`)

### Настройка порта

По умолчанию используется порт 8080. Чтобы изменить порт, установите переменную окружения:

**Windows:**
```bash
set PORT=4000 && npm start
```

**Unix/Linux/Mac:**
```bash
PORT=4000 npm start
```

## Способ 2: Запуск через Aspire AppHost

Запуск фронтенда как части распределенного приложения через .NET Aspire.

### Шаги

1. Перейдите в папку AppHost:
```bash
cd AspireJavaScript.AppHost
```

2. Запустите Aspire приложение:
```bash
dotnet run
```

### Результат

- Aspire Dashboard откроется автоматически в браузере
- Фронтенд будет доступен на `http://localhost:8085` (внешний порт)
- Внутри контейнера приложение слушает на порту 8080 (targetPort)
- Aspire автоматически настроит переменные окружения для связи с API

### Конфигурация в Aspire

Фронтенд настроен в `AspireJavaScript.AppHost/AppHost.cs`:

```csharp
builder.AddJavaScriptApp("react", "../frontend", runScriptName: "start")
    .WithReference(passwordManager)
    .WaitFor(passwordManager)
    .WithEnvironment("BROWSER", "none")
    .WithHttpEndpoint(
        env: "PORT",
        targetPort: 8080,
        port: 8085
    )
    .WithExternalHttpEndpoints();
```

**Параметры:**
- `runScriptName: "start"` - запускает npm-скрипт `start`
- `targetPort: 8080` - внутренний порт приложения
- `port: 8085` - внешний порт для доступа с хоста
- `env: "PORT"` - переменная окружения для передачи порта в приложение

## Переменные окружения

### Для standalone запуска

Создайте файл `.env` в папке `frontend/` на основе `env.example`:

```env
# API base URL for backend
REACT_APP_API_BASE_URL=https://localhost:5001/api

# Enable mock services (true/false)
REACT_APP_ENABLE_MOCKS=false
```

### Для запуска через Aspire

Aspire автоматически настраивает переменные окружения:
- `PORT` - устанавливается в 8080
- `services__passwordmanagerapi__http__0` - URL HTTP API
- `services__passwordmanagerapi__https__0` - URL HTTPS API

Эти переменные используются в `webpack.config.js` для настройки прокси.

## Сборка для production

Для создания production сборки:

```bash
cd frontend
npm run build
```

Собранные файлы будут находиться в папке `frontend/dist/`.

## Устранение проблем

### Порт уже занят

Если порт 8080 (или другой указанный порт) уже занят:

1. Найдите процесс, использующий порт:
   - Windows: `netstat -ano | findstr :8080`
   - Unix: `lsof -i :8080`

2. Остановите процесс или используйте другой порт через переменную окружения `PORT`

### Зависимости не установлены

Если возникают ошибки при запуске:

```bash
cd frontend
rm -rf node_modules package-lock.json  # или yarn.lock
npm install
```

### Проблемы с прокси API

Если API запросы не работают:

1. Убедитесь, что бэкенд запущен и доступен
2. Проверьте настройки прокси в `webpack.config.js`
3. Для standalone запуска убедитесь, что API доступен на `http://localhost:5000`

## Скрипты в package.json

- `npm start` - запуск dev-сервера (кроссплатформенный через `run-script-os`)
- `npm run build` - сборка для production
- `npm start:win32` - запуск на Windows (используется автоматически через `run-script-os`)
- `npm start:default` - запуск на Unix/Linux/Mac (используется автоматически через `run-script-os`)
