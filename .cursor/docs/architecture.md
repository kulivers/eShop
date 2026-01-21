# Архитектура приложения Password Manager Frontend

## Обзор

Password Manager Frontend - это React-приложение, построенное на современном стеке технологий с использованием TypeScript, Redux Toolkit, Redux Saga и Material-UI.

## Технологический стек

### Основные технологии
- **React 18.2.0** - UI библиотека
- **TypeScript 5.1.6** - типизация
- **Redux Toolkit 1.9.5** - управление состоянием
- **Redux Saga 1.2.3** - асинхронные сайд-эффекты
- **Material-UI 5.14.0** - UI компоненты
- **React Router 6.14.1** - маршрутизация
- **Axios 1.4.0** - HTTP клиент
- **Formik 2.4.2 + Yup 1.2.0** - работа с формами и валидация
- **Notistack 3.0.1** - уведомления

## Структура проекта

```
src/
├── api/                         # API слой
│   ├── client.ts                # Axios instance
│   ├── config.ts                # Конфигурация (env)
│   ├── interceptors.ts          # Interceptors (auth/errors)
│   └── index.ts                 # Роутинг экспорта
├── config/env.ts                # Обёртка над переменными окружения
├── features/
│   ├── auth/                    # Auth feature
│   │   ├── api/authService.ts   # Auth API
│   │   ├── authSlice.ts         # Redux slice
│   │   ├── sagas/authSaga.ts    # Auth sagas
│   │   ├── hooks/               # useAuth, useLogin
│   │   └── components/LoginPage.tsx
│   ├── registration/            # Registration feature
│   │   ├── api/registrationService.ts
│   │   ├── registrationSlice.ts
│   │   ├── sagas/registrationSaga.ts
│   │   ├── hooks/useRegistration.ts
│   │   └── components/MultiStepRegistration.tsx
│   ├── accounts/                # Accounts feature
│   │   ├── api/accountsService.ts
│   │   ├── accountsSlice.ts
│   │   ├── sagas/accountsSaga.ts
│   │   └── hooks/useAccounts.ts
│   └── passwords/               # Passwords feature (без изменений)
│       ├── components/
│       ├── passwordsSlice.ts
│       └── passwordsSelectors.ts
├── routing/                     # Маршрутизация (routes + ProtectedRoute)
├── shared/components/           # Общие компоненты (NavBar, ErrorBoundary, LoadingSpinner)
├── redux/                       # Redux инфраструктура (store, hooks, root saga)
├── theme/                       # Тема MUI
├── types/                       # Общие типы домена
├── utils/                       # Утилиты
├── App.tsx                      # Корневой компонент (SnackbarProvider + Router)
└── index.tsx                    # Точка входа
```

## Архитектурные паттерны

### 1. Feature-Based Structure
Приложение использует feature-based подход для организации кода. Каждая фича (например, `passwords`) содержит все необходимые компоненты, логику, типы и селекторы в одной директории.

### 2. Redux Architecture

#### Store Structure
```typescript
{
  auth: AuthState,              // Состояние авторизации
  registration: RegistrationState,  // Состояние регистрации
  accounts: AccountsState,      // Состояние аккаунтов
  passwords: PasswordsState     // Состояние паролей
}
```

#### Redux Toolkit Slices
- Используется `createSlice` для создания reducers и actions
- Immer встроен для иммутабельных обновлений
- Типизированные actions и state

#### Redux Saga
- Обработка асинхронных операций
- Централизованная обработка ошибок
- Побочные эффекты (API вызовы, навигация)

### 3. Component Architecture

#### Container/Presentational Pattern
- **Container компоненты**: Управляют состоянием и логикой (например, `MultiStepRegistration`, `PasswordManager`)
- **Presentational компоненты**: Отображают UI и получают данные через props (например, `PasswordCard`, `Step1BasicInfo`)

#### Композиция компонентов
- Многоуровневая композиция компонентов
- Переиспользуемые UI компоненты
- Стилизация через Material-UI и styled-components

### 4. API Layer

#### Axios Configuration
```typescript
// src/api/index.ts
- Базовый URL: https://localhost:5001/api
- Request interceptor: Добавляет Authorization token
- withCredentials: true для работы с cookies
```

