<#
.SYNOPSIS
    Validates document upload and metadata application success.

.DESCRIPTION
    This script performs comprehensive validation of document uploads to SharePoint 
    Online sites. It verifies document counts, tests accessibility, validates 
    metadata application, and generates detailed validation reports.
    
    The script connects to each SharePoint site, compares uploaded document counts 
    against generation reports, tests random document samples for accessibility, 
    and confirms metadata field application.

.PARAMETER SiteName
    Name of specific SharePoint site to validate. If not specified, validates all sites.

.PARAMETER DetailedValidation
    Perform detailed validation including file access tests and metadata verification.

.PARAMETER SampleSize
    Number of documents to sample for detailed validation (default: 50).

.EXAMPLE
    .\Test-UploadValidation.ps1
    
    Perform basic upload validation for all SharePoint sites.

.EXAMPLE
    .\Test-UploadValidation.ps1 -DetailedValidation
    
    Perform comprehensive validation including file access and metadata tests.

.EXAMPLE
    .\Test-UploadValidation.ps1 -SiteName "HR-Simulation"
    
    Validate only the HR-Simulation site uploads.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - PnP.PowerShell module v2.0+
    - SharePoint Online permissions (read access minimum)
    - Documents already uploaded to SharePoint sites
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION CHECKS
    Document Count Verification: Compare uploaded vs expected counts
    Document Accessibility: Test random sample document retrieval
    Metadata Application: Verify metadata fields are populated
    Site Quota Status: Check storage consumption
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$SiteName,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedValidation,
    
    [Parameter(Mandatory = $false)]
    [int]$SampleSize = 50
)

# =============================================================================
# Comprehensive validation of document uploads and metadata application.
# =============================================================================

# =============================================================================
# Action 1: Load Configuration
# =============================================================================

Write-Verbose "🔍 Action 1: Load Configuration" -Verbose
Write-Verbose "================================" -Verbose

# Load shared utilities
$sharedUtilitiesPath = Join-Path $PSScriptRoot "..\..\Shared-Utilities"

try {
    . (Join-Path $sharedUtilitiesPath "Import-GlobalConfig.ps1")
    . (Join-Path $sharedUtilitiesPath "Write-SimulationLog.ps1")
    . (Join-Path $sharedUtilitiesPath "Connect-PurviewServices.ps1")
    Write-Verbose "   ✅ Shared utilities loaded" -Verbose
} catch {
    Write-Error "Failed to load shared utilities: $($_.Exception.Message)"
    exit 1
}

# Load configuration
try {
    $config = Import-GlobalConfig
    Write-Verbose "   ✅ Configuration loaded" -Verbose
} catch {
    Write-SimulationLog -Message "Failed to load configuration: $($_.Exception.Message)" -Level Error
    throw
}

# Load previous upload report for comparison
$reportsPath = $config.Paths.Reports
if (-not [System.IO.Path]::IsPathRooted($reportsPath)) {
    $reportsPath = Join-Path $PSScriptRoot "..\.." $reportsPath
    $reportsPath = [System.IO.Path]::GetFullPath($reportsPath)
}
$lastUploadReport = Get-ChildItem -Path $reportsPath -Filter "document-upload-*.json" -ErrorAction SilentlyContinue | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

$expectedCounts = @{}

if ($lastUploadReport) {
    try {
        $uploadData = Get-Content $lastUploadReport.FullName | ConvertFrom-Json
        Write-Verbose "   📋 Loaded upload report: $($lastUploadReport.Name)" -Verbose
        Write-Verbose "      • Upload Date: $($uploadData.Summary.CompletedOn)" -Verbose
        Write-Verbose "      • Total Documents: $($uploadData.Summary.SuccessfulUploads)" -Verbose
        
        # Extract expected counts by category
        foreach ($category in $uploadData.ByCategory.PSObject.Properties) {
            $categoryName = $category.Name
            $successCount = $category.Value.SuccessCount
            $expectedCounts[$categoryName] = $successCount
        }
    } catch {
        Write-SimulationLog -Message "Failed to load upload report: $($_.Exception.Message)" -Level Warning
    }
} else {
    Write-Verbose "   ⚠️  No previous upload report found - validation will be basic" -Verbose
}

Write-Verbose "   ✅ Validation configuration loaded" -Verbose

# =============================================================================
# Action 2: Determine Target Sites
# =============================================================================

