# Purview Classification & Lifecycle Labs

## 🎯 Project Overview

This comprehensive lab environment demonstrates Microsoft Purview's data classification, information protection, and lifecycle management capabilities from the ground up. Through five progressive hands-on labs, you'll learn to implement enterprise-grade data governance using Sensitive Information Types (SITs), retention labels, auto-apply policies, and PowerShell automation.

**Target Audience**: IT professionals, compliance administrators, and security engineers learning Microsoft Purview Information Protection and Data Lifecycle Management.

**Approach**: "From scratch" implementation - no prior Purview configuration assumed. All prerequisites, setup steps, and foundational concepts are fully documented.

---

## 📚 Lab Progression

### [Lab 1: On-Demand Classification for SharePoint & OneDrive](./01-OnDemandClassification/)

**Duration**: 45-60 minutes  
**Objective**: Master manual re-indexing and on-demand classification of existing content

**What You'll Learn**:

- Create custom Sensitive Information Types (SITs) for your organization.
- Trigger On-Demand Classification scans on SharePoint sites.
- Validate classification results using Content Explorer.
- Understand classification timing and indexing behavior.

**Key Deliverables**:

- Custom SIT created and tested.
- On-Demand Classification executed successfully on SharePoint site.
- Classification results validated in Content Explorer.

---

### [Lab 2: Custom Sensitive Information Types](./02-CustomSITs/)

**Duration**: 90-120 minutes  
**Objective**: Create and tune custom SITs using regex, keywords, and Exact Data Match (EDM)

**What You'll Learn**:

- Design regex patterns for custom data formats.
- Build keyword dictionaries for context-based detection.
- Configure confidence levels and instance counts.
- Implement Exact Data Match (EDM) for structured data.
- Hash and upload sensitive source tables securely.

**Key Deliverables**:

- 3+ custom regex-based SITs with varying confidence levels.
- Keyword dictionary SIT for specialized terminology.
- EDM schema created with 3-5 searchable fields.
- Sensitive data table hashed and uploaded to tenant.

---

### [Lab 3: Retention Labels & Data Lifecycle Management](./03-RetentionLabels/)

**Duration**: 60-90 minutes  
**Objective**: Configure retention labels and auto-apply policies for automated lifecycle management

**What You'll Learn**:

- Create retention labels with file plan descriptors.
- Configure retention periods and deletion triggers.
- Publish retention labels to SharePoint locations.
- Create auto-apply policies based on SIT detection.
- Understand the 7-day policy processing timeline.

**Key Deliverables**:

- 3+ retention labels with varying retention periods (1yr, 3yr, 7yr).
- Auto-apply policy configured for sensitive data detection.
- Retention labels published to target SharePoint sites.
- Understanding of simulation mode vs. enforcement.

---

### [Lab 4: PowerShell Automation & Scaling](./04-PowerShellAutomation/)

**Duration**: 75-105 minutes  
**Objective**: Implement enterprise-scale automation using Security & Compliance PowerShell

**What You'll Learn**:

- Execute compliance content searches using KQL syntax.
- Perform bulk deletion operations with audit trails.
- Apply retention labels at scale across multiple sites.
- Monitor classification policy adoption and coverage.
- Generate compliance reports for stakeholder review.

**Key Deliverables**:

- Compliance search scripts with parameterized KQL queries.
- Bulk operation scripts with error handling and logging.
- Multi-site monitoring dashboard data.
- Executive-level compliance report generation.

---

### [Lab 5: Runbook Documentation](./05-Runbooks/)

**Duration**: 30-45 minutes (review and customization)  
**Objective**: Understand operational procedures and enterprise deployment workflows

**What You'll Learn**:

- End-to-end Purview deployment procedures.
- Classification workflow best practices.
- Retention label lifecycle management.
- Automation workflow integration patterns.
- Troubleshooting common scenarios.
- Operational handoff for IT teams.

**Key Deliverables**:

- Deployment runbook for new tenants.
- Classification and labeling workflow documentation.
- Retention policy implementation guide.
- Troubleshooting knowledge base.
- Operational support handoff checklist.

