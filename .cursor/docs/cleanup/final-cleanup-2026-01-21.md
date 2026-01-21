# Финальная очистка упоминаний мобильного приложения

**Дата:** 2026-01-21  
**Автор:** AI Assistant  
**Связанный план:** `.cursor/plans/delete_mobile_webhook_infrastructure_589a98e8.plan.md`

## Обзор

После основного удаления WebhookClient/Webhooks.API и устаревших компонентов build системы, был выполнен дополнительный поиск и очистка всех оставшихся упоминаний мобильных технологий (.NET MAUI, Android).

## Найденные и удалённые упоминания

### 1. Код аутентификации (`src\eShop.ServiceDefaults\AuthenticationExtensions.cs`)

**Что удалено:**
- Комментарий со ссылкой на документацию .NET MAUI для Android Emulator
- Условная компиляция `#if DEBUG` для поддержки Android Emulator
- Дополнительный ValidIssuer для Android Emulator: `"https://10.0.2.2:5243"`

**До:**
```csharp
options.Authority = identityUrl;
options.RequireHttpsMetadata = false;
options.Audience = audience;

#if DEBUG
    //Needed if using Android Emulator Locally. See https://learn.microsoft.com/en-us/dotnet/maui/data-cloud/local-web-services?view=net-maui-8.0#android
    options.TokenValidationParameters.ValidIssuers = [identityUrl, "https://10.0.2.2:5243"];
#else
    options.TokenValidationParameters.ValidIssuers = [identityUrl];
#endif

options.TokenValidationParameters.ValidateAudience = false;
```

**После:**
```csharp
options.Authority = identityUrl;
options.RequireHttpsMetadata = false;
options.Audience = audience;
options.TokenValidationParameters.ValidIssuers = [identityUrl];
options.TokenValidationParameters.ValidateAudience = false;
```

**Обоснование:**  
Условная компиляция для Android Emulator была нужна только для мобильного приложения MAUI. После удаления мобильного приложения эта логика больше не требуется.

---

### 2. Конфигурация Identity API (`src\Identity.API\appsettings.json`)

**Что удалено:**
- Настройка `"MauiCallback": "maui://authcallback"`

**До:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "MauiCallback": "maui://authcallback",
  "UseCustomizationData": false,
  "TokenLifetimeMinutes": 120,
  "PermanentTokenLifetimeDays": 365
}
```

**После:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "UseCustomizationData": false,
  "TokenLifetimeMinutes": 120,
  "PermanentTokenLifetimeDays": 365
}
```

**Обоснование:**  
Callback URL схема `maui://` использовалась для OAuth redirect в мобильном приложении MAUI. После удаления мобильного клиента эта настройка не нужна.

---

### 3. Документация проекта (`README.md`)

**Изменение 1: Workloads для Visual Studio**

**До:**
```markdown
- Install [Visual Studio 2022 version 17.10 or newer](https://visualstudio.microsoft.com/vs/).
  - Select the following workloads:
    - `ASP.NET and web development` workload.
    - `.NET Aspire SDK` component in `Individual components`.
    - Optional: `.NET Multi-platform App UI development` to run client apps
```

**После:**
```markdown
- Install [Visual Studio 2022 version 17.10 or newer](https://visualstudio.microsoft.com/vs/).
  - Select the following workloads:
    - `ASP.NET and web development` workload.
    - `.NET Aspire SDK` component in `Individual components`.
```

**Изменение 2: Дополнительные зависимости**

**До:**
```markdown
> Note: These commands may require `sudo`

- Optional: Install [Visual Studio Code with C# Dev Kit](https://code.visualstudio.com/docs/csharp/get-started)
- Optional: Install [.NET MAUI Workload](https://learn.microsoft.com/dotnet/maui/get-started/installation?tabs=visual-studio-code)

> Note: When running on Mac with Apple Silicon (M series processor), Rosetta 2 for grpc-tools.
```

**После:**
```markdown
> Note: These commands may require `sudo`

- Optional: Install [Visual Studio Code with C# Dev Kit](https://code.visualstudio.com/docs/csharp/get-started)

> Note: When running on Mac with Apple Silicon (M series processor), Rosetta 2 for grpc-tools.
```

**Обоснование:**  
.NET MAUI Workload нужен только для разработки мобильных приложений. После удаления WebhookClient (MAUI app) эта зависимость больше не требуется.

