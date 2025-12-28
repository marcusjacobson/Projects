# Lab 06: Cleanup and Reset

This lab provides comprehensive procedures for safely decommissioning the Microsoft Purview Discovery Methods simulation environment. You'll systematically remove simulation resources, verify complete cleanup, and generate final project documentation.

## 📋 Overview

**Objective**: Safely remove all simulation resources while preserving important reports and documentation, then verify complete cleanup and generate final project summary.

**Duration**: 30-60 minutes

**Prerequisites**:

- Completed Labs 00-05 (or desire to remove partial implementation)
- Global Administrator or appropriate deletion permissions
- Backup of important reports and documentation
- Understanding of resources to be removed

## 🎯 Learning Objectives

By completing this lab, you will:

1. **Understand Safe Decommissioning**: Learn proper procedures for removing Azure resources
2. **Implement Systematic Cleanup**: Remove resources in proper dependency order
3. **Verify Complete Removal**: Validate all simulation resources are removed
4. **Preserve Important Data**: Archive reports and documentation before cleanup
5. **Generate Final Documentation**: Create comprehensive project summary

## ⚠️ Critical Safety Warnings

### Before You Begin

> **🚨 DESTRUCTIVE OPERATIONS**: This lab performs irreversible deletion of resources. Review carefully before proceeding.

**Important Considerations**:

- **No Undo**: Deleted resources cannot be recovered
- **Shared Resources**: Verify resources are not used by other projects
- **Production Separation**: Ensure you're working in lab/test environment only
- **Backup First**: Archive all important reports and documentation
- **Confirmation Required**: Scripts will prompt for confirmation before deletion

### What Will Be Removed

| Resource Type | Count | Impact |
|---------------|-------|--------|
| **DLP Policies/Rules** | Simulation policies | Policy enforcement removed |
| **SharePoint Sites** | 5 sites | All documents and metadata deleted |
| **Documents** | 1,000+ | Test data permanently removed |
| **Discovery Reports** | Lab 05 CSV files | Can be archived before deletion |
| **Reports** | Lab outputs | Can be archived before deletion |

### What Will Be Preserved

The cleanup scripts are designed to preserve the local project structure while removing cloud simulation resources.

#### Always Preserved (Both Scripts)

These items are **never removed** regardless of which script or flags you use:

| Item | Location | Description |
|------|----------|-------------|
| **PowerShell Scripts** | `*/scripts/` folders | All automation scripts preserved for reuse |
| **Documentation** | `*/README.md` files | All guides and instructions remain intact |
| **Shared Utilities** | `Shared-Utilities/` | Import modules and helper functions |
| **Style Guides** | `Style-Guides/` | Repository standards |
| **Configuration Template** | `global-config.json.template` | Default template for reset operations |

#### Conditionally Preserved

| Item | `Remove-SimulationResources.ps1` | `Reset-Environment.ps1` | How to Preserve |
|------|----------------------------------|-------------------------|-----------------|
| **Reports Directory** | ✅ Always preserved | ❌ Cleared by default | Use `-KeepReports` flag |
| **Logs Directory** | ✅ Always preserved | ⚠️ Files >30 days removed | Archive before reset |
| **global-config.json** | ✅ Preserved with values | 🔄 Reset to template defaults | Backup created automatically |

#### Preservation Summary by Script

**`Remove-SimulationResources.ps1`** (Standard Cleanup):

- ✅ Removes cloud resources only (DLP, Documents, Sites)
- ✅ Preserves all local files (reports, logs, config)
- ✅ Preserves your `global-config.json` settings
- 💡 Use this for cleanup between simulation runs

**`Reset-Environment.ps1`** (Full Reset):

- ✅ Removes cloud resources (calls Remove-SimulationResources.ps1)
- ❌ Clears Reports directory (unless `-KeepReports` specified)
- ⚠️ Removes log files older than 30 days
- 🔄 Resets `global-config.json` to template defaults (backup created)
- 💡 Use this for complete fresh start or project handoff

> **💡 Best Practice**: Run `Export-FinalDocumentation.ps1` before using `Reset-Environment.ps1` to archive important reports. The archive file itself is preserved.

## 🔧 Lab Workflow

### Step 1: Archive Reports and Documentation

**Before removing any resources**, archive important outputs:

```powershell
# Export final project documentation
.\scripts\Export-FinalDocumentation.ps1

# Verify archive creation
Get-ChildItem -Path "..\Reports\Purview-Simulation-Final-Documentation-*.zip"
```

**What this does**:

- Creates comprehensive final project summary
- Archives all reports from Labs 04-06
- Generates execution statistics and metrics
- Creates lessons learned documentation
- Packages everything into timestamped archive

**Expected output**:

- `Final-Project-Summary-YYYY-MM-DD.html` - Comprehensive project overview
- `Archived-Reports-YYYY-MM-DD.zip` - All reports and exports
- `Project-Metrics-YYYY-MM-DD.json` - Execution statistics
- `Lessons-Learned-YYYY-MM-DD.md` - Key takeaways and insights

### Step 2: Execute Cleanup

Run the cleanup script to remove simulation resources:

