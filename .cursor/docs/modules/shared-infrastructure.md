# Модуль Shared Infrastructure

Модуль Shared Infrastructure содержит общие компоненты и утилиты, используемые всеми сервисами eShop.

## Проекты модуля

### 1. eShop.ServiceDefaults

**Назначение:** Базовые сервисы и настройки по умолчанию для всех сервисов Aspire.

**Ответственность:**
- **Аутентификация:**
  - `AuthenticationExtensions` - настройка аутентификации
  - `ClaimsPrincipalExtensions` - расширения для работы с claims
  - Поддержка JWT Bearer токенов
- **Конфигурация:**
  - `ConfigurationExtensions` - расширения для конфигурации
  - Настройка по умолчанию для всех сервисов
- **HTTP клиенты:**
  - `HttpClientExtensions` - настройка HTTP клиентов
  - Интеграция с Service Discovery
  - Настройка resilience (повторные попытки, circuit breaker)
- **OpenAPI:**
  - `OpenApi.Extensions` - настройка OpenAPI/Swagger
  - `OpenApiOptionsExtensions` - расширения для опций OpenAPI
  - Интеграция с Scalar для документации API
- **Телеметрия:**
  - Настройка OpenTelemetry
  - Интеграция с Aspire Dashboard
  - Метрики и трассировка
- **Health Checks:**
  - Настройка health checks по умолчанию
  - Интеграция с Aspire

**Зависимости:**
- `Microsoft.AspNetCore.App` - базовые зависимости ASP.NET Core
- `Asp.Versioning.Mvc.ApiExplorer` - версионирование API
- `Microsoft.AspNetCore.OpenApi` - OpenAPI поддержка
- `Scalar.AspNetCore` - документация API
- `Microsoft.AspNetCore.Authentication.JwtBearer` - JWT аутентификация
- `Microsoft.Extensions.Http.Resilience` - устойчивость HTTP клиентов
- `Microsoft.Extensions.ServiceDiscovery` - обнаружение сервисов
- OpenTelemetry пакеты для телеметрии

**Особенности:**
- Единообразная настройка всех сервисов
- Интеграция с Aspire для оркестрации
- Автоматическая настройка телеметрии
- Поддержка Service Discovery
- Resilience patterns для надежности

---

### 2. IntegrationEventLogEF

**Назначение:** Логирование интеграционных событий в БД для обеспечения надежности доставки.

**Ответственность:**
- **Логирование событий:**
  - Хранение интеграционных событий в БД
  - Отслеживание статуса обработки событий
  - Поддержка транзакций с бизнес-данными
- **Outbox Pattern:**
  - Реализация паттерна Transactional Outbox
  - Гарантия доставки событий
  - Идемпотентная обработка
- **Интеграция:**
  - `IIntegrationEventLogService` - интерфейс сервиса логирования
  - `IntegrationEventLogService<T>` - реализация для конкретного DbContext
  - Расширения для EF Core

**Зависимости:**
- `EventBus` - абстракции для событий
- `Npgsql.EntityFrameworkCore.PostgreSQL` - работа с PostgreSQL

**Особенности:**
- Транзакционное логирование событий
- Гарантия доставки через Outbox Pattern
- Поддержка идемпотентности
- Интеграция с любым DbContext

---

### 3. Shared

**Назначение:** Общие утилиты и расширения.

**Ответственность:**
- **Расширения:**
  - `ActivityExtensions` - расширения для OpenTelemetry Activity
  - `MigrateDbContextExtensions` - расширения для миграций БД
- **Утилиты:**
  - Общие вспомогательные методы
  - Расширения для работы с типами

**Зависимости:**
- Базовые зависимости .NET

**Особенности:**
- Переиспользуемые утилиты
- Расширения для упрощения кода
- Общие паттерны и практики

---

## Архитектура

```
┌─────────────────┐
│  All Services    │
│  (Ordering,      │
│   Catalog, etc.) │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼──────────┐
│Service│ │Integration  │
│Defaults│ │EventLogEF   │
└───────┘ └─────────────┘
    │
┌───▼──────────┐
│  Shared      │
│  Utilities   │
└──────────────┘
```

## Использование

### ServiceDefaults в сервисе:
```csharp
var builder = WebApplication.CreateBuilder(args);
builder.AddServiceDefaults(); // Добавляет все базовые настройки
```

### IntegrationEventLog в сервисе:
```csharp
services.AddTransient<IIntegrationEventLogService, 
    IntegrationEventLogService<MyDbContext>>();
```

### Shared утилиты:
```csharp
// Использование расширений для Activity
activity?.SetTag("key", "value");

// Использование расширений для миграций
app.MigrateDbContext<MyDbContext>();
```

## Особенности реализации

- **Единообразие:** Все сервисы используют одинаковые настройки
- **Надежность:** Outbox Pattern для гарантии доставки событий
- **Наблюдаемость:** Автоматическая настройка телеметрии
- **Устойчивость:** Resilience patterns для обработки ошибок
- **Масштабируемость:** Service Discovery для динамической маршрутизации

## Интеграция с Aspire

Все компоненты Shared Infrastructure интегрированы с .NET Aspire:
- Автоматическое обнаружение сервисов
- Централизованная конфигурация
- Единая телеметрия через Dashboard
- Управление зависимостями
