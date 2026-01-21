# Aspire Quickstart Guide

## Быстрый старт с PostgreSQL и pgAdmin

### Требования

- .NET SDK 10.0 или выше
- Docker Desktop (для контейнеров PostgreSQL и pgAdmin)
- Node.js и npm (для React frontend)

### Запуск приложения

1. **Запустите AppHost:**
   ```bash
   dotnet run --project AspireJavaScript.AppHost/AspireJavaScript.AppHost.csproj
   ```

2. **Дождитесь запуска всех сервисов:**
   - PostgreSQL контейнер запустится с персистентным томом данных
   - pgAdmin будет доступен на порту 5050
   - PasswordManager API запустится на порту 8081
   - React frontend запустится на порту 80

### Доступ к сервисам

#### Aspire Dashboard
После запуска откроется Aspire Dashboard, где вы можете:
- Мониторить состояние всех сервисов
- Просматривать логи
- Отслеживать метрики и трассировку

#### pgAdmin
- **URL:** http://localhost:5050
- **Email:** `pgadmin4@pgadmin.org`
- **Password:** `admin`

**Настройка подключения к PostgreSQL в pgAdmin:**
1. Откройте pgAdmin в браузере
2. Добавьте новый сервер:
   - **Name:** `PostgreSQL (Aspire)`
   - **Host:** `postgres` (имя сервиса в Aspire)
   - **Port:** `5432`
   - **Username:** `postgres`
   - **Password:** `postgres` (или значение из переменной окружения)
   - **Database:** `passwordmanagerdb`

#### PasswordManager API
- **URL:** http://localhost:8081
- Доступен через Aspire Dashboard или напрямую по URL

#### React Frontend
- **URL:** http://localhost:80
- Доступен через Aspire Dashboard или напрямую по URL

### Конфигурация

#### PostgreSQL
- **Сервис:** `postgres`
- **База данных:** `passwordmanagerdb`
- **Том данных:** Персистентный (данные сохраняются между перезапусками)
- **Lifetime:** Persistent (контейнер не удаляется при остановке)

#### Подключение к базе данных

Connection string автоматически инжектируется в сервисы через Aspire:
```
ConnectionStrings:passwordmanagerdb
```

В коде используйте:
```csharp
var connectionString = builder.Configuration.GetConnectionString("passwordmanagerdb");
```

### Структура AppHost.cs

```csharp
// PostgreSQL с pgAdmin
var postgres = builder.AddPostgres("postgres")
    .WithDataVolume()
    .WithLifetime(ContainerLifetime.Persistent)
    .WithPgAdmin(pgAdmin => pgAdmin
        .WithHostPort(5050)
        .WithFriendlyUrls(displayText: "pgAdmin Dashboard"));

// База данных
var passwordManagerDb = postgres.AddDatabase("passwordmanagerdb");

// API сервис
var passwordManager = builder.AddProject<Projects.PasswordManager_Startup>("passwordmanagerapi")
    .WithReference(passwordManagerDb)
    .WaitFor(postgres)
    .WithHttpEndpoint(targetPort: 8081, name: "passwordmanagerapi")
    .WithExternalHttpEndpoints();

// React frontend
builder.AddJavaScriptApp("react", "../PasswordManager-Client", runScriptName: "start")
    .WithReference(passwordManager)
    .WaitFor(passwordManager)
    .WithEnvironment("BROWSER", "none")
    .WithHttpEndpoint(env: "PORT", targetPort: 8080, port: 80)
    .WithExternalHttpEndpoints();
```

### Порты

| Сервис | Внутренний порт | Внешний порт | URL |
|--------|----------------|--------------|-----|
| PostgreSQL | 5432 | 5432 | postgres:5432 |
| pgAdmin | 80 | 5050 | http://localhost:5050 |
| PasswordManager API | 8081 | 8081 | http://localhost:8081 |
| React Frontend | 8080 | 80 | http://localhost:80 |

### Troubleshooting

#### Проблема: Контейнеры не запускаются
- Убедитесь, что Docker Desktop запущен
- Проверьте, что порты не заняты другими приложениями

#### Проблема: pgAdmin не открывается
- Проверьте, что порт 5050 свободен
- Убедитесь, что контейнер pgAdmin запущен (проверьте в Aspire Dashboard)

#### Проблема: Не могу подключиться к PostgreSQL из pgAdmin
- Используйте имя сервиса `postgres` как Host (не `localhost`)
- Проверьте учетные данные: username `postgres`, password `postgres`

#### Проблема: База данных не создается
- Убедитесь, что миграции настроены в PasswordManager.Startup
- Проверьте логи в Aspire Dashboard

### Дополнительные ресурсы

- [Aspire Documentation](https://learn.microsoft.com/en-us/dotnet/aspire/)
- [PostgreSQL Integration](https://learn.microsoft.com/en-us/dotnet/aspire/database/postgresql-integration)
- [Aspire Dashboard](https://aspire.dev/)