Write-Verbose "`n🔍 Action 2: Determine Target Sites" -Verbose
Write-Verbose "====================================" -Verbose

# Get sites to validate
$sites = if ($SiteName) {
    Write-Verbose "   📋 Validating single site: $SiteName" -Verbose
    @($config.SharePointSites | Where-Object { $_.Name -eq $SiteName })
} else {
    Write-Verbose "   📋 Validating all SharePoint sites: $($config.SharePointSites.Count)" -Verbose
    $config.SharePointSites
}

if ($sites.Count -eq 0) {
    Write-SimulationLog -Message "No SharePoint sites found to validate" -Level Error
    throw "No sites to validate"
}

Write-Verbose "   ✅ Target sites identified: $($sites.Count)" -Verbose

# =============================================================================
# Action 3: Validate Document Counts
# =============================================================================

Write-Verbose "`n🔍 Action 3: Validate Document Counts" -Verbose
Write-Verbose "======================================" -Verbose

$validationResults = @{
    TotalSites = $sites.Count
    SiteResults = @()
    TotalDocumentsFound = 0
    TotalDocumentsExpected = 0
    AllCountsMatch = $true
}

# Store tenant URL for later use
$tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')

foreach ($site in $sites) {
    $siteName = $site.Name
    $siteUrl = "$tenantUrl/sites/$siteName"
    $department = $site.Department
    
    Write-Verbose "`n   📋 Validating Site: $siteName ($department)" -Verbose
    
    try {
        # Connect to SharePoint using shared utilities
        Write-Verbose "      🔐 Connecting to $siteName..." -Verbose
        $clientId = $config.Environment.PnPClientId
        Connect-PurviewServices -TenantUrl $siteUrl -ClientId $clientId -SkipCompliance
        Write-Verbose "      ✅ Connected" -Verbose
        
        # Get document count
        $documents = Get-PnPListItem -List "Documents" -PageSize 500
        $actualCount = $documents.Count
        
        # Determine expected count (map department to category)
        $categoryMapping = @{
            "HR" = "HR"
            "Finance" = "Financial"
            "Legal" = "Identity"
            "Marketing" = "Mixed"
            "IT" = "Mixed"
        }
        
        $expectedCategory = $categoryMapping[$department]
        $expectedCount = if ($expectedCounts.ContainsKey($expectedCategory)) {
            $expectedCounts[$expectedCategory]
        } else {
            $null
        }
        
        # Calculate match percentage
        $matchStatus = if ($expectedCount) {
            $matchPercent = [math]::Round(($actualCount / $expectedCount) * 100, 1)
            
            if ($matchPercent -ge 95) {
                "✅ Match"
            } elseif ($matchPercent -ge 80) {
                "⚠️  Partial"
            } else {
                "❌ Mismatch"
            }
        } else {
            "❓ Unknown"
        }
        
        Write-Verbose "      📊 Documents Found: $actualCount" -Verbose
        if ($expectedCount) {
            Write-Verbose "      📊 Expected Count: $expectedCount" -Verbose
            Write-Verbose "      📊 Status: $matchStatus" -Verbose
        }
        
        # Store results
        $siteResult = @{
            SiteName = $siteName
            Department = $department
            ActualCount = $actualCount
            ExpectedCount = $expectedCount
            MatchStatus = $matchStatus
        }
        
        $validationResults.SiteResults += $siteResult
        $validationResults.TotalDocumentsFound += $actualCount
        
        if ($null -ne $expectedCount -and $expectedCount -gt 0) {
            $validationResults.TotalDocumentsExpected += $expectedCount
        }
        
        if ($matchStatus -like "*Mismatch*") {
            $validationResults.AllCountsMatch = $false
        }
        
        # Disconnect
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
        
    } catch {
        Write-SimulationLog -Message "Failed to validate site '$siteName': $($_.Exception.Message)" -Level Error
        Write-Verbose "      ❌ Validation failed: $($_.Exception.Message)" -Verbose
        
        $validationResults.SiteResults += @{
            SiteName = $siteName
            Department = $department
            ActualCount = 0
            ExpectedCount = $null
            MatchStatus = "❌ Error"
        }
        
        $validationResults.AllCountsMatch = $false
    }
}

Write-Verbose "`n   ✅ Document count validation completed" -Verbose

