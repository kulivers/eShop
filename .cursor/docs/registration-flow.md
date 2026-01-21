# Registration Flow - Поток данных регистрации

## Обзор

Документ описывает полный поток данных для формы регистрации (`RegistrationForm`) в приложении Password Manager. Регистрация реализована как многошаговый процесс с использованием Redux для управления состоянием и Redux Saga для обработки асинхронных операций.

## Компоненты потока

### 1. Entry Point
**Файл**: `src/features/registration/components/RegistrationPage.tsx`

```typescript
RegistrationPage
  └── MultiStepRegistration
      ├── onSuccess callback
      └── onError callback
```

### 2. Main Component
**Файл**: `src/features/registration/components/MultiStepRegistration.tsx`

Главный компонент, который:
- Управляет отображением шагов
- Интегрируется с Redux store
- Обрабатывает навигацию между шагами
- Управляет модальными окнами (Terms, Privacy)

### 3. Registration Steps
**Директория**: `src/features/registration/components/steps/`

- **Step1BasicInfo.tsx** - Шаг 1: Основная информация (fullName)
- **Step3Security.tsx** - Шаг 2: Безопасность (email, country, password, confirmPassword, acceptTerms, acceptMarketing)
- **Step4Verification.tsx** - Шаг 3: Верификация email (verificationCode)
- **Step5Complete.tsx** - Шаг 4: Завершение регистрации

## Поток данных

### Шаг 1: Инициализация

```
User navigates to /register
  ↓
RegistrationPage renders
  ↓
MultiStepRegistration mounts
  ↓
Redux store initialized with initialState
  ↓
currentStep = 1
formData = { fullName: '', email: '', ... }
```

**Redux State**:
```typescript
{
  registration: {
    currentStep: 1,
    totalSteps: 5,
    isLoading: false,
    error: null,
    isCompleted: false,
    formData: {
      fullName: '',
      email: '',
      country: '',
      password: '',
      confirmPassword: '',
      acceptTerms: false,
      acceptMarketing: false,
      verificationCode: '',
      isVerified: false,
      profilePicture: null,
      bio: '',
      preferences: { ... },
      onboardingCompleted: false
    }
  }
}
```

### Шаг 2: Заполнение формы (Step 1)

```
User fills Step1BasicInfo form
  ↓
User clicks "Next"
  ↓
handleNext(data) called
  ↓
dispatch(submitStep({ step: 1, data: { fullName: "..." } }))
  ↓
registrationSlice: submitStep reducer (isLoading = true, error = null)
  ↓
registrationSaga: handleSubmitStep (features/registration/sagas/registrationSaga.ts)
  - call(registrationService.submitStep, step, data)
  - dispatch(submitStepSuccess(data))
  ↓
registrationSlice: submitStepSuccess reducer
  - isLoading = false
  - formData = { ...formData, ...data }
  - currentStep = 2 (if not last step)
```

**Action Flow**:
```
Component → Action Creator → Redux Store → Saga → API → Redux Store → Component
```

### Шаг 3: Переход между шагами

```
Step 1 → Step 2:
  submitStep({ step: 1, data }) → submitStepSuccess → currentStep = 2

Step 2 → Step 3:
  submitStep({ step: 2, data }) → submitStepSuccess → currentStep = 3

Step 3 → Step 4:
  submitStep({ step: 3, data }) → submitStepSuccess → currentStep = 4

Back navigation:
  handlePrevious() → dispatch(previousStep()) → currentStep -= 1
```

### Шаг 4: Завершение регистрации

```
User completes Step 4 (Step5Complete)
  ↓
User clicks "Complete"
  ↓
handleComplete() called
  ↓
dispatch(completeRegistration())
  ↓
registrationSlice: completeRegistration reducer
  - isLoading = true
  - error = null
  ↓
registrationSaga: handleCompleteRegistration
  - call(registrationService.completeRegistration, formData)
  - dispatch(completeRegistrationSuccess())
  ↓
registrationSlice: completeRegistrationSuccess reducer
  - isLoading = false
  - isCompleted = true
  - formData.onboardingCompleted = true
  ↓
useEffect in MultiStepRegistration detects isCompleted
  ↓
onSuccess?.(formData) callback
  ↓
RegistrationPage: handleSuccess
  - Navigate to /login after 2 seconds
```