---

## Проверка полноты очистки

Выполнена финальная проверка на отсутствие упоминаний удалённых компонентов:

```bash
# Проверка 1: MAUI и мобильные технологии
grep -r "maui|MAUI|android|Android|Xamarin" -i
# Результат: No matches found ✓

# Проверка 2: Webhook компоненты
grep -r "webhook|WebhookClient|Webhooks\.API|mobile-bff" -i
# Результат: No matches found ✓

# Проверка 3: Устаревшие компоненты
grep -r "WebSPA|WebMVC|WebStatus|OcelotApiGw|SignalrHub|webshoppingagg|mobileshoppingagg" -i
# Результат: No matches found ✓

# Проверка 4: Специфичные webhook clients
grep -r "webhooksclient|webhooks\.client|mobile.*client|WebhookClient" -i
# Результат: No matches found ✓
```

**Легитимные упоминания "client":**
- `HttpClient` - стандартный HTTP клиент .NET
- OAuth `client` - клиенты в конфигурации Identity Server
- Domain `ClientRequest` - доменная модель для идемпотентности
- Это **НЕ** связано с удалёнными мобильными/webhook клиентами ✓

---

## Итоговый список изменённых файлов

### Фаза 1: Основное удаление (согласно плану)
1. `eShop.slnx` - удалены проекты WebhookClient и Webhooks.API
2. `src/eShop.AppHost/Program.cs` - удалены webhooksdb, webHooksApi, mobile-bff, webhooksClient
3. `src/eShop.AppHost/Extensions.cs` - удалён метод ConfigureMobileBffRoutes
4. `src/Identity.API/Configuration/Config.cs` - удалены webhook-related клиенты и scopes
5. `build/multiarch-manifests/create-manifests.ps1` - удалены webhook сервисы
6. `build/acr-build/queue-all.ps1` - удалены webhook и legacy сервисы
7. Удалены папки: `src/WebhookClient/`, `src/Webhooks.API/`

### Фаза 2: Дополнительная очистка (2026-01-21, второй проход)
8. `src/eShop.ServiceDefaults/AuthenticationExtensions.cs` - удалена поддержка Android Emulator
9. `src/Identity.API/appsettings.json` - удалён MauiCallback
10. `README.md` - удалены упоминания .NET MAUI workload

---

## Влияние изменений

### ✅ Безопасные изменения
- Удаление условной компиляции для Android не влияет на работу WebApp (Blazor)
- Удаление MauiCallback не влияет на OAuth flow для webapp
- Упрощена конфигурация JWT authentication (один ValidIssuer вместо условного)

### ⚠️ Потенциальные проблемы
- **НЕТ**: Все удалённые настройки относились только к мобильному приложению

### 📋 Рекомендуется протестировать
1. ✅ Сборка решения: `dotnet build eShop.slnx`
2. ✅ Запуск приложения: `dotnet run --project src/eShop.AppHost`
3. ⚠️ Авторизация в WebApp (проверить OAuth flow)
4. ⚠️ JWT токен валидация в API

---

## Текущая архитектура (после очистки)

### Активные клиентские приложения
- **WebApp** (Blazor WebAssembly) - единственное frontend приложение

### Identity Server Clients
- `webapp` - Blazor WebApp
- `webappswaggerui` - Swagger UI для WebApp
- `basketswaggerui` - Swagger UI для Basket.API
- `catalogswaggerui` - Swagger UI для Catalog.API  
- `orderingswaggerui` - Swagger UI для Ordering.API

### Удалённые клиенты
- ~~`maui`~~ - мобильное приложение MAUI
- ~~`webhooksclient`~~ - webhook клиент
- ~~`webhooksswaggerui`~~ - Swagger UI для Webhooks.API

---

## Заключение

✅ **Все упоминания мобильного приложения и webhook инфраструктуры успешно удалены**

Проект теперь содержит только:
- Blazor WebApp (frontend)
- Microservices API (backend)
- Identity Server (authentication)
- Infrastructure (databases, cache, message bus)

Никаких следов мобильного приложения (MAUI), webhook клиента или устаревших компонентов не осталось.

---

## Следующие действия

1. ✅ Код очищен от всех упоминаний
2. ✅ Документация обновлена
3. ⏭️ Рекомендуется протестировать авторизацию WebApp
4. ⏭️ Рекомендуется запустить полную сборку и smoke tests
