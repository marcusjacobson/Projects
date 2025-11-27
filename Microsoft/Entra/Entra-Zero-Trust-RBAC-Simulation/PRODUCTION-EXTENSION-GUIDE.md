# Production Implementation Guide: Practical Script Extension

This guide provides actionable, low-level technical guidance on how to adapt the **existing PowerShell scripts and parameter files** from this simulation for use in a live production tenant.

It focuses on **how to modify the code**, **how to structure your data**, and **how to execute safely**.

---

## 1. Parameter File Strategy

The simulation uses a monolithic `module.parameters.json` for each lab. In production, you need environment-specific configurations.

### A. Environment-Specific Files

Create separate parameter files for each environment to prevent accidental configuration bleed.

* `infra/dev.parameters.json`
* `infra/prod.parameters.json`

**Example Adaptation:**
In `01-Identity-Foundation/infra/prod.parameters.json`, you would remove the `users` array (since you don't deploy fake users in prod) but keep the hardening settings.

```json
{
    "global": {
        "location": "US",
        "customDomain": "contoso.com"
    },
    "Configure-TenantHardening": {
        "allowInvitesFrom": "adminsAndGuestInviters",
        "allowedToReadOtherUsers": false
    },
    "Configure-GroupBasedLicensing": {
        "groupName": "GRP-All-Employees-Licensing",
        "groupDescription": "Dynamic group for E5 assignment"
    }
}
```

### B. Handling Secrets

**NEVER** store passwords (like `breakGlassPassword`) in the JSON file in production.

#### Technique 1: Script Modification

Modify the scripts to accept a `SecureString` parameter that overrides the JSON value.

```powershell
# In Deploy-BreakGlassAccounts.ps1
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [SecureString]$OverridePassword  # <--- Add this
)

# ... inside the script ...
if ($OverridePassword) {
    $Password = $OverridePassword
} else {
    $Password = $jsonParams.global.breakGlassPassword
}
```

#### Technique 2: CI/CD Token Replacement

Use a placeholder in your JSON file and let your pipeline replace it.

* JSON: `"breakGlassPassword": "#{BG_PASSWORD}#"`
* Pipeline: Replaces `#{BG_PASSWORD}#` with the value from Azure Key Vault before execution.

---

## 2. Script Safety & Execution

The simulation scripts are designed to "fail fast" or "create if missing". In production, you need more safety rails.

### A. Adding `WhatIf` Support

Most simulation scripts use `[CmdletBinding()]` but may not explicitly implement `SupportsShouldProcess`. To make them safe for "Dry Runs":

1. Update the `CmdletBinding` attribute:

    ```powershell
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(...)
    ```

2. Wrap destructive/creation logic in `if ($PSCmdlet.ShouldProcess(...))`:

    ```powershell
    if ($PSCmdlet.ShouldProcess("Target: $AuName", "Operation: Create Administrative Unit")) {
        New-MgDirectoryAdministrativeUnit -BodyParameter $params
    }
    ```

### B. Logging

Production execution requires audit trails. Wrap the script execution in a transcript.

```powershell
$date = Get-Date -Format "yyyyMMdd-HHmm"
Start-Transcript -Path ".\logs\Deploy-Prod-$date.log"
try {
    .\Configure-TenantHardening.ps1 -UseParametersFile
}
finally {
    Stop-Transcript
}
```

---

## 3. Module-Specific Extension Tips

### Module 01: Identity Foundation

* **Script**: `Deploy-IdentityHierarchy.ps1`
  * **Prod Use**: Do **NOT** use the user creation logic for employees.
  * **Adaptation**: Use this script to provision **Service Accounts** or **Test Users** in a dedicated sandbox AU.
  * **Extension**: Modify the `departments` array in `module.parameters.json` to match your exact organizational structure (e.g., "Global Supply Chain", "R&D").
* **Script**: `Configure-TenantHardening.ps1`
  * **Prod Use**: Highly recommended.
  * **Adaptation**: Review the `allowedToReadOtherUsers` setting. In some collaborative orgs, setting this to `false` breaks Teams functionality. Test in Dev first.

### Module 02: Delegated Administration

* **Script**: `Deploy-AdministrativeUnits.ps1`
  * **Prod Use**: Use for creating the AU structure.
  * **Adaptation**: The script currently does static assignment. Modify it to accept a **Dynamic Membership Rule** in the parameters.

    *JSON Extension:*

    ```json
    "administrativeUnits": [
        { 
            "name": "AU-Germany", 
            "description": "Germany Business Unit",
            "dynamicRule": "(user.country -eq 'Germany')" 
        }
    ]
    ```

    *Script Extension:*

    ```powershell
    # Inside the loop
    if ($au.dynamicRule) {
        New-MgDirectoryAdministrativeUnit -DisplayName $au.name -MembershipType "Dynamic" -MembershipRule $au.dynamicRule ...
    }
    ```

### Module 04: RBAC & PIM

* **Script**: `Configure-PIM-Roles.ps1`
  * **Prod Use**: This is the most valuable script for production.
  * **Adaptation**: The current JSON only defines *one* role configuration. Extend the JSON array to cover your "Top 10" roles.

    *JSON Extension:*

    ```json
    "rolesToConfigure": [
        { "roleName": "Global Administrator", "maxDuration": "PT4H", "requireMfa": true, "approver": "ciso@contoso.com" },
        { "roleName": "Exchange Administrator", "maxDuration": "PT8H", "requireMfa": true, "approver": "it-manager@contoso.com" },
        { "roleName": "User Administrator", "maxDuration": "PT8H", "requireMfa": false, "approver": null }
    ]
    ```

    *Script Extension:*
    Wrap the core logic of `Configure-PIM-Roles.ps1` in a `foreach ($role in $jsonParams.rolesToConfigure)` loop.

### Module 06: Conditional Access

* **Script**: `Deploy-CAPolicies.ps1`
  * **Prod Use**: Use to deploy baseline policies.
  * **Adaptation**: The script reads JSON files from `../templates/`.
  * **Workflow**:
    1. Export your *current* production policies to JSON using `Get-MgIdentityConditionalAccessPolicy`.
    2. Save them to the `templates/` folder.
    3. Modify the JSON to apply your new hardening standards (e.g., adding FIDO2).
    4. Run the script with a `-ReportOnly` switch (you may need to add this parameter to the script to override the JSON state).

---

## 4. Data Injection Techniques

In production, you often need to feed data from external sources (CSV, API) into these scripts.

### Technique: Pipeline Input

Modify the scripts to accept input from the pipeline.

```powershell
# Configure-PIM-Roles.ps1
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$true)]
    [PSCustomObject[]]$RoleConfigs
)

process {
    foreach ($config in $RoleConfigs) {
        # Use $config.roleName, $config.maxDuration, etc.
    }
}
```

**Usage:**

```powershell
$csvData = Import-Csv ".\roles-config.csv"
$csvData | .\Configure-PIM-Roles.ps1
```

This allows you to manage your configuration in Excel/CSV (which business users like) and pipe it directly into the automation engine.