#### Error Handling
- Централизованная обработка ошибок в Saga
- Типизированные ошибки API
- Отображение ошибок через Notistack

### 5. Routing

#### React Router
- `/register` - Страница регистрации
- `/login` - Страница входа
- `/` - Главная страница (Password Manager)

#### Navigation Flow
```
Registration → Login → Dashboard (Password Manager)
```

## Потоки данных

### 1. Registration Flow
См. [registration-flow.md](./registration-flow.md) для детального описания.

### 2. Authentication Flow
1. Пользователь вводит credentials в `LoginForm`
2. Action `login` диспатчится в Redux
3. Saga обрабатывает запрос через API
4. Token сохраняется в localStorage
5. Состояние auth обновляется
6. Редирект на главную страницу

### 3. Password Management Flow
1. Пользователь взаимодействует с `PasswordManager`
2. Actions диспатчатся в `passwordsSlice`
3. Selectors вычисляют производные данные
4. Компоненты перерисовываются с новыми данными
5. API вызовы через Saga (если необходимо)

## State Management

### Redux Toolkit Slices

#### registrationSlice
- Управляет состоянием многошаговой регистрации
- Отслеживает текущий шаг, данные формы, загрузку, ошибки
- Actions: `submitStep`, `nextStep`, `previousStep`, `completeRegistration`

#### authSlice
- Управляет состоянием авторизации
- Хранит информацию о текущем пользователе
- Actions: `login`, `logout`, `setUser`

#### passwordsSlice
- Управляет состоянием паролей
- CRUD операции для паролей
- Фильтрация и поиск
- Actions: `addPassword`, `updatePassword`, `deletePassword`, `setSearchQuery`

### Selectors
- Мемоизированные селекторы для производных данных
- Используется `reselect` (встроен в Redux Toolkit)
- Примеры: `selectFilteredPasswords`, `selectCategoryCounts`

## Стилизация

### Material-UI Theme
- Централизованная тема в `src/theme/index.ts`
- Кастомизация цветов, типографики, компонентов

### Styled Components
- Используется для кастомных компонентов
- Пример: `MultiStepRegistration` использует styled-components

### CSS Modules
- Для некоторых компонентов (например, `AccountsTable/styles.css`)

## Типизация

### TypeScript
- Строгая типизация всех компонентов, функций, состояний
- Интерфейсы для API responses
- Типы для форм и валидации

### Основные типы
- `RegistrationFormData` - данные формы регистрации
- `RegistrationState` - состояние регистрации
- `Account` - модель аккаунта
- `PasswordFormData` - данные формы пароля

## Тестирование

### Настройка
- React Testing Library
- Jest (через react-scripts)
- Playwright MCP для E2E тестирования

## Безопасность

### Authentication
- JWT токены в localStorage
- Автоматическое добавление токена в заголовки запросов
- Interceptors для обновления токенов

### Data Protection
- Пароли не хранятся в открытом виде
- HTTPS для всех API запросов
- Валидация данных на клиенте и сервере

## Производительность

### Оптимизации
- React.memo для предотвращения лишних ререндеров
- Мемоизированные селекторы
- Code splitting (готовность к использованию)
- Lazy loading компонентов (при необходимости)

### Bundle Management
- Tree shaking
- Минификация в production
- Source maps для debugging

## Развертывание

### Build Process
```bash
npm run build  # Создает оптимизированную production сборку
```

### Environment
- Development: `http://localhost:3000`
- API: `https://localhost:5001/api`

## Будущие улучшения

1. **Code Splitting**: Lazy loading для страниц
2. **PWA**: Service workers для офлайн работы
3. **Testing**: Увеличение покрытия тестами
4. **Performance**: Оптимизация bundle size
5. **Accessibility**: Улучшение a11y

## Принципы разработки

- **SOLID**: Принципы объектно-ориентированного дизайна
- **DRY**: Избежание дублирования кода
- **KISS**: Простота и понятность решений
- **Separation of Concerns**: Разделение ответственности
- **Single Responsibility**: Один компонент - одна задача

