---
name: Apply PasswordManager-Client changes to frontend
overview: Apply changes from commit c0e56b403c974e537961b70e3a15886faa8161d4 in PasswordManager-Client to the frontend directory, including API routing updates, Redux store changes, accounts/registration API integration, and Material-UI Grid v2 migration.
todos:
  - id: update-api-config
    content: Update API configuration to use relative paths (/api) instead of absolute URLs
    status: pending
  - id: create-accounts-api
    content: Create frontend/src/api/accountsApi.ts with DTO mapping and service functions
    status: pending
  - id: create-registration-api
    content: Create frontend/src/api/registrationApi.ts with RTK Query endpoints
    status: pending
  - id: update-redux-store
    content: Add registrationApi reducer and middleware to Redux store
    status: pending
    dependencies:
      - create-registration-api
  - id: update-accounts-slice
    content: Refactor accountsSlice to use request/success/failure pattern with loading/error states
    status: pending
  - id: update-accounts-service
    content: Update accountsService to use new DTO mapping from accountsApi
    status: pending
    dependencies:
      - create-accounts-api
  - id: update-accounts-saga
    content: Update accountsSaga to use new accountsApi and add refetch logic after mutations
    status: pending
    dependencies:
      - update-accounts-slice
      - update-accounts-service
  - id: update-passwords-slice
    content: Add setAccounts action to passwordsSlice for syncing accounts from API
    status: pending
  - id: update-password-manager
    content: Update PasswordManager component to integrate with accountsSlice and use saga actions
    status: pending
    dependencies:
      - update-accounts-slice
      - update-passwords-slice
  - id: update-registration-slice
    content: Update registrationSlice verifyEmail and completeRegistration to accept proper payload types
    status: pending
  - id: update-registration-saga
    content: Replace delay calls with actual API calls in registrationSaga
    status: pending
    dependencies:
      - update-registration-slice
  - id: migrate-grid-components
    content: Update all Grid components to use size prop instead of item prop (Material-UI v2)
    status: pending
  - id: update-login-form
    content: Update LoginForm Grid components and verify API URL uses relative path
    status: pending
---

# Apply PasswordManager-Client Changes to Frontend

This plan applies changes from commit `c0e56b403c974e537961b70e3a15886faa8161d4` to migrate PasswordManager-Client updates to the frontend directory.

## Key Changes Summary

1. **API Routing**: Change from absolute URLs (`https://localhost:5001/api`) to relative paths (`/api`) for Aspire routing
2. **Accounts API**: Create new `accountsApi.ts` with backend DTO mapping and service functions
3. **Registration API**: Create RTK Query-based `registrationApi.ts` 
4. **Redux Store**: Add registrationApi reducer and middleware
5. **Accounts Slice**: Refactor to use request/success/failure pattern with loading/error states
6. **Accounts Saga**: Update to use new accountsApi service and refetch after mutations
7. **Passwords Slice**: Add `setAccounts` action for syncing accounts from API
8. **PasswordManager**: Integrate with accountsSlice, fetch on mount, use saga actions for CRUD
9. **Material-UI Grid**: Migrate from `item` prop to `size` prop (Grid v2)
10. **Registration Saga**: Replace delays with actual API calls

## Implementation Tasks

### 1. API Configuration Updates

- **File**: `frontend/src/api/config.ts`
- Update `baseURL` to use `/api` instead of full URL (or ensure env.ts uses relative path)
- **File**: `frontend/src/config/env.ts`
- Change default `apiBaseUrl` from `'https://localhost:5001/api'` to `'/api'`

### 2. Create New API Files

- **File**: `frontend/src/api/accountsApi.ts` (NEW)
- Create accounts API service with DTO mapping functions
- Map between backend DTOs (AccountWithoutIdDto, AccountForCreatingDto) and frontend Account types
- Implement fetchAccounts, addAccount, updateAccount, deleteAccount functions

- **File**: `frontend/src/api/registrationApi.ts` (NEW)
- Create RTK Query API for registration endpoints
- Implement submitStep, verifyEmail, completeRegistration, registerUser mutations
- Configure base query with credentials and auth headers

### 3. Update Redux Store

- **File**: `frontend/src/redux/store.ts`
- Import `registrationApi` from `../api/registrationApi`
- Add `[registrationApi.reducerPath]: registrationApi.reducer` to reducers
- Add `registrationApi.middleware` to middleware chain

### 4. Update Accounts Feature

- **File**: `frontend/src/features/accounts/accountsSlice.ts`
- Refactor state structure to include `accounts`, `loading`, `error` (currently uses `items`)
- Add request/success/failure actions for fetch, add, update, delete operations
- Add `addAccountRequest`, `updateAccountRequest`, `deleteAccountRequest` actions
- Keep backward compatibility with `setAccounts` and `clearAccounts`

