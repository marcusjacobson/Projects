# Lab 07: Cleanup and Reset

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
| **Power BI Dashboards** | Lab 06 .pbix files | Can be archived before deletion |
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
.\Export-FinalDocumentation.ps1

# Verify archive creation
Get-ChildItem -Path "..\Reports\Archives" -Recurse
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

### Step 2: Remove Simulation Resources

Use `Remove-SimulationResources.ps1` for targeted resource removal:

```powershell
# Preview what will be removed (dry-run mode)
.\Remove-SimulationResources.ps1 -WhatIf

# Remove specific resource types
.\Remove-SimulationResources.ps1 -ResourceType "DLPPolicies"
.\Remove-SimulationResources.ps1 -ResourceType "Documents"
.\Remove-SimulationResources.ps1 -ResourceType "Sites"

# Remove all simulation resources (requires confirmation)
.\Remove-SimulationResources.ps1 -ResourceType "All"
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
.\Reset-Environment.ps1 -WhatIf

# Reset with confirmation prompts
.\Reset-Environment.ps1

# Reset without prompts (use with caution)
.\Reset-Environment.ps1 -Force
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

### Step 4: Verify Complete Cleanup

Use `Test-CleanupCompletion.ps1` to verify all resources removed:

```powershell
# Run comprehensive verification
.\Test-CleanupCompletion.ps1

# Verify specific resource types
.\Test-CleanupCompletion.ps1 -ResourceType "Sites"
.\Test-CleanupCompletion.ps1 -ResourceType "DLPPolicies"

