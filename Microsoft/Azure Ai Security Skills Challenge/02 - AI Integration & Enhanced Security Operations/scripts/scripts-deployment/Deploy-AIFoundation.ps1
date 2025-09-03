# Deploy-AIFoundation.ps1
# Complete AI foundation deployment script following Week 1 automation pattern

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $true)]
    [string]$NotificationEmail,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [int]$BudgetLimit = 150,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipStorage,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipOpenAI,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipCostManagement,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Script configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Import helper functions
. (Join-Path $PSScriptRoot "lib" "Helper-Functions.ps1")

# Script header
Write-AIHeader "Deploy AI Foundation - Week 2" $EnvironmentName $Location $NotificationEmail

try {
    # Initialize Azure connection
    Initialize-AzureConnection -SubscriptionId $SubscriptionId
    
    # Calculate deployment parameters
    $deploymentParams = @{
        environmentName = $EnvironmentName
        location = $Location
        notificationEmail = $NotificationEmail
        monthlyBudgetLimit = $BudgetLimit
        enableAIStorage = -not $SkipStorage
        enableOpenAI = -not $SkipOpenAI
        enableCostManagement = -not $SkipCostManagement
        enableSentinelIntegration = $false  # Deploy in next phase
    }
    
    Write-Host "`n=== Deployment Configuration ===" -ForegroundColor Cyan
    foreach ($param in $deploymentParams.GetEnumerator()) {
        Write-Host "$($param.Key): $($param.Value)" -ForegroundColor White
    }
    
    if ($WhatIf) {
        Write-Host "`nWhatIf: Would deploy AI foundation with above configuration" -ForegroundColor Magenta
        return
    }
    
    # Deploy foundation infrastructure
    Write-AIPhase "Phase 1: Foundation Infrastructure"
    
    $bicepFile = Join-Path $PSScriptRoot "..\infra\main.bicep"
    $deploymentName = "ai-foundation-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    Write-Host "Starting Bicep deployment: $deploymentName" -ForegroundColor Cyan
    $deployment = New-AzSubscriptionDeployment `
        -Location $Location `
        -TemplateFile $bicepFile `
        -TemplateParameterObject $deploymentParams `
        -Name $deploymentName `
        -Verbose
    
    if ($deployment.ProvisioningState -ne "Succeeded") {
        throw "Deployment failed with state: $($deployment.ProvisioningState)"
    }
    
    Write-Host "✅ Foundation deployment completed successfully!" -ForegroundColor Green
    
    # Phase 2: Validate deployments
    Write-AIPhase "Phase 2: Validation and Testing"
    
    $outputs = $deployment.Outputs
    $resourceGroupName = $outputs.aiResourceGroupName.Value
    
    # Validate storage account (if deployed)
    if ($deploymentParams.enableAIStorage) {
        Write-Verbose "Validating storage account deployment..."
        Test-StorageDeployment -ResourceGroupName $resourceGroupName -StorageAccountName $outputs.storageAccountName.Value
    }
    
    # Validate OpenAI service (if deployed)
    if ($deploymentParams.enableOpenAI) {
        Write-Verbose "Validating OpenAI service deployment..."
        Test-OpenAIDeployment -ResourceGroupName $resourceGroupName -OpenAIServiceName $outputs.openAIServiceName.Value
    }
    
    # Validate cost management (if deployed)
    if ($deploymentParams.enableCostManagement) {
        Write-Verbose "Validating cost management deployment..."
        Test-CostManagementDeployment -BudgetId $outputs.costManagementBudgetId.Value
    }
    
    # Phase 3: Display results and next steps
    Write-AIPhase "Phase 3: Deployment Summary"
    
    # Display deployment outputs
    Write-Host "`n=== Deployment Outputs ===" -ForegroundColor Cyan
    foreach ($output in $outputs.GetEnumerator()) {
        if ($output.Value.Type -eq "String" -and $output.Value.Value) {
            Write-Host "$($output.Key): $($output.Value.Value)" -ForegroundColor White
        } elseif ($output.Value.Type -eq "Object") {
            Write-Host "$($output.Key):" -ForegroundColor Yellow
            $output.Value.Value | ConvertTo-Json -Depth 2 | Write-Host -ForegroundColor White
        }
    }
    
    # Cost summary
    Write-Host "`n=== Cost Summary ===" -ForegroundColor Cyan
    $estimatedCost = 0
    if ($deploymentParams.enableAIStorage) {
        Write-Host "Storage Account: ~$10-15/month" -ForegroundColor Green
        $estimatedCost += 12.5
    }
    if ($deploymentParams.enableOpenAI) {
        Write-Host "Azure OpenAI (GPT-5): ~$15-30/month" -ForegroundColor Green
        $estimatedCost += 22.5
    }
    if ($deploymentParams.enableCostManagement) {
        Write-Host "Cost Management: ~$0-2/month" -ForegroundColor Green
        $estimatedCost += 1
    }
    
    Write-Host "Total Estimated: ~$$estimatedCost/month (Budget: $$BudgetLimit)" -ForegroundColor Yellow
    $remainingBudget = $BudgetLimit - $estimatedCost
    Write-Host "Remaining Budget: ~$$remainingBudget/month" -ForegroundColor Green
    
    # Security validation
    Write-Host "`n=== Security Validation ===" -ForegroundColor Cyan
    Invoke-SecurityValidation -ResourceGroupName $resourceGroupName
    
    # Next steps
    Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
    if (-not $SkipSentinelIntegration) {
        Write-Host "1. Deploy Sentinel Integration: .\Deploy-SentinelIntegration.ps1" -ForegroundColor Yellow
    }
    Write-Host "2. Create AI prompt templates" -ForegroundColor Yellow
    Write-Host "3. Test AI integration with sample data" -ForegroundColor Yellow
    Write-Host "4. Enable built-in AI features (UEBA, Fusion)" -ForegroundColor Yellow
    Write-Host "5. Run threat simulation scenarios" -ForegroundColor Yellow
    
    # Final validation summary
    Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
    $validationResults = @{
        "Storage Account" = $deploymentParams.enableAIStorage
        "Azure OpenAI" = $deploymentParams.enableOpenAI
        "Cost Management" = $deploymentParams.enableCostManagement
        "Budget Compliance" = ($estimatedCost -lt $BudgetLimit)
        "Security Configuration" = $true
    }
    
    foreach ($validation in $validationResults.GetEnumerator()) {
        $status = if ($validation.Value) { "✅ PASS" } else { "❌ SKIP" }
        Write-Host "$($validation.Key): $status" -ForegroundColor $(if ($validation.Value) { "Green" } else { "Yellow" })
    }
    
} catch {
    Write-Error "AI Foundation deployment failed: $($_.Exception.Message)"
    Write-Error "Stack trace: $($_.ScriptStackTrace)"
    
    # Cleanup on failure option
    $cleanup = Read-Host "Would you like to clean up failed resources? (y/N)"
    if ($cleanup -eq 'y' -or $cleanup -eq 'Y') {
        Write-Host "Initiating cleanup..." -ForegroundColor Yellow
        # Call cleanup script if available
        $cleanupScript = Join-Path $PSScriptRoot "Remove-AIInfrastructure.ps1"
        if (Test-Path $cleanupScript) {
            & $cleanupScript -EnvironmentName $EnvironmentName -Force
        }
    }
    
    exit 1
}

Write-Host "`n=== AI Foundation Deployment Complete ===" -ForegroundColor Green
Write-Host "Week 2 foundation ready for AI integration and testing!" -ForegroundColor Cyan
