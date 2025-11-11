# Generate-NegativeTrainingSamples.ps1
# Generates 200 diverse business documents (non-financial) for trainable classifier negative training samples

# Prompt for SharePoint site URL
$siteUrl = Read-Host "Enter your SharePoint site URL (e.g., https://[YourTenant].sharepoint.com/sites/[YourSiteName])"

# Extract tenant from URL
if ($siteUrl -match '//([^\.]+)\.sharepoint\.com') {
    $tenant = "$($matches[1]).onmicrosoft.com"
    Write-Host "   Detected tenant: $tenant" -ForegroundColor Gray
} else {
    $tenant = Read-Host "Enter your tenant (e.g., contoso.onmicrosoft.com)"
}

# Check for Entra ID App Registration
Write-Host "`nChecking Entra ID App Registration..." -ForegroundColor Cyan

$appName = "PnP PowerShell Interactive"
$appClientId = $null

# Check if environment variable already set (from previous session)
if ($env:ENTRAID_APP_ID) {
    Write-Host "   Environment variable already set: $env:ENTRAID_APP_ID" -ForegroundColor Green
    $appClientId = $env:ENTRAID_APP_ID
} else {
    Write-Host "   No app registration found (environment variable not set)" -ForegroundColor Yellow
    Write-Host "   You need to register an Entra ID app for PnP PowerShell" -ForegroundColor Yellow
    Write-Host ""
    
    # Prompt user for registration method
    Write-Host "   Choose app registration method:" -ForegroundColor Cyan
    Write-Host "   1. Automatic (PowerShell 7.4+ required, uses PnP cmdlet)" -ForegroundColor White
    Write-Host "   2. Manual (Works with ALL PowerShell versions, use Azure Portal)" -ForegroundColor White
    Write-Host "   3. Skip (I already have a Client ID)" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "   Enter choice (1, 2, or 3)"
    
    switch ($choice) {
        "1" {
            # Automatic registration
            Write-Host ""
            Write-Host "   Attempting automatic app registration..." -ForegroundColor Cyan
            Write-Host "   This requires PowerShell 7.4+ and will open a browser for authentication" -ForegroundColor Gray
            Write-Host ""
            
            try {
                Register-PnPEntraIDAppForInteractiveLogin -ApplicationName $appName -Tenant $tenant -ErrorAction Stop
                
                Write-Host ""
                Write-Host "   ✅ App registration created successfully!" -ForegroundColor Green
                Write-Host "   ⚠️ You need to copy the Client ID from the output above" -ForegroundColor Yellow
                Write-Host ""
                
                $appClientId = Read-Host "   Enter the Client ID (Application ID) from the output above"
                
            } catch {
                Write-Host ""
                Write-Host "   ❌ Automatic registration failed: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "   This likely means your PowerShell version is older than 7.4" -ForegroundColor Yellow
                Write-Host "   Falling back to manual registration instructions..." -ForegroundColor Yellow
                Write-Host ""
                $choice = "2"
            }
        }
        "2" {
            # Manual registration instructions
            Write-Host ""
            Write-Host "   📋 Manual App Registration Steps:" -ForegroundColor Yellow
            Write-Host "   1. Go to https://portal.azure.com" -ForegroundColor White
            Write-Host "   2. Navigate: Entra ID -> App registrations -> + New registration" -ForegroundColor White
            Write-Host "   3. Name: $appName" -ForegroundColor White
            Write-Host "   4. Account type: Single tenant" -ForegroundColor White
            Write-Host "   5. Redirect URI: Public client/native -> http://localhost" -ForegroundColor White
            Write-Host "   6. Click Register, then COPY the Application (client) ID" -ForegroundColor White
            Write-Host "   7. Add API Permissions:" -ForegroundColor White
            Write-Host "      - SharePoint: AllSites.FullControl, User.ReadWrite.All (Delegated)" -ForegroundColor Gray
            Write-Host "      - Microsoft Graph: Group.ReadWrite.All, User.ReadWrite.All (Delegated)" -ForegroundColor Gray
            Write-Host "   8. Grant admin consent" -ForegroundColor White
            Write-Host "   9. Authentication -> Allow public client flows -> Yes" -ForegroundColor White
            Write-Host ""
            
            $appClientId = Read-Host "   Enter the Client ID (Application ID) from Azure Portal"
        }
        "3" {
            # User already has Client ID
            Write-Host ""
            $appClientId = Read-Host "   Enter your existing Client ID (Application ID)"
        }
        default {
            Write-Host ""
            Write-Host "   ❌ Invalid choice. Exiting..." -ForegroundColor Red
            exit 1
        }
    }
    
    # Validate Client ID format (GUID)
    if ($appClientId -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
        Write-Host ""
        Write-Host "   ❌ Invalid Client ID format. Expected GUID format: 12345678-1234-1234-1234-123456789012" -ForegroundColor Red
        Write-Host "   Exiting..." -ForegroundColor Red
        exit 1
    }
    
    # Save to environment variable for future sessions
    $env:ENTRAID_APP_ID = $appClientId
    Write-Host ""
    Write-Host "   ✅ Environment variable set: ENTRAID_APP_ID = $appClientId" -ForegroundColor Green
}

