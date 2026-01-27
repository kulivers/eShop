# Модуль Catalog

Модуль Catalog отвечает за управление каталогом товаров в системе eShop. Предоставляет REST API для работы с товарами, брендами и типами товаров.

## Проекты модуля

### 1. Catalog.API

**Назначение:** REST API для управления каталогом товаров.

**Ответственность:**
- **REST эндпоинты:**
  - `GET /api/catalog/items` - получение списка товаров (с пагинацией)
  - `GET /api/catalog/items/{id}` - получение товара по ID
  - `GET /api/catalog/items/by` - пакетное получение товаров по IDs
  - `GET /api/catalog/items/by/{name}` - поиск товаров по имени
  - `GET /api/catalog/items/{id}/pic` - получение изображения товара
  - `GET /api/catalog/brands` - получение списка брендов
  - `GET /api/catalog/types` - получение списка типов товаров
  - `POST /api/catalog/items` - создание товара
  - `PUT /api/catalog/items` - обновление товара
  - `DELETE /api/catalog/items/{id}` - удаление товара
  - `PUT /api/catalog/items/{id}/pic` - обновление изображения товара
- **Версионирование API:**
  - Поддержка версий v1 и v2
  - Использование `Asp.Versioning.Http`
- **Модели данных:**
  - `CatalogItem` - товар каталога
  - `CatalogBrand` - бренд товара
  - `CatalogType` - тип товара
  - `PaginatedItems<T>` - пагинированный результат
  - `PaginationRequest` - параметры пагинации
- **Инфраструктура:**
  - `CatalogContext` - EF Core контекст для работы с PostgreSQL
  - `CatalogContextSeed` - инициализация данных
  - Конфигурации Entity Framework для всех сущностей
  - Миграции БД
- **Интеграционные события:**
  - `OrderStatusChangedToAwaitingValidationIntegrationEventHandler` - обработка заказов на валидацию
  - `OrderStatusChangedToPaidIntegrationEventHandler` - обработка оплаченных заказов
  - Публикация событий через Event Bus
- **AI интеграция:**
  - `CatalogAI` - сервис для работы с AI (OpenAI/Ollama)
  - `ICatalogAI` - интерфейс AI сервиса
  - Поддержка векторного поиска через pgvector
- **Изображения товаров:**
  - Хранение изображений в формате WebP
  - Статические файлы в папке `Pics/`

**Зависимости:**
- `EventBusRabbitMQ` - для интеграционных событий
- `IntegrationEventLogEF` - для логирования событий
- `eShop.ServiceDefaults` - базовые сервисы Aspire
- `Asp.Versioning.Http` - версионирование API
- `Aspire.Npgsql.EntityFrameworkCore.PostgreSQL` - работа с PostgreSQL
- `Aspire.Azure.AI.OpenAI` - интеграция с OpenAI (опционально)
- `CommunityToolkit.Aspire.OllamaSharp` - интеграция с Ollama (опционально)
- `Pgvector` и `Pgvector.EntityFrameworkCore` - векторный поиск

**Особенности:**
- Версионирование API (v1, v2)
- Поддержка пагинации
- Интеграция с AI для умного поиска
- Векторный поиск через pgvector
- Оптимизация работы с изображениями
- Health checks для мониторинга

---

### 2. Catalog.FunctionalTests

**Назначение:** Функциональные тесты для Catalog API.

**Ответственность:**
- Тесты REST API эндпоинтов
- Тесты пагинации
- Тесты поиска товаров
- Тесты работы с изображениями
- Интеграционные тесты с БД

**Зависимости:**
- `Catalog.API`
- `Aspire.Hosting.PostgreSQL` - для поднятия инфраструктуры
- `xunit.v3.mtp-v2` - фреймворк тестирования
- `Microsoft.AspNetCore.Mvc.Testing` - тестирование веб-приложений

**Особенности:**
- Полноценные интеграционные тесты
- Использование Aspire для поднятия инфраструктуры
- Тестирование всех версий API

---

## Архитектура

```
┌─────────────────┐
│  Catalog.API    │ ← REST API для клиентов
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼────┐ ┌──▼──────────┐
│PostgreSQL│ │ RabbitMQ   │
│(pgvector)│ │ Event Bus  │
└─────────┘ └────────────┘
         │
    ┌────┴────┐
    │         │
┌───▼────┐ ┌──▼──────────┐
│OpenAI/ │ │  Images     │
│Ollama  │ │  (WebP)     │
└────────┘ └─────────────┘
```

## Основные потоки данных

### Получение списка товаров:
1. Клиент отправляет `GET /api/catalog/items?pageIndex=0&pageSize=10`
2. API обрабатывает запрос и получает данные из БД
3. Возвращает пагинированный результат

### Создание товара:
1. Клиент отправляет `POST /api/catalog/items` с данными товара
2. API создает новый `CatalogItem` в БД
3. Возвращает созданный товар

### Обработка интеграционных событий:
1. Получение события `OrderStatusChangedToAwaitingValidationIntegrationEvent`
2. Проверка наличия товаров на складе
3. Публикация события `OrderStockConfirmedIntegrationEvent` или `OrderStockRejectedIntegrationEvent`

### AI поиск:
1. Клиент отправляет запрос через AI интерфейс
2. `CatalogAI` обрабатывает запрос через OpenAI/Ollama
3. Выполняется векторный поиск в БД через pgvector
4. Возвращаются релевантные товары

## Особенности реализации

- **Версионирование:** Поддержка нескольких версий API для обратной совместимости
- **Пагинация:** Эффективная работа с большими объемами данных
- **Векторный поиск:** Использование pgvector для семантического поиска
- **AI интеграция:** Опциональная интеграция с OpenAI или Ollama
- **Оптимизация изображений:** Хранение в формате WebP для экономии места
- **Event-Driven:** Асинхронная обработка через интеграционные события