```powershell
# Remove all simulation resources (default behavior, requires confirmation)
.\scripts\Remove-SimulationResources.ps1

# Preview what would be removed without making changes
.\scripts\Remove-SimulationResources.ps1 -WhatIf

# Remove specific resource types only
.\scripts\Remove-SimulationResources.ps1 -ResourceType "DLPPolicies"
.\scripts\Remove-SimulationResources.ps1 -ResourceType "Documents"
.\scripts\Remove-SimulationResources.ps1 -ResourceType "Sites"

# Remove all without confirmation prompts (use with caution)
.\scripts\Remove-SimulationResources.ps1 -Force
```

**What this does**:

- Removes DLP policies and rules in proper dependency order
- Deletes test documents from SharePoint sites
- Removes SharePoint simulation sites
- Validates removal at each stage
- **Preserves**: All local files (reports, logs, config, scripts, documentation)

**Resource Removal Order**:

1. **DLP Rules** - Remove detection rules first
2. **DLP Policies** - Remove policies after rules
3. **Documents** - Delete test documents from sites
4. **SharePoint Sites** - Remove sites after content

> **💡 Note**: Classification jobs created in Lab 04 are managed through the Microsoft Purview portal and do not require script-based cleanup. They can be manually deleted via **Data Classification** > **Classifiers** > **On-demand classification** if desired.

**Expected output**:

- Confirmation prompts for each resource type
- Progress updates during removal
- Validation of successful deletion
- Summary of removed resources

### Step 3: Reset Environment to Clean State (Optional)

Use `Reset-Environment.ps1` for complete environment reset when you need a fresh start or are handing off the project.

> **⚠️ More Aggressive**: This script removes local files in addition to cloud resources. Use `Remove-SimulationResources.ps1` if you only want to remove cloud resources.

```powershell
# Preview reset actions
.\scripts\Reset-Environment.ps1 -WhatIf

# Reset with confirmation prompts (clears Reports directory)
.\scripts\Reset-Environment.ps1

# Reset but keep your reports
.\scripts\Reset-Environment.ps1 -KeepReports

# Reset without prompts (use with caution)
.\scripts\Reset-Environment.ps1 -Force
```

**What this does**:

- Removes all simulation resources (calls `Remove-SimulationResources.ps1`)
- Clears Reports directory (unless `-KeepReports` specified)
- Resets `global-config.json` to template defaults (backup created as `global-config.backup.json`)
- Removes log files older than 30 days
- Cleans up temporary files (*.tmp, *.temp, ~*)
- Validates environment is clean

**What is preserved**:

- ✅ All PowerShell scripts and documentation
- ✅ `global-config.json.template` (used for reset)
- ✅ `global-config.backup.json` (your previous settings)
- ✅ Reports directory (if `-KeepReports` specified)
- ✅ Recent log files (less than 30 days old)

**Expected output**:

- Complete removal of all simulation artifacts
- Clean project structure ready for future use
- Validation report confirming clean state
- Reset completion summary

### Step 4: Verify Cleanup

Run the verification script to ensure all resources have been removed:

```powershell
.\scripts\Test-CleanupCompletion.ps1
```

**What this does**:

- Verifies SharePoint sites are deleted
- Checks for remaining DLP policies
- Validates documents have been removed
- Generates final status report

**Expected output**:

- ✅ All SharePoint simulation sites removed
- ✅ No active DLP simulation policies found
- ✅ All simulation documents removed
- 📝 Final report generated: `Reports\Cleanup-Validation-Report.json`

#### Troubleshooting

#### Issue: DLP Policy Removal Fails

- Error: "Policy in use" or "Policy has rules"
- **Solution**:

  1. Remove all rules from the policy first
  2. Wait 5-10 minutes for rule deletion to propagate
  3. Retry policy removal

#### Issue: SharePoint Site Deletion Fails

- Error: "Site is locked" or "Access denied"
- **Solution**:

  1. Verify you have Site Collection Administrator permissions
  2. Check if site has a retention policy applied (remove if necessary)
  3. Use `Remove-SPOSite -Identity $url -NoWait`

#### Issue: Document Deletion Fails

- Error: "File is checked out" or "File locked"
- **Solution**:

  1. Check in all checked-out documents first
  2. Remove any preservation hold libraries
  3. Force delete using `-Force` parameter

#### Issue: Cleanup Verification Fails

- Verification reports orphaned resources
- **Solution**:

  1. Wait 15-30 minutes for deletion propagation
  2. Run `.\scripts\Reset-Environment.ps1` again
  3. Manually remove stubborn resources via portal

#### Issue: Report Archiving Fails

- Error: "Access denied" on archive creation
- **Solution**:

  1. Verify write permissions to Reports directory
  2. Ensure no files are open in other applications
  3. Check available disk space

#### Issue: Accidental Deletion

- Important non-simulation resources deleted
- **Solution**:

  1. **PREVENTION**: Always use `-WhatIf` first
  2. Restore from SharePoint Recycle Bin (93 days retention)
  3. Restore deleted DLP policies from backup (if available)

## 🤖 AI-Assisted Content Generation

This comprehensive cleanup and reset guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating safe decommissioning procedures, resource dependency management, and enterprise-grade cleanup verification standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of cleanup and reset procedures while maintaining safety standards and reflecting Microsoft 365 resource management best practices for simulation environment decommissioning.*
