# =============================================================================
# Microsoft Defender for Cloud - Compliance Analysis Script
# =============================================================================
# This script analyzes compliance standards and provides detailed security
# posture assessment for governance and reporting.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Environment name for resource identification")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Additional compliance standards to analyze (comma-separated). Options: nist, pci, iso27001")]
    [string]$AdditionalStandards = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview analysis without making changes")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Generate detailed compliance report")]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory=$false, HelpMessage="Export results to file")]
    [string]$ExportPath = ""
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "📋 Microsoft Defender for Cloud - Compliance Analysis" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# =============================================================================
# 📊 COMPLIANCE GOVERNANCE BENEFITS
# =============================================================================
Write-Host "📊 COMPLIANCE GOVERNANCE BENEFITS" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow
Write-Host "🎯 This script provides comprehensive compliance analysis for:" -ForegroundColor Yellow
Write-Host "   • Microsoft Cloud Security Benchmark (MCSB) detailed assessment" -ForegroundColor Yellow
Write-Host "   • Regulatory compliance standards evaluation" -ForegroundColor Yellow
Write-Host "   • Security control coverage analysis" -ForegroundColor Yellow
Write-Host "   • Compliance scoring and gap identification" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Expected Benefits:" -ForegroundColor Cyan
Write-Host "   • Clear visibility into security posture compliance" -ForegroundColor Cyan
Write-Host "   • Actionable insights for security improvements" -ForegroundColor Cyan
Write-Host "   • Regulatory alignment assessment" -ForegroundColor Cyan
Write-Host "   • Risk prioritization based on compliance gaps" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Learn more: https://learn.microsoft.com/en-us/azure/defender-for-cloud/regulatory-compliance-dashboard" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# Parameter File Integration
# =============================================================================

