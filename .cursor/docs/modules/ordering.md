# Модуль Ordering

Модуль Ordering отвечает за управление заказами в системе eShop. Реализован по принципам Domain-Driven Design (DDD) и Clean Architecture.

## Проекты модуля

### 1. Ordering.Domain (Domain Layer)

**Назначение:** Доменный слой - содержит бизнес-логику и правила предметной области.

**Ответственность:**
- **Агрегаты:**
  - `Order` - основной агрегат заказа с бизнес-логикой изменения статусов
  - `Buyer` - агрегат покупателя
  - `PaymentMethod` - метод оплаты
  - `Address` - адрес доставки (Value Object)
  - `OrderItem` - элемент заказа
- **Доменные события:**
  - `OrderStartedDomainEvent` - заказ создан
  - `OrderCancelledDomainEvent` - заказ отменен
  - `OrderShippedDomainEvent` - заказ отправлен
  - `OrderStatusChangedToAwaitingValidationDomainEvent` - статус изменен на ожидание валидации
  - `OrderStatusChangedToPaidDomainEvent` - статус изменен на оплачен
  - `OrderStatusChangedToStockConfirmedDomainEvent` - статус изменен на подтвержден склад
  - `BuyerPaymentMethodVerifiedDomainEvent` - метод оплаты покупателя подтвержден
- **Интерфейсы репозиториев:**
  - `IOrderRepository` - репозиторий заказов
  - `IBuyerRepository` - репозиторий покупателей
- **Базовые классы:**
  - `Entity` - базовый класс для сущностей
  - `ValueObject` - базовый класс для объектов-значений
  - `IAggregateRoot` - маркерный интерфейс для корней агрегатов
  - `IUnitOfWork` - интерфейс единицы работы

**Зависимости:**
- `MediatR` - для доменных событий
- `System.Reflection.TypeExtensions` - для рефлексии

**Особенности:**
- Чистая доменная модель без зависимостей от инфраструктуры
- Инкапсуляция бизнес-логики в агрегатах
- Использование доменных событий для координации между агрегатами

---

### 2. Ordering.Infrastructure (Infrastructure Layer)

**Назначение:** Слой инфраструктуры - реализация персистентности и внешних зависимостей.

**Ответственность:**
- **DbContext:**
  - `OrderingContext` - EF Core контекст для работы с PostgreSQL
  - Управление транзакциями
  - Диспетчеризация доменных событий через MediatR
- **Репозитории:**
  - `OrderRepository` - реализация `IOrderRepository`
  - `BuyerRepository` - реализация `IBuyerRepository`
- **Конфигурации Entity Framework:**
  - `OrderEntityTypeConfiguration` - конфигурация сущности Order
  - `OrderItemEntityTypeConfiguration` - конфигурация сущности OrderItem
  - `BuyerEntityTypeConfiguration` - конфигурация сущности Buyer
  - `PaymentMethodEntityTypeConfiguration` - конфигурация сущности PaymentMethod
  - `CardTypeEntityTypeConfiguration` - конфигурация сущности CardType
  - `ClientRequestEntityTypeConfiguration` - конфигурация для идемпотентности
- **Миграции БД:**
  - Управление схемой БД через EF Core Migrations
  - Миграции хранятся в папке `Migrations/`
- **Идемпотентность:**
  - `RequestManager` - управление идемпотентными запросами
  - `ClientRequest` - сущность для отслеживания обработанных запросов
  - `IRequestManager` - интерфейс менеджера запросов
- **Интеграция:**
  - Интеграция с `IntegrationEventLogEF` для логирования интеграционных событий

**Зависимости:**
- `Ordering.Domain`
- `IntegrationEventLogEF`
- `Npgsql.EntityFrameworkCore.PostgreSQL`

**Особенности:**
- Использование PostgreSQL как основной БД
- Реализация паттерна Unit of Work
- Поддержка транзакций на уровне контекста
- Автоматическая диспетчеризация доменных событий при сохранении

