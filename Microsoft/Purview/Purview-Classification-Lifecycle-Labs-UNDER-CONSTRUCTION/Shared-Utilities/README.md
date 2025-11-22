# Shared Utilities Module

This module provides reusable PowerShell functions and utilities extracted from common patterns across Labs 1-5. These utilities standardize connection management, error handling, logging, and operational tasks used throughout the Microsoft Purview Classification Lifecycle Labs.

## 📋 Purpose

**Objectives:**

- Eliminate code duplication across lab scripts.
- Provide consistent error handling and logging patterns.
- Standardize connection management for Microsoft 365 services.
- Simplify common operational tasks with helper functions.
- Improve maintainability through centralized utilities.

## 🗂️ Module Structure

```text
Shared-Utilities/
├── README.md                           # This file
├── PurviewUtilities.psm1              # Main PowerShell module
└── Functions/
    ├── Connection-Management.ps1       # Service connection utilities
    ├── Error-Handling.ps1              # Standardized error handling
    ├── Logging-Utilities.ps1           # Logging and output functions
    ├── Validation-Helpers.ps1          # Common validation patterns
    └── Retry-Logic.ps1                 # Retry and backoff mechanisms
```

## 🚀 Installation

### Import the Module

```powershell
# Import from relative path
Import-Module ".\Shared-Utilities\PurviewUtilities.psm1" -Force

# Or add to PowerShell profile for persistent availability
$profilePath = $PROFILE.CurrentUserAllHosts
Add-Content $profilePath "`nImport-Module 'C:\Path\To\Shared-Utilities\PurviewUtilities.psm1'"
```

### Verify Installation

```powershell
# List available commands
Get-Command -Module PurviewUtilities

# Get help for specific function
Get-Help Connect-PurviewServices -Detailed
```

## 📚 Available Functions

### Connection Management

| Function | Purpose | Common Usage |
|----------|---------|--------------|
| `Connect-PurviewServices` | Connect to SharePoint, Exchange, Compliance Center | All labs requiring service access |
| `Disconnect-PurviewServices` | Safely disconnect all active sessions | Cleanup after operations |
| `Test-PurviewConnection` | Verify service connectivity | Health checks, troubleshooting |
| `Get-ServiceConnectionStatus` | Check current connection state | Connection validation |

### Error Handling

| Function | Purpose | Common Usage |
|----------|---------|--------------|
| `Invoke-WithErrorHandling` | Execute code with standardized error handling | All critical operations |
| `Write-PurviewError` | Log errors with consistent formatting | Error logging across labs |
| `Get-DetailedErrorInfo` | Extract comprehensive error details | Troubleshooting, diagnostics |
| `Test-PurviewOperation` | Validate operation success | Post-operation validation |

### Logging Utilities

| Function | Purpose | Common Usage |
|----------|---------|--------------|
| `Write-PurviewLog` | Write to log file with timestamps | All script logging |
| `Initialize-PurviewLog` | Set up logging for session | Script initialization |
| `Write-ProgressStatus` | Display progress with consistent formatting | Long-running operations |
| `Write-SectionHeader` | Display section headers | Script organization |

### Validation Helpers

| Function | Purpose | Common Usage |
|----------|---------|--------------|
| `Test-PurviewPrerequisites` | Validate prerequisites before execution | Script startup validation |
| `Test-ModuleVersion` | Check PowerShell module versions | Module validation |
| `Test-ServicePrincipal` | Validate service principal configuration | Authentication testing |
| `Confirm-PurviewOperation` | Get user confirmation for critical operations | Destructive operations |

### Retry Logic

| Function | Purpose | Common Usage |
|----------|---------|--------------|
| `Invoke-WithRetry` | Execute with exponential backoff | API calls, throttling |
| `Wait-ForRateLimit` | Intelligent delay for rate limiting | Batch processing |
| `Test-ShouldRetry` | Determine if operation should retry | Retry decision logic |

## 🔧 Usage Examples

### Example 1: Connect to Services with Error Handling

```powershell
Import-Module ".\Shared-Utilities\PurviewUtilities.psm1"

# Initialize logging
Initialize-PurviewLog -LogPath ".\logs\script-execution.log"

# Connect to services with built-in error handling
Invoke-WithErrorHandling -ScriptBlock {
    Connect-PurviewServices -Services @("SharePoint", "Exchange")
    
    # Your code here
    $sites = Get-PnPTenantSite
    Write-PurviewLog "Retrieved $($sites.Count) sites"
    
} -Finally {
    Disconnect-PurviewServices
}
```

### Example 2: API Call with Retry Logic

```powershell
# Execute API call with exponential backoff
$result = Invoke-WithRetry -ScriptBlock {
    Get-DlpSensitiveInformationType -ResultSize 1000
} -MaxRetries 5 -InitialDelay 10

