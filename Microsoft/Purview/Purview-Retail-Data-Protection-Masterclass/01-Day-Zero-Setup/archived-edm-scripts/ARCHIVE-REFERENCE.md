# Archived EDM Scripts - Reference for IaC Development

**Archive Date**: December 31, 2025  
**Reason**: EDM workflow moved to Lab 02 (03-Classification-UI) using portal wizard approach

## 📋 Purpose of This Archive

These scripts contain valuable patterns and best practices for future Infrastructure-as-Code (IaC) lab development. While the EDM workflow has been simplified using the portal wizard in Lab 02, these scripts demonstrate:

- **PowerShell automation patterns** for Microsoft Purview
- **EDM Upload Agent integration** techniques
- **Security group management** via Microsoft Graph
- **Error handling and validation** patterns
- **User experience considerations** (progress indicators, troubleshooting guidance)

## 📁 Archived Scripts

| Script | Original Purpose | IaC Value |
|--------|------------------|-----------|
| **Initialize-EdmPrerequisites.ps1** | EDM agent setup, security group creation, user assignment | Graph API security group patterns, admin privilege checks |
| **Sync-EdmSchema.ps1** | Schema synchronization between local and cloud | EDM schema validation patterns, cloud sync techniques |
| **Upload-EdmData.ps1** | Data hashing and upload to Purview EDM Datastore | EDM Upload Agent integration, data processing workflows |
| **Test-EdmWorkflow.ps1** | End-to-end EDM workflow validation | Comprehensive testing patterns, validation workflows |

## 🔧 Key Patterns Worth Reusing

### 1. Microsoft Graph Security Group Management

**From Initialize-EdmPrerequisites.ps1:**

```powershell
# Connect with specific scopes
Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All", "Directory.Read.All"

# Create security group if not exists
$groupName = "EDM_DataUploaders"
$group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -ErrorAction SilentlyContinue

if (-not $group) {
    $group = New-MgGroup -BodyParameter @{
        DisplayName = $groupName
        MailEnabled = $false
        MailNickname = "EDM_DataUploaders"
        SecurityEnabled = $true
    }
}

# Add user to group with membership check
$isMember = Get-MgGroupMember -GroupId $group.Id -Filter "Id eq '$($user.Id)'"
if (-not $isMember) {
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
}
```

**IaC Applications:**
- Role-based access provisioning
- Automated group lifecycle management
- Permission prerequisite validation

### 2. Administrator Privilege Validation

**From Initialize-EdmPrerequisites.ps1:**

```powershell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: Administrator privileges required." -ForegroundColor Red
    Write-Host "   Please right-click PowerShell/VS Code and select 'Run as Administrator'." -ForegroundColor Yellow
    exit
}
```

**IaC Applications:**
- Agent installation prerequisites
- System-level configuration scripts
- Security-sensitive operations

### 3. EDM Upload Agent Integration

**From Upload-EdmData.ps1:**

```powershell
# Authorize with EDM Agent (interactive authentication)
& .\EdmUploadAgent.exe /Authorize

# Upload data with schema validation
& .\EdmUploadAgent.exe /UploadData `
    /DataStoreName $SchemaName `
    /DataFile $DataFile `
    /HashLocation $HashDir `
    /Schema $SchemaFile.FullName `
    /ColumnSeparator "," `
    /AllowedBadLinesPercentage 5
```

**IaC Applications:**
- External tool integration patterns
- Authentication flow handling
- Data processing pipelines

### 4. Schema Synchronization Patterns

**From Sync-EdmSchema.ps1:**

```powershell
# Download cloud schema for comparison
& .\EdmUploadAgent.exe /SaveSchema `
    /DataStoreName $SchemaName `
    /OutputDir $OutputDir

# Validate local schema matches cloud
$cloudSchemaPath = Join-Path $OutputDir "$SchemaName.xml"
if (Test-Path $cloudSchemaPath) {
    # Compare and validate
}
```

**IaC Applications:**
- Infrastructure drift detection
- Configuration validation
- Idempotent deployment patterns

### 5. Comprehensive Error Handling

**Pattern used across all scripts:**

```powershell
try {
    # Operation
    Write-Host "✅ Success message" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "`n🔍 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Specific guidance..." -ForegroundColor Cyan
    Write-Host "   2. Retry command..." -ForegroundColor White
    exit 1
}
```

**IaC Applications:**
- User-friendly error messages
- Actionable troubleshooting guidance
- Graceful failure handling

### 6. Progress Indication and User Experience

**Pattern used across all scripts:**

```powershell
Write-Host "🔍 Step 1: Validation..." -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host "   📋 Detail information..." -ForegroundColor Cyan
Write-Host "   ✅ Validation successful" -ForegroundColor Green

Write-Host "`n🚀 Step 2: Processing..." -ForegroundColor Green
# Consistent emoji usage, color coding, indentation
```

**IaC Applications:**
- Clear progress indicators
- Hierarchical information display
- Professional script output

## 🎯 Why These Scripts Were Archived

**Original Approach (Day Zero Setup):**
- Required manual EDM schema creation via PowerShell/Graph API
- Complex multi-script workflow (3-4 separate scripts)
- Manual security group management
- Schema synchronization complexity

**New Approach (Lab 02 Portal Wizard):**
- Portal wizard handles schema creation automatically
- Single upload script (`Upload-EdmData.ps1` in 03-Classification-UI)
- Automatic authentication via EDM Upload Agent
- Schema downloaded from cloud (wizard-created)

**Result**: Simplified user experience while maintaining technical accuracy

## 📚 Reference Documentation

**Microsoft Learn EDM Documentation:**
- [Create EDM-based SIT](https://learn.microsoft.com/en-us/purview/sit-create-edm-sit-unified-ux-workflow)
- [EDM Upload Agent Reference](https://learn.microsoft.com/en-us/purview/sit-get-started-exact-data-match-based-sits-overview)

**PowerShell Patterns:**
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/module/exchange/get-dlpedmschema)

## 🔄 Migration to IaC Labs

**Future Use Cases:**

1. **Automated EDM Deployment** - Bicep/ARM templates with PowerShell orchestration
2. **Security Group Provisioning** - Graph API automation for RBAC setup
3. **Agent Installation Automation** - Scripted prerequisite management
4. **Validation Framework** - End-to-end testing patterns from Test-EdmWorkflow.ps1

**Best Practices to Carry Forward:**

- ✅ User-facing scripts should handle authentication gracefully
- ✅ Provide clear progress indicators and troubleshooting guidance
- ✅ Validate prerequisites before attempting operations
- ✅ Use consistent color coding and emoji for visual hierarchy
- ✅ Include comprehensive error handling with actionable next steps

---

## 🤖 AI-Assisted Content Generation

This archive reference documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, preserving valuable automation patterns and best practices for future Infrastructure-as-Code lab development.

*AI tools were used to enhance productivity and ensure comprehensive documentation of archived scripts while maintaining technical accuracy and identifying reusable patterns for future development.*
