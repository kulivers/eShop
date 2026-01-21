# Удаление устаревших компонентов из eShop

## Дата: 2026-01-21

## Обзор

Выполнена полная очистка проекта от упоминаний удалённых компонентов мобильного приложения (WebhookClient) и webhook infrastructure, а также обновлены build скрипты для соответствия текущей архитектуре проекта на базе .NET Aspire.

## Удалённые упоминания

### 1. Build Scripts - ACR Build (`build\acr-build\queue-all.ps1`)

**Удалено:**
- `eshopmobileshoppingagg` - Mobile shopping aggregator (BFF)
- `eshopwebspa` - WebSPA приложение
- `eshopwebmvc` - WebMVC приложение  
- `eshopwebstatus` - WebStatus монит<br/>
- `eshopocelotapigw` - Ocelot API Gateway
- `eshoporderingsignalrhub` - Ordering SignalR Hub

**Оставлено (актуальные компоненты):**
- `eshopbasket` - Basket.API
- `eshopcatalog` - Catalog.API
- `eshopidentity` - Identity.API
- `eshopordering` - Ordering.API
- `eshoporderprocessor` - OrderProcessor
- `eshoppayment` - PaymentProcessor
- `eshopwebapp` - WebApp (Blazor)

### 2. Build Scripts - Multiarch Manifests (`build\multiarch-manifests\create-manifests.ps1`)

**Удалено:**
- `ocelotapigw`
- `webshoppingagg`
- `ordering.signalrhub`
- `webstatus`
- `webspa`
- `webmvc`

**Оставлено (актуальные компоненты):**
- `identity.api`
- `basket.api`
- `catalog.api`
- `ordering.api`
- `orderprocessor`
- `paymentprocessor`
- `webapp`

### 3. Identity Configuration (`src\Identity.API\Configuration\Config.cs`)

**Удалено из AllowedScopes клиента "webapp":**
- `"webshoppingagg"` - scope для несуществующего Web shopping aggregator

**Оставлено:**
- `IdentityServerConstants.StandardScopes.OpenId`
- `IdentityServerConstants.StandardScopes.Profile`
- `IdentityServerConstants.StandardScopes.OfflineAccess`
- `"orders"`
- `"basket"`

## Контекст изменений

### Предыдущая очистка

Согласно плану `.cursor/plans/delete_mobile_webhook_infrastructure_589a98e8.plan.md`, ранее были удалены:

1. **Проекты:**
   - `src/WebhookClient/` (33 файла)
   - `src/Webhooks.API/` (31 файла)

2. **AppHost конфигурация:**
   - `webhooksdb` база данных
   - `webHooksApi` проект
   - `mobile-bff` YARP proxy
   - `webhooksClient` проект

3. **Identity конфигурация:**
   - API resource "webhooks"
   - API scope "webhooks"
   - Client "maui"
   - Client "webhooksclient"
   - Client "webhooksswaggerui"

### Текущая очистка

Дополнительно удалены упоминания в build скриптах и конфигурации, которые ссылались на:
- Компоненты из старой архитектуры eShop (до перехода на .NET Aspire)
- Несуществующие BFF aggregators
- Устаревшие клиентские приложения (WebSPA, WebMVC)

### Дополнительная очистка (2026-01-21, второй проход)

Удалены последние упоминания MAUI и мобильных компонентов:

**Файл: `src\eShop.ServiceDefaults\AuthenticationExtensions.cs`**
- ✅ Удалён комментарий про Android Emulator
- ✅ Удалена условная компиляция `#if DEBUG` для Android
- ✅ Удалён дополнительный ValidIssuer для Android Emulator (https://10.0.2.2:5243)

**Файл: `src\Identity.API\appsettings.json`**
- ✅ Удалена настройка `"MauiCallback": "maui://authcallback"`

**Файл: `README.md`**
- ✅ Удалено упоминание `.NET Multi-platform App UI development` из workloads
- ✅ Удалена секция "Install .NET MAUI Workload"

## Причина изменений

1. **Build скрипты** (`build/acr-build/` и `build/multiarch-manifests/`):
   - Содержали ссылки на проекты из старой архитектуры eShop
   - Не соответствовали текущей структуре solution
   - Ссылались на несуществующие Dockerfile'ы

2. **Identity конфигурация**:
   - Содержала scope для несуществующего API gateway/aggregator
   - Потенциально могла вызвать проблемы с авторизацией

## Текущая архитектура проекта

### Активные сервисы (.NET Aspire)

```
eShop/
├── src/
│   ├── eShop.AppHost/           # Orchestration (Aspire)
│   ├── eShop.ServiceDefaults/   # Shared configuration
│   ├── Basket.API/              # Basket microservice
│   ├── Catalog.API/             # Catalog microservice
│   ├── Identity.API/            # Identity Server
│   ├── Ordering.API/            # Ordering microservice
│   ├── Ordering.Domain/         # Domain models
│   ├── Ordering.Infrastructure/ # Data access
│   ├── OrderProcessor/          # Background worker
│   ├── PaymentProcessor/        # Background worker
│   ├── WebApp/                  # Blazor frontend
│   ├── WebAppComponents/        # Shared UI components
│   ├── EventBus/                # Event bus abstraction
│   ├── EventBusRabbitMQ/        # RabbitMQ implementation
│   ├── IntegrationEventLogEF/   # Event sourcing
│   └── Shared/                  # Shared utilities
```

### Инфраструктура

- **База данных:** PostgreSQL (через Aspire)
- **Кэш:** Redis (через Aspire)
- **Сообщения:** RabbitMQ (через Aspire)
- **Identity:** IdentityServer/Duende
- **Frontend:** Blazor WebAssembly

## Проверка

Выполнена проверка на отсутствие упоминаний удалённых компонентов:

```bash
# Проверка всех удалённых упоминаний
grep -r "WebSPA|WebMVC|WebStatus|OcelotApiGw|SignalrHub|webshoppingagg|mobileshoppingagg|webhook|WebhookClient|Webhooks\.API|mobile-bff" -i
# Результат: No matches found ✓
```

## Следующие шаги

1. ✅ Удалены все упоминания устаревших компонентов
2. ✅ Обновлены build скрипты под текущую архитектуру
3. ✅ Очищена конфигурация Identity
4. ✅ Удалены упоминания MAUI из кода и документации
5. ⚠️ Рекомендуется: Протестировать build процесс (если используются ACR build скрипты)
6. ⚠️ Рекомендуется: Проверить работу Identity авторизации для WebApp

## Файлы изменены

1. `build\acr-build\queue-all.ps1`
2. `build\multiarch-manifests\create-manifests.ps1`
3. `src\Identity.API\Configuration\Config.cs`
4. `src\eShop.ServiceDefaults\AuthenticationExtensions.cs` (2026-01-21)
5. `src\Identity.API\appsettings.json` (2026-01-21)
6. `README.md` (2026-01-21)

## Примечания

- Build скрипты в `build/` предназначены для старой архитектуры и могут потребовать дополнительной адаптации под Aspire
- Текущая версия проекта использует .NET Aspire для orchestration, поэтому классические Docker/Kubernetes build скрипты могут быть не актуальны
- Возможно, стоит рассмотреть полное удаление или архивирование папки `build/` если она не используется