---

### 3. Ordering.API (Application/API Layer)

**Назначение:** REST API для управления заказами.

**Ответственность:**
- **REST эндпоинты:**
  - `POST /api/orders` - создание нового заказа
  - `POST /api/orders/draft` - создание черновика заказа
  - `GET /api/orders/{orderId}` - получение заказа по ID
  - `GET /api/orders` - получение всех заказов текущего пользователя
  - `PUT /api/orders/cancel` - отмена заказа
  - `PUT /api/orders/ship` - отправка заказа
  - `GET /api/orders/cardtypes` - получение типов банковских карт
- **Команды (CQRS):**
  - `CreateOrderCommand` - создание заказа
  - `CreateOrderDraftCommand` - создание черновика заказа
  - `CancelOrderCommand` - отмена заказа
  - `ShipOrderCommand` - отправка заказа
  - Обработчики команд через MediatR
- **Запросы (CQRS):**
  - `OrderQueries` - запросы для чтения данных
  - `IOrderQueries` - интерфейс для запросов
  - `OrderViewModel` - модели представления для чтения
- **Обработчики доменных событий:**
  - `OrderCancelledDomainEventHandler`
  - `OrderShippedDomainEventHandler`
  - `OrderStatusChangedToAwaitingValidationDomainEventHandler`
  - `OrderStatusChangedToPaidDomainEventHandler`
  - `OrderStatusChangedToStockConfirmedDomainEventHandler`
  - `UpdateOrderWhenBuyerAndPaymentMethodVerifiedDomainEventHandler`
  - `ValidateOrAddBuyerAggregateWhenOrderStartedDomainEventHandler`
- **Обработчики интеграционных событий:**
  - `GracePeriodConfirmedIntegrationEventHandler`
  - `OrderStockConfirmedIntegrationEventHandler`
  - `OrderStockRejectedIntegrationEventHandler`
  - `OrderPaymentFailedIntegrationEventHandler`
  - `OrderPaymentSucceededIntegrationEventHandler`
- **Валидация:**
  - Использование FluentValidation для валидации команд
  - `CancelOrderCommandValidator` и другие валидаторы
- **Поведения MediatR:**
  - `LoggingBehavior` - логирование команд и запросов
  - `ValidatorBehavior` - автоматическая валидация команд
  - `TransactionBehavior` - управление транзакциями
- **Интеграция с Event Bus:**
  - Публикация интеграционных событий через RabbitMQ
  - Подписка на интеграционные события от других сервисов
- **Идемпотентность:**
  - Поддержка идемпотентных запросов через заголовок `x-requestid`

**Зависимости:**
- `Ordering.Domain`
- `Ordering.Infrastructure`
- `EventBusRabbitMQ`
- `IntegrationEventLogEF`
- `eShop.ServiceDefaults`
- `Asp.Versioning.Http` - версионирование API
- `FluentValidation` - валидация
- `Aspire.Npgsql.EntityFrameworkCore.PostgreSQL` - интеграция с Aspire

**Особенности:**
- Использование CQRS паттерна
- Версионирование API
- Поддержка идемпотентности запросов
- Интеграция с Identity для аутентификации
- Health checks для мониторинга

---

### 4. OrderProcessor (Background Worker Service)

**Назначение:** Фоновый сервис для обработки заказов с истекшим grace period.

**Ответственность:**
- **GracePeriodManagerService:**
  - Периодическая проверка заказов в статусе `AwaitingValidation`
  - Определение заказов с истекшим grace period
  - Публикация события `GracePeriodConfirmedIntegrationEvent` при истечении периода
- **Фоновая обработка:**
  - Работает как Background Service
  - Настраиваемый интервал проверки через `BackgroundTaskOptions`
  - Прямой доступ к БД через Npgsql для оптимизации

**Зависимости:**
- `EventBusRabbitMQ` - для публикации событий
- `eShop.ServiceDefaults` - базовые сервисы Aspire
- `Aspire.Npgsql` - для работы с PostgreSQL