# Connect to SharePoint Online with authentication choice
Write-Host "`nConnecting to SharePoint Online..." -ForegroundColor Cyan
$authMethod = Read-Host "Authentication method? (1=Interactive Browser, 2=Device Code)"

try {
    if ($authMethod -eq "1") {
        # Interactive browser-based authentication (best for standalone PowerShell)
        Write-Host "   Opening browser for authentication..." -ForegroundColor Gray
        Connect-PnPOnline -Url $siteUrl -Interactive -ErrorAction Stop
    } else {
        # Device code flow (best for VS Code terminal, SSH, Cloud Shell)
        Write-Host "   Using device code authentication (no browser spawning required)." -ForegroundColor Gray
        Write-Host "   A code will be displayed below - it's automatically copied to your clipboard." -ForegroundColor Gray
        Write-Host "   Open https://microsoft.com/devicelogin in a browser and paste the code." -ForegroundColor Gray
        Write-Host ""
        Connect-PnPOnline -Url $siteUrl -DeviceLogin -Tenant $tenant -ErrorAction Stop
    }
    
    Write-Host "✅ Connected to SharePoint successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to connect: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Verify `$env:ENTRAID_APP_ID is set to YOUR app's Client ID" -ForegroundColor Gray
    Write-Host "      Current value: $env:ENTRAID_APP_ID" -ForegroundColor Gray
    Write-Host "   2. Verify you have permissions (Site Owner or Site Collection Admin)" -ForegroundColor Gray
    Write-Host "   3. Check the site URL is correct" -ForegroundColor Gray
    Write-Host "   4. Ensure admin consent was granted for the Entra ID app" -ForegroundColor Gray
    Write-Host "   5. Verify 'Allow public client flows' is set to Yes in app settings" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   See app registration instructions above if you haven't created the app yet." -ForegroundColor Gray
    exit 1
}

Write-Host "`n🔄 Generating 200 negative training samples (non-financial documents)..." -ForegroundColor Cyan

# Define document templates for various business document types
$documentTypes = @(
    @{Type="Meeting Minutes"; Template="MEETING MINUTES`n`nDate: {date}`nAttendees: {attendees}`n`nAgenda Items:`n- Project updates`n- Budget review`n- Action items`n`nDiscussion:`n{discussion}`n`nAction Items:`n- Follow up on pending tasks`n- Schedule next meeting"},
    @{Type="Marketing Plan"; Template="MARKETING STRATEGY`n`nCampaign: {campaign}`nTarget Audience: {audience}`n`nObjectives:`n- Increase brand awareness`n- Drive customer engagement`n- Generate qualified leads`n`nTactics:`n- Social media campaigns`n- Content marketing`n- Email marketing`n`nBudget: {budget}`nTimeline: {timeline}"},
    @{Type="HR Policy"; Template="HUMAN RESOURCES POLICY`n`nPolicy Name: {policy}`nEffective Date: {date}`n`nPurpose:`nThis policy establishes guidelines for {purpose}.`n`nScope:`nApplies to all employees, contractors, and temporary staff.`n`nProcedures:`n1. {procedure1}`n2. {procedure2}`n3. {procedure3}`n`nCompliance:`nEmployees must comply with this policy. Violations may result in disciplinary action."},
    @{Type="Technical Documentation"; Template="TECHNICAL SPECIFICATION`n`nSystem: {system}`nVersion: {version}`n`nArchitecture Overview:`n{architecture}`n`nComponents:`n- Frontend: {frontend}`n- Backend: {backend}`n- Database: {database}`n`nAPI Endpoints:`n- GET /api/{endpoint1}`n- POST /api/{endpoint2}`n`nSecurity Requirements:`n- Authentication: OAuth 2.0`n- Authorization: Role-based access control`n- Encryption: TLS 1.3"},
    @{Type="Project Status"; Template="PROJECT STATUS REPORT`n`nProject: {project}`nStatus: {status}`nCompletion: {completion}%`n`nMilestones:`n- {milestone1} - Completed`n- {milestone2} - In Progress`n- {milestone3} - Pending`n`nRisks and Issues:`n- {risk1}`n- {risk2}`n`nNext Steps:`n- {nextstep1}`n- {nextstep2}"},
    @{Type="Sales Proposal"; Template="SALES PROPOSAL`n`nClient: {client}`nSolution: {solution}`n`nExecutive Summary:`n{summary}`n`nProposed Solution:`n{solution_detail}`n`nPricing:`n- Base Package: {price1}`n- Premium Package: {price2}`n- Enterprise Package: {price3}`n`nImplementation Timeline:`n{timeline}`n`nTerms and Conditions:`n{terms}"}
)