---

## ⚡ Quick Start

### Prerequisites

**Microsoft 365 Licensing**:

- Microsoft 365 E5 OR Microsoft 365 E5 Compliance add-on.
- Required for advanced SITs, EDM, trainable classifiers, and auto-apply policies.

**Azure AD Permissions**:

- Compliance Administrator OR Global Administrator role.
- EDM_DataUploaders security group membership (for Lab 2 EDM section).

**Technical Requirements**:

- PowerShell 5.1+ or PowerShell 7+.
- ExchangeOnlineManagement module v3.0+.
- Internet connectivity for Microsoft 365 tenant access.
- SharePoint Online test site with sample documents.

**Knowledge Prerequisites**:

- Basic understanding of Microsoft 365 administration.
- Familiarity with SharePoint Online navigation.
- PowerShell scripting fundamentals (for Labs 4-5).

### Installation Steps

#### Step 1: Install Required PowerShell Modules

```powershell
# Install Exchange Online Management (includes Security & Compliance PowerShell)
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force

# Install SharePoint Online Management Shell (for multi-site operations)
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force

# Verify module installation
Get-Module -Name ExchangeOnlineManagement -ListAvailable
Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable
```

#### Step 2: Connect to Security & Compliance PowerShell

```powershell
# Import module
Import-Module ExchangeOnlineManagement

# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName your-admin@yourtenant.onmicrosoft.com
```

#### Step 3: Verify Permissions

```powershell
# Check your admin roles
Get-ManagementRoleAssignment -RoleAssignee "your-admin@yourtenant.onmicrosoft.com" | 
    Select-Object Role, RoleAssigneeType | 
    Format-Table -AutoSize
```

#### Step 4: Create SharePoint Test Site

