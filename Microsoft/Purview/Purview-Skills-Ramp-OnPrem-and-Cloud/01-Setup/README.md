# Section 1: Setup - Foundational Prerequisites

## 🎯 Section Overview

This section establishes all foundational prerequisites required for the remaining labs. It includes time-sensitive components (auditing activation) and Azure infrastructure deployment. **All three setup labs must be completed sequentially before proceeding to on-premises or cloud scanning.**

**Critical Success Factor**: Enable auditing early (Setup-01) as it requires 2-24 hours to activate and is essential for Activity Explorer functionality in Section 4.

---

## 📋 Labs in This Section

| Lab | Duration | Key Activities | Wait Period |
|-----|----------|----------------|-------------|
| **[Setup-01-Licensing-and-Auditing](./Setup-01-Licensing-and-Auditing/README.md)** | 30-45 min | • Activate M365 E5/E5 Compliance trial<br>• Assign licenses to admin + service account<br>• **Enable auditing** for Activity Explorer<br>• Verify Purview portal access | **2-24 hours** (auditing activation) |
| **[Setup-02-Azure-Infrastructure](./Setup-02-Azure-Infrastructure/README.md)** | 1.5-2 hours | • Create Resource Group with cost tags<br>• Deploy Windows Server VM (Standard_B2ms)<br>• Configure SQL Express<br>• Create SMB file shares with PII/credit card samples<br>• Deploy Azure Files (cloud storage simulation)<br>• Configure auto-shutdown + cost alerts | None (can run in parallel with auditing) |
| **[Setup-03-Service-Account-Creation](./Setup-03-Service-Account-Creation/README.md)** | 15-30 min | • Create Entra ID service account<br>• Assign M365 E5 license<br>• Configure Compliance Data Administrator role<br>• Document credentials securely | None |

---

## ⏱️ Total Section Duration

**Active Work**: 2-3 hours  
**Wait Period**: 2-24 hours (auditing activation runs in background)  
**Recommended Approach**: Complete all 3 setup labs in one session, then proceed to Section 2 while auditing activates

---

## 💰 Cost Impact

**This section starts Azure billing at $3-5/day** for:

- Windows Server 2022 VM (Standard_B2ms).
- SQL Server Express (included in VM cost).
- Azure Files Premium (100 GiB minimum).

**Cost Optimization**:

- Auto-shutdown configured in Setup-02 for 10 PM local time.
- Deallocate VM between sessions (reduces cost to $0.50-1.00/day storage only).
- Delete Resource Group immediately after completing all sections.

---

## 🔄 Sequential Completion Required

**These labs MUST be completed in order**:

1. **Setup-01** → Enables auditing (2-24 hr activation for Activity Explorer in Section 4)
2. **Setup-02** → Deploys Azure infrastructure (VM, SQL, file shares) required for scanner in Section 2
3. **Setup-03** → Creates service account with proper licensing for scanner authentication

**Do not skip Setup-01** even if you plan to focus on on-prem scanning only. Auditing is required for DLP policy validation and reporting in later labs.

---

## ✅ Section Completion Checklist

Before proceeding to Section 2 (On-Prem Scanning) or Section 3 (Cloud Scanning), verify:

### Setup-01 Complete

- [ ] Microsoft 365 E5 (or E5 Compliance) trial activated
- [ ] Licenses assigned to admin account
- [ ] Auditing enabled in Purview portal (banner dismissed in Activity Explorer)
- [ ] 2-24 hours elapsed since auditing enablement (or accept incomplete Activity Explorer data in Section 4)

### Setup-02 Complete

- [ ] Resource group `rg-purview-lab` created with cost tracking tags
- [ ] VM `vm-purview-scanner` running and accessible via RDP
- [ ] SQL Server Express installed, TCP/IP enabled, service running
- [ ] SMB shares created: `\\localhost\Finance`, `\\localhost\HR`, `\\localhost\Projects`
- [ ] Sample files contain sensitive data (credit cards 4532/5425/3782, SSNs 123-45-6789)
- [ ] Phoenix project file LastAccessTime > 3 years old
- [ ] Azure Files share mounted as Z: drive with CloudMigration.txt
- [ ] Auto-shutdown configured for 10 PM local time
- [ ] Microsoft Office IFilter installed (FilterPack64bit.exe)
- [ ] Azure CLI installed and working (`az --version`)

### Setup-03 Complete

- [ ] Service account `scanner-svc@tenant.onmicrosoft.com` created
- [ ] Usage location set (required for license assignment)
- [ ] Microsoft 365 E5 (or E5 Compliance) license assigned to scanner account
- [ ] Compliance Data Administrator role assigned
- [ ] Password documented securely (no expiration)

---

## 🚦 Next Steps

**After completing all Setup labs**:

**Option A - On-Premises Scanning Path**:

- Proceed to **[Section 2: On-Premises Scanning](../02-OnPrem-Scanning/README.md)**.
- Learn Information Protection Scanner for file shares and Azure Files.
- Complete DLP policy configuration and enforcement validation.

**Option B - Cloud Scanning Path**:

- Proceed to **[Section 3: Cloud Scanning](../03-Cloud-Scanning/README.md)**.
- Learn SharePoint/OneDrive retention labels and lifecycle management.
- Note: Section 2 recommended but not strictly required for Section 3.

**Option C - Complete Coverage Path** (Recommended):

- Complete Section 2 first (on-prem scanning).
- Then complete Section 3 (cloud scanning).
- Then complete Section 4 (validation & reporting).

---

## 🔧 Troubleshooting Common Setup Issues

### Microsoft 365 License Trial Not Activating

**Solutions**:

1. Verify Global Admin role assigned
2. Check if trial already used (each tenant can only use same trial type once)
3. Wait 15-30 minutes for license propagation
4. Try different browser or clear cache
5. Look for **Microsoft 365 E5** (standard) if **E5 Compliance** not available

### Auditing Not Enabling

**Solutions**:

1. Verify Global Admin or Compliance Admin role
2. Check Purview portal: Data loss prevention > Explorers > Activity explorer
3. Wait 24 hours and recheck (activation can take up to 24 hours)
4. Verify Microsoft 365 E5 (or E5 Compliance) license assigned

### VM Deployment Fails

**Solutions**:

1. Verify Azure subscription has available quota for Standard_B2ms VM
2. Try different region (East US → West US 2)
3. Check subscription spending limits
4. Verify Contributor role on subscription

### SQL Server Not Accessible After Installation

**Solutions**:

1. Verify service running: Services.msc → SQL Server (SQLEXPRESS) → Status = Running
2. Enable TCP/IP: SQL Configuration Manager → Protocols for SQLEXPRESS → TCP/IP → Enable
3. Restart service after enabling TCP/IP
4. Test connection: `Test-NetConnection -ComputerName localhost -Port 1433`

---

## 📚 Additional Resources

- [Microsoft 365 Licensing Guidance for Security & Compliance](https://learn.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-365-security-compliance-licensing-guidance)
- [Enable Audit Log Search](https://learn.microsoft.com/en-us/purview/audit-log-enable-disable)
- [Create Windows VM in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal)
- [Install SQL Server Express](https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server)

---

## 🤖 AI-Assisted Content Generation

This setup section guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models while maintaining 100% technical accuracy.
