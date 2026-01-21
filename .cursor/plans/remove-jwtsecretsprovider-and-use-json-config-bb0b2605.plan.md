<!-- bb0b2605-bfd8-45ef-b90f-32b4bee33457 5d59ed39-9cd9-4171-b1e7-642595ed6715 -->
# Remove JwtSecretsProvider and Use JSON Configuration Directly

## Overview

Delete the `JwtSecretsProvider` class and `ISecretsProvider` interface, replacing all usages with direct access to `JwtConfiguration.SecretKey` from JSON configuration files.

## Changes Required

### 1. Delete Files

- Delete `Services/JwtSecretsProvider.cs`
- Delete `Services.Contracts/ISecretsProvider.cs`

### 2. Update JwtBearerOptionsSetup.cs

- Remove `ISecretsProvider` dependency from constructor
- Remove `_secretsProvider` field
- Update `Configure` method to use `_jwtConfiguration.SecretKey` directly
- Remove validation that checks for empty secret (since it's now in JSON)
- Remove `using Services.Contracts;` if no longer needed

**File:** `PasswordManager.Startup/Configuration/JwtBearerOptionsSetup.cs`

- Remove line 18: `private readonly ISecretsProvider _secretsProvider;`
- Update constructor to remove `ISecretsProvider secretsProvider` parameter
- Update line 43 to use `_jwtConfiguration.SecretKey` instead of `_secretsProvider.GetJwtSecretKey()`
- Remove or update validation logic (lines 45-48)

### 3. Update AuthenticationService.cs

- Remove `ISecretsProvider` dependency from constructor
- Remove `_secretsProvider` field
- Update `GetSigningCredentials()` method (line 100) to use `_jwtConfiguration.SecretKey` directly
- Update `GetPrincipalFromExpiredToken()` method (line 162) to use `_jwtConfiguration.SecretKey` directly
- Remove `using PasswordManager.SecretsProviders;` (line 18)
- Remove `using Services.Contracts;` if no longer needed

**File:** `Services/AuthenticationService.cs`

- Remove line 33: `private readonly ISecretsProvider _secretsProvider;`
- Update constructor (line 35) to remove `ISecretsProvider secretsProvider` parameter
- Update line 100: Replace `_secretsProvider.GetJwtSecretKey()` with `_jwtConfiguration.SecretKey`
- Update line 162: Replace `_secretsProvider.GetJwtSecretKey()` with `_jwtConfiguration.SecretKey`

### 4. Update ServicesExtensions.cs

- Remove `ConfigureSecretsProvider` method or simplify it to only configure JWT settings
- Remove `services.AddSingleton<ISecretsProvider, JwtSecretsProvider>();` registration
- Remove `using PasswordManager.SecretsProviders;` (line 13)
- Remove `using Services.Contracts;` if no longer needed

**File:** `PasswordManager.Startup/Extensions/ServicesExtentions.cs`

- Update `ConfigureSecretsProvider` method (lines 30-37) to only configure JWT settings, or remove the method entirely if `Startup.cs` can configure JWT directly
- Remove line 36: `services.AddSingleton<ISecretsProvider, JwtSecretsProvider>();`

### 5. Update Startup.cs

- If `ConfigureSecretsProvider` is removed, update the call site
- Ensure JWT configuration is still properly bound from configuration

**File:** `PasswordManager.Startup/Startup.cs`

- Update line 38: Either remove the call to `ConfigureSecretsProvider` or ensure JWT configuration binding is handled elsewhere

### 6. Configuration Files

- No changes needed to appsettings.json files - `secretKey` is already present in all configuration files

## Notes

- All sensitive data (JWT secret key) will be stored directly in JSON configuration files as requested
- The environment variable fallback logic (`JWTPMSECRET`) will be removed
- The DEBUG-specific validation logic will be removed
- Direct access to `JwtConfiguration.SecretKey` will be used throughout the application

### To-dos

- [ ] Delete Services/JwtSecretsProvider.cs file
- [ ] Delete Services.Contracts/ISecretsProvider.cs file
- [ ] Update JwtBearerOptionsSetup.cs to use JwtConfiguration.SecretKey directly instead of ISecretsProvider
- [ ] Update AuthenticationService.cs to use JwtConfiguration.SecretKey directly instead of ISecretsProvider
- [ ] Update ServicesExtensions.cs to remove ISecretsProvider registration and clean up ConfigureSecretsProvider method
- [ ] Update Startup.cs to remove or update ConfigureSecretsProvider call