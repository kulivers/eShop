<!-- acd3a05c-4003-44ba-a9f1-429d4a486dab e8ff4125-162b-455f-b92a-975ba30f1157 -->
# Refactor SMTP Email Projects

## Overview

Refactor `Smtp.Api` and `Smtp.Core` projects to be clean, reusable libraries. These projects were imported from another application and need significant improvements to meet modern C# standards and be production-ready.

## Current Issues Identified

### 1. Namespace Problems

- Old namespaces from previous app (`Comindware.Adapter.SMTPSenderAdapter`, `Comindware.Platform.Logging`)
- Extension class in wrong namespace (`System.ComponentModel.DataAnnotations`)
- Inconsistent namespace usage

### 2. Dependency Issues

- `Smtp.Core` depends on application-specific projects (`PasswordManager.Startup.Api`, `Resources`)
- Should be self-contained and reusable
- Configuration classes in wrong location

### 3. Code Quality Issues

- Blocking async calls (`.GetAwaiter().GetResult()`) - violates async best practices
- Inconsistent return types (`bool` vs `Result<bool>`)
- Poor error handling in retry logic
- Null reference issues (no null checks for collections)
- Duplicate `Concat` methods in multiple classes
- `SmtpMessageFactory.ForgotPasswordMessage` not implemented
- `ValidationUtils` throws exception without message

### 4. Architecture Issues

- Configuration classes (`SmtpConnectionConfig`) should be in `Smtp.Api`
- Missing proper abstraction for logging
- No proper separation of concerns

## Refactoring Plan

### Phase 1: Fix Namespaces and Project Structure

**Files to modify:**

- `Integrations/Email/Smtp.Api/Email/ValidationUtils.cs` - Fix namespace from `Comindware.Adapter.SMTPSenderAdapter` to `Smtp.Api.Validation`
- `Integrations/Email/Smtp.Api/Email/EmailAddressAttributeOverload.cs` - Move to proper namespace `Smtp.Api.Validation`
- `Integrations/Email/Smtp.Core/SmtpEmailService.cs` - Update all namespace references
- `Integrations/Email/Smtp.Core/AdapterSmtpClient.cs` - Update namespace references

**Actions:**

1. Create proper namespace structure: `Smtp.Api` for contracts, `Smtp.Core` for implementation
2. Move `SmtpConnectionConfig` and related enums from `PasswordManager.Startup.Api` to `Smtp.Api.Config`
3. Remove dependencies on application-specific projects

### Phase 2: Fix Dependencies

**Files to modify:**

- `Integrations/Email/Smtp.Core/Smtp.Core.csproj` - Remove dependencies on `PasswordManager.Startup.Api` and `Resources`
- `Integrations/Email/Smtp.Api/Smtp.Api.csproj` - Add `Microsoft.Extensions.Options` if needed

**Actions:**

1. Move `SmtpConnectionConfig`, `Encryption`, `AuthenticationType` to `Smtp.Api.Config`
2. Create abstraction for logging (`ILogger` interface or use `Microsoft.Extensions.Logging.Abstractions`)
3. Remove dependency on `Resources` project - use string constants or configuration
4. Update all references to use new locations

### Phase 3: Improve Code Quality

**Files to modify:**

- `Integrations/Email/Smtp.Core/SmtpEmailService.cs`:
- Convert `SendEmail` to async and return `Task<bool>` or `Task<Result<bool>>`
- Fix blocking async calls (use `await` instead of `.GetAwaiter().GetResult()`)
- Improve retry logic with proper exception handling
- Add null checks for collections in `TranslateIncomingMessage`
- Make method async/await consistent

- `Integrations/Email/Smtp.Core/AdapterSmtpClient.cs`:
- Add proper connection state management
- Improve error handling
- Consider making methods async where appropriate

- `Integrations/Email/Smtp.Api/Email/ValidationUtils.cs`:
- Fix exception message in `ThrowIfInvalidEmail`
- Use proper email validation

- `Integrations/Email/Smtp.Api/Config/MailMessage.cs`:
- Extract duplicate `Concat` methods to extension methods or helper class
- Improve null safety with proper initialization
- Consider using `IReadOnlyList` for collections

