---
name: Настройка логирования PasswordManager
overview: "Настройка комплексного логирования для PasswordManager: добавление Aspire Dashboard интеграции, настройка NLog для записи в файлы и сохранение консольного вывода."
todos:
  - id: add-aspire-integration
    content: Добавить AddServiceDefaults() и MapDefaultEndpoints() в Program.cs для интеграции с Aspire Dashboard
    status: pending
  - id: create-nlog-config
    content: Создать/адаптировать NLog.config с настройками для записи в папку logs/ с ротацией по дням
    status: pending
  - id: initialize-nlog
    content: Инициализировать NLog в Program.cs с использованием NLogBuilder.ConfigureNLog()
    status: pending
    dependencies:
      - create-nlog-config
  - id: verify-csproj
    content: Проверить и при необходимости обновить ссылку на NLog.config в .csproj файле
    status: pending
    dependencies:
      - create-nlog-config
---

# Настройка логирования PasswordManager

## Цель

Настроить комплексное логирование для PasswordManager API с тремя каналами:

1. **Aspire Dashboard** - через OpenTelemetry для мониторинга в реальном времени
2. **NLog файлы** - для персистентного хранения логов в папке `logs/`
3. **Консоль** - стандартный вывод для разработки

## Текущее состояние

- В [PasswordManager/PasswordManager.Startup/Program.cs](PasswordManager/PasswordManager.Startup/Program.cs) отсутствует `AddServiceDefaults()`, поэтому логи не попадают в Aspire Dashboard
- NLog пакеты установлены, но не инициализированы в коде
- Существующий [PasswordManager/Logging/NLog.config](PasswordManager/Logging/NLog.config) слишком сложный и специфичен для другой платформы
- В [PasswordManager/PasswordManager.Startup/PasswordManager.Startup.csproj](PasswordManager/PasswordManager.Startup/PasswordManager.Startup.csproj) есть ссылка на NLog.config, но он не используется

## Изменения

### 1. Добавление Aspire Dashboard интеграции

**Файл:** [PasswordManager/PasswordManager.Startup/Program.cs](PasswordManager/PasswordManager.Startup/Program.cs)

- Добавить вызов `builder.AddServiceDefaults()` после создания `WebApplicationBuilder`
- Это включит OpenTelemetry логирование для отправки в Aspire Dashboard
- Добавить вызов `app.MapDefaultEndpoints()` для health checks (опционально)

### 2. Создание упрощенного NLog.config для PasswordManager

**Файл:** [PasswordManager/Logging/NLog.config](PasswordManager/Logging/NLog.config)

- Адаптировать существующий файл или создать упрощенную версию
- Настроить путь к логам: `${basedir}/logs/` (папка рядом с приложением)
- Создать основные targets:
- `allFile` - все логи (Info и выше)
- `errorFile` - только ошибки (Error и выше)
- `console` - вывод в консоль
- Настроить правила маршрутизации:
- Все логи уровня Info+ → `allFile` и `console`
- Ошибки уровня Error+ → `errorFile`, `allFile` и `console`
- Настроить архивацию: ротация по дням, хранение 30 дней

### 3. Инициализация NLog в Program.cs

**Файл:** [PasswordManager/PasswordManager.Startup/Program.cs](PasswordManager/PasswordManager.Startup/Program.cs)

- Добавить `using NLog.Web;` и `using NLog;`
- Вызвать `NLogBuilder.ConfigureNLog()` перед созданием `WebApplicationBuilder`
- Настроить NLog для использования конфигурации из `NLog.config`
- Добавить очистку NLog при завершении приложения

### 4. Обновление .csproj (если необходимо)

**Файл:** [PasswordManager/PasswordManager.Startup/PasswordManager.Startup.csproj](PasswordManager/PasswordManager.Startup/PasswordManager.Startup.csproj)

- Проверить, что ссылка на `NLog.config` корректна
- Убедиться, что файл копируется в output directory

## Структура логов

После настройки логи будут писаться в:

- `PasswordManager/PasswordManager.Startup/logs/all_YYYY-MM-DD.log` - все логи
- `PasswordManager/PasswordManager.Startup/logs/error_YYYY-MM-DD.log` - только ошибки
- Консоль - все логи уровня Info и выше
- Aspire Dashboard - все логи через OpenTelemetry

## Зависимости

- `NLog` и `NLog.Web.AspNetCore` уже установлены (версия 5.3.2)
- `AspireJavaScript.ServiceDefaults` уже подключен как проект
- Папка `logs/` уже создана в структуре проекта