**Конфигурация:**
- `BackgroundTaskOptions`:
  - `GracePeriodTime` - время grace period в минутах
  - `CheckUpdateTime` - интервал проверки в секундах

**Особенности:**
- Независимый фоновый сервис
- Оптимизирован для работы с большим количеством заказов
- Интеграция с Event Bus для асинхронной обработки

---

### 5. Ordering.UnitTests (Unit Tests)

**Назначение:** Модульные тесты для доменной логики и компонентов.

**Ответственность:**
- Тесты доменных агрегатов:
  - `OrderAggregateTest` - тесты агрегата Order
  - `BuyerAggregateTest` - тесты агрегата Buyer
- Тесты команд и запросов
- Тесты репозиториев
- Тесты валидации

**Зависимости:**
- `Ordering.API`
- `Ordering.Domain`
- `Ordering.Infrastructure`
- `MSTest.Sdk` - фреймворк тестирования
- `NSubstitute` - мокирование зависимостей

**Особенности:**
- Изолированные unit-тесты
- Использование моков для зависимостей
- Тестирование бизнес-логики без инфраструктуры

---

### 6. Ordering.FunctionalTests (Functional/Integration Tests)

**Назначение:** Функциональные и интеграционные тесты API.

**Ответственность:**
- Тесты REST API эндпоинтов
- Интеграционные тесты с БД
- Тесты взаимодействия между компонентами
- Тесты интеграционных событий

**Зависимости:**
- `Ordering.API`
- `Ordering.Domain`
- `Ordering.Infrastructure`
- `Identity.API` - для аутентификации в тестах
- `xunit.v3.mtp-v2` - фреймворк тестирования
- `Microsoft.AspNetCore.Mvc.Testing` - тестирование веб-приложений
- `Aspire.Hosting.PostgreSQL` - тестирование с Aspire

**Особенности:**
- Полноценные интеграционные тесты
- Использование Aspire для поднятия инфраструктуры
- Тестирование реальных сценариев использования

---

## Архитектура взаимодействия

```
┌─────────────────┐
│  Ordering.API   │ ← REST API для клиентов
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼──────────┐
│Domain │ │Infrastructure│
└───────┘ └─────────────┘
         │
    ┌────┴────┐
    │         │
┌───▼────┐ ┌──▼──────────┐
│PostgreSQL│ │ RabbitMQ   │
└─────────┘ └────────────┘

┌─────────────────┐
│OrderProcessor   │ ← Фоновый сервис
└─────────────────┘
```

## Основные потоки данных

### Создание заказа:
1. Клиент отправляет `POST /api/orders`
2. `CreateOrderCommand` обрабатывается через MediatR
3. Создается агрегат `Order` в доменном слое
4. Публикуется доменное событие `OrderStartedDomainEvent`
5. Заказ сохраняется в БД через `OrderRepository`
6. Публикуется интеграционное событие `OrderStartedIntegrationEvent`

### Обработка grace period:
1. `OrderProcessor` периодически проверяет заказы
2. Находит заказы с истекшим grace period
3. Публикует `GracePeriodConfirmedIntegrationEvent`
4. `Ordering.API` обрабатывает событие и обновляет статус заказа

### Отмена заказа:
1. Клиент отправляет `PUT /api/orders/cancel`
2. `CancelOrderCommand` обрабатывается
3. Вызывается метод `SetCancelledStatus()` на агрегате `Order`
4. Публикуется доменное событие `OrderCancelledDomainEvent`
5. Заказ обновляется в БД

## Принципы проектирования

- **Domain-Driven Design (DDD)** - четкое разделение доменной логики
- **Clean Architecture** - разделение на слои с зависимостями внутрь
- **CQRS** - разделение команд и запросов
- **Event-Driven Architecture** - использование событий для координации
- **SOLID** - следование принципам объектно-ориентированного проектирования