## Детальный поток данных

### 1. User Input → Redux Store

```
┌─────────────────┐
│  Step Component │
│  (User Input)   │
└────────┬────────┘
         │
         │ onNext(data)
         ↓
┌─────────────────┐
│ MultiStepReg    │
│ handleNext()    │
└────────┬────────┘
         │
         │ dispatch(submitStep({ step, data }))
         ↓
┌─────────────────┐
│  Redux Store    │
│ registrationSlice│
└────────┬────────┘
         │
         │ Action dispatched
         ↓
┌─────────────────┐
│  Root Saga      │
│  Watches action │
└────────┬────────┘
```

### 2. Saga Processing

```
┌─────────────────┐
│ registrationSaga│
│ handleSubmitStep│
└────────┬────────┘
         │
         │ call(registrationService.submitStep, step, data)
         │
         │ yield put(submitStepSuccess(data))
         ↓
┌─────────────────┐
│  Redux Store    │
│  State Updated  │
└────────┬────────┘
         │
         │ Component re-renders
         ↓
┌─────────────────┐
│ MultiStepReg    │
│ New step shown  │
└─────────────────┘
```

### 3. Error Handling

```
API Error occurs
  ↓
registrationSaga: catch block
  ↓
yield put(submitStepFailure(error.message))
  ↓
registrationSlice: submitStepFailure reducer
  - isLoading = false
  - error = error.message
  ↓
useEffect in MultiStepRegistration detects error
  ↓
onError?.(error) callback
  ↓
Error displayed to user
```

## Redux Actions

### Navigation Actions
```typescript
// Переход к следующему шагу
nextStep()

// Возврат к предыдущему шагу
previousStep()

// Установка конкретного шага
setCurrentStep(step: number)
```

### Form Data Actions
```typescript
// Обновление данных формы
updateFormData(data: Partial<RegistrationFormData>)

// Отправка шага
submitStep({ step: number, data: Partial<RegistrationFormData> })

// Успешная отправка шага
submitStepSuccess(data: Partial<RegistrationFormData>)

// Ошибка отправки шага
submitStepFailure(error: string)
```

### Registration Actions
```typescript
// Завершение регистрации
completeRegistration()

// Успешное завершение
completeRegistrationSuccess()

// Ошибка завершения
completeRegistrationFailure(error: string)
```

### Verification Actions
```typescript
// Верификация email
verifyEmail()

// Успешная верификация
verifyEmailSuccess()

// Ошибка верификации
verifyEmailFailure(error: string)
```

## Redux Saga Flow

### Root Saga
**Файл**: `src/redux/sagas/index.ts`

```typescript
rootSaga
  ├── fork(registerUserFlowSaga)  // Старая saga (legacy)
  └── fork(registrationSagaFlow)  // Новая saga
```

### Registration Saga Flow
**Файл**: `src/redux/sagas/registrationSaga.ts`

```typescript
registrationSagaFlow
  ├── takeEvery(submitStep.type, handleSubmitStep)
  ├── takeEvery(verifyEmail.type, handleVerifyEmail)
  └── takeEvery(completeRegistration.type, handleCompleteRegistration)
```

### Legacy Registration Saga
**Файл**: `src/features/registration/sagas/registrationSaga.ts`

- `handleSubmitStep` → `registrationService.submitStep`
- `handleVerifyEmail` → `registrationService.verifyEmail`
- `handleCompleteRegistration` → `registrationService.completeRegistration`
- `handleRegisterUser` → `registrationService.registerUser`

## API Integration

### Текущая реализация
```typescript
// features/registration/sagas/registrationSaga.ts
function* handleSubmitStep(action) {
  const { step, data } = action.payload;
  yield call(registrationService.submitStep, step, data);
  yield put(submitStepSuccess(data));
}
```

