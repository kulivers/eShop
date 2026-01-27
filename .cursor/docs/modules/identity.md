# Модуль Identity

Модуль Identity отвечает за аутентификацию и авторизацию пользователей в системе eShop. Использует Duende IdentityServer для реализации OAuth 2.0 / OpenID Connect.

## Проекты модуля

### 1. Identity.API

**Назначение:** Identity Server для аутентификации и авторизации.

**Ответственность:**
- **Аутентификация:**
  - OAuth 2.0 / OpenID Connect сервер
  - Поддержка различных типов авторизации (Authorization Code, Implicit, etc.)
  - JWT токены для API доступа
- **Управление пользователями:**
  - Регистрация пользователей
  - Вход в систему
  - Выход из системы
  - Управление профилем
- **Управление клиентами:**
  - Регистрация клиентских приложений
  - Управление scopes и claims
  - Настройка redirect URIs
- **UI компоненты:**
  - Страницы входа (`Login.cshtml`)
  - Страницы выхода (`Logout.cshtml`)
  - Страницы согласия (`Consent/Index.cshtml`)
  - Страницы управления устройствами (`Device/`)
  - Страницы диагностики (`Diagnostics/Index.cshtml`)
  - Страницы управления доступом (`Grants/Index.cshtml`)
- **База данных:**
  - Хранение пользователей через ASP.NET Core Identity
  - Хранение конфигурации IdentityServer в БД
  - Использование PostgreSQL через EF Core
- **Интеграция:**
  - Callback URLs для других сервисов (Basket, Ordering, WebApp)
  - Настройка клиентов для каждого сервиса

**Зависимости:**
- `Duende.IdentityServer` - основной Identity Server
- `Duende.IdentityServer.AspNetIdentity` - интеграция с ASP.NET Core Identity
- `Duende.IdentityServer.EntityFramework` - хранение конфигурации в БД
- `Microsoft.AspNetCore.Identity.EntityFrameworkCore` - управление пользователями
- `Microsoft.AspNetCore.Identity.UI` - UI компоненты
- `Aspire.Npgsql.EntityFrameworkCore.PostgreSQL` - работа с PostgreSQL
- `eShop.ServiceDefaults` - базовые сервисы Aspire

**Особенности:**
- Полнофункциональный Identity Server
- Интеграция с ASP.NET Core Identity
- Хранение конфигурации в БД
- Поддержка различных типов авторизации
- UI для управления пользователями и клиентами
- Интеграция со всеми сервисами eShop

---

## Архитектура

```
┌─────────────────┐
│  Identity.API   │ ← Identity Server
│  (OAuth/OIDC)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼────┐ ┌──▼──────────┐
│PostgreSQL│ │  Clients   │
│          │ │  (Basket,  │
│          │ │  Ordering, │
│          │ │  WebApp)   │
└──────────┘ └────────────┘
```

## Основные потоки данных

### Аутентификация пользователя:
1. Пользователь перенаправляется на Identity Server
2. Вводит учетные данные на странице входа
3. Identity Server проверяет учетные данные
4. Выдается authorization code или токен
5. Клиентское приложение обменивает код на access token
6. Access token используется для доступа к защищенным ресурсам

### Регистрация нового пользователя:
1. Пользователь заполняет форму регистрации
2. Создается новый пользователь в ASP.NET Core Identity
3. Пользователь может войти в систему

### Выход из системы:
1. Пользователь инициирует выход
2. Identity Server инвалидирует токены
3. Перенаправление на страницу выхода
4. Очистка сессии на всех подключенных сервисах

## Конфигурация клиентов

Identity Server настроен для работы со следующими клиентами:
- **Basket API** - для доступа к корзине
- **Ordering API** - для доступа к заказам
- **WebApp** - веб-приложение
- **Catalog API** - публичный доступ (опционально)

## Особенности реализации

- **Duende IdentityServer:** Профессиональный Identity Server с полной поддержкой OAuth 2.0 / OIDC
- **ASP.NET Core Identity:** Управление пользователями и ролями
- **Entity Framework:** Хранение конфигурации и пользователей в БД
- **UI компоненты:** Готовые страницы для управления аутентификацией
- **Интеграция:** Настроенные callback URLs для всех сервисов
- **Безопасность:** Использование HTTPS, защита от CSRF, валидация токенов

## Endpoints Identity Server

- `/connect/authorize` - авторизация
- `/connect/token` - получение токенов
- `/connect/userinfo` - информация о пользователе
- `/connect/logout` - выход из системы
- `/connect/revocation` - отзыв токенов
- `/.well-known/openid-configuration` - конфигурация OpenID Connect