# Generate detailed verification report
.\Test-CleanupCompletion.ps1 -DetailedReport
```

**What this does**:
- Verifies SharePoint sites are deleted
- Confirms DLP policies and rules removed
- Checks for orphaned resources
- Validates clean Reports directory
- Generates verification report

**Expected output**:
- ✅ All SharePoint simulation sites removed
- ✅ All DLP policies and rules deleted
- ✅ No orphaned documents or resources
- ✅ Reports directory clean (or archived)
- Verification report with pass/fail status

## 📊 Cleanup Process Flowchart

```
┌─────────────────────────────────────┐
│  Step 1: Archive Reports            │
│  Export-FinalDocumentation.ps1      │
│  - Create final summary             │
│  - Archive all reports              │
│  - Generate project metrics         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Step 2: Remove DLP Policies        │
│  Remove-SimulationResources.ps1     │
│  - Remove DLP rules                 │
│  - Remove DLP policies              │
│  - Validate deletion                │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Step 3: Remove Documents           │
│  Remove-SimulationResources.ps1     │
│  - Delete test documents            │
│  - Clear recycle bins               │
│  - Validate removal                 │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Step 4: Remove SharePoint Sites    │
│  Remove-SimulationResources.ps1     │
│  - Delete simulation sites          │
│  - Remove from recycle bin          │
│  - Validate deletion                │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Step 5: Reset Environment          │
│  Reset-Environment.ps1              │
│  - Clear Reports directory          │
│  - Reset configuration              │
│  - Clean temporary files            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Step 6: Verify Cleanup             │
│  Test-CleanupCompletion.ps1         │
│  - Check all resources removed      │
│  - Generate verification report     │
│  - Confirm clean state              │
└─────────────────────────────────────┘
```

## ⚠️ Troubleshooting

### Issue 1: DLP Policy Deletion Fails

**Symptoms**:
- Error: "Policy in use" or "Policy has rules"
- DLP policy deletion returns error
- Policy still appears after deletion attempt

**Resolution**:
1. Remove all rules from the policy first
2. Wait 2-3 minutes for rule removal to propagate
3. Retry policy deletion
4. Verify no rules reference the policy
5. Check for dependent policies
6. Use `-Force` parameter if safe to do so

### Issue 2: SharePoint Site Cannot Be Deleted

**Symptoms**:
- Error: "Site is locked" or "Access denied"
- Site appears in recycle bin but won't delete
- Deletion hangs or times out

**Resolution**:
1. Verify you have Site Collection Administrator permissions
2. Check if site is in hold or retention policy
3. Remove any legal holds on the site
4. Wait 24 hours for recycle bin automatic cleanup
5. Use SharePoint Admin Center to manually delete
6. Contact SharePoint administrator if persistent

### Issue 3: Documents Won't Delete from Site

**Symptoms**:
- Error: "File is checked out" or "File locked"
- Some documents remain after deletion
- Recycle bin still contains files

**Resolution**:
1. Check in all checked-out documents first
2. Break any workflow locks on documents
3. Remove retention labels if applied
4. Delete in smaller batches (100-200 at a time)
5. Empty site recycle bin after document deletion
6. Wait 10 minutes between deletion attempts

### Issue 4: Cleanup Verification Reports Failures

**Symptoms**:
- Verification reports orphaned resources
- Sites/policies still detected after deletion
- Inconsistent verification results

**Resolution**:
1. Wait 15-30 minutes for deletion propagation
2. Clear PowerShell session and reconnect
3. Verify credentials have proper permissions
4. Check Azure AD cache refresh (can take 1 hour)
5. Re-run verification with `-DetailedReport` flag
6. Manually verify resources in portals

### Issue 5: Archive Creation Fails

**Symptoms**:
- Error: "Access denied" on archive creation
- Archive file incomplete or corrupted
- Reports missing from archive

**Resolution**:
1. Verify write permissions to Reports directory
2. Check available disk space (need 100MB+)
3. Close any open report files in Excel/browsers
4. Retry archive creation with `-Force` parameter
5. Manually copy Reports directory as backup
6. Use Windows Compress-Archive cmdlet directly

### Issue 6: Reset Removes Too Much

**Symptoms**:
- Important non-simulation resources deleted
- Configuration files corrupted
- Project structure damaged

**Resolution**:
1. **PREVENTION**: Always use `-WhatIf` first
2. Restore from archived reports if available
3. Re-create global configuration using template
4. Regenerate directory structure
5. Review Reset-Environment.ps1 exclusions
6. Implement custom exclusion list if needed

## 💡 Best Practices

### Safety Measures

- **Always Archive First**: Run Export-FinalDocumentation.ps1 before any deletion
- **Use WhatIf**: Preview all deletion operations before executing
- **Verify Scope**: Confirm resource names match simulation patterns
- **Incremental Removal**: Remove resources by type, not all at once
- **Wait for Propagation**: Allow 5-10 minutes between major deletions

### Documentation

- **Capture Final State**: Take screenshots before cleanup
- **Save Reports**: Archive all Lab 04-06 reports
- **Record Metrics**: Note final classification and incident counts
- **Lessons Learned**: Document challenges and solutions
- **Configuration Backup**: Save global configuration values

### Verification

- **Multi-Stage Checks**: Verify after each resource type removal
- **Portal Validation**: Check SharePoint Admin Center and Compliance Center
- **Wait Periods**: Allow time for backend cleanup to complete
- **Detailed Reports**: Use `-DetailedReport` for comprehensive verification
- **Manual Spot Checks**: Randomly verify a few resources manually

### Environment Management

- **Clean Slate**: Reset environment completely for future projects
- **Preserve Scripts**: Never delete PowerShell script files
- **Maintain Documentation**: Keep README files for reference
- **Version Control**: Commit final state to Git before cleanup
- **Future Readiness**: Leave environment ready for next simulation

## 🎯 Expected Results

After completing this lab, you should have:

- ✅ **Complete Archive**: All reports and documentation preserved
- ✅ **Zero Simulation Resources**: No SharePoint sites, DLP policies, or test documents
- ✅ **Clean Environment**: Reports directory empty or archived
- ✅ **Verification Report**: Confirmation all resources removed
- ✅ **Final Documentation**: Comprehensive project summary generated
- ✅ **Lessons Learned**: Documented insights and challenges

### Success Indicators

```
SharePoint Sites:        0 simulation sites found
DLP Policies:            0 simulation policies found
DLP Rules:               0 simulation rules found
Test Documents:          0 documents in simulation sites
Reports Archived:        Yes - timestamped archive created
Environment Status:      Clean - ready for future use
Verification Status:     PASSED - all checks successful
```

## 📚 Additional Resources

### Microsoft Documentation

- [SharePoint Site Deletion](https://learn.microsoft.com/en-us/sharepoint/delete-site-collection)
- [DLP Policy Management](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Purview Cleanup Procedures](https://learn.microsoft.com/en-us/purview/compliance-manager-assessments)

### Cleanup Tools

- [SharePoint Admin Center](https://admin.microsoft.com/sharepoint)
- [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
- [PowerShell Recycle Bin Management](https://learn.microsoft.com/en-us/powershell/module/sharepoint-online)

### Safety Guidelines

- [Azure Resource Deletion Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/delete-resource-group)
- [Data Loss Prevention Policy Lifecycle](https://learn.microsoft.com/en-us/purview/dlp-policy-reference)

## ⏭️ After Cleanup

Once cleanup is complete:

1. **Review Final Documentation**: Examine archived reports and project summary
2. **Preserve Lessons Learned**: Save insights for future projects
3. **Update Skills**: Reflect on what you learned about Purview and data governance
4. **Share Knowledge**: Document key findings for team or community
5. **Plan Next Steps**: Consider production implementation or advanced scenarios

---

## 🤖 AI-Assisted Content Generation

This comprehensive cleanup and reset guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating safe decommissioning procedures, resource dependency management, and enterprise-grade cleanup verification standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of cleanup and reset procedures while maintaining safety standards and reflecting Microsoft 365 resource management best practices for simulation environment decommissioning.*