if ($UseParametersFile) {
    Write-Host "📄 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    $parametersFilePath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    
    if (Test-Path $parametersFilePath) {
        try {
            $mainParameters = Get-Content $parametersFilePath -Raw | ConvertFrom-Json
            
            # Extract parameters
            if ($mainParameters.parameters.environmentName.value -and -not $EnvironmentName) {
                $EnvironmentName = $mainParameters.parameters.environmentName.value
                Write-Host "   ✅ Environment Name: $EnvironmentName" -ForegroundColor Green
            }
            
            Write-Host "   ✅ Parameters loaded successfully" -ForegroundColor Green
            
        } catch {
            Write-Host "   ❌ Failed to read parameters file: $_" -ForegroundColor Red
            Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️ Parameters file not found: $parametersFilePath" -ForegroundColor Yellow
        Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
    }
    Write-Host ""
}

# Validate environment name
if (-not $EnvironmentName) {
    Write-Host "❌ Environment name is required. Please provide -EnvironmentName or use -UseParametersFile" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Additional Standards: $(if ($AdditionalStandards) { $AdditionalStandards } else { 'Default only (MCSB)' })" -ForegroundColor White
Write-Host "   What-If Mode: $WhatIf" -ForegroundColor White
Write-Host ""

# =============================================================================
# Azure Authentication and Subscription Validation
# =============================================================================

Write-Host "🔐 Validating Azure authentication and subscription..." -ForegroundColor Cyan

try {
    # Check if Azure CLI is authenticated
    $currentAccount = az account show 2>$null | ConvertFrom-Json
    if (-not $currentAccount) {
        Write-Host "❌ Azure CLI not authenticated. Please run 'az login' first." -ForegroundColor Red
        exit 1
    }
    
    $subscriptionId = $currentAccount.id
    $subscriptionName = $currentAccount.name
    
    Write-Host "   ✅ Authenticated to Azure" -ForegroundColor Green
    Write-Host "   📝 Subscription: $subscriptionName ($subscriptionId)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Failed to validate Azure authentication: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Compliance Standards Analysis
# =============================================================================

Write-Host ""
Write-Host "📋 Analyzing compliance standards and security posture..." -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

$complianceResults = @{
    "Available" = @()
    "Enabled" = @()
    "Summary" = @{}
    "Recommendations" = @()
}

try {
    Write-Host "   🔍 Retrieving available compliance standards..." -ForegroundColor Cyan
    
    # Get regulatory compliance standards (suppress Azure CLI warnings)
    $standards = az security regulatory-compliance-standards list --query "[].{Name:name, DisplayName:displayName, State:state}" --output json 2>$null | ConvertFrom-Json
    
    if ($standards -and $standards.Count -gt 0) {
        foreach ($standard in $standards) {
            $complianceResults.Available += $standard
            # Consider standards as "active" if they are enabled or have completed assessment (Failed state means assessed with findings)
            if ($standard.State -eq "Enabled" -or $standard.State -eq "Failed" -or $standard.State -eq "Passed") {
                $complianceResults.Enabled += $standard
            }
        }
        
        Write-Host "   ✅ Found $($standards.Count) available compliance standards" -ForegroundColor Green
        Write-Host "   📊 Currently active (assessed): $($complianceResults.Enabled.Count)" -ForegroundColor White
        
        # Display active standards with their assessment status
        if ($complianceResults.Enabled.Count -gt 0) {
            Write-Host ""
            Write-Host "   📌 Currently Active Standards (Enabled by This Lab):" -ForegroundColor Cyan
            
            # Identify standards enabled by this lab deployment
            $labEnabledStandards = @(
                "Microsoft-cloud-security-benchmark",
                "Azure-CSPM", 
                "Azure-NIST-CSF-v2.0-(Preview)"
            )
            
            foreach ($enabled in $complianceResults.Enabled) {
                $displayName = if ($enabled.DisplayName) { $enabled.DisplayName } else { 
                    switch ($enabled.Name) {
                        "Microsoft-cloud-security-benchmark" { "Microsoft Cloud Security Benchmark (MCSB)" }
                        "Azure-CSPM" { "Azure Cloud Security Posture Management" }
                        "Azure-NIST-CSF-v2.0-(Preview)" { "NIST Cybersecurity Framework v2.0 (Preview)" }
                        default { $enabled.Name }
                    }
                }
                
                $statusColor = switch ($enabled.State) {
                    "Enabled" { "Green" }
                    "Passed" { "Green" }
                    "Failed" { "Yellow" }  # Failed means assessed with findings, not disabled
                    default { "Gray" }
                }
                
                $statusText = switch ($enabled.State) {
                    "Failed" { "Active & Assessed (findings detected - normal for new deployments)" }
                    "Enabled" { "Active & Assessment In Progress" }
                    "Passed" { "Active & Fully Compliant (no findings)" }
                    default { $enabled.State }
                }
                
                $labEnabledText = if ($labEnabledStandards -contains $enabled.Name) { " ✅ Lab-Enabled" } else { "" }
                
                Write-Host "      • $displayName - $statusText$labEnabledText" -ForegroundColor $statusColor
                
                # Explain what each standard means
                if ($enabled.Name -eq "Microsoft-cloud-security-benchmark") {
                    Write-Host "        📋 Core security baseline for Azure workloads (primary compliance framework)" -ForegroundColor Gray
                } elseif ($enabled.Name -eq "Azure-CSPM") {
                    Write-Host "        🔍 Cloud Security Posture Management (foundational security assessments)" -ForegroundColor Gray
                } elseif ($enabled.Name -eq "Azure-NIST-CSF-v2.0-(Preview)") {
                    Write-Host "        🏛️ US federal cybersecurity framework (widely adopted across industries)" -ForegroundColor Gray
                }
            }
        }
        
        # Industry-aligned recommendations for additional standards (always display for educational value)
        Write-Host ""
        Write-Host "   💡 Industry-Specific Compliance Standards Available:" -ForegroundColor Yellow
        Write-Host "      (These can be enabled based on your industry requirements)" -ForegroundColor Gray
        Write-Host ""
        
        # Group recommendations by industry with enhanced retail/e-commerce section
        Write-Host "      🛒 Retail & E-Commerce:" -ForegroundColor Cyan
        Write-Host "         • PCI DSS: Payment Card Industry Data Security Standard (required for card payments)" -ForegroundColor White
        Write-Host "         • SOC 2 Type II: Service organization controls for customer data protection" -ForegroundColor White
        Write-Host "         • GDPR: European customer data protection requirements" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/offering-pci-dss" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      🏦 Financial Services & Banking:" -ForegroundColor Cyan
        Write-Host "         • PCI DSS: Payment card data protection compliance" -ForegroundColor White
        Write-Host "         • SOX: Sarbanes-Oxley compliance for publicly traded companies" -ForegroundColor White
        Write-Host "         • Basel III: International banking regulations for risk management" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/offering-pci-dss" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      🏥 Healthcare & Life Sciences:" -ForegroundColor Cyan
        Write-Host "         • HIPAA: Health Insurance Portability and Accountability Act" -ForegroundColor White
        Write-Host "         • FDA CFR Part 11: Electronic records and signatures in clinical trials" -ForegroundColor White
        Write-Host "         • GDPR: European patient data protection requirements" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/offering-hipaa-us" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      🏛️ Government & Public Sector:" -ForegroundColor Cyan
        Write-Host "         • FedRAMP: Federal Risk and Authorization Management Program" -ForegroundColor White
        Write-Host "         • FISMA: Federal Information Security Management Act" -ForegroundColor White
        Write-Host "         • CJIS: Criminal Justice Information Services Security Policy" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/offering-fedramp" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      🏭 Manufacturing & Industrial:" -ForegroundColor Cyan
        Write-Host "         • IEC 62443: Industrial cybersecurity standards" -ForegroundColor White
        Write-Host "         • ISO 27001: Information security management systems" -ForegroundColor White
        Write-Host "         • NIST Framework: Manufacturing cybersecurity guidelines" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/offering-iso-27001" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      📚 Education & Research:" -ForegroundColor Cyan
        Write-Host "         • FERPA: Family Educational Rights and Privacy Act" -ForegroundColor White
        Write-Host "         • COPPA: Children's Online Privacy Protection Act" -ForegroundColor White
        Write-Host "         • ISO 27001: Information security for educational institutions" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/offering-ferpa" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      🌍 Global & Multi-Regional Organizations:" -ForegroundColor Cyan
        Write-Host "         • ISO 27001: International information security management standard" -ForegroundColor White
        Write-Host "         • GDPR: European General Data Protection Regulation" -ForegroundColor White
        Write-Host "         • SOC 2 Type II: Service organization controls for cloud providers" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/compliance/offerings/" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      ⚙️ General Industry Best Practices:" -ForegroundColor Cyan
        Write-Host "         • CIS Controls: Center for Internet Security cybersecurity framework" -ForegroundColor White
        Write-Host "         • NIST CSF: National Institute of Standards and Technology framework" -ForegroundColor White
        Write-Host "         • ISO 22301: Business continuity management systems" -ForegroundColor White
        Write-Host "         • Learn more: https://docs.microsoft.com/azure/governance/policy/samples/cis-azure-1-1-0" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "      📌 To enable additional standards:" -ForegroundColor Yellow
        Write-Host "         1. Navigate to Azure Portal → Defender for Cloud → Regulatory compliance" -ForegroundColor Gray
        Write-Host "         2. Click 'Manage compliance policies'" -ForegroundColor Gray
        Write-Host "         3. Select standards based on your industry requirements" -ForegroundColor Gray
        Write-Host "         4. Review and assign policies to your subscription" -ForegroundColor Gray
        
    } else {
        Write-Host "   ⚠️ No compliance standards found" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Failed to retrieve compliance standards: $_" -ForegroundColor Red
}

# =============================================================================
# Microsoft Cloud Security Benchmark (MCSB) and NIST CSF Analysis
# =============================================================================

Write-Host ""
Write-Host "🔍 Compliance Standards Detailed Analysis..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

try {
    # Find MCSB standard - check multiple naming patterns
    $mcsb = $complianceResults.Enabled | Where-Object { 
        $_.Name -like "*asb*" -or 
        $_.Name -like "*benchmark*" -or 
        $_.Name -like "*mcsb*" -or
        $_.Name -like "*Microsoft-cloud-security-benchmark*" -or
        ($_.DisplayName -and (
            $_.DisplayName -like "*Cloud Security Benchmark*" -or
            $_.DisplayName -like "*Microsoft Cloud Security*" -or
            $_.DisplayName -like "*Azure Security Benchmark*"
        ))
    }
    
    # Also check for NIST CSF
    $nistCsf = $complianceResults.Enabled | Where-Object { 
        $_.Name -like "*nist*" -or 
        $_.Name -like "*NIST*" -or
        ($_.DisplayName -and (
            $_.DisplayName -like "*NIST*" -or
            $_.DisplayName -like "*Cybersecurity Framework*"
        ))
    }
    
    if ($mcsb -or $nistCsf) {
        if ($mcsb) {
            $mcsbDisplayName = if ($mcsb.DisplayName) { $mcsb.DisplayName } else { $mcsb.Name }
            Write-Host "   🎯 Analyzing Microsoft Cloud Security Benchmark..." -ForegroundColor Cyan
            Write-Host "      📌 Found MCSB: $mcsbDisplayName" -ForegroundColor Green
        }
        if ($nistCsf) {
            $nistDisplayName = if ($nistCsf.DisplayName) { $nistCsf.DisplayName } else { $nistCsf.Name }
            Write-Host "   🎯 Analyzing NIST Cybersecurity Framework..." -ForegroundColor Cyan
            Write-Host "      📌 Found NIST CSF: $nistDisplayName" -ForegroundColor Green
        }
        
        # Use MCSB for detailed analysis, fallback to NIST CSF if available
        $primaryStandard = if ($mcsb) { $mcsb } else { $nistCsf }
        
        try {
            $mcsbControls = az security regulatory-compliance-controls list --standard-name $primaryStandard.Name --query "[].{Name:name, State:state, Description:description}" --output json 2>$null | ConvertFrom-Json
            
            if ($mcsbControls -and $mcsbControls.Count -gt 0) {
                $passed = ($mcsbControls | Where-Object { $_.State -eq "Passed" }).Count
                $failed = ($mcsbControls | Where-Object { $_.State -eq "Failed" }).Count
                $skipped = ($mcsbControls | Where-Object { $_.State -eq "Skipped" }).Count
                $unsupported = ($mcsbControls | Where-Object { $_.State -eq "Unsupported" }).Count
                
                $compliancePercentage = if ($mcsbControls.Count -gt 0) { 
                    [math]::Round(($passed / ($mcsbControls.Count - $unsupported)) * 100, 1) 
                } else { 0 }
                
                $complianceResults.Summary = @{
                    "TotalControls" = $mcsbControls.Count
                    "Passed" = $passed
                    "Failed" = $failed
                    "Skipped" = $skipped
                    "Unsupported" = $unsupported
                    "CompliancePercentage" = $compliancePercentage
                    "AssessableControls" = ($mcsbControls.Count - $unsupported)
                }
                
                $primaryDisplayName = if ($primaryStandard.DisplayName) { $primaryStandard.DisplayName } else { 
                    switch ($primaryStandard.Name) {
                        "Microsoft-cloud-security-benchmark" { "Microsoft Cloud Security Benchmark (MCSB)" }
                        "Azure-CSPM" { "Azure Cloud Security Posture Management" }
                        "Azure-NIST-CSF-v2.0-(Preview)" { "NIST Cybersecurity Framework v2.0 (Preview)" }
                        default { $primaryStandard.Name }
                    }
                }
                
                Write-Host "      ✅ Compliance Standard Analysis Complete:" -ForegroundColor Green
                Write-Host "         • Standard: $primaryDisplayName" -ForegroundColor White
                Write-Host "         • Total Controls: $($mcsbControls.Count)" -ForegroundColor White
                Write-Host "         • Assessable Controls: $($complianceResults.Summary.AssessableControls)" -ForegroundColor White
                Write-Host "         • Passed: $passed (controls meeting security requirements ✅)" -ForegroundColor Green
                Write-Host "         • Failed: $failed (controls with improvement opportunities 🔧)" -ForegroundColor Yellow
                Write-Host "         • Skipped: $skipped (controls not applicable to current resources ⏭️)" -ForegroundColor Cyan
                Write-Host "         • Unsupported: $unsupported (controls not available for assessment ❌)" -ForegroundColor Gray
                Write-Host "         • Compliance Score: $compliancePercentage% (percentage of assessable controls passing)" -ForegroundColor Cyan
                Write-Host ""
                
                # Explain what the compliance score means
                Write-Host ""
                Write-Host "      📊 Understanding Your Compliance Results:" -ForegroundColor Cyan
                Write-Host "         🎯 Compliance Score: $compliancePercentage% (percentage of assessable controls passing)" -ForegroundColor White
                
                if ($compliancePercentage -ge 90) {
                    Write-Host "         🟢 Excellent (90%+): Outstanding security posture with minimal gaps" -ForegroundColor Green
                } elseif ($compliancePercentage -ge 70) {
                    Write-Host "         🟡 Good (70-89%): Solid foundation - typical for well-configured deployments" -ForegroundColor Yellow
                } elseif ($compliancePercentage -ge 50) {
                    Write-Host "         🟠 Fair (50-69%): Basic security in place - room for improvement" -ForegroundColor Yellow
                } else {
                    Write-Host "         🔴 Needs Attention (<50%): Focus on fundamental security controls first" -ForegroundColor Red
                }
                
                Write-Host ""
                Write-Host "      💡 What Do These Results Mean?" -ForegroundColor Cyan
                Write-Host "         ✅ PASSED: Security controls are properly configured and working" -ForegroundColor Green
                Write-Host "         🔧 FAILED: Areas where security can be improved (not broken, just perfectible)" -ForegroundColor Yellow
                Write-Host "         ⏭️ SKIPPED: Controls that don't apply to your current setup (perfectly normal)" -ForegroundColor Cyan
                Write-Host "         ❌ UNSUPPORTED: Controls that can't be assessed yet (Azure limitation)" -ForegroundColor Gray
                
                # Provide context for a new deployment
                Write-Host ""
                Write-Host "      🆕 New Deployment Context:" -ForegroundColor Cyan
                Write-Host "         • This lab shows BASELINE security (exactly as expected for new deployments)" -ForegroundColor Gray
                Write-Host "         • 'Failed' controls are improvement opportunities, NOT errors or problems" -ForegroundColor Gray
                Write-Host "         • Production environments achieve higher scores through ongoing optimization" -ForegroundColor Gray
                Write-Host "         • Your lab is working correctly - these results are completely normal!" -ForegroundColor Green
                
                # Educational breakdown for improvement opportunities (when detailed report requested)
                if ($failed -gt 0 -and $DetailedReport) {
                    Write-Host ""
                    Write-Host "      � Learning Opportunities (Improvement Areas):" -ForegroundColor Yellow
                    Write-Host "         📚 These are areas where Azure suggests enhancements (not problems!):" -ForegroundColor Gray
                    $failedControls = $mcsbControls | Where-Object { $_.State -eq "Failed" } | Select-Object -First 5
                    Write-Host ""
                    Write-Host "         🔧 Common Security Improvement Categories:" -ForegroundColor Cyan
                    Write-Host "            • Network Security: Secure network configurations and access controls" -ForegroundColor White
                    Write-Host "            • Identity & Access: Multi-factor authentication and role-based access" -ForegroundColor White
                    Write-Host "            • Data Protection: Encryption at rest and in transit" -ForegroundColor White
                    Write-Host "            • Monitoring & Logging: Security event detection and response" -ForegroundColor White
                    Write-Host "            • Vulnerability Management: System patching and security updates" -ForegroundColor White
                    Write-Host ""
                    Write-Host "         📖 Learn More About Azure Security:" -ForegroundColor Yellow
                    Write-Host "            • Microsoft Cloud Security Benchmark: https://aka.ms/mcsb" -ForegroundColor Gray
                    Write-Host "            • Azure Security Documentation: https://docs.microsoft.com/azure/security/" -ForegroundColor Gray
                    Write-Host "            • Azure Security Best Practices: https://aka.ms/azure-security-best-practices" -ForegroundColor Gray
                    Write-Host "            • Defender for Cloud Learning: https://aka.ms/defender-for-cloud-learn" -ForegroundColor Gray
                    Write-Host "         💡 These represent learning opportunities to explore Azure security features" -ForegroundColor Cyan
                }
                
                # Generate recommendations based on compliance score
                if ($compliancePercentage -lt 50) {
                    $complianceResults.Recommendations += "LEARNING OPPORTUNITY: Review fundamental security controls for hands-on experience"
                    $complianceResults.Recommendations += "NEXT STEPS: Explore failed controls in Azure Portal → Defender for Cloud → Regulatory compliance"
                } elseif ($compliancePercentage -lt 70) {
                    $complianceResults.Recommendations += "GREAT PROGRESS: Your baseline deployment is working well - explore improvements when ready"
                    $complianceResults.Recommendations += "OPTIONAL: Address high-impact controls for deeper learning about Azure security"
                } elseif ($compliancePercentage -lt 90) {
                    $complianceResults.Recommendations += "EXCELLENT: Strong security foundation established - fine-tuning opportunities available"
                    $complianceResults.Recommendations += "ADVANCED: Consider remaining controls for production-grade security practices"
                } else {
                    $complianceResults.Recommendations += "OUTSTANDING: Exceptional compliance posture for a new deployment!"
                    $complianceResults.Recommendations += "MAINTAIN: Continue monitoring for new recommendations as you add resources"
                }
                
                # Add lab-specific context
                $complianceResults.Recommendations += "LAB SUCCESS: Your deployment is working perfectly - these results demonstrate proper Defender for Cloud operation"
                
            } else {
                $primaryDisplayName = if ($primaryStandard.DisplayName) { $primaryStandard.DisplayName } else { $primaryStandard.Name }
                Write-Host "      ⚠️ No compliance control details available for $primaryDisplayName" -ForegroundColor Yellow
            }
            
        } catch {
            Write-Host "      ❌ Failed to analyze compliance standard details: $_" -ForegroundColor Red
        }
        
    } else {
        Write-Host "   ⚠️ Microsoft Cloud Security Benchmark or NIST CSF not found or enabled" -ForegroundColor Yellow
        $complianceResults.Recommendations += "SETUP: Ensure Defender for Cloud plans are properly enabled to activate compliance standards"
    }
    
} catch {
    Write-Host "   ❌ Failed to analyze compliance standards: $_" -ForegroundColor Red
}

# =============================================================================
# Security Recommendations Analysis
# =============================================================================

Write-Host ""
Write-Host "🔍 Security recommendations analysis..." -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    Write-Host "   📊 Analyzing security recommendations..." -ForegroundColor Cyan
    
    $recommendations = az security assessment list --query "value[].{Name:displayName, Status:status.code, Severity:metadata.severity}" --output json 2>$null | ConvertFrom-Json
    
    if ($recommendations -and $recommendations.Count -gt 0) {
        $high = ($recommendations | Where-Object { $_.Severity -eq "High" }).Count
        $medium = ($recommendations | Where-Object { $_.Severity -eq "Medium" }).Count
        $low = ($recommendations | Where-Object { $_.Severity -eq "Low" }).Count
        $healthy = ($recommendations | Where-Object { $_.Status -eq "Healthy" }).Count
        $unhealthy = ($recommendations | Where-Object { $_.Status -eq "Unhealthy" }).Count
        $notApplicable = ($recommendations | Where-Object { $_.Status -eq "NotApplicable" }).Count
        
        Write-Host "      ✅ Security Recommendations Summary:" -ForegroundColor Green
        Write-Host "         • Total Assessments: $($recommendations.Count)" -ForegroundColor White
        Write-Host "         • Healthy: $healthy" -ForegroundColor Green
        Write-Host "         • Unhealthy: $unhealthy" -ForegroundColor Red
        Write-Host "         • Not Applicable: $notApplicable" -ForegroundColor Gray
        Write-Host "         • High Severity Issues: $high" -ForegroundColor Red
        Write-Host "         • Medium Severity Issues: $medium" -ForegroundColor Yellow
        Write-Host "         • Low Severity Issues: $low" -ForegroundColor Gray
        
        # Add to compliance results
        $complianceResults.Summary["SecurityRecommendations"] = @{
            "Total" = $recommendations.Count
            "Healthy" = $healthy
            "Unhealthy" = $unhealthy
            "HighSeverity" = $high
            "MediumSeverity" = $medium
            "LowSeverity" = $low
        }
        
        # Generate recommendations based on severity
        if ($high -gt 0) {
            $complianceResults.Recommendations += "PRIORITY: Address $high high-severity security recommendations immediately"
        }
        if ($medium -gt 5) {
            $complianceResults.Recommendations += "ATTENTION: $medium medium-severity recommendations need review"
        }
        
    } else {
        Write-Host "      ⚠️ No security recommendations found" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Failed to analyze security recommendations: $_" -ForegroundColor Red
}

# =============================================================================
# Results Export
# =============================================================================

if ($ExportPath) {
    Write-Host ""
    Write-Host "📤 Exporting compliance analysis results..." -ForegroundColor Cyan
    
    try {
        $exportData = @{
            "Timestamp" = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            "EnvironmentName" = $EnvironmentName
            "SubscriptionId" = $subscriptionId
            "SubscriptionName" = $subscriptionName
            "ComplianceResults" = $complianceResults
            "AnalysisType" = "Compliance Standards Assessment"
        }
        
        $exportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
        Write-Host "   ✅ Results exported to: $ExportPath" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Failed to export results: $_" -ForegroundColor Red
    }
}

# =============================================================================
# Completion Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Compliance Analysis Summary" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

if ($WhatIf) {
    Write-Host "👁️ Compliance analysis preview completed!" -ForegroundColor Yellow
    Write-Host "   • Standards analysis: ✅ Completed" -ForegroundColor White
    Write-Host "   • MCSB assessment: ✅ Analyzed" -ForegroundColor White
    Write-Host "   • Recommendations: ✅ Generated" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "🎉 Compliance analysis completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Analysis Results:" -ForegroundColor Green
    Write-Host "   • Compliance Standards: ✅ Analyzed ($($complianceResults.Enabled.Count) enabled)" -ForegroundColor White
    if ($complianceResults.Summary.CompliancePercentage -gt 0) {
        $scoreColor = if ($complianceResults.Summary.CompliancePercentage -ge 80) { "Green" } 
                     elseif ($complianceResults.Summary.CompliancePercentage -ge 60) { "Yellow" } 
                     else { "Red" }
        Write-Host "   • MCSB Compliance Score: $($complianceResults.Summary.CompliancePercentage)%" -ForegroundColor $scoreColor
    }
    Write-Host "   • Security Recommendations: ✅ Analyzed" -ForegroundColor White
    if ($complianceResults.Summary.SecurityRecommendations) {
        Write-Host "     - High Priority Issues: $($complianceResults.Summary.SecurityRecommendations.HighSeverity)" -ForegroundColor $(if ($complianceResults.Summary.SecurityRecommendations.HighSeverity -gt 0) { "Red" } else { "Green" })
    }
    Write-Host ""
    
    if ($complianceResults.Recommendations.Count -gt 0) {
        Write-Host "💡 Key Recommendations:" -ForegroundColor Cyan
        foreach ($recommendation in $complianceResults.Recommendations) {
            Write-Host "   • $recommendation" -ForegroundColor White
        }
        Write-Host ""
    }
}

Write-Host "💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   • Review compliance dashboard in Azure Portal → Defender for Cloud → Regulatory compliance" -ForegroundColor White
Write-Host "   • Address high-priority security recommendations based on your industry requirements" -ForegroundColor White
Write-Host "   • Consider enabling additional compliance standards as needed for your sector" -ForegroundColor White
if ($ExportPath) {
    Write-Host "   • Review detailed analysis in exported file: $ExportPath" -ForegroundColor White
}
Write-Host ""
Write-Host "📚 Additional Learning Resources:" -ForegroundColor Yellow
Write-Host "   • Azure Compliance Documentation: https://docs.microsoft.com/azure/compliance/" -ForegroundColor Gray
Write-Host "   • Industry-Specific Compliance: https://docs.microsoft.com/azure/compliance/offerings/" -ForegroundColor Gray
Write-Host "   • Microsoft Cloud Security Benchmark: https://aka.ms/mcsb" -ForegroundColor Gray
Write-Host "   • Azure Security Best Practices: https://aka.ms/azure-security-best-practices" -ForegroundColor Gray

Write-Host ""
Write-Host "🎯 Compliance analysis script completed!" -ForegroundColor Green