Write-PurviewLog "Retrieved $($result.Count) SITs"
```

### Example 3: Prerequisite Validation

```powershell
# Validate prerequisites before script execution
$validation = Test-PurviewPrerequisites -RequiredModules @(
    @{ Name = "PnP.PowerShell"; MinVersion = "1.12.0" }
    @{ Name = "ExchangeOnlineManagement"; MinVersion = "3.4.0" }
)

if (-not $validation.Success) {
    Write-PurviewError "Prerequisites not met: $($validation.Message)"
    exit 1
}
```

### Example 4: Progress Tracking

```powershell
# Process items with progress display
$sites = Get-PnPTenantSite
$total = $sites.Count
$current = 0

foreach ($site in $sites) {
    $current++
    Write-ProgressStatus -Activity "Processing Sites" -Status $site.Url -PercentComplete (($current / $total) * 100)
    
    # Process site
}
```

## 🎯 Integration with Labs

### Lab 1: Tenant Setup

```powershell
# Use shared utilities for tenant setup
Import-Module ".\Shared-Utilities\PurviewUtilities.psm1"

Initialize-PurviewLog -LogPath ".\logs\tenant-setup.log"
Test-PurviewPrerequisites -RequiredModules $requiredModules
Connect-PurviewServices -Services @("Exchange")
```

### Lab 2: Classification Engine

```powershell
# Leverage retry logic for bulk classification
$sites | ForEach-Object -ThrottleLimit 5 -Parallel {
    $using:Invoke-WithRetry -ScriptBlock {
        # Classification logic
    }
}
```

### Lab 3: Advanced Features

```powershell
# Use validation helpers for DLP policy creation
if (Confirm-PurviewOperation -Message "Create DLP policy?") {
    Invoke-WithErrorHandling -ScriptBlock {
        New-DlpCompliancePolicy @params
    }
}
```

### Lab 4: Workflow Orchestration

```powershell
# Integrate logging and error handling in workflows
foreach ($step in $workflow.Steps) {
    Write-SectionHeader -Text "Executing: $($step.Name)"
    Invoke-WithErrorHandling -ScriptBlock {
        & $step.Script
    }
}
```

### Lab 5: Runbooks

```powershell
# Use diagnostic utilities in troubleshooting
$connectionStatus = Get-ServiceConnectionStatus
$errorDetails = Get-DetailedErrorInfo -ErrorRecord $_
Write-PurviewLog "Connection: $connectionStatus, Error: $errorDetails"
```

## 📊 Function Reference

### Connection Management Functions

#### Connect-PurviewServices

```powershell
<#
.SYNOPSIS
    Connect to Microsoft Purview services.

.PARAMETER Services
    Array of services to connect to: "SharePoint", "Exchange", "ComplianceCenter"

.PARAMETER Interactive
    Use interactive authentication (default: $true)

.PARAMETER ClientId
    Service principal client ID for certificate authentication

.PARAMETER Thumbprint
    Certificate thumbprint for service principal authentication

.EXAMPLE
    Connect-PurviewServices -Services @("SharePoint", "Exchange")
#>
```

#### Test-PurviewConnection

```powershell
<#
.SYNOPSIS
    Test connectivity to Purview services.

.PARAMETER Service
    Service to test: "SharePoint", "Exchange", "ComplianceCenter"

.EXAMPLE
    Test-PurviewConnection -Service "SharePoint"
    Returns: [PSCustomObject]@{ Service = "SharePoint"; Connected = $true }
#>
```

### Error Handling Functions

#### Invoke-WithErrorHandling

```powershell
<#
.SYNOPSIS
    Execute script block with standardized error handling.

.PARAMETER ScriptBlock
    Script block to execute

.PARAMETER ErrorAction
    Action on error: "Stop", "Continue", "SilentlyContinue"

.PARAMETER Finally
    Script block to execute in finally clause

.EXAMPLE
    Invoke-WithErrorHandling -ScriptBlock { 
        # Your code 
    } -Finally { 
        # Cleanup 
    }
#>
```

### Logging Functions

#### Write-PurviewLog

```powershell
<#
.SYNOPSIS
    Write message to Purview log file.

.PARAMETER Message
    Message to log

.PARAMETER Level
    Log level: "INFO", "WARNING", "ERROR", "DEBUG"