# Generate 200 negative samples
1..200 | ForEach-Object {
    $docNumber = $_
    $docType = Get-Random -InputObject $documentTypes
    
    # Replace template placeholders with random data
    $content = $docType.Template
    $content = $content -replace '\{date\}', (Get-Date -Format 'yyyy-MM-dd')
    $content = $content -replace '\{attendees\}', ((1..(Get-Random -Minimum 3 -Maximum 8) | ForEach-Object { "Person $_" }) -join ', ')
    $content = $content -replace '\{discussion\}', "Discussion about $(Get-Random -InputObject @('strategy', 'operations', 'planning', 'improvements'))"
    $content = $content -replace '\{campaign\}', "Campaign $(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{audience\}', (Get-Random -InputObject @('Enterprise customers', 'Small businesses', 'Consumers', 'Partners'))
    $content = $content -replace '\{budget\}', "`$$((Get-Random -Minimum 10000 -Maximum 100000).ToString('N0'))"
    $content = $content -replace '\{timeline\}', "$(Get-Random -Minimum 3 -Maximum 12) months"
    $content = $content -replace '\{policy\}', (Get-Random -InputObject @('Remote Work', 'Time Off', 'Code of Conduct', 'Data Security'))
    $content = $content -replace '\{purpose\}', (Get-Random -InputObject @('employee conduct', 'work arrangements', 'leave management', 'security practices'))
    $content = $content -replace '\{procedure\d\}', "Procedure step $(Get-Random -Minimum 1 -Maximum 10)"
    $content = $content -replace '\{system\}', "System-$(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{version\}', "v$(Get-Random -Minimum 1 -Maximum 5).$(Get-Random -Minimum 0 -Maximum 9)"
    $content = $content -replace '\{architecture\}', "Cloud-based $(Get-Random -InputObject @('microservices', 'monolithic', 'serverless')) architecture"
    $content = $content -replace '\{frontend\}', (Get-Random -InputObject @('React', 'Angular', 'Vue.js'))
    $content = $content -replace '\{backend\}', (Get-Random -InputObject @('Node.js', '.NET Core', 'Python'))
    $content = $content -replace '\{database\}', (Get-Random -InputObject @('SQL Server', 'PostgreSQL', 'MongoDB'))
    $content = $content -replace '\{endpoint\d\}', "endpoint$(Get-Random -Minimum 1 -Maximum 99)"
    $content = $content -replace '\{project\}', "Project-$(Get-Random -Minimum 1000 -Maximum 9999)"
    $content = $content -replace '\{status\}', (Get-Random -InputObject @('On Track', 'At Risk', 'Delayed', 'Completed'))
    $content = $content -replace '\{completion\}', (Get-Random -Minimum 10 -Maximum 100)
    $content = $content -replace '\{milestone\d\}', "Milestone $(Get-Random -Minimum 1 -Maximum 10)"
    $content = $content -replace '\{risk\d\}', "Risk: $(Get-Random -InputObject @('Resource constraints', 'Technical challenges', 'Schedule delays'))"
    $content = $content -replace '\{nextstep\d\}', "Next step: $(Get-Random -InputObject @('Review requirements', 'Update timeline', 'Schedule meeting'))"
    $content = $content -replace '\{client\}', "Client-$(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{solution\}', (Get-Random -InputObject @('Cloud Migration', 'Digital Transformation', 'Security Enhancement'))
    $content = $content -replace '\{summary\}', "Comprehensive solution for business needs"
    $content = $content -replace '\{solution_detail\}', "Detailed implementation plan with milestones"
    $content = $content -replace '\{price\d\}', "`$$((Get-Random -Minimum 50000 -Maximum 500000).ToString('N0'))"
    $content = $content -replace '\{terms\}', "Standard terms and conditions apply"
    
    # Create and upload
    $fileName = "$($docType.Type -replace ' ', '_')_${docNumber}.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    Add-PnPFile -Path $tempPath -Folder "Classifier_Training/BusinessDocs_Negative" | Out-Null
    Remove-Item -Path $tempPath -Force
    
    if ($docNumber % 20 -eq 0) {
        Write-Host "   Created $docNumber negative samples..." -ForegroundColor Cyan
    }
}

Write-Host "`n✅ Created 200 negative training samples (non-financial documents)" -ForegroundColor Green
Write-Host "`n📊 Sample Details:" -ForegroundColor Cyan
Write-Host "   - Document types: Meeting Minutes, Marketing Plans, HR Policies, Technical Docs, Project Status, Sales Proposals" -ForegroundColor White
Write-Host "   - Content: Diverse business documents (NOT financial reports)" -ForegroundColor White
Write-Host "   - Count: 200 documents across 6 document types" -ForegroundColor White
Write-Host "   - Target location: Classifier_Training/BusinessDocs_Negative" -ForegroundColor White
Write-Host "   - Purpose: Trainable classifier negative samples (teach what financial reports are NOT)" -ForegroundColor White