# =============================================================================
# Action 4: Test Document Accessibility (Detailed Mode)
# =============================================================================

if ($DetailedValidation) {
    Write-Verbose "`n🔍 Action 4: Test Document Accessibility" -Verbose
    Write-Verbose "=========================================" -Verbose
    
    $accessibilityResults = @{
        TotalTested = 0
        Accessible = 0
        Inaccessible = 0
    }
    
    foreach ($site in $sites) {
        $siteName = $site.Name
        $siteUrl = "$tenantUrl/sites/$siteName"
        
        try {
            Write-Verbose "   🔐 Connecting to $siteName..." -Verbose
            $clientId = $config.Environment.PnPClientId
            Connect-PurviewServices -TenantUrl $siteUrl -ClientId $clientId -SkipCompliance
            
            # Get random sample of documents
            $allDocuments = Get-PnPListItem -List "Documents" -PageSize 500
            $sampleCount = [math]::Min($SampleSize, $allDocuments.Count)
            $sampleDocuments = $allDocuments | Get-Random -Count $sampleCount
            
            Write-Verbose "   📋 Testing $sampleCount documents from $siteName..." -Verbose
            
            foreach ($doc in $sampleDocuments) {
                try {
                    $fileName = $doc.FieldValues.FileLeafRef
                    $fileRef = $doc.FieldValues.FileRef
                    
                    # Test file retrieval
                    $file = Get-PnPFile -Url $fileRef -AsListItem -ErrorAction Stop
                    
                    if ($file) {
                        $accessibilityResults.Accessible++
                    }
                } catch {
                    Write-SimulationLog -Message "Document inaccessible: $fileName" -Level Warning
                    $accessibilityResults.Inaccessible++
                }
                
                $accessibilityResults.TotalTested++
            }
            
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
            
        } catch {
            Write-SimulationLog -Message "Failed to test accessibility for site '$siteName': $($_.Exception.Message)" -Level Error
        }
    }
    
    $accessRate = if ($accessibilityResults.TotalTested -gt 0) {
        [math]::Round(($accessibilityResults.Accessible / $accessibilityResults.TotalTested) * 100, 1)
    } else {
        0
    }
    
    Write-Verbose "`n   📊 Accessibility Test Results:" -Verbose
    Write-Verbose "      • Total Tested: $($accessibilityResults.TotalTested)" -Verbose
    Write-Verbose "      • Accessible: $($accessibilityResults.Accessible)" -Verbose
    Write-Verbose "      • Inaccessible: $($accessibilityResults.Inaccessible)" -Verbose
    Write-Verbose "      • Access Rate: $accessRate%" -Verbose
    
    $validationResults.AccessibilityTest = $accessibilityResults
}

# =============================================================================
# Action 5: Validate Metadata Application (Detailed Mode)
# =============================================================================

if ($DetailedValidation) {
    Write-Verbose "`n🔍 Action 5: Validate Metadata Application" -Verbose
    Write-Verbose "===========================================" -Verbose
    
    $metadataResults = @{
        TotalDocuments = 0
        WithMetadata = 0
        MissingMetadata = 0
    }
    
    $requiredFields = @("Department", "ContentCategory", "PIIDensity", "GeneratedDate")
    
    foreach ($site in $sites) {
        $siteName = $site.Name
        $siteUrl = "$tenantUrl/sites/$siteName"
        
        try {
            Write-Verbose "   🔐 Connecting to $siteName..." -Verbose
            $clientId = $config.Environment.PnPClientId
            Connect-PurviewServices -TenantUrl $siteUrl -ClientId $clientId -SkipCompliance
            
            $documents = Get-PnPListItem -List "Documents" -PageSize 500
            
            Write-Verbose "   📋 Checking metadata for $($documents.Count) documents in $siteName..." -Verbose
            
            foreach ($doc in $documents) {
                $hasAllMetadata = $true
                
                foreach ($field in $requiredFields) {
                    if (-not $doc.FieldValues.ContainsKey($field) -or -not $doc.FieldValues[$field]) {
                        $hasAllMetadata = $false
                        break
                    }
                }
                
                if ($hasAllMetadata) {
                    $metadataResults.WithMetadata++
                } else {
                    $metadataResults.MissingMetadata++
                }
                
                $metadataResults.TotalDocuments++
            }
            
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
            
        } catch {
            Write-SimulationLog -Message "Failed to validate metadata for site '$siteName': $($_.Exception.Message)" -Level Error
        }
    }
    
    $metadataRate = if ($metadataResults.TotalDocuments -gt 0) {
        [math]::Round(($metadataResults.WithMetadata / $metadataResults.TotalDocuments) * 100, 1)
    } else {
        0
    }
    
    Write-Verbose "`n   📊 Metadata Validation Results:" -Verbose
    Write-Verbose "      • Total Documents: $($metadataResults.TotalDocuments)" -Verbose
    Write-Verbose "      • With Metadata: $($metadataResults.WithMetadata)" -Verbose
    Write-Verbose "      • Missing Metadata: $($metadataResults.MissingMetadata)" -Verbose
    Write-Verbose "      • Metadata Coverage: $metadataRate%" -Verbose
    
    $validationResults.MetadataValidation = $metadataResults
}