.PARAMETER LogPath
    Path to log file (optional, uses initialized path)

.EXAMPLE
    Write-PurviewLog "Operation completed" -Level "INFO"
#>
```

### Retry Functions

#### Invoke-WithRetry

```powershell
<#
.SYNOPSIS
    Execute script block with exponential backoff retry logic.

.PARAMETER ScriptBlock
    Script block to execute

.PARAMETER MaxRetries
    Maximum number of retry attempts (default: 5)

.PARAMETER InitialDelay
    Initial delay in seconds (default: 10)

.PARAMETER BackoffMultiplier
    Multiplier for exponential backoff (default: 2)

.EXAMPLE
    $result = Invoke-WithRetry -ScriptBlock { Get-PnPWeb } -MaxRetries 3
#>
```

## 🔐 Best Practices

### Module Usage

1. **Always Import at Script Start**: Import module at the beginning of every script.
2. **Initialize Logging**: Call `Initialize-PurviewLog` before other operations.
3. **Use Error Handling**: Wrap critical operations in `Invoke-WithErrorHandling`.
4. **Implement Retry Logic**: Use `Invoke-WithRetry` for API calls subject to throttling.
5. **Validate Prerequisites**: Check requirements with `Test-PurviewPrerequisites`.
6. **Clean Up Connections**: Always call `Disconnect-PurviewServices` in finally blocks.

### Performance Optimization

- **Connection Reuse**: Connect once, reuse connection across operations.
- **Batch Operations**: Use retry logic with appropriate delays between batches.
- **Progress Reporting**: Use `Write-ProgressStatus` for user feedback on long operations.

### Error Management

- **Capture Details**: Use `Get-DetailedErrorInfo` for comprehensive error information.
- **Log All Errors**: Every error should be logged with `Write-PurviewError`.
- **Fail Fast**: Exit early on critical errors after logging.

## 📖 Module Development

### Adding New Functions

1. Create function in appropriate file under `Functions/` directory.
2. Add function export to `PurviewUtilities.psm1`.
3. Document with comment-based help.
4. Add usage example to this README.
5. Test with existing lab scripts.

### Function Template

```powershell
function Verb-PurviewNoun {
    <#
    .SYNOPSIS
        Brief description
    
    .DESCRIPTION
        Detailed description
    
    .PARAMETER ParameterName
        Parameter description
    
    .EXAMPLE
        Verb-PurviewNoun -ParameterName "Value"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )
    
    # Function logic
}
```

## 🧪 Testing

### Unit Testing

```powershell
# Test individual functions
Import-Module ".\Shared-Utilities\PurviewUtilities.psm1" -Force

# Test connection function
$result = Test-PurviewConnection -Service "SharePoint"
Write-Host "Connection test: $($result.Connected)"

# Test logging
Initialize-PurviewLog -LogPath ".\logs\test.log"
Write-PurviewLog "Test message" -Level "INFO"

# Verify log file created
Test-Path ".\logs\test.log"
```

### Integration Testing

Run existing lab scripts with shared utilities:

```powershell
# Test with Lab 1 script
Import-Module ".\Shared-Utilities\PurviewUtilities.psm1"
.\01-TenantSetup\scripts\New-CustomSIT.ps1 -UseSharedUtilities

# Test with Lab 2 script
.\02-BulkClassification\scripts\Invoke-BulkClassification.ps1 -UseSharedUtilities
```

## 📊 Performance Metrics

**Expected improvements with shared utilities:**

- **Code Reduction**: 20-30% reduction in script length through utility reuse
- **Error Handling**: 95%+ consistent error handling across all scripts
- **Retry Success**: 80%+ success rate on throttled API calls
- **Maintainability**: Single source for common patterns reduces bugs

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-11 | Initial release with core utilities |

## 📚 Related Documentation

- **Lab 1**: Tenant Setup - Uses connection management and validation helpers
- **Lab 2**: Classification Engine - Uses retry logic and progress tracking
- **Lab 3**: Advanced Features - Uses error handling and validation
- **Lab 4**: Workflow Orchestration - Uses logging and section headers
- **Lab 5**: Runbooks - References utilities for troubleshooting

## 🤖 AI-Assisted Content Generation

This comprehensive shared utilities module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, extracting common patterns from Labs 1-4 to create reusable PowerShell utilities following enterprise-grade module development standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of utility functions while maintaining technical accuracy and reflecting PowerShell module development best practices.*

---

*This module is part of the Microsoft Purview Classification Lifecycle Labs.*
