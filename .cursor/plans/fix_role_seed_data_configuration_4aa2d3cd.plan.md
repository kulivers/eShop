---
name: Fix Role Seed Data Configuration
overview: Fix the RoleConfiguration seed data to use fixed GUIDs and ConcurrencyStamps matching the migration, ensuring consistency and preventing runtime errors.
todos:
  - id: update-role-configuration
    content: Update RoleConfiguration.cs to use anonymous types with fixed GUIDs, ConcurrencyStamps, and RoleNames constants
    status: pending
  - id: add-using-statement
    content: Add 'using PasswordManager.Entities.Models;' to access RoleNames constants
    status: pending
---

# Fix Role Seed Data Configuration

## Problem Summary

The `RoleConfiguration` seed data has three critical issues:

1. **GUID Mismatch**: Uses `new ApplicationRole("Administrator")` which generates random GUIDs, but the migration expects fixed GUIDs
2. **Missing ConcurrencyStamp**: Migration includes ConcurrencyStamp values but seed data doesn't set them
3. **Inconsistency**: Seed data doesn't match the migration, causing potential conflicts

## Solution

Update `RoleConfiguration` to use anonymous types with fixed GUIDs and ConcurrencyStamps that match the migration exactly. Use existing `RoleNames` constants for role names.

## Implementation Steps

### 1. Update RoleConfiguration.cs

Modify [`PasswordManager/Repository/RoleConfiguration.cs`](PasswordManager/Repository/RoleConfiguration.cs) to use anonymous types with fixed values:

- Use fixed GUIDs matching the migration:
  - Administrator: `3fb5367e-0a6d-40d6-8893-663a5865fd08`
  - User: `f8948564-aafa-499e-8c44-fed8b5fa0d0c`
- Include ConcurrencyStamp values from migration:
  - Administrator: `dcf072b4-529a-41ba-beba-2724f986c7de`
  - User: `f5bc7060-04ea-49b3-a4ce-918c18cec7ba`
- Use `RoleNames` constants from `PasswordManager.Entities.Models` namespace
- Use anonymous types instead of `ApplicationRole` instances to ensure EF Core can properly map all properties

### 2. Add Using Statement

Add `using PasswordManager.Entities.Models;` to access `RoleNames` constants.

## Files to Modify

- `PasswordManager/Repository/RoleConfiguration.cs` - Update the `Configure` method to use fixed GUIDs, ConcurrencyStamps, and RoleNames constants

## Code Changes

Replace the current `HasData` call with anonymous types that explicitly set all required properties:

```csharp
builder.HasData(
    new
    {
        Id = new Guid("3fb5367e-0a6d-40d6-8893-663a5865fd08"),
        Name = RoleNames.Admin,
        NormalizedName = RoleNames.Admin.ToUpperInvariant(),
        ConcurrencyStamp = "dcf072b4-529a-41ba-beba-2724f986c7de"
    },
    new
    {
        Id = new Guid("f8948564-aafa-499e-8c44-fed8b5fa0d0c"),
        Name = RoleNames.User,
        NormalizedName = RoleNames.User.ToUpperInvariant(),
        ConcurrencyStamp = "f5bc7060-04ea-49b3-a4ce-918c18cec7ba"
    });
```

## Verification

After the fix:

- Seed data GUIDs will match migration GUIDs exactly
- ConcurrencyStamp values will be included
- Role names will use constants for maintainability
- EF Core migrations will be consistent with seed data configuration