- `Integrations/Email/Smtp.Core/SmtpMessageFactory.cs`:
- Implement `ForgotPasswordMessage` method (or remove if not needed in core)

### Phase 4: Improve Architecture

**Files to create/modify:**

1. Create `Smtp.Api.Config/SmtpConnectionConfig.cs` - Move configuration classes here
2. Create `Smtp.Api/Abstractions/ILogger.cs` or use `Microsoft.Extensions.Logging.Abstractions`
3. Create extension methods for collection concatenation in `Smtp.Api/Extensions/CollectionExtensions.cs`
4. Improve error handling with custom exceptions if needed

**Actions:**

1. Follow SOLID principles:

- Single Responsibility: Separate concerns (client, service, factory, validation)
- Dependency Inversion: Use interfaces, inject dependencies
- Open/Closed: Make classes extensible

2. Use proper async/await patterns throughout
3. Add comprehensive null checks and validation
4. Improve error messages and exception handling

### Phase 5: Update Integration Points

**Files to modify:**

- `PasswordManager.Startup/Extensions/ServicesExtentions.cs` - Update to use new namespaces and configuration location
- Update any other files that reference the old namespaces

## Implementation Details

### Key Changes:

1. **Namespace Structure:**

- `Smtp.Api` - Contracts, interfaces, DTOs, configuration
- `Smtp.Core` - Implementation, SMTP client wrapper, service

2. **Async Pattern:**

- All email sending operations should be async
- Use `Task<bool>` or `Task<Result<bool>>` consistently
- Remove all `.GetAwaiter().GetResult()` calls

3. **Error Handling:**

- Proper exception messages
- Retry logic with exponential backoff (optional improvement)
- Proper logging of errors

4. **Dependency Injection:**

- Use `IOptions<SmtpConnectionConfig>` for configuration
- Inject logger abstraction
- Make all dependencies explicit

5. **Validation:**

- Centralize email validation
- Use consistent validation approach
- Provide clear error messages

## Files to Modify

1. `Integrations/Email/Smtp.Api/Email/ValidationUtils.cs`
2. `Integrations/Email/Smtp.Api/Email/EmailAddressAttributeOverload.cs`
3. `Integrations/Email/Smtp.Api/Config/MailMessage.cs`
4. `Integrations/Email/Smtp.Api/IEmailService.cs`
5. `Integrations/Email/Smtp.Api/IEmailMessageFactory.cs`
6. `Integrations/Email/Smtp.Core/SmtpEmailService.cs`
7. `Integrations/Email/Smtp.Core/SmtpMessageFactory.cs`
8. `Integrations/Email/Smtp.Core/AdapterSmtpClient.cs`
9. `Integrations/Email/Smtp.Api/Smtp.Api.csproj`
10. `Integrations/Email/Smtp.Core/Smtp.Core.csproj`
11. `PasswordManager.Startup.Api/Config/SmtpConnectionConfig.cs` (move to Smtp.Api)
12. `PasswordManager.Startup/Extensions/ServicesExtentions.cs` (update references)

## Expected Outcomes

- Clean, reusable SMTP email libraries
- Proper async/await patterns
- Consistent error handling
- No application-specific dependencies
- Proper namespace organization
- SOLID principles followed
- Improved maintainability and testability

### To-dos

- [ ] Fix all namespace issues - remove old Comindware namespaces, fix extension class namespace, ensure consistent naming
- [ ] Move SmtpConnectionConfig and related enums from PasswordManager.Startup.Api to Smtp.Api.Config
- [ ] Remove application-specific dependencies from Smtp.Core (PasswordManager.Startup.Api, Resources), add proper abstractions
- [ ] Convert all blocking async calls to proper async/await patterns, make SendEmail and related methods async
- [ ] Improve error handling - fix exception messages, improve retry logic, add proper null checks
- [ ] Extract duplicate Concat methods, improve MailMessage class, implement missing methods, fix validation
- [ ] Update ServicesExtensions and other integration points to use new namespaces and structure