- **File**: `frontend/src/features/accounts/api/accountsService.ts`
- Replace with implementation from `accountsApi.ts` or update to use the new DTO mapping
- Update to match the backend API contract (Login, ResourceName, ResourceUrl, Password fields)

- **File**: `frontend/src/features/accounts/sagas/accountsSaga.ts`
- Update to use `accountsService` from `accountsApi.ts`
- Add refetch logic after add/update/delete operations
- Update action types to match new slice structure (addAccountRequest, updateAccountRequest, deleteAccountRequest)

### 5. Update Passwords Feature

- **File**: `frontend/src/features/passwords/passwordsSlice.ts`
- Add `setAccounts` action to sync accounts from accountsSlice
- Update comments to note CRUD operations are handled by RTK Query/API

- **File**: `frontend/src/features/passwords/components/PasswordManager.tsx`
- Import `RootState` from redux store
- Add `useEffect` to fetch accounts on mount using `fetchAccounts` from accountsSlice
- Add `useEffect` to sync accounts from accountsSlice to passwordsSlice
- Replace direct slice actions with saga actions: `addAccountRequest`, `updateAccountRequest`, `deleteAccountRequest`
- Add error handling UI for accounts loading failures
- Remove local account creation logic (let saga handle it)

- **File**: `frontend/src/features/passwords/components/PasswordList.tsx`
- Update Grid component: change `item xs={12} sm={6} md={4}` to `size={{ xs: 12, sm: 6, md: 4 }}`

### 6. Update Registration Feature

- **File**: `frontend/src/features/registration/registrationSlice.ts`
- Update `verifyEmail` reducer to accept `PayloadAction<{ code: string }>`
- Update `completeRegistration` reducer to accept `PayloadAction<RegistrationFormData>`

- **File**: `frontend/src/features/registration/sagas/registrationSaga.ts`
- Replace `delay` calls with actual API calls using `api.post`
- Update `handleSubmitStep` to call `/registration/step/${step}` endpoint
- Update `handleVerifyEmail` to call `/registration/verify-email` with code
- Update `handleCompleteRegistration` to call `/registration/complete` endpoint
- Add proper error handling with `error.response?.data?.message`

### 7. Update Auth Components

- **File**: `frontend/src/features/auth/components/LoginForm/LoginForm.tsx`
- Update Grid components: change `item xs={12}` to `size={{ xs: 12 }}`
- Note: LoginForm uses `useLogin` hook, so URL change may be in hook implementation

- **File**: `frontend/src/features/auth/hooks/useLogin.ts` (if exists)
- Update API URL from `'https://localhost:5001/api/token'` to `'/api/token'`

### 8. Update Root Saga

- **File**: `frontend/src/redux/sagas/index.ts`
- Verify accountsSaga is already included (should be present)

### 9. Webpack Configuration

- **File**: `frontend/webpack.config.js`
- Add commented `devtool: 'eval-source-map'` line (already present, verify)

## File Mapping Reference

| PasswordManager-Client | frontend |
|------------------------|----------|
| `src/api/accountsApi.ts` | `src/api/accountsApi.ts` (NEW) |
| `src/api/registrationApi.ts` | `src/api/registrationApi.ts` (NEW) |
| `src/api/index.ts` | `src/api/config.ts` + `src/api/client.ts` |
| `src/redux/store.ts` | `src/redux/store.ts` |
| `src/redux/slices/accountsSlice.ts` | `src/features/accounts/accountsSlice.ts` |
| `src/redux/sagas/accountsSaga.ts` | `src/features/accounts/sagas/accountsSaga.ts` |
| `src/redux/slices/registrationSlice.ts` | `src/features/registration/registrationSlice.ts` |
| `src/redux/sagas/registrationSaga.ts` | `src/features/registration/sagas/registrationSaga.ts` |
| `src/features/passwords/passwordsSlice.ts` | `src/features/passwords/passwordsSlice.ts` |
| `src/features/passwords/components/PasswordManager.tsx` | `src/features/passwords/components/PasswordManager.tsx` |
| `src/features/passwords/components/PasswordList.tsx` | `src/features/passwords/components/PasswordList.tsx` |
| `src/Components/Modals/LoginForm/LoginForm.tsx` | `src/features/auth/components/LoginForm/LoginForm.tsx` |
| `webpack.config.js` | `webpack.config.js` |

## Notes

- The frontend uses a feature-based structure (`features/accounts`, `features/auth`, etc.) while PasswordManager-Client uses a flatter structure
- Frontend already has `accountsService.ts` in `features/accounts/api/` - this may need to be replaced or updated
- Frontend uses `items` in accountsSlice while PasswordManager-Client uses `accounts` - need to align
- Registration API uses RTK Query in PasswordManager-Client but frontend may use sagas - need to integrate both
- Material-UI Grid v2 migration (`item` → `size`) is required for all Grid components