### API Endpoints (Expected)
```
POST /api/registration
  Body: RegistrationFormData
  Response: { success: boolean, data?: any, error?: string }

POST /api/registration/step/{stepNumber}
  Body: Partial<RegistrationFormData>
  Response: { success: boolean, data?: any }

POST /api/registration/verify-email
  Body: { code: string }
  Response: { success: boolean, verified: boolean }

POST /api/registration/complete
  Body: RegistrationFormData
  Response: { success: boolean, user?: User }
```

## Типы данных

### RegistrationFormData
```typescript
interface RegistrationFormData {
  // Step 1
  fullName: string;
  
  // Step 2
  email: string;
  country: string;
  
  // Step 3
  password: string;
  confirmPassword: string;
  acceptTerms: boolean;
  acceptMarketing: boolean;
  
  // Step 4
  verificationCode: string;
  isVerified: boolean;
  
  // Step 5 (optional)
  profilePicture: string | null;
  bio: string;
  preferences: UserPreferences;
  
  // Completion
  onboardingCompleted: boolean;
}
```

### RegistrationState
```typescript
interface RegistrationState {
  currentStep: number;
  totalSteps: number;
  isLoading: boolean;
  error: string | null;
  formData: RegistrationFormData;
  isCompleted: boolean;
}
```

## Визуализация потока

```
┌─────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW                         │
└─────────────────────────────────────────────────────────────┘

1. INITIALIZATION
   User → RegistrationPage → MultiStepRegistration
   Redux: initialState loaded

2. STEP 1: Basic Info
   User Input → Step1BasicInfo → handleNext(data)
   → dispatch(submitStep({ step: 1, data }))
   → Saga: handleSubmitStep → registrationService.submitStep → submitStepSuccess
   → Redux: formData updated, currentStep = 2

3. STEP 2: Security
   User Input → Step3Security → handleNext(data)
   → dispatch(submitStep({ step: 2, data }))
   → Saga: handleSubmitStep → registrationService.submitStep → submitStepSuccess
   → Redux: formData updated, currentStep = 3

4. STEP 3: Verification
   User Input → Step4Verification → handleNext(data)
   → dispatch(verifyEmail()) → Saga: handleVerifyEmail
   → verifyEmailSuccess → Redux: isVerified = true
   → dispatch(submitStep({ step: 3, data }))
   → Redux: currentStep = 4

5. STEP 4: Complete
   User clicks Complete → handleComplete()
   → dispatch(completeRegistration())
   → Saga: handleCompleteRegistration → registrationService.completeRegistration
   → completeRegistrationSuccess
   → Redux: isCompleted = true
   → useEffect: onSuccess callback
   → Navigation to /login
```

## Обработка ошибок

### Error Flow
```
Error occurs (API/Validation)
  ↓
Saga catch block
  ↓
dispatch(actionFailure(error))
  ↓
Redux: error state updated
  ↓
Component: useEffect detects error
  ↓
onError callback
  ↓
Error displayed to user
```

### Error Types
1. **Validation Errors**: Отображаются в форме
2. **API Errors**: Отображаются через Notistack
3. **Network Errors**: Обрабатываются в Saga

## Callbacks

### onSuccess
```typescript
onSuccess?: (data: RegistrationFormData) => void
```
Вызывается когда `isCompleted === true`

### onError
```typescript
onError?: (error: string) => void
```
Вызывается когда `error !== null`

## Навигация после регистрации

```
Registration completed
  ↓
isCompleted = true
  ↓
useEffect triggers
  ↓
onSuccess(formData)
  ↓
RegistrationPage.handleSuccess
  ↓
setTimeout(() => navigate('/login'), 2000)
```

## Заметки по реализации

1. **Saga**: Единая saga (`features/registration/sagas/registrationSaga.ts`) вызывает реальные API через `registrationService`.

2. **Валидация**: Валидация происходит на уровне компонентов (Formik + Yup) и локального состояния шагов.

3. **Состояние формы**: Все данные формы хранятся в Redux, что позволяет:
   - Сохранять прогресс при переходах между шагами
   - Восстанавливать данные при ошибках
   - Легко тестировать состояние