- Navigate to [SharePoint Admin Center](https://admin.microsoft.com/sharepoint).
- Create a new Communication Site named "Purview Testing Lab".
- Upload 5-10 test documents with varying content types.

---

## 🗂️ Project Structure

```text
Purview-Classification-Lifecycle-Labs/
├── README.md                           # This file
├── 01-OnDemandClassification/          # Lab 1: Manual classification and indexing
│   ├── README.md
│   ├── scripts/
│   └── data/
├── 02-CustomSITs/                      # Lab 2: Custom SIT creation (regex, keywords, EDM)
│   ├── README.md
│   ├── scripts/
│   ├── configs/
│   ├── data/
│   └── edm/                            # EDM-specific subdirectory
├── 03-RetentionLabels/                 # Lab 3: Retention labels and auto-apply policies
│   ├── README.md
│   ├── scripts/
│   └── configs/
├── 04-PowerShellAutomation/            # Lab 4: Enterprise-scale automation
│   ├── README.md
│   ├── scripts/
│   └── configs/
├── 05-Runbooks/                        # Lab 5: Operational documentation
│   ├── README.md
│   └── docs/
└── scripts/                            # Shared utilities and modules
    ├── common/
    └── modules/
```

---

## 🔧 Shared Utilities

The `scripts/` directory contains reusable PowerShell functions used across all labs:

**Common Scripts**:

- `Connect-PurviewCompliance.ps1` - Authentication and connection management.
- `Test-Prerequisites.ps1` - Validate module installation and permissions.
- `Write-ComplianceLog.ps1` - Standardized logging with color-coded output.

**PowerShell Modules**:

- `PurviewHelpers.psm1` - Exported functions for SIT management, retention operations, content searches.
- `ErrorHandling.psm1` - Enterprise error handling with retry logic and comprehensive reporting.

**Usage Example**:

```powershell
# Import shared modules
Import-Module ".\scripts\modules\PurviewHelpers.psm1" -Force
Import-Module ".\scripts\modules\ErrorHandling.psm1" -Force

# Use helper functions
Test-PurviewPrerequisites
Connect-PurviewCompliance -TenantName "yourtenant"
```

---

## 📊 Learning Outcomes

Upon completing all five labs, you will be able to:

**Information Protection & Classification**:

- Design and implement custom Sensitive Information Types for organizational data patterns.
- Configure Exact Data Match (EDM) for structured sensitive data protection.
- Tune confidence levels and instance counts for optimal detection accuracy.
- Execute On-Demand Classification to re-index existing SharePoint content.

**Data Lifecycle Management**:

- Create retention labels with file plan descriptors aligned to compliance requirements.
- Configure retention periods with appropriate deletion triggers (created/modified/labeled).
- Implement auto-apply policies based on sensitive data detection.
- Manage the retention label lifecycle from creation through enforcement.

**Automation & Scaling**:

- Write PowerShell scripts for compliance content searches using KQL syntax.
- Execute bulk operations (deletion, labeling) with comprehensive error handling.
- Monitor classification policy adoption across multiple SharePoint sites.
- Generate executive-level compliance reports for stakeholder review.

**Enterprise Deployment**:

- Follow production deployment runbooks for Purview Information Protection.
- Implement operational handoff procedures for IT support teams.
- Troubleshoot common classification and retention policy issues.
- Maintain Purview configurations in enterprise Microsoft 365 tenants.

---

## ⏱️ Time Investment

| Lab | Active Work | Wait Period | Total Duration |
|-----|-------------|-------------|----------------|
| Lab 1 | 45-60 min | None | 45-60 min |
| Lab 2 | 90-120 min | None | 90-120 min |
| Lab 3 | 60-90 min | Up to 7 days* | 60-90 min active |
| Lab 4 | 75-105 min | None | 75-105 min |
| Lab 5 | 30-45 min | None | 30-45 min |
| **Total** | **5-7 hours** | **Up to 7 days*** | **5-7 hours active** |

> **⚠️ Important Timing Note**: Auto-apply retention policies (Lab 3) require **up to 7 days** to process and begin applying labels automatically. This is a Microsoft 365 service processing timeline, not a configuration issue. You can continue with Labs 4-5 while waiting for policy activation.

---

## 🚨 Critical Success Factors

**Before Starting**:

- ✅ Verify Microsoft 365 E5 or E5 Compliance licensing for your test account.
- ✅ Confirm Compliance Administrator or Global Administrator role assignment.
- ✅ Install ExchangeOnlineManagement module v3.0+ and SharePoint Online Management Shell.
- ✅ Create dedicated SharePoint test site with sample documents containing sensitive data.
- ✅ Review Microsoft Purview portal navigation (compliance.microsoft.com).

**Common Pitfalls to Avoid**:

- ❌ **Insufficient Licensing**: Basic Microsoft 365 plans don't include advanced SITs or EDM - verify E5 Compliance licensing.
- ❌ **Incorrect Permissions**: Requires Compliance Administrator role minimum - Global Reader is insufficient.
- ❌ **Module Version Issues**: ExchangeOnlineManagement v2.x lacks REST API support - upgrade to v3.0+.
- ❌ **7-Day Wait Period Misunderstanding**: Auto-apply policies take up to 7 days to activate - this is expected behavior.
- ❌ **EDM Security Group Missing**: EDM upload requires EDM_DataUploaders group membership - add before Lab 2 EDM section.

---

## 🔍 Validation Checkpoints

Each lab includes validation steps to confirm successful completion:

**Lab 1 Validation**:

- Custom SIT appears in Microsoft Purview portal under **Data classification** → **Sensitive info types**.
- On-Demand Classification scan completes without errors in SharePoint site settings.
- Content Explorer shows classified documents matching your custom SIT patterns.

**Lab 2 Validation**:

- Custom regex SITs detect test patterns with correct confidence levels.
- Keyword dictionary SIT matches specialized organizational terminology.
- EDM schema uploads successfully via PowerShell (`New-DlpEdmSchema` cmdlet).
- Sensitive data table hash uploads complete via EdmUploadAgent.exe.

**Lab 3 Validation**:

- Retention labels appear in **Records management** → **File plan**.
- Auto-apply policy shows "On" status (not "Off (Error)") in **Data lifecycle management**.
- Simulation mode results display in policy details after 24-48 hours.
- Labels begin appearing on documents within 7 days of policy activation.

**Lab 4 Validation**:

- Compliance search cmdlets execute without authentication errors.
- Bulk operation scripts complete with comprehensive success/failure logs.
- Multi-site monitoring scripts return classification coverage metrics.
- Compliance reports generate in CSV/JSON format for executive review.

**Lab 5 Validation**:

- Runbook documentation covers all prerequisite steps and dependencies.
- Workflow diagrams accurately reflect portal navigation and configuration steps.
- Troubleshooting guide includes common error messages with resolution steps.
- Operational handoff checklist provides complete information for IT support teams.

---

## 🛠️ Troubleshooting Resources

**Common Issues & Solutions**:

1. **PowerShell Connection Failures**:
   - **Symptom**: `Connect-IPPSSession` fails with authentication errors.
   - **Solution**: Verify MFA enrollment, check conditional access policies, ensure ExchangeOnlineManagement v3.0+ installed.

2. **SIT Not Detecting Content**:
   - **Symptom**: Custom SIT created but doesn't match expected documents.
   - **Solution**: Verify regex pattern syntax, check confidence level settings (try Medium instead of High), test with simplified patterns first.

3. **EDM Upload Failures**:
   - **Symptom**: EdmUploadAgent.exe errors during hash/upload process.
   - **Solution**: Verify EDM_DataUploaders group membership, check CSV file encoding (must be UTF-8), ensure column count matches schema fields.

4. **Retention Labels Not Applying**:
   - **Symptom**: Auto-apply policy shows "On" but labels don't appear after 7+ days.
   - **Solution**: Run PowerShell retry command: `Set-RetentionCompliancePolicy -Identity "PolicyName" -RetryDistribution`.

5. **Compliance Search Errors**:
   - **Symptom**: Content search fails with KQL syntax errors.
   - **Solution**: Validate KQL syntax using Microsoft documentation, test queries in Content Search UI before PowerShell, check location specifications.

**Additional Support**:

- Microsoft Learn Documentation: [learn.microsoft.com/purview](https://learn.microsoft.com/en-us/purview/)
- Microsoft 365 Admin Center: **Health** → **Service health** for platform issues.
- Each lab's README.md includes detailed troubleshooting sections with lab-specific guidance.

---

## 📖 Additional Resources

**Microsoft Official Documentation**:

- [Microsoft Purview Information Protection](https://learn.microsoft.com/en-us/purview/information-protection)
- [Sensitive Information Types Entity Definitions](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)
- [Learn About Exact Data Match](https://learn.microsoft.com/en-us/purview/sit-learn-about-exact-data-match-based-sits)
- [Create and Publish Retention Labels with PowerShell](https://learn.microsoft.com/en-us/purview/bulk-create-publish-labels-using-powershell)
- [Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/scc-powershell)

**PowerShell Module References**:

- [ExchangeOnlineManagement Module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2)
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell)
- [SharePoint Online Management Shell](https://learn.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online)

**Compliance & Governance**:

- [Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager)
- [Data Lifecycle Management Overview](https://learn.microsoft.com/en-us/purview/data-lifecycle-management)
- [Microsoft 365 Retention Policies](https://learn.microsoft.com/en-us/purview/retention)

---

## 🤝 Contributing

This project is designed for learning and can be customized for organizational needs. When adapting labs:

- Follow the PowerShell Style Guide in `Style Guides/powershell-style-guide.md`.
- Maintain markdown formatting standards from `Style Guides/markdown-style-guide.md`.
- Test all scripts in a non-production tenant before enterprise deployment.
- Update validation checkpoints when modifying lab objectives.

---

## 📝 License

Copyright (c) 2025 Marcus Jacobson. All rights reserved.  
Licensed under the MIT License.

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab curriculum was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview Information Protection best practices, PowerShell automation patterns, and enterprise data governance workflows validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview capabilities while maintaining technical accuracy and reflecting industry best practices for information protection and data lifecycle management.*
