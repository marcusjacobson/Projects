<#
.SYNOPSIS
    Tests DLP Policies using the Test-DlpPolicies cmdlet.

.DESCRIPTION
    This script connects to Security & Compliance PowerShell and runs a test against
    a provided text string to see which DLP rules match.
    
    Note: Requires ExchangeOnlineManagement module (Connect-IPPSSession).

.PARAMETER TextToTest
    The string to test (e.g., a credit card number).

.EXAMPLE
    .\Test-DlpRules.ps1 -TextToTest "4111 1111 1111 1111"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Requirements:
    - ExchangeOnlineManagement module
    - Permissions to run Test-DlpPolicies

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TextToTest,

    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$AppId,

    [Parameter(Mandatory = $false)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory = $false)]
    [string]$Organization
)

# =============================================================================
# Step 0: Configuration Loading
# =============================================================================

# Try to load from global-config.json if parameters are missing
if (-not $TenantId -or -not $AppId -or -not $CertificateThumbprint) {
    $configPath = Join-Path $PSScriptRoot "..\..\templates\global-config.json"
    
    if (Test-Path $configPath) {
        Write-Host "   📂 Loading configuration from global-config.json..." -ForegroundColor Cyan
        $config = Get-Content $configPath | ConvertFrom-Json
        
        if (-not $TenantId -and $config.tenantId) { $TenantId = $config.tenantId }
        
        if (-not $CertificateThumbprint -and $config.servicePrincipal.certificateName) {
            $certName = $config.servicePrincipal.certificateName
            $cert = Get-ChildItem "Cert:\CurrentUser\My" | Where-Object { $_.Subject -eq "CN=$certName" } | Sort-Object NotAfter -Descending | Select-Object -First 1
            if ($cert) { $CertificateThumbprint = $cert.Thumbprint }
        }
        
        if (-not $AppId -and $config.servicePrincipal.appId) {
            $AppId = $config.servicePrincipal.appId
        }
        elseif (-not $AppId) {
            $detailsPath = Join-Path $PSScriptRoot "..\..\scripts\ServicePrincipal-Details.txt"
            if (Test-Path $detailsPath) {
                $detailsContent = Get-Content $detailsPath
                foreach ($line in $detailsContent) {
                    if ($line -match "App ID:\s+([a-f0-9-]{36})") {
                        $AppId = $matches[1]
                        break
                    }
                }
            }
        }
    }
}

# Resolve Organization via Graph if missing
if (-not $Organization) {
    Write-Host "   🔍 Resolving Organization domain via Microsoft Graph..." -ForegroundColor Cyan
    $connectScript = Join-Path $PSScriptRoot "..\..\scripts\Connect-PurviewGraph.ps1"
    if (Test-Path $connectScript) {
        & $connectScript
        try {
            $domain = Get-MgDomain | Where-Object { $_.IsInitial } | Select-Object -ExpandProperty Id
            $Organization = $domain
            Write-Host "   ✅ Resolved Organization: $Organization" -ForegroundColor Cyan
        } catch {
            Write-Host "   ⚠️ Failed to resolve domain via Graph. Please provide -Organization parameter." -ForegroundColor Yellow
        }
    }
}

Write-Host "🔌 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan

# Check if already connected
try {
    Get-DlpCompliancePolicy -ErrorAction Stop | Out-Null
    Write-Host "   ✅ Already connected." -ForegroundColor Green
} catch {
    try {
        # Use helper script for connection
        $helperScriptPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "scripts\Connect-PurviewIPPS.ps1"
        if (Test-Path $helperScriptPath) {
            . $helperScriptPath
            Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
        } else {
            throw "Helper script not found at: $helperScriptPath"
        }
    } catch {
        Write-Host "   ❌ Failed to connect: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🧪 Testing Text: '$TextToTest'" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

try {
    # Note: Test-DlpPolicies is the cmdlet, but parameters vary by version.
    # Often used: Test-DlpPolicies -TestText ...
    
    $result = Test-DlpPolicies -TestText $TextToTest
    
    if ($result) {
        $result | Format-List
    } else {
        Write-Host "   ⚠️ No matches found." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Error running test: $_" -ForegroundColor Red
}