# =============================================================================
# Action 6: Validation Summary
# =============================================================================

Write-Verbose "`n🎯 Validation Summary" -Verbose
Write-Verbose "=====================" -Verbose

Write-Verbose "   📊 Sites Validated: $($validationResults.TotalSites)" -Verbose
Write-Verbose "   📊 Total Documents Found: $($validationResults.TotalDocumentsFound)" -Verbose

if ($validationResults.TotalDocumentsExpected -gt 0) {
    Write-Verbose "   📊 Total Documents Expected: $($validationResults.TotalDocumentsExpected)" -Verbose
    $overallMatch = [math]::Round(($validationResults.TotalDocumentsFound / $validationResults.TotalDocumentsExpected) * 100, 1)
    Write-Verbose "   📊 Overall Match Rate: $overallMatch%" -Verbose
}

if ($validationResults.AllCountsMatch) {
    Write-Verbose "   ✅ All document counts validated successfully" -Verbose
} else {
    Write-Verbose "   ⚠️  Some document counts show discrepancies" -Verbose
}

if ($DetailedValidation) {
    Write-Verbose "`n   📊 Detailed Validation:" -Verbose
    
    if ($validationResults.AccessibilityTest) {
        $accessRate = [math]::Round(($validationResults.AccessibilityTest.Accessible / $validationResults.AccessibilityTest.TotalTested) * 100, 1)
        Write-Verbose "      • Document Accessibility: $accessRate%" -Verbose
    }
    
    if ($validationResults.MetadataValidation) {
        $metadataRate = [math]::Round(($validationResults.MetadataValidation.WithMetadata / $validationResults.MetadataValidation.TotalDocuments) * 100, 1)
        Write-Verbose "      • Metadata Coverage: $metadataRate%" -Verbose
    }
}

# Save validation report
$reportFileName = "upload-validation-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"
$reportBasePath = $config.Paths.Reports
if (-not [System.IO.Path]::IsPathRooted($reportBasePath)) {
    $reportBasePath = Join-Path $PSScriptRoot "..\.." $reportBasePath
    $reportBasePath = [System.IO.Path]::GetFullPath($reportBasePath)
}

# Ensure reports directory exists
if (-not (Test-Path $reportBasePath)) {
    New-Item -ItemType Directory -Path $reportBasePath -Force | Out-Null
}

$reportPath = Join-Path $reportBasePath $reportFileName

try {
    $validationResults | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force
    Write-Verbose "`n   ✅ Validation report saved: $reportFileName" -Verbose
} catch {
    Write-SimulationLog -Message "Failed to save validation report: $($_.Exception.Message)" -Level Warning
}

# Determine overall validation status
$allPassed = $true

if (-not $validationResults.AllCountsMatch) {
    $allPassed = $false
}

if ($DetailedValidation) {
    if ($validationResults.AccessibilityTest.Inaccessible -gt 0) {
        $allPassed = $false
    }
    
    if ($validationResults.MetadataValidation.MissingMetadata -gt 0) {
        $allPassed = $false
    }
}

if ($allPassed) {
    Write-Verbose "`n   ✅ All validation checks passed" -Verbose
    Write-SimulationLog -Message "Upload validation passed: $($validationResults.TotalDocumentsFound) documents validated" -Level Success
} else {
    Write-Verbose "`n   ⚠️  Validation completed with warnings" -Verbose
    Write-SimulationLog -Message "Upload validation completed with warnings - review validation report" -Level Warning
}

return $validationResults
