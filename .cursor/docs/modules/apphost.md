# Модуль AppHost

Модуль AppHost является точкой входа для оркестрации всех сервисов eShop через .NET Aspire. Определяет топологию приложения и зависимости между сервисами.

## Проекты модуля

### 1. eShop.AppHost

**Назначение:** Оркестрация всех сервисов и ресурсов eShop через .NET Aspire.

**Ответственность:**
- **Ресурсы инфраструктуры:**
  - Redis - для корзины покупок
  - RabbitMQ - для Event Bus
  - PostgreSQL - основная БД с поддержкой pgvector
  - Базы данных:
    - `catalogdb` - для каталога товаров
    - `identitydb` - для Identity Server
    - `orderingdb` - для заказов
- **Сервисы:**
  - `Identity.API` - Identity Server
  - `Basket.API` - сервис корзины
  - `Catalog.API` - сервис каталога
  - `Ordering.API` - сервис заказов
  - `OrderProcessor` - фоновый сервис обработки заказов
  - `PaymentProcessor` - фоновый сервис обработки платежей
  - `WebApp` - веб-приложение
- **Конфигурация:**
  - Настройка зависимостей между сервисами
  - Настройка переменных окружения
  - Настройка health checks
  - Настройка callback URLs
- **AI интеграция (опционально):**
  - OpenAI - для AI функций
  - Ollama - альтернатива OpenAI

**Зависимости:**
- `.NET Aspire` - для оркестрации
- Все проекты сервисов eShop

**Особенности:**
- Единая точка конфигурации
- Автоматическое управление зависимостями
- Интеграция с Aspire Dashboard
- Поддержка локальной разработки и развертывания

---

## Архитектура

```
┌─────────────────┐
│  eShop.AppHost  │ ← Оркестратор
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼──────────┐
│Services│ │ Resources   │
│        │ │ (Redis,     │
│        │ │  RabbitMQ,  │
│        │ │  PostgreSQL)│
└────────┘ └─────────────┘
```

## Конфигурация сервисов

### Identity API:
```csharp
var identityApi = builder.AddProject<Projects.Identity_API>("identity-api")
    .WithExternalHttpEndpoints()
    .WithReference(identityDb);
```

### Basket API:
```csharp
var basketApi = builder.AddProject<Projects.Basket_API>("basket-api")
    .WithReference(redis)
    .WithReference(rabbitMq)
    .WithEnvironment("Identity__Url", identityEndpoint);
```

### Catalog API:
```csharp
var catalogApi = builder.AddProject<Projects.Catalog_API>("catalog-api")
    .WithReference(rabbitMq)
    .WithReference(catalogDb);
```

### Ordering API:
```csharp
var orderingApi = builder.AddProject<Projects.Ordering_API>("ordering-api")
    .WithReference(rabbitMq)
    .WithReference(orderDb)
    .WithHttpHealthCheck("/health")
    .WithEnvironment("Identity__Url", identityEndpoint);
```

### OrderProcessor:
```csharp
builder.AddProject<Projects.OrderProcessor>("order-processor")
    .WithReference(rabbitMq)
    .WithReference(orderDb)
    .WaitFor(orderingApi); // Ожидание готовности Ordering API
```

### PaymentProcessor:
```csharp
builder.AddProject<Projects.PaymentProcessor>("payment-processor")
    .WithReference(rabbitMq);
```

### WebApp:
```csharp
var webApp = builder.AddProject<Projects.WebApp>("webapp")
    .WithExternalHttpEndpoints()
    .WithReference(basketApi)
    .WithReference(catalogApi)
    .WithReference(orderingApi)
    .WithReference(rabbitMq)
    .WithEnvironment("IdentityUrl", identityEndpoint);
```

## Ресурсы инфраструктуры

### Redis:
```csharp
var redis = builder.AddRedis("redis");
```

### RabbitMQ:
```csharp
var rabbitMq = builder.AddRabbitMQ("eventbus")
    .WithLifetime(ContainerLifetime.Persistent);
```

### PostgreSQL:
```csharp
var postgres = builder.AddPostgres("postgres")
    .WithImage("ankane/pgvector")
    .WithImageTag("latest")
    .WithLifetime(ContainerLifetime.Persistent);

var catalogDb = postgres.AddDatabase("catalogdb");
var identityDb = postgres.AddDatabase("identitydb");
var orderDb = postgres.AddDatabase("orderingdb");
```

## AI интеграция

### OpenAI (опционально):
```csharp
bool useOpenAI = false;
if (useOpenAI)
{
    builder.AddOpenAI(catalogApi, webApp, OpenAITarget.OpenAI);
}
```

### Ollama (опционально):
```csharp
bool useOllama = false;
if (useOllama)
{
    builder.AddOllama(catalogApi, webApp);
}
```

## Особенности реализации

- **Оркестрация:** Единая точка управления всеми сервисами
- **Зависимости:** Автоматическое управление порядком запуска
- **Конфигурация:** Централизованная настройка всех сервисов
- **Мониторинг:** Интеграция с Aspire Dashboard
- **Развертывание:** Поддержка локальной разработки и production

## Запуск приложения

Для запуска всего приложения:
```bash
dotnet run --project src/eShop.AppHost
```

Это запустит:
- Все сервисы
- Все ресурсы (Redis, RabbitMQ, PostgreSQL)
- Aspire Dashboard для мониторинга

## Aspire Dashboard

AppHost автоматически настраивает Aspire Dashboard, который предоставляет:
- Обзор всех сервисов и их статусов
- Метрики и логи
- Трассировка запросов
- Health checks
- Конфигурация сервисов
