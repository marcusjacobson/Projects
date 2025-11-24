# Lab 06: Cleanup and Reset

This lab provides comprehensive procedures for safely decommissioning the Microsoft Purview Data Governance simulation environment. You'll systematically remove simulation resources, verify complete cleanup, and generate final project documentation.

## 📋 Overview

**Objective**: Safely remove all simulation resources while preserving important reports and documentation, then verify complete cleanup and generate final project summary.

**Duration**: 30-60 minutes

**Prerequisites**:
- Completed Labs 00-06 (or desire to remove partial implementation)
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
| **SharePoint Sites** | 5 sites | All documents and metadata deleted |
| **Documents** | 1,000+ | Test data permanently removed |
| **Discovery Reports** | Lab 05 CSV files | Can be archived before deletion |
| **Classification Jobs** | Historical | Job history cleared |
| **Reports** | Lab outputs | Can be archived before deletion |

### What Will Be Preserved

- **Global Configuration**: Project structure remains for future use
- **Scripts**: All PowerShell scripts preserved for reference
- **Archived Reports**: Reports saved before cleanup (if archived)
- **Documentation**: README files and guides remain intact

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
# Remove specific resource types
.\scripts\Remove-SimulationResources.ps1 -ResourceType "SharePoint"
.\scripts\Remove-SimulationResources.ps1 -ResourceType "DLP"

# Remove all simulation resources (requires confirmation)
.\scripts\Remove-SimulationResources.ps1
```

**What this does**:

- Removes DLP policies and rules in proper dependency order
- Deletes test documents from SharePoint sites
- Removes SharePoint simulation sites
- Cleans up classification job history
- Validates removal at each stage

**Resource Removal Order**:

1. **DLP Rules** - Remove detection rules first
2. **DLP Policies** - Remove policies after rules
3. **Documents** - Delete test documents from sites
4. **SharePoint Sites** - Remove sites after content
5. **Classification Jobs** - Clean up job history

**Expected output**:

- Confirmation prompts for each resource type
- Progress updates during removal
- Validation of successful deletion
- Summary of removed resources

### Step 3: Reset Environment to Clean State

Use `Reset-Environment.ps1` for complete environment reset:

```powershell
# Preview reset actions
.\scripts\Reset-Environment.ps1 -WhatIf

# Reset with confirmation prompts
.\scripts\Reset-Environment.ps1

# Reset without prompts (use with caution)
.\scripts\Reset-Environment.ps1 -Force
```

**What this does**:

- Removes all simulation resources
- Clears Reports directory (after archiving)
- Resets global configuration to defaults
- Cleans up temporary files and logs
- Validates environment is clean

**Expected output**:

- Complete removal of all simulation artifacts
- Clean project structure ready for future use
- Validation report confirming clean state
- Reset completion summary

#### Step 3: Full Environment Reset (Optional)

If you need to completely reset the environment to its initial state:

```powershell
.\scripts\Reset-Environment.ps1 -Force -ArchiveReports
```

**What this does**:

- Removes all simulation resources
- Resets environment to clean state
- Archives final reports and logs
- Validates complete cleanup

**Expected output**:

- Complete removal of all simulation artifacts
- Clean environment validation
- Archived documentation package
- Final status report

### Step 4: Verify Cleanup

Run the verification script to ensure all resources have been removed:

```powershell
.\scripts\Test-CleanupCompletion.ps1
```

**What this does**:

- Verifies SharePoint sites are deleted
- Checks for remaining DLP policies
- Confirms classification job cleanup
- Generates final status report

**Expected output**:

- ✅ All SharePoint simulation sites removed
- ✅ No active DLP simulation policies found
- ✅ Classification jobs cleaned up
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
