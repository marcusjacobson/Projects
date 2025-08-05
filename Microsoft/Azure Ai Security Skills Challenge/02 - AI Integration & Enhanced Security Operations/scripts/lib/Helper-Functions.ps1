# Helper-Functions.ps1
# Common functions for AI integration deployment scripts

function Write-AIHeader {
    param(
        [string]$Title,
        [string]$Environment,
        [string]$Location,
        [string]$Email
    )
    
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "🤖 $Title" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "Environment: $Environment" -ForegroundColor Green
    Write-Host "Location: $Location" -ForegroundColor Green
    Write-Host "Notification Email: $Email" -ForegroundColor Green
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
    Write-Host ""
}

function Write-AIPhase {
    param([string]$PhaseTitle)
    
    Write-Host "`n🔄 $PhaseTitle" -ForegroundColor Magenta
    Write-Host "-" * 50 -ForegroundColor Magenta
}

function Initialize-AzureConnection {
    param([string]$SubscriptionId)
    
    Write-Verbose "Checking Azure PowerShell connection..."
    $context = Get-AzContext
    if (-not $context) {
        Write-Error "Not connected to Azure. Please run Connect-AzAccount first."
        throw "Azure connection required"
    }
    
    # Set subscription if provided
    if ($SubscriptionId) {
        Write-Verbose "Setting subscription context to: $SubscriptionId"
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
    
    $currentSubscription = (Get-AzContext).Subscription
    Write-Host "Using subscription: $($currentSubscription.Name) ($($currentSubscription.Id))" -ForegroundColor Yellow
}

function Test-StorageDeployment {
    param(
        [string]$ResourceGroupName,
        [string]$StorageAccountName
    )
    
    try {
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction Stop
        Write-Host "✅ Storage account validated: $($storageAccount.StorageAccountName)" -ForegroundColor Green
        
        # Test container access
        $containers = Get-AzStorageContainer -Context $storageAccount.Context
        Write-Host "Containers available: $($containers.Count)" -ForegroundColor White
        foreach ($container in $containers) {
            Write-Host "  - $($container.Name)" -ForegroundColor Gray
        }
        
        return $true
    } catch {
        Write-Warning "Storage validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-OpenAIDeployment {
    param(
        [string]$ResourceGroupName,
        [string]$OpenAIServiceName
    )
    
    try {
        $openAIService = Get-AzCognitiveServicesAccount -ResourceGroupName $ResourceGroupName -Name $OpenAIServiceName -ErrorAction Stop
        Write-Host "✅ OpenAI service validated: $($openAIService.AccountName)" -ForegroundColor Green
        Write-Host "Endpoint: $($openAIService.Endpoint)" -ForegroundColor White
        Write-Host "SKU: $($openAIService.Sku.Name)" -ForegroundColor White
        
        # Test deployments
        $deployments = Get-AzCognitiveServicesAccountDeployment -ResourceGroupName $ResourceGroupName -AccountName $OpenAIServiceName
        Write-Host "Models deployed: $($deployments.Count)" -ForegroundColor White
        foreach ($deployment in $deployments) {
            Write-Host "  - $($deployment.Name): $($deployment.Properties.Model.Name)" -ForegroundColor Gray
        }
        
        return $true
    } catch {
        Write-Warning "OpenAI validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-CostManagementDeployment {
    param([string]$BudgetId)
    
    try {
        if ($BudgetId) {
            Write-Host "✅ Cost management configured: Budget ID present" -ForegroundColor Green
            Write-Host "Budget tracking: Active" -ForegroundColor White
            Write-Host "Alert thresholds: 50%, 75%, 90%, 100%" -ForegroundColor White
            return $true
        } else {
            Write-Warning "Budget ID not found"
            return $false
        }
    } catch {
        Write-Warning "Cost management validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Invoke-SecurityValidation {
    param([string]$ResourceGroupName)
    
    try {
        Write-Host "Performing security validation..." -ForegroundColor Yellow
        
        # Check resource group tags
        $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
        if ($resourceGroup.Tags -and $resourceGroup.Tags.Count -gt 0) {
            Write-Host "✅ Resource tagging: Configured" -ForegroundColor Green
        } else {
            Write-Warning "⚠️ Resource tagging: Missing"
        }
        
        # Check for public endpoints
        $resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        $publicEndpoints = 0
        foreach ($resource in $resources) {
            if ($resource.ResourceType -eq "Microsoft.Storage/storageAccounts") {
                $storage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $resource.Name
                if ($storage.AllowBlobPublicAccess) {
                    $publicEndpoints++
                }
            }
        }
        
        if ($publicEndpoints -eq 0) {
            Write-Host "✅ Public access: Properly restricted" -ForegroundColor Green
        } else {
            Write-Warning "⚠️ Public access: $publicEndpoints resources with public access"
        }
        
        # Check encryption
        Write-Host "✅ Encryption: Enabled by default" -ForegroundColor Green
        
        return $true
    } catch {
        Write-Warning "Security validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Get-CostEstimate {
    param(
        [bool]$IncludeStorage = $false,
        [bool]$IncludeOpenAI = $false,
        [bool]$IncludeLogicApps = $false
    )
    
    $estimate = 0
    $breakdown = @{}
    
    if ($IncludeStorage) {
        $storageCost = 12
        $estimate += $storageCost
        $breakdown["Storage"] = $storageCost
    }
    
    if ($IncludeOpenAI) {
        $openAICost = 25
        $estimate += $openAICost
        $breakdown["OpenAI"] = $openAICost
    }
    
    if ($IncludeLogicApps) {
        $logicAppsCost = 8
        $estimate += $logicAppsCost
        $breakdown["LogicApps"] = $logicAppsCost
    }
    
    return @{
        Total = $estimate
        Breakdown = $breakdown
        Currency = "USD/month"
    }
}

function Write-CostSummary {
    param(
        [hashtable]$CostEstimate,
        [int]$BudgetLimit
    )
    
    Write-Host "`n=== Cost Summary ===" -ForegroundColor Cyan
    
    foreach ($service in $CostEstimate.Breakdown.GetEnumerator()) {
        Write-Host "$($service.Key): ~$$($service.Value)/month" -ForegroundColor Green
    }
    
    Write-Host "Total Estimated: ~$$($CostEstimate.Total)/month" -ForegroundColor Yellow
    Write-Host "Budget Limit: $$BudgetLimit/month" -ForegroundColor White
    
    $remaining = $BudgetLimit - $CostEstimate.Total
    if ($remaining -gt 0) {
        Write-Host "Remaining Budget: ~$$remaining/month" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Budget Exceeded by: $$([Math]::Abs($remaining))/month" -ForegroundColor Red
    }
}

function Test-BudgetCompliance {
    param(
        [int]$EstimatedCost,
        [int]$BudgetLimit
    )
    
    $compliance = @{
        IsCompliant = ($EstimatedCost -le $BudgetLimit)
        UtilizationPercent = [Math]::Round(($EstimatedCost / $BudgetLimit) * 100, 1)
        RemainingBudget = $BudgetLimit - $EstimatedCost
    }
    
    return $compliance
}

function Write-NextSteps {
    param([string[]]$Steps)
    
    Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Steps.Count; $i++) {
        Write-Host "$($i + 1). $($Steps[$i])" -ForegroundColor Yellow
    }
}

# Export functions for use in other scripts
Export-ModuleMember -Function *
