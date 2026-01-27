# Модуль EventBus

Модуль EventBus предоставляет абстракцию для асинхронной коммуникации между сервисами через события. Реализует паттерн Event-Driven Architecture.

## Проекты модуля

### 1. EventBus (Abstractions)

**Назначение:** Абстракции и интерфейсы для Event Bus.

**Ответственность:**
- **Интерфейсы:**
  - `IEventBus` - основной интерфейс Event Bus
  - `IEventBusBuilder` - построитель для настройки Event Bus
  - `IIntegrationEventHandler<T>` - интерфейс обработчика событий
- **Базовые классы:**
  - `IntegrationEvent` - базовый класс для интеграционных событий
- **Вспомогательные классы:**
  - `EventBusSubscriptionInfo` - информация о подписках
  - Расширения для работы с типами (`GenericTypeExtensions`)
  - Расширения для построителя (`EventBusBuilderExtensions`)

**Зависимости:**
- Только базовые зависимости .NET

**Особенности:**
- Независимость от конкретной реализации
- Возможность замены реализации Event Bus
- Типобезопасная работа с событиями

---

### 2. EventBusRabbitMQ (Implementation)

**Назначение:** Реализация Event Bus на основе RabbitMQ.

**Ответственность:**
- **Реализация Event Bus:**
  - `RabbitMQEventBus` - основная реализация `IEventBus`
  - Публикация событий в RabbitMQ
  - Подписка на события из RabbitMQ
  - Управление подписками
- **Конфигурация:**
  - `EventBusOptions` - настройки подключения к RabbitMQ
  - Настройка через DI
- **Телеметрия:**
  - `RabbitMQTelemetry` - интеграция с OpenTelemetry
  - Трассировка событий
- **Расширения DI:**
  - `RabbitMqDependencyInjectionExtensions` - методы расширения для настройки

**Зависимости:**
- `EventBus` - абстракции
- `RabbitMQ.Client` - клиент RabbitMQ
- OpenTelemetry для телеметрии

**Особенности:**
- Надежная доставка сообщений через RabbitMQ
- Поддержка различных типов обменников (Exchange)
- Автоматическое создание очередей и биндингов
- Интеграция с телеметрией для мониторинга
- Обработка ошибок и повторные попытки

---

## Архитектура

```
┌─────────────────┐
│   Services      │
│  (Ordering,      │
│   Catalog, etc.) │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼──────────┐
│EventBus│ │ RabbitMQ   │
│(Abst.) │ │ (Impl.)    │
└────────┘ └────────────┘
```

## Основные потоки данных

### Публикация события:
1. Сервис вызывает `IEventBus.PublishAsync(event)`
2. `RabbitMQEventBus` сериализует событие в JSON
3. Сообщение публикуется в RabbitMQ Exchange
4. RabbitMQ доставляет сообщение подписчикам

### Подписка на событие:
1. Сервис регистрирует обработчик через `IEventBus.Subscribe<T, THandler>()`
2. `RabbitMQEventBus` создает очередь и биндинг
3. При получении сообщения вызывается обработчик
4. Обработчик обрабатывает событие

## Использование

### Публикация события:
```csharp
await eventBus.PublishAsync(new OrderCreatedIntegrationEvent(orderId));
```

### Подписка на событие:
```csharp
eventBus.Subscribe<OrderCreatedIntegrationEvent, OrderCreatedEventHandler>();
```

### Настройка через DI:
```csharp
builder.AddRabbitMqEventBus("eventbus")
    .AddSubscription<OrderCreatedIntegrationEvent, OrderCreatedEventHandler>();
```

## Особенности реализации

- **Абстракция:** Независимость от конкретной реализации
- **Типобезопасность:** Строгая типизация событий и обработчиков
- **Надежность:** Гарантия доставки через RabbitMQ
- **Масштабируемость:** Поддержка множества подписчиков
- **Телеметрия:** Интеграция с OpenTelemetry для мониторинга
- **Обработка ошибок:** Автоматические повторные попытки

## Типы обменников

EventBusRabbitMQ использует различные типы обменников RabbitMQ:
- **Direct Exchange** - для прямых маршрутизаций
- **Topic Exchange** - для маршрутизации по паттернам
- **Fanout Exchange** - для широковещательной рассылки

## Интеграция с Aspire

EventBus интегрирован с .NET Aspire:
- Автоматическое обнаружение RabbitMQ через Aspire
- Настройка через `AddRabbitMqEventBus()`
- Интеграция с телеметрией Aspire
