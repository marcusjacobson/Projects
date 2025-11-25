# Deploy Microsoft Defender for Cloud via Azure Portal - Step-by-Step Guide

This guide provides a comprehensive, step-by-step approach to deploying Microsoft Defender for Cloud using the Azure Portal, following the same proven workflow as our Infrastructure-as-Code deployment. Each step can be completed independently, allowing you to understand each component of the security architecture.

## 🎯 Overview

This Azure Portal approach follows the same logical progression as our automated Infrastructure-as-Code deployment, providing:

- **Learning-Focused Experience** - Understand each security component as you deploy it manually.
- **Portal-Based Deployment** - Hands-on experience with Azure Portal interfaces and workflows.
- **Comprehensive Validation** - Manual verification at every deployment step.
- **Foundation for Automation** - Understanding portal workflows that can later be automated.

### Core Deployment Steps

This guide follows the same logical progression as our modular IaC deployment:

1. **Access and Enable Foundation Infrastructure** - Set up core infrastructure and workspace via Azure Portal.
2. **Enable Modern Server Protection** - Deploy VMs with agentless scanning and endpoint protection.
3. **Configure Security Policies and Defender Plans** - Enable Defender plans and compliance standards.
4. **Verify Protection Architecture** - Validate deployment and security coverage.
5. **Enable Advanced Threat Protection Features** - Just-in-Time access and security features.
6. **Configure Microsoft Sentinel Integration** - Set up SIEM for security data collection.
7. **Generate and Monitor Security Alerts** - Test alert generation and investigation workflows.
8. **Create Workbooks and Dashboards** - Set up security visualization and reporting.
9. **Portal-Only Advanced Configuration** - Features requiring interactive configuration.
10. **Set Up Analytics and Cost Management** - Compliance monitoring and cost optimization.

## 📋 Prerequisites

Before starting, ensure you have:

- An active Azure subscription with Owner or Contributor permissions.
- Access to the Azure Portal.
- Basic understanding of Azure resources and security concepts.

**Required Permissions**: Owner, Contributor, or Security Admin roles at subscription level.

---

## Step 1: Access and Enable Foundation Infrastructure

Deploy the foundational infrastructure that supports Microsoft Defender for Cloud through the Azure Portal.

### 🚀 Sign in to Azure Portal and Navigate to Defender for Cloud

#### Initial Portal Access

- Navigate to [https://portal.azure.com](https://portal.azure.com).
- Sign in with your Azure account credentials.
- In the Azure Portal search bar, type **Microsoft Defender for Cloud**.
- Click **Microsoft Defender for Cloud** from the search results.
- Alternatively, find it under **Security** in the Azure services menu.

📸 **[View Screenshot: Azure Portal Search](https://learn.microsoft.com/en-us/azure/defender-for-cloud/media/get-started/defender-for-cloud-search.png)**

#### Getting Started Page

- Upon first access, the Defender for Cloud Getting Started page appears.
- Review the overview of capabilities and benefits.
- Click **Enable Defender for Cloud** if not already enabled.
- The foundational CSPM (Cloud Security Posture Management) capabilities are free.

📸 **[View Screenshot: Defender Overview](https://learn.microsoft.com/en-us/azure/reusable-content/ce-skilling/azure/media/defender-for-cloud/overview.png)**

### 🚀 Create Resource Group for Organized Deployment

Follow the same organizational structure as our IaC deployment by creating a dedicated resource group.

#### Navigate to Resource Groups

- In Azure Portal, search for **Resource groups**.
- Click **+ Create** to create a new resource group.

#### Configure Resource Group

- **Subscription**: Select your subscription.
- **Resource group**: Enter a name such as **rg-aisec-defender-portal**.
- **Region**: Choose your preferred region (e.g., West US, East US).

#### Review and Create Resource Group

- Click **Review + create**.
- After validation passes, click **Create**.
- Wait for the resource group to be created.

### 🚀 Create Log Analytics Workspace

Create the foundational workspace for security monitoring and data collection.

#### Navigate to Log Analytics Workspaces

- In Azure Portal, search for **Log Analytics workspaces**.
- Click **+ Create**.

#### Configure Log Analytics Workspace

- **Subscription**: Select your subscription.
- **Resource Group**: Select the resource group created above.
- **Name**: Enter **law-aisec-defender-portal**.
- **Region**: Choose the same region as your resource group.
- **Pricing tier**: **Pay-as-you-go (Per GB)** (recommended for most scenarios).

#### Review and Create Workspace

- Click **Review + create**.
- After validation passes, click **Create**.
- Wait for deployment to complete (typically 2-3 minutes).

### Foundation Deployment Results

After successful completion:

- **Resource Group**: Created with standardized naming for organization.
- **Log Analytics Workspace**: Ready for security data ingestion and monitoring.
- **Defender for Cloud**: Initial access configured and ready for plan enablement.

**Timeline**: 5-8 minutes for complete foundation setup via Azure Portal.

## Step 2: Enable Modern Server Protection

Deploy virtual machines with modern agentless scanning and Defender for Endpoint integration, along with the supporting network infrastructure.

> **💰 COST AWARENESS**: This step deploys Azure virtual machines and network infrastructure which incur compute and networking costs:
>
> - **Windows Server VM** (Standard_B2s): ~$31-35/month or ~$1.05/day.
> - **Linux VM** (Standard_B1ms): ~$15-18/month or ~$0.50/day.  
> - **Virtual Network and NSG**: Minimal cost (~$0.05/month for public IP addresses if used).
> - **Combined Daily Cost**: ~$1.55/day (~$47/month) when VMs are running.
> - **Cost Optimization**: Stop/deallocate VMs when not in use to avoid compute charges.
> - **Storage Costs**: Additional ~$2-4/month for VM disks (persist when VMs are stopped).

### 🚀 Create Virtual Network Infrastructure

Deploy the foundational network infrastructure that will securely host your virtual machines, following the same network design as our IaC deployment.

#### Navigate to Virtual Networks

- In Azure Portal, search for **Virtual networks**.
- Click **+ Create**.

#### Configure Virtual Network

- **Subscription**: Select your subscription.
- **Resource Group**: Select the resource group created in Step 1.
- **Name**: Enter **vnet-aisec-defender-portal**.
- **Region**: Choose the same region as your resource group.

#### Configure IP Address Space

- **IPv4 address space**: Enter **10.0.0.0/16** (provides 65,536 available IP addresses).
- **IPv6 address space**: Leave unchecked (not needed for this deployment).

#### Configure Subnets

Create a dedicated subnet for the virtual machines:

- **Subnet name**: Enter **subnet-vms**.
- **Subnet address range**: Enter **10.0.1.0/24** (provides 256 IP addresses for VMs).
- **Security services**: Leave default settings.

#### Review and Create Virtual Network

- Click **Review + create**.
- After validation passes, click **Create**.
- Wait for deployment to complete (typically 2-3 minutes).

### 🚀 Create Network Security Groups

Create network security groups to control traffic flow to your virtual machines, implementing defense-in-depth security principles.

#### Navigate to Network Security Groups

- In Azure Portal, search for **Network security groups**.
- Click **+ Create**.

#### Configure Network Security Group

- **Subscription**: Select your subscription.
- **Resource Group**: Select the same resource group.
- **Name**: Enter **nsg-aisec-vms**.
- **Region**: Choose the same region as your virtual network.

#### Review and Create NSG

- Click **Review + create**.
- After validation passes, click **Create**.
- Wait for deployment to complete (typically 1-2 minutes).

#### Configure Security Rules

After NSG creation, configure essential security rules:

1. **Access the NSG**: Navigate to your newly created NSG **nsg-aisec-vms**.
2. **Add Inbound Security Rules**: Click **Inbound security rules** → **+ Add**.

##### Rule 1: Allow RDP for Windows VM

- **Source**: **Any** (restrict to your IP in production).
- **Source port ranges**: **\***.
- **Destination**: **Any**.
- **Service**: **RDP**.
- **Action**: **Allow**.
- **Priority**: **300**.
- **Name**: **AllowRDP**.

##### Rule 2: Allow SSH for Linux VM

- **Source**: **Any** (restrict to your IP in production).
- **Source port ranges**: **\***.
- **Destination**: **Any**.
- **Service**: **SSH**.
- **Action**: **Allow**.
- **Priority**: **310**.
- **Name**: **AllowSSH**.

1. **Review Default Rules**: Note the existing default rules that:

   - Allow inbound traffic within the virtual network.
   - Allow inbound traffic from Azure Load Balancer.
   - Deny all other inbound traffic.

### 🚀 Associate NSG with Subnet

Connect the network security group to the virtual machine subnet for traffic filtering.

#### Access NSG Subnet Association

- In your NSG **nsg-aisec-vms**, click **Subnets** in the left navigation.
- Click **+ Associate**.

#### Configure Subnet Association

- **Virtual network**: Select **vnet-aisec-defender-portal**.
- **Subnet**: Select **subnet-vms**.
- Click **OK**.

### 🚀 Create Virtual Machines for Security Monitoring

Deploy virtual machines within the secure network infrastructure.

### Create VM 1 - Windows Server

#### Navigate to Virtual Machines

- In Azure Portal, search for **Virtual machines**.
- Click **+ Create** → **Virtual machine**.

#### Basic Configuration

- **Subscription**: Select your subscription.
- **Resource Group**: Select the resource group created in Step 1.
- **Virtual machine name**: **vm-windows-testlab001**.
- **Region**: Choose the same region as your resource group.
- **Image**: **Windows Server 2022 Datacenter: Azure Edition - x64 Gen2**.
- **Size**: **Standard_B2s** (cost-effective for testing).
- **Security type**: Select **Trusted launch virtual machines** (recommended for enhanced security).

#### Administrator Account

- **Username**: **azureuser**.
- **Password**: Create a strong password (save securely for later use).
- **Confirm password**: Re-enter password.

> **🔐 SECURITY IMPORTANT**: For production deployments, never hard-code passwords. Instead:
>
> - Store passwords securely in **Azure Key Vault**.
> - Use **Azure AD authentication** with certificates or managed identities.  
> - Enable **passwordless authentication** methods when possible.
> - Implement proper **secret rotation** and access policies.

#### Networking Configuration

Configure the VM to use the secure network infrastructure created earlier:

- **Virtual network**: Select **vnet-aisec-defender-portal** (created in previous step).
- **Subnet**: Select **subnet-vms (10.0.1.0/24)** (created in previous step).
- **Public IP**: **Create new** → Enter name **pip-vm-windows-testlab001**.
  - **SKU**: **Standard** (recommended for production workloads).
  - **Assignment**: **Static** (ensures consistent IP address).
- **NIC network security group**: Select **Advanced**.
- **Configure network security group**: Select **nsg-aisec-vms** (created in previous step).
- **Public inbound ports**: Select **None** (NSG rules will handle access).

> **🔐 NETWORK SECURITY NOTE**:
>
> - The VM will be deployed into the secure subnet with NSG protection.
> - RDP access is controlled through NSG rules rather than direct VM configuration.
> - This follows defense-in-depth security principles matching our IaC deployment.

#### Inbound Port Rules

The NSG rules created earlier will handle port access:

- **RDP (3389)**: Already configured in NSG for secure remote access.
- **Note**: This is for demo purposes only; restrict access in production environments.

#### Review and Create Windows VM

- Review settings and click **Create**.
- Wait for deployment to complete (typically 5-8 minutes).

### Create VM 2 - Ubuntu Linux

#### Create Second Virtual Machine

- Follow similar steps as above for creating a new VM.
- **Virtual machine name**: **vm-linux-testlab001**
- **Resource Group**: Select the same resource group
- **Region**: Choose the same region as your resource group
- **Image**: **Ubuntu Server 24.04 LTS - x64 Gen2**
- **Size**: **Standard_B1ms** (1 vCPU, 2 GB RAM - cost-effective for testing)
- **Security type**: Select **Trusted launch virtual machines** (recommended for enhanced security)

#### Authentication Configuration

- **Authentication type**: **SSH public key** (recommended for enhanced security)
- **Username**: **azureuser**
- **SSH public key source**: **Generate new key pair**
- **Key pair name**: **vm-linux-testlab001-key**

#### Linux VM Networking Configuration

Configure the Linux VM to use the same secure network infrastructure:

- **Virtual network**: Select **vnet-aisec-defender-portal** (same VNET as Windows VM).
- **Subnet**: Select **subnet-vms (10.0.1.0/24)** (same subnet as Windows VM).
- **Public IP**: **Create new** → Enter name **pip-vm-linux-testlab001**.
  - **SKU**: **Standard** (recommended for production workloads).
  - **Assignment**: **Static** (ensures consistent IP address).
- **NIC network security group**: Select **Advanced**.
- **Configure network security group**: Select **nsg-aisec-vms** (same NSG as Windows VM).
- **Public inbound ports**: Select **None** (NSG rules will handle SSH access).

> **🔐 NETWORK CONSISTENCY**: Both VMs are deployed in the same subnet for simplified network management and consistent security policies matching our IaC deployment architecture.

#### Linux VM Inbound Port Rules

The NSG rules created earlier will handle port access:

- **SSH (22)**: Already configured in NSG for secure remote access.

#### Review and Create Linux VM

- Review settings and click **Create**.
- **Download private key**: Save the SSH key securely for later access.
- Wait for deployment to complete (typically 5-8 minutes).

## ✅ Step 2 Network Infrastructure Verification

The portal guide has been updated to match our proven IaC deployment structure:

### **Network Infrastructure Alignment Confirmed:**

✅ **Virtual Network Creation**:

- Portal: `vnet-aisec-defender-portal` with `10.0.0.0/16`
- IaC: `vnet-${environmentName}-${resourceToken}` with `10.0.0.0/16`

✅ **Subnet Configuration**:

- Portal: `subnet-vms` with `10.0.1.0/24`
- IaC: `subnet-default` with `10.0.1.0/24`

✅ **Network Security Group**:

- Portal: `nsg-aisec-vms` with RDP/SSH rules.
- IaC: `nsg-${environmentName}-${resourceToken}` with identical rules.

✅ **VM Network Association**:

- Portal: VMs explicitly configured to use the created VNET and subnet.
- IaC: NICs reference `virtualNetwork.properties.subnets[0].id`.

### **Deployment Validation Steps:**

The portal guide now ensures that when VMs are created:

1. **Networking Tab Configuration** explicitly selects the created VNET and subnet.
2. **NIC Network Security Group** uses the Advanced option to reference the created NSG.
3. **Public IP Configuration** follows the same pattern as IaC (Static Standard SKU).
4. **Subnet Association** ensures both VMs are in the same secure subnet.

This maintains complete consistency between the manual Azure Portal deployment and our automated Infrastructure-as-Code approach, ensuring users learn the exact same architecture they would deploy through automation.

### Virtual Machine Deployment Results

After successful completion:

- **Network Infrastructure**: Secure virtual network with dedicated VM subnet and NSG protection.
- **Windows VM**: Running with modern security baseline configuration within secure subnet.
- **Linux VM**: Running with cross-platform security hardening within secure subnet.
- **Network Security**: NSG rules controlling RDP and SSH access with defense-in-depth architecture.
- **Extension Readiness**: VMs prepared for automatic security extension installation.

**Timeline**: 15-20 minutes for complete network infrastructure and VM deployment via Azure Portal.

---

## Step 3: Configure Security Policies and Defender Plans

Enable Defender for Cloud protection plans and establish security governance.

> **💰 COST AWARENESS**: This step enables premium Defender for Cloud plans which incur subscription-level costs:
>
> - **Defender for Servers Plan 2**: ~$15/server/month (comprehensive protection with agentless scanning)
> - **Defender for Storage**: ~$10/storage account/month (malware scanning and activity monitoring)
> - **Defender for Key Vault**: ~$2/vault/month (protection for cryptographic keys and secrets)
> - **Defender for Containers**: ~$7/vCore/month (security for containerized workloads)
> - **Foundational CSPM**: Free (Cloud Security Posture Management - included)
> - **Cost Management**: Plans can be disabled anytime to stop charges
>
> **💡 Cost Optimization**: This lab selectively enables only 4 out of 10+ available Defender plans, focusing on core infrastructure security while avoiding costs for services not deployed (App Service, Databases, AI Services, etc.). Estimated monthly savings: ~$50-100+ compared to enabling all plans.

### 🚀 Configure Defender Plans and Security Contacts

#### Access Environment Settings

- In the Defender for Cloud left navigation pane, click **Environment settings**.
- Select your subscription from the list.
- Review the current status of Defender plans.

#### Enable Defender for Servers Plan 2

- Find **Defender for Servers** in the plan list.
- Toggle the status to **On** for Plan 2 (recommended for full features).
- This automatically enables:
  - **Agentless scanning** for vulnerability assessment and security posture
  - **Defender for Endpoint integration** for endpoint protection
  - **Malware scanning** without performance impact

#### Configure Agentless Scanning (Enabled by Default)

- Agentless scanning is automatically enabled with Defender for Servers Plan 2.
- This provides:
  - Vulnerability assessment without agents.
  - Configuration assessment.
  - Malware scanning.
  - Software inventory.
- No additional configuration required - works out-of-the-box.

#### Enable Additional Defender Plans

Enable the same core plans as our IaC deployment:

- **Defender for Storage**: Toggle to **On** (ready for future storage resources)
- **Defender for Key Vault**: Toggle to **On** (ready for future vault resources)
- **Defender for Containers**: Toggle to **On** (ready for future container workloads)
- **Foundational CSPM**: Already enabled (free tier)

#### Configure Security Contacts

In Environment Settings, select **Email notifications**:

- **Define notification recipients** using one or both options:
  - **By Azure role**: Select from dropdown (Owner, Contributor, Security Admin, etc.).
  - **By email address**: Enter specific email addresses separated by commas.
- **Configure notification types**:
  - **Notify about alerts with the following severity (or higher)**: Select **High**.
  - **Notify about attack paths with the following risk level (or higher)**: Select **High**.
- Click **Save** to apply the email notification settings.

### What This Step Configures

**Defender for Cloud Plans:**

- ✅ **Defender for Servers Plan 2** - Comprehensive server protection with agentless scanning (protects deployed VMs).
- ✅ **Defender for Storage** - Malware scanning and activity monitoring for storage accounts (ready for future storage resources).
- ✅ **Defender for Key Vault** - Protection for cryptographic keys and secrets (ready for future vault resources).
- ✅ **Defender for Containers** - Security for containerized workloads (ready for future AKS/ACI/Container Apps).
- ✅ **Foundational CSPM** - Cloud Security Posture Management (free tier).

**Security Governance:**

- ✅ Security contact email notifications for critical alerts.
- ✅ Alert severity thresholds and notification preferences.
- ✅ Role-based notifications for subscription owners and contributors.
- ✅ Microsoft Cloud Security Benchmark (MCSB) compliance monitoring.

**Modern 2025 Features:**

- ✅ Agentless scanning for vulnerabilities and malware.
- ✅ Cross-platform endpoint protection integration.
- ✅ Cloud workload protection capabilities.
- ✅ Unified security posture management.

### Security Policy Configuration Results

After successful completion:

- **Defender Plans**: 4 core plans enabled with Standard tier pricing.
- **Security Contacts**: Email notifications configured and tested.
- **Compliance Dashboard**: MCSB showing initial compliance assessment.
- **Cost Estimation**: Monthly cost projections for enabled plans.

**Timeline**: 5-8 minutes for plan configuration and validation via Azure Portal.

---

- **Subscription**: Select your subscription.
- **Resource Group**: Select the resource group we just created.
- **Virtual machine name**: **vm-windows-server**.
- **Region**: Choose the same region as your resource group.
- **Image**: **Windows Server 2022 Datacenter: Azure Edition - x64 Gen2**.
- **Size**: **Standard_B2s** (cost-effective for testing) - you may need to select **See all sizes** to find this VM size.
- **Security type**: Select "**Trusted launch virtual machines**" (recommended for enhanced security).
  - This enables Secure Boot, vTPM, and integrity monitoring for protection against boot kits and rootkits.
  - Trusted Launch is the default for Gen2 VMs and provides verified boot loaders and OS kernels.

#### Windows VM Administrator Account

- **Username**: **azureuser**.
- **Password**: Create a strong password.
- **Confirm password**: Re-enter password.

#### Windows VM Inbound Port Rules

- Allow selected ports: RDP (3389), HTTP (80), HTTPS (443).
- **Note**: This is for demo purposes only; restrict access in production environments.

#### Review and Create VM

- Review settings and click **Create**.
- Wait for deployment to complete.

### Create VM 2 - Ubuntu Linux Server

Follow similar steps as above for creating a new VM:

- **Virtual machine name**: **vm-linux-db**.
- **Resource Group**: Select the resource group we created.
- **Region**: Choose the same region as your resource group.
- **Image**: **Ubuntu Server 24.04 LTS - x64 Gen2**.
- **Size**: **Standard_B1ms** (1 vCPU, 2 GB RAM - cost-effective for small database testing).
  - Alternative: **Standard_B2ms** (2 vCPU, 8 GB RAM) if planning heavier database workloads.
  - B-series VMs are ideal for small databases and development environments with burstable performance.
- **Security type**: Select **Trusted launch virtual machines** (recommended for enhanced security).
  - Provides secure boot and vTPM for Linux environments.
  - Note: You may disable Secure Boot if using custom unsigned kernel drivers.
- **Authentication type**: SSH public key or Password.
  - **Recommended**: Select **SSH public key** for enhanced security.
  - **SSH key type**: Use **ED25519** (modern, secure, and efficient).
    - Alternative: RSA with minimum 2048 bits (legacy compatibility).
    - ED25519 provides better security and performance than RSA.
  - **Key pair name**: Enter a Key pair name such as **vm-linux-db-key** (descriptive naming convention).
    - Use consistent naming that identifies the VM and purpose.
- **Inbound ports**: SSH (22), HTTP (80).

### Create VM 3 - Windows Client (Optional)

Follow similar steps as above for creating a new VM:

- **Virtual machine name**: **vm-windows-client**.
- **Resource Group**: Select the resource group we created.
- **Region**: Choose the same region as your resource group.
- **Image**: **Windows 10 Pro, version 22H2 - x64 Gen2**.
- **Size**: **Standard_B2ms** (2 vCPU, 8 GB RAM - meets Windows 10 requirements).
  - Alternative: **Standard_B4ms** (4 vCPU, 16 GB RAM) for better performance with applications.
  - B-series provides cost-effective burstable performance for client workloads.
- **Administrator account**: Use the same administrator account as VM1 for simplicity, or create a new one if you prefer.
- **Security type**: Select **Trusted launch virtual machines** (recommended for enhanced security).
  - Provides TPM 2.0 and secure boot capabilities for Windows 10.
  - Trusted Launch enhances security with verified boot loaders and OS kernels.
- **Inbound ports**: RDP (3389).

📸 **[View Azure VM Creation Guide](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal)**

---

## Step 6: Verify Modern Agent Architecture

**Navigate back to Defender for Cloud**: Once all virtual machines are created, use the Azure Portal search bar to search for **Microsoft Defender for Cloud** and select it to return to the main Defender for Cloud interface.

### Check Defender for Servers Settings and Status

- Navigate to **Environment settings** → Your subscription.
- Under **Cloud Workload Protection** → **Servers**, click **Settings**.
- Verify the following settings are enabled and operational:
  - **Agentless scanning for machines**: Check that this shows as **On**.
  - **Endpoint protection**: Verify the status shows as **On**.
  - **Vulnerability assessment for machines**: Confirm this is enabled (part of agentless scanning).
- Click **Save** if any changes were made.

### Navigate to Workload Protections

- From the main Defender for Cloud interface, click **Workload protections** in the left navigation menu.
- This displays the interactive Workload protections dashboard with four main sections:
  - **Defender for Cloud coverage section**: Shows resource types eligible for protection and coverage status.
  - **Security alerts section**: Shows current security alerts (likely empty in new deployments).
  - **Advanced protection section**: Shows status of protection capabilities.
  - **Insights section**: Provides customized items for your environment.
- **Expected timeline**: Protection status may take 15-30 minutes to fully populate after VM creation.

### Monitor VM Protection Status

- Navigate to **Inventory** in Defender for Cloud.
- Review your VMs in the asset inventory page.
- Select individual VMs to view their security posture, recommendations, and alerts.
- Allow 15-30 minutes for initial agentless scanning to complete.

📸 **[View Data Collection Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/enable-data-collection)**

---

## Step 7: Configure Security Policies

### Access Security Policies

- In Defender for Cloud, navigate to **Environment settings**.
- Select your subscription from the list.
- Select **Security policies**.
- You'll see the **Microsoft Cloud Security Benchmark (MCSB)** policy automatically assigned to your subscription.

### Review MCSB Compliance

- The Microsoft Cloud Security Benchmark is enabled by default and provides comprehensive security recommendations.
- This standard includes controls for identity management, network security, data protection, and more.
- **To access and review the compliance dashboard:**
  - From the main Defender for Cloud menu, navigate to **Regulatory compliance** in the left navigation pane
  - **What you'll see in the current Regulatory Compliance dashboard:**
    - **Applied standards**: Shows which compliance standards are currently assigned to your subscription (Microsoft Cloud Security Benchmark is enabled by default).
    - **Overall compliance percentage** for each standard with visual progress bars.
    - **Controls summary**: Each standard shows passed/failed controls with specific counts.
    - **Resource assessment status**: Breakdown of compliant vs. non-compliant resources.
  - **How to review compliance details:**
    - **Select a compliance standard** (e.g., Microsoft Cloud Security Benchmark) to drill down into specific controls.
    - **Click individual controls** to see associated security assessments and affected resources.
    - **View control details** including Overview, Your Actions (automated/manual assessments), and Microsoft Actions tabs.
    - **Access remediation guidance** by clicking on failed assessments to see specific steps to fix issues.
  - **Additional dashboard capabilities:**
    - **Download compliance reports** using the download button at the top of the dashboard.
    - **Track compliance over time** with trend indicators.
    - **Filter by subscription** for environments with multiple subscriptions.

### Add Additional Compliance Standards (Optional)

**Prerequisites**: Ensure you have `Owner` or `Policy Contributor` permissions on the subscription.

### Steps to Add More Standards

- In the left navigation, select **Environment settings**.
- Locate your subscription in the list (you may need to expand management groups by selecting **Expand all**).
- In the left navigation bar, select **Security policy**.
- Browse the available standards under **Standards**.
- Enable desired standards by selecting **Enable** on each standard's row.

### Available Standards

- PCI DSS.
- ISO 27001.
- SOC 2.
- NIST Cybersecurity Framework.
- HIPAA (if applicable).
- Microsoft cloud security benchmark (enabled by default).
- Azure Security Benchmark (legacy).

### Recommended Standards for New Deployments

#### For Most Organizations Starting with Defender for Cloud

- **Microsoft Cloud Security Benchmark (MCSB)**: Already enabled by default - provides comprehensive baseline security controls.
- **NIST Cybersecurity Framework**: Excellent starting point for organizations new to compliance frameworks.
  - Currently based on **NIST CSF v2.0** (newer versions may be available after the time of this writing).
  - Well-documented and widely adopted.
  - Good balance of security controls without excessive complexity.
  - Helpful for establishing foundational security practices.

##### NIST CSF v2.0 Configuration for Demo Environments

When enabling NIST CSF v2.0, a **Set parameters** page appears. Here are the recommended settings for new demo configurations:

- **Members to exclude**: Leave empty.
- **Operation name (Field 1)**: Select **Microsoft.Authorization/policyAssignments/write** (recommended for demo environments).
  - Available options: Microsoft.Authorization/policyAssignments/write, Microsoft.Authorization/policyAssignments/delete.
  - Choose **write** to enable policy assignment capabilities for compliance assessment.
- **Operation name (Field 2)**: Select **Microsoft.Network/NetworkSecurityGroups/write** (recommended for comprehensive network security coverage).
  - Available options: Microsoft.Sql, Microsoft.Network, Microsoft.ClassicNetwork.
  - Microsoft.Network provides modern networking security assessments.
- **Members to include**: Enter **"*"** (asterisk) to include all available controls (required field for comprehensive demo coverage).

##### Recommended Settings Explanation

- **Members to include with asterisk**: The asterisk (*) includes all NIST CSF v2.0 controls across all six functions (Identify, Protect, Detect, Respond, Recover, Govern) - this field is required and cannot be left empty.
- **Empty exclusion list**: No controls are excluded, ensuring full framework coverage for learning purposes.
- **Write operation selection**: Enables policy assignment functionality needed for compliance assessments.
- **Modern network provider**: Microsoft.Network covers current Azure networking security rather than legacy Classic networking.
- **Full coverage approach**: Provides comprehensive learning experience with all NIST CSF controls active.

   **Note**: These settings enable complete NIST CSF v2.0 assessment with modern Azure services while remaining easy to configure for demonstration and learning purposes.

#### For Specific Industry Requirements

- **SOC 2 Type II**: Recommended for service organizations handling customer data (SaaS companies, service providers).
- **PCI DSS**: Essential if handling credit card data (retail and payment processing organizations).
- **HIPAA**: Required for healthcare entities handling PHI (Protected Health Information).

#### Standards to Avoid for Beginners

- **ISO 27001**: While excellent, it's quite comprehensive and may be overwhelming for new deployments.
- **Azure Security Benchmark (legacy)**: Being phased out in favor of MCSB.

   **Best practice recommendation**: Start with **MCSB + NIST Cybersecurity Framework** for most new deployments, then add industry-specific standards as needed.

   **Note**: For organizations requiring advanced policy customization beyond the standard compliance frameworks, Azure Policy provides powerful capabilities for creating custom governance rules. This includes creating custom policy definitions, organizing policies into initiatives, and assigning them across management groups for organization-wide governance. Most users will find the default MCSB sufficient for comprehensive security coverage, but Azure Policy offers extensive customization options for specific organizational requirements.

   📸 **[Azure Policy Overview and Management Guide](https://learn.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage)**

📸 **[View Security Policy Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/security-policy-concept)**

---

## Step 8: Review Modern Security Recommendations

### Access Recommendations

- Navigate to **Recommendations** in the Defender for Cloud menu.
- Wait 15-30 minutes after VM creation for initial agentless assessment.
- Review the list of security recommendations powered by agentless scanning.

### Understanding Blurred Out Columns (Expected Behavior)

- **Risk factors**, **Attack paths**, and **Owner** columns will appear **blurred out** in new deployments.
- **This is normal behavior** when using the free Foundational CSPM plan.
- These advanced risk prioritization features require the **Defender CSPM plan** (paid upgrade, $5/billable resource/month).
- **What you'll see with Foundational CSPM:**
  - Recommendation title and description.
  - Affected resources.
  - Basic severity levels.
  - Remediation steps.
- **What requires Defender CSPM upgrade:**
  - Risk factors (internet exposure, sensitive data, lateral movement potential).
  - Attack paths analysis and visualization.
  - Recommendation ownership and governance features.
  - Advanced risk prioritization based on environmental context.
- **To enable these features**: Navigate to Environment Settings → Your subscription → Enable **Defender CSPM** plan.

### Common Modern Recommendations (2025)

- Enable disk encryption on virtual machines.
- Install endpoint protection solution on machines (via Defender for Endpoint).
- Apply system updates (now powered by Azure Update Manager integration).
- Enable Network Security Groups on subnets.
- Enable backup on virtual machines.
- Resolve endpoint detection and response (EDR) solution recommendations.
- Remediate vulnerabilities found in container images (agentless).

### Implement Available Recommendations

- **Initial state**: Most recommendations will show as **Not Evaluated** in new deployments.
- **Wait for assessment**: Allow 15-30 minutes for initial agentless scanning to complete.
- **Start with available recommendations**: Focus on recommendations that show actual severity levels (not **Not Evaluated**).
- **Common first recommendations to address:**
  - Basic security configurations that can be immediately assessed.
  - VM-level settings that don't require extended scanning time.
  - Network security group configurations.
- **Use Quick fix options**: When available, these provide automated remediation (expanded automation in 2025).
- **Manual remediation**: Follow the detailed remediation steps for recommendations without quick fix options.
- **Note**: Risk-based prioritization and severity levels become more accurate as the agentless scanning completes its initial assessment cycle.

📸 **[View Recommendations Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/review-security-recommendations)**

---

## Step 9: Configure Alerts and Notifications

### Set up Email Notifications

- Navigate to **Microsoft Defender for Cloud** → **Environment settings**.
- Select your subscription from the list.
- Select **Email notifications** from the left navigation.
- **Define notification recipients** using one or both options:
  - **By Azure role**: Select from dropdown (Owner, Contributor, Security Admin, etc.).
  - **By email address**: Enter specific email addresses separated by commas.
- **Configure notification types**:
  - **Notify about alerts with the following severity (or higher)**: Select severity level (High, Medium, Low).
  - **Notify about attack paths with the following risk level (or higher)**: Select risk level (Critical, High, Medium, Low).
- Click **Save** to apply the email notification settings.
- **Note**: By default, subscription owners receive notifications for high-severity alerts and attack paths.

📸 **[View Email Notifications Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/configure-email-notifications)**

---

## Step 10: Configure Modern Advanced Threat Protection Features

### Just-in-Time VM Access

#### Just-in-Time VM Access Benefits

- **Reduces attack surface** by closing management ports when not needed.
- **Prevents brute force attacks** against RDP/SSH ports.
- **Provides controlled access** with time-limited, audited connections.
- **Maintains operational efficiency** while enhancing security posture.
- **Integrates with Azure RBAC** for role-based access control.

#### Just-in-Time VM Access Configuration

- Navigate to **Workload protections** → **Just-in-time VM access**.
- Select the **Not Configured** tab.
- Select your VMs and click **Enable JIT on X VMs**.
- Configure allowed ports and time windows.
- This reduces attack surface by limiting VM access.

### Agentless Malware Scanning

#### Agentless Malware Scanning Benefits

- **Zero performance impact** on virtual machines during scanning.
- **Comprehensive malware detection** without agent installation overhead.
- **Continuous monitoring** for threats across all VM files and processes.
- **Cost-effective** solution with no additional licensing per VM.
- **Cloud-native approach** leveraging Azure's scanning infrastructure.

#### Agentless Malware Scanning Configuration

- Automatically enabled with Defender for Servers Plan 2.
- Provides comprehensive malware detection without performance impact.
- Integrates with Defender for Endpoint for enhanced protection.
- View results in Security Alerts and Defender XDR.

### Endpoint Detection and Response (EDR)

#### EDR Benefits

- **Advanced threat hunting** capabilities across all endpoints.
- **Behavioral analysis** to detect sophisticated attacks and living-off-the-land techniques.
- **Automated investigation** and response to reduce security team workload.
- **Historical forensics** for post-incident analysis and threat intelligence.
- **Integration with Microsoft Defender XDR** for unified security operations.

#### EDR Configuration

- Automatically available through Defender for Endpoint integration.
- Provides behavioral analysis and advanced threat hunting.
- No additional configuration required.
- Access advanced features through Microsoft Defender XDR portal.

📸 **[View Just-in-Time Access Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)**

---

## Step 11: Monitor Security Alerts

### Access Security Alerts

- Navigate to **Security alerts** in Defender for Cloud.
- Initially, you may not see alerts (they appear as threats are detected).

### Generate Sample Alerts (Recommended Method)

Microsoft Defender for Cloud provides a built-in sample alert generation feature that's the easiest and safest way to test your alert configuration:

#### Steps to Generate Sample Alerts

- Navigate to **Security alerts** in Defender for Cloud.
- Click **Sample alerts** in the toolbar.
- Select your subscription from the dropdown.
- Select the relevant Microsoft Defender plan(s) you want to test:
  - **Defender for Servers**: Tests VM-related threat detection.
  - **Defender for Storage**: Tests storage account threat detection.
  - **Defender for Containers**: Tests container security alerts.
  - **Defender for App Service**: Tests web application security alerts.
- Click **Create sample alerts**.
- **Requirements**:
  - **Subscription Contributor** role or higher.
  - Relevant Defender plans must be enabled on your subscription.
- **Results**:
  - Sample alerts appear within 2-5 minutes.
  - Alerts are clearly marked as simulated/test resources.
  - Triggers all configured notifications (email, SIEM, workflow automation).
  - Safe to run multiple times without impacting production systems.

##### Alternative Alert Generation Methods (for advanced testing)

- **Agentless Malware Testing**: Run PowerShell test scripts on VMs to test malware detection (results in 24 hours).
  📸 **[Learn More: Test Agentless Malware Scanning](https://learn.microsoft.com/en-us/azure/defender-for-cloud/test-agentless-malware-scanning)**
- **Defender for Endpoint Simulation**: Execute specific commands to simulate endpoint attacks (results in 10 minutes, requires admin access).
  📸 **[Learn More: Validate Alerts in Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alert-validation)**
- **EICAR Test File**: Create harmless test files to trigger antimalware alerts (immediate detection, safe for all environments).
  📸 **[Learn More: EICAR Test File Standard](https://learn.microsoft.com/en-us/defender-endpoint/configure-extension-file-exclusions-microsoft-defender-antivirus#validate-exclusions-lists-with-the-eicar-test-file)**

### Alert Investigation

When you click any alert in Defender for Cloud, the detailed investigation interface appears:

#### Initial Alert View (Side Pane)

- **Alert overview**: Description of the detected activity and precise explanation.
- **Alert severity**: High, Medium, or Low priority classification.
- **Status**: New, Active, Dismissed, or Resolved.
- **Activity time**: When the threat was first detected and last activity.
- **Affected resources**: List of VMs, storage accounts, or other resources involved.
- **MITRE ATT&CK mapping**: Shows the attack technique classification (if applicable).

#### Full Details View

Click **View full details** to access comprehensive information across two main tabs:

#### Alert Details Tab

- **Technical details**: IP addresses, file hashes, processes, network connections.
- **Evidence**: Specific indicators of compromise (IoCs) detected.
- **Entities involved**: Users, devices, files, and other components affected.
- **Attack timeline**: Chronological sequence of malicious activities.
- **Raw data**: Log entries and telemetry supporting the alert.

#### Take Action Tab

- **Inspect resource context**: Direct link to resource activity logs and monitoring data.
- **Mitigate the threat**: Step-by-step manual remediation instructions specific to the alert.
- **Prevent future attacks**: Security recommendations to reduce attack surface.
- **Trigger automated response**: Option to launch Logic Apps or automated workflows.
- **Suppress similar alerts**: Configuration to prevent false positives for similar activities.

#### Investigation Best Practices

- Review the **MITRE ATT&CK technique** to understand the attack methodology.
- Check **affected resources** to determine the scope of potential compromise.
- Use **Inspect resource context** to validate the alert against normal activity patterns.
- Follow **mitigation steps** in priority order based on alert severity.
- Implement **prevention recommendations** to strengthen security posture.
- **Mark alerts as resolved** only after confirming remediation is complete.

---

## Step 12: Set Up Workbooks and Dashboards

### Access Workbooks

- Navigate to **Workbooks** in Defender for Cloud.
- The **Defender for Cloud gallery** displays 9 pre-built workbooks ready for customization:

#### Recommended Starting Workbook: Coverage Workbook

##### Purpose

Track which Defender for Cloud plans are active across your subscriptions and environments.

##### What You'll See Based on Your Deployment

- **Environment Selection**: Choose Azure (since you've deployed Azure VMs).
- **Subscription Overview**: Your subscription with enabled/disabled plan status.
- **Four Main Tabs**:
  - **Additional information**: Release notes and feature explanations.
  - **Relative coverage**: Percentage showing 100% coverage for enabled plans (Defender for Servers Plan 2).
  - **Absolute coverage**: Plan status per subscription - you'll see:
    - ✅ **Foundational CSPM**: Enabled (free tier).
    - ✅ **Defender for Servers**: Enabled (Plan 2).
    - ❌ **Other plans**: Disabled (Storage, Containers, App Service, etc.).
  - **Detailed coverage**: Additional settings status including:
    - ✅ **Agentless scanning**: Enabled.
    - ✅ **Endpoint protection**: Enabled via Defender for Endpoint.
    - ❌ **Vulnerability assessment settings**: May show as partially configured initially.

##### Expected Results for New Deployment

- **Green indicators** for Foundational CSPM and Defender for Servers.
- **Coverage percentage**: ~22% (2 out of 9 main plans enabled).
- **Resource count**: Your 2-3 VMs showing as protected resources.
- **Environment status**: Azure environment fully onboarded.

##### Other Available Workbooks

Explore after initial setup:

- **Secure Score Over Time**: Tracks security posture improvements (requires continuous export setup).
- **Active Alerts**: Displays current security alerts by severity and type.
- **Compliance Over Time**: Shows regulatory compliance trends for enabled standards (MCSB, NIST CSF if added).
- **System Updates**: Missing updates across your VMs (populated after agentless scanning completes).
- **Vulnerability Assessment Findings**: Vulnerability scan results from agentless scanning.
- **Price Estimation**: Monthly cost estimates for enabled Defender plans.

### Review Key Workbooks

#### Coverage Workbook

Start here to understand your current protection status:

- Shows which Defender plans are enabled across your subscription.
- Displays coverage percentage (~22% for your basic deployment with CSPM + Servers).
- Confirms your 2-3 VMs are being protected.
- Use the default view - no customization needed for initial assessment.

#### Active Alerts

Monitor security events as they occur:

- Initially empty in new deployments.
- Will populate with real or sample alerts.
- Provides severity-based filtering and investigation links.

### Create Custom Dashboard

- Go to Azure Portal dashboard (portal.azure.com main page).
- Click **+ Create** → **Custom dashboard**.
- **Add Defender for Cloud tiles**:
  - **Security alerts tile**: Shows current alert count and severity distribution.
  - **Secure score tile**: Displays current security posture percentage.
  - **Compliance tile**: Shows MCSB compliance percentage.
  - **Recommendations tile**: Active security recommendations count.
- **Pin workbook**: Pin your customized Coverage workbook for quick access.
- **Share dashboard**: Click **Share** to make it available to your security team.

### Validation Steps

- **Coverage Workbook**: Verify it shows your 2-3 VMs as protected resources.
- **Secure Score**: Should start appearing within 24 hours showing initial baseline score.
- **Compliance Dashboard**: Should show MCSB standard with initial assessment results.
- **Alerts Section**: Will be empty initially but ready to display future threats.

📸 **[View Workbooks and Dashboards Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/custom-dashboards-azure-workbooks)**

---

## 🔧 Advanced Configuration: Modern Data Export and SIEM Integration

**2025 Modern Approach**: Instead of requiring Log Analytics workspaces for basic data collection, Defender for Cloud now uses **Continuous Export** and **native connectors** for integration with SIEM solutions like Microsoft Sentinel, providing a cleaner, more efficient approach.

### When Advanced Data Export is Required

Modern data export and integration is essential for:

- **Microsoft Sentinel Integration** - Centralized SIEM with native Defender for Cloud connector.
- **Third-Party SIEM Integration** - Stream to Splunk, QRadar, ServiceNow, etc.
- **Advanced Analytics** - Custom KQL queries and correlation rules.
- **Compliance Reporting** - Long-term data retention for audit requirements.
- **Cross-Platform Correlation** - Integration with Microsoft Defender XDR.
- **Custom Automation** - Logic Apps and automated response workflows.

### Modern Data Collection Architecture (2025)

#### Primary Methods

- **Agentless Data Collection** - Built-in, no additional configuration required.
- **Continuous Export** - Stream alerts and recommendations to external systems.
- **Native SIEM Connectors** - Direct integration without Log Analytics dependency.
- **File Integrity Monitoring** - Uses Defender for Endpoint agent (modern approach).

#### Legacy Methods (Deprecated)

- ❌ Log Analytics agent (MMA) - Being phased out.
- ❌ Manual Log Analytics workspace integration - Replaced by Continuous Export.

### Step 1: Configure Modern Microsoft Sentinel Integration

#### Method 1: Native Sentinel Connector (Recommended)

This is the preferred 2025 approach - the Log Analytics workspace is created for Sentinel, then the native connector handles all Defender for Cloud integration automatically.

#### Step 1a: Create Log Analytics Workspace for Sentinel

##### Navigate to Log Analytics Workspaces in Azure Portal

- In Azure Portal, search for **Log Analytics workspaces**.
- Click **+ Create** to create a new workspace.

##### Configure Workspace Settings

- **Subscription**: Select your subscription.
- **Resource group**: Use your existing resource group (e.g., **rg-Project-AiSecuritySkillsChallenge**).
- **Name**: Enter a descriptive name (e.g., **law-sentinel-security-operations**).
- **Region**: Choose the same region as your VMs for optimal performance and compliance.
- **Pricing tier**:
  - **Pay-as-you-go (Per GB)**: Recommended for most scenarios.
  - **Commitment Tiers**: Available for predictable, high-volume data ingestion (100GB+/day).

##### Review and Create

- Click **Review + create**.
- After validation passes, click **Create**.
- Wait for deployment to complete (typically 2-3 minutes).

#### Step 1b: Enable Microsoft Sentinel

##### Navigate to Microsoft Sentinel

- In Azure Portal, search for **Microsoft Sentinel**.
- Click **+ Create** or **+ Add**.

##### Onboard Sentinel to Workspace

- **Select workspace**: Choose the Log Analytics workspace you just created.
- **Add Microsoft Sentinel to workspace**: Click **Add**
- **Pricing tier confirmation**: Sentinel pricing is based on data ingestion volume
- Wait for Sentinel onboarding to complete (typically 3-5 minutes)

##### Verify Sentinel Setup

- The Microsoft Sentinel overview dashboard will now appear.
- Initial setup is complete and ready for data connector configuration.

#### Step 1c: Install and Configure Defender for Cloud Connector in Sentinel

##### Install Connector from Content Hub

- In Microsoft Sentinel, navigate to **Content management** → **Content hub** in the left menu.
- In the Content Hub, search for **Microsoft Defender for Cloud**.
- Find the **Microsoft Defender for Cloud** solution (by Microsoft).
- Click the solution tile to view details.
- Click **Install** to install the Defender for Cloud solution.
- Wait for installation to complete (typically 2-3 minutes).
- **Note**: This installs the data connector, workbooks, analytics rules, and other related content.

##### Access Data Connectors

- After installation, navigate to **Configuration** → **Data connectors** in the left menu.
- **Two Microsoft Defender for Cloud connector options** will appear in the available connectors list:
  - **Subscription-based Microsoft Defender for Cloud (Legacy)** - older connector model.
  - **Tenant-based Microsoft Defender for Cloud** - modern connector (recommended for 2025).

##### Select the Modern Tenant-Based Connector

- Click the **Tenant-based Microsoft Defender for Cloud** connector tile.
- Click **Open connector page** to access configuration.
- **Why choose Tenant-based over Subscription-based:**
  - **Multi-subscription support**: Automatically collects data from all subscriptions in your tenant.
  - **Simplified management**: Single connector configuration instead of per-subscription setup.
  - **Better scalability**: Designed for enterprise environments with multiple subscriptions.
  - **Future-proof**: Microsoft's recommended approach for new deployments in 2025.
  - **Unified view**: Centralized security posture across all tenant subscriptions.

##### Configure Tenant-Based Connector (When Connected via Defender XDR)

##### Current Interface Layout

- **Left Panel**: Shows connection status, description, and additional solution components.
  - **Connection Status**: **Connected** (via Microsoft Defender XDR integration).
  - **Description**: Overview of the tenant-based connector capabilities.
  - **Additional Components**: Workbooks, Queries, and Analytics Rules templates available.
- **Middle Panel**: Prerequisites verification and configuration options.
  - **Prerequisites**: All items should show as checked/completed.
  - **Configuration Panel**: Limited options since Defender XDR handles the connection.

##### What This Means

- **Automatic Integration**: Microsoft Defender XDR is already connected and handling Defender for Cloud data ingestion.
- **No Manual Configuration Needed**: The tenant-wide connection is managed through Defender XDR.
- **Modern Architecture**: This represents the latest 2025 approach where XDR serves as the central integration hub.

##### Recommended Verification Steps

###### Confirm Prerequisites (Should All Be Checked)

- ✅ **Workspace**: Read and write permissions confirmed.
- ✅ **Connector Access Control**: User is member of the Microsoft Entra ID associated with the tenant that the workspace belongs to.
- ✅ **Tenant Permissions**: **Security Administrator** or **Global Administrator** on the workspace's tenant.

###### Explore Available Components

- **Workbooks**: Click to view pre-built Defender for Cloud workbooks.
- **Queries**: Access sample KQL queries for threat hunting.
- **Analytics Rules Templates**: Pre-configured detection rules for Defender for Cloud alerts.

###### Verify Data Flow Through XDR

- **Microsoft Defender XDR Portal**: Navigate to [security.microsoft.com](https://security.microsoft.com).
- **Incidents Section**: Should show Defender for Cloud alerts as incidents.
- **Advanced Hunting**: Use KQL to query Defender for Cloud data across the tenant.

##### Configuration Notes

- **No Disconnect Option**: This is expected when XDR integration is active.
- **Tenant-Wide Coverage**: Automatically includes all subscriptions where Defender for Cloud is enabled.
- **Incident Creation**: Defender for Cloud alerts automatically become XDR incidents.
- **Bi-directional Sync**: Managed automatically through XDR integration.

##### Benefits of XDR Integration

- ✅ **Unified Security Operations**: All security tools managed from single portal.
- ✅ **Cross-Platform Correlation**: Alerts correlated with endpoint, identity, and email threats.
- ✅ **Simplified Management**: No manual connector configuration required.
- ✅ **Enhanced Investigation**: Full attack timeline across all Microsoft security products.
- ✅ **Automatic Updates**: Integration maintained by Microsoft without manual intervention.

#### Verify XDR Integration is Working (Recommended Primary Approach)

Microsoft Defender XDR is the preferred 2025 approach for Defender for Cloud integration as it provides:

- **Native integration** with immediate data flow.
- **Cross-platform correlation** with endpoint, identity, and email threats.
- **Unified incident management** across all Microsoft security products.
- **Real-time alert processing** without additional configuration.

##### Primary Data Flow Verification (Defender XDR)

###### Navigate to Defender XDR Portal

Go to [security.microsoft.com](https://security.microsoft.com)

###### Find Incidents

- Click **Incidents & alerts** in the left navigation.
- Select **Incidents** tab.
- Look for incidents with **Source: Microsoft Defender for Cloud**.
- **Sample Alert Identification**: Sample alerts will show:
  - Resource names containing **Sample** or test identifiers.
  - Alert descriptions mentioning **This is a sample alert**.
  - Activity on resources that don't exist in your actual environment.

###### Find Individual Alerts

- In **Incidents & alerts**, select **Alerts** tab.
- Filter by **Product name: Microsoft Defender for Cloud**.
- **Sample Alert Identification**: Look for:
  - Alert titles with **(Sample)** or similar test indicators.
  - Affected resources with names like **sample-vm** or test resource identifiers.
  - Alert descriptions explicitly stating this is a test/sample alert.

##### Secondary Data Flow Verification (Microsoft Sentinel - Optional)

**Important Note about Timing**: Sentinel workspaces created **after** generating sample alerts will **not** display those alerts. This occurs because:

- **Defender for Cloud alerts are retained for 90 days** in the Defender for Cloud portal and XDR.
- **Sentinel only receives alerts generated after the connector is configured**.
- **Historical alerts are not backfilled** when creating a new workspace or enabling the connector.
- **Sample alerts generated before workspace creation will only appear in Defender XDR**.

##### To verify Sentinel integration (for workspaces created before alert generation)

###### Navigate to Sentinel

Go to your Microsoft Sentinel workspace in the Azure portal

###### Access Incident Management

- Click **Threat management** → **Incidents** in the left menu.
- Look for incidents with **Product name: Microsoft Defender for Cloud**.
- **Sample Alert Identification**: Sample incidents will show:
  - Incident titles referencing sample or test scenarios.
  - Entity details pointing to non-existent or test resources.
  - Investigation graphs showing simulated attack patterns.

###### Find Raw Alerts

- Navigate to **Logs** in the left menu.
- Run this query to see all Defender for Cloud alerts:

```kql
SecurityAlert
| where ProductName == "Azure Security Center"
| where TimeGenerated > ago(2h)
| project TimeGenerated, AlertName, AlertSeverity, Entities, Description
| order by TimeGenerated desc
```

- **Note**: The ProductName field contains **Azure Security Center** for historical compatibility reasons, even though the service is now called Microsoft Defender for Cloud.
- **Sample Alert Identification in Logs**: Look for:
  - **AlertName** fields containing **Sample** or test identifiers.
  - **Description** fields mentioning this is a sample/test alert.
  - **Entities** pointing to resources with test/sample naming patterns.

##### If Sample Alerts Don't Appear in Sentinel

- **Expected behavior** if workspace was created after sample alert generation.
- **Solution**: Generate new sample alerts (refer to Step 11) after Sentinel connector is configured.
- **Alternative**: Focus on Defender XDR portal for immediate verification and use Sentinel for future alerts.

##### Expected Sample Alert Types (from Step 11)

- **VM Alerts**: **Sample alert: suspicious process detected** on sample VMs.
- **Storage Alerts**: **Sample alert: unusual data access** on test storage accounts.
- **Container Alerts**: **Sample alert: malicious container activity** on sample container resources.
- **App Service Alerts**: **Sample alert: web shell detected** on test web applications.

##### Timeline Expectations

- **Sample alerts**: Appear within 2-5 minutes of generation.
- **Incident creation**: Sample alerts become incidents within 5-10 minutes.
- **Cross-platform correlation**: XDR correlates sample alerts with simulated activity within 10-15 minutes.

##### Integration Benefits Already Active

- ✅ **Automatic data streaming**: No Continuous Export configuration needed.
- ✅ **Built-in incident creation**: Defender for Cloud alerts become XDR incidents automatically.
- ✅ **Cross-platform correlation**: Alerts correlated with endpoint, identity, and email data.
- ✅ **Optimized data management**: Single pane of glass for all security operations.
- ✅ **Real-time alert processing**: Immediate alert availability in XDR portal.

#### Benefits of Native Connector

- ✅ **No manual Log Analytics configuration needed in Defender for Cloud**.
- ✅ **Automatic data streaming without Continuous Export setup**.
- ✅ **Built-in incident creation and correlation**.
- ✅ **Optimized data ingestion and cost management**.
- ✅ **Real-time alert streaming** (within 2-5 minutes).
- ✅ **Native security recommendations integration**.

#### Step 1d: Verify Integration

##### Check Connector Status

- In the Defender for Cloud connector page, status should show **Connected**.
- **Data received**: May show **No data** initially - this is normal.

##### Test Integration with Sample Alerts

- Generate sample alerts in Defender for Cloud (refer to Step 11 in main guide).
- In Microsoft Sentinel, navigate to **Threat management** → **Incidents**.
- Verify incidents are automatically created within 5-10 minutes.
- **Expected results**:
  - New incidents with **Microsoft Defender for Cloud** as the product name.
  - Incidents inherit alert severity (High, Medium, Low).
  - Full alert details and investigation timeline preserved.

##### Validate Data Flow in Microsoft Sentinel

**This step tests the SecurityAlert table in Microsoft Sentinel** to confirm that Defender for Cloud alerts are being ingested into your Sentinel workspace through the data connector.

###### Steps

- Navigate to **Logs** in Microsoft Sentinel.
- Run this KQL query to verify Sentinel data collection:

```kql
// Query SecurityAlert table in Microsoft Sentinel workspace for Defender for Cloud alerts
SecurityAlert
| where TimeGenerated > ago(1h)
| where ProductName == "Azure Security Center" //Azure Security Center is the legacy name for Microsoft Defender for Cloud
| summarize count() by AlertName, AlertSeverity
| order by count_ desc
```

#### What This Tests

- ✅ **Sentinel data ingestion**: Confirms alerts are flowing into Sentinel SecurityAlert table from Defender for Cloud.
- ✅ **Connector functionality**: Verifies the tenant-based Defender for Cloud connector is working.
- ✅ **Data transformation**: Ensures alerts are properly formatted for Sentinel analysis.
- ✅ **Historical retention**: Shows alerts stored in Sentinel for long-term analysis.

#### Expected Results in Sentinel

- Sample alerts with `ProductName == "Azure Security Center"`.
- Alert counts grouped by name and severity.
- TimeGenerated timestamps showing when alerts entered Sentinel.

#### If No Results in Sentinel

- **Common cause**: Sentinel workspace created after sample alert generation.
- **Solution**: Generate new sample alerts (Step 11) after Sentinel connector configuration.
- **Alternative verification**: Use Defender XDR verification (next section) as primary method.
- **Note**: Sentinel data may take 15-30 minutes to appear for initial setup.

##### Verify Data Synchronization in Defender XDR (Recommended)

**Sentinel Integration Validation**: Use Defender XDR's Advanced Hunting to confirm data synchronization with Microsoft Sentinel.

###### Steps to Verify

- Navigate to **Microsoft Defender XDR Portal**: Go to [security.microsoft.com](https://security.microsoft.com).
- Click **Hunting** → **Advanced hunting** in the left navigation.
- Run this comprehensive KQL query to verify Defender for Cloud data integration:

```kql
// Verify the Sentinel alerts are also visible in Defender XDR
SecurityAlert
| where TimeGenerated > ago(1h)
| where ProductName == "Azure Security Center" //Azure Security Center is the legacy name for Microsoft Defender for Cloud
| summarize count() by AlertName, AlertSeverity
| order by count_ desc
```

###### What This Sentinel Integration Test Verifies

- ✅ **Sentinel-XDR synchronization**: Confirms that alerts ingested into Sentinel are also accessible through XDR Advanced Hunting.
- ✅ **Data consistency**: Verifies the same SecurityAlert table data appears in both Sentinel and XDR interfaces.
- ✅ **Unified query capability**: Tests that the same KQL queries work across both platforms.
- ✅ **Cross-platform accessibility**: Validates that Sentinel data is available for XDR-based threat hunting and investigation.

###### Expected Results for Sentinel Integration Test

- Sample alerts with `ProductName == "Azure Security Center"` (legacy naming maintained for compatibility).
- Alert counts grouped by AlertName and AlertSeverity showing Sentinel data accessibility.
- TimeGenerated timestamps confirming data synchronization between Sentinel and XDR.
- Consistent data structure proving unified query capability across platforms.

###### Cross-platform Defender XDR Verification Query

For broader security context:

```kql
// Query Cross-platform security events including Defender for Cloud within Defender XDR
AlertInfo
| where Timestamp > ago(24h)
| where ServiceSource in ("Microsoft Defender for Cloud", "Microsoft Defender for Endpoint", "Microsoft Defender for Identity")
| summarize AlertCount = count() by ServiceSource, Severity
| order by AlertCount desc
```

###### What This Cross-Platform Test Verifies

- ✅ **XDR data integration**: Confirms alerts are flowing into XDR AlertInfo table from Defender for Cloud.
- ✅ **Cross-platform correlation**: Verifies alerts appear alongside other Microsoft security products.
- ✅ **Unified security operations**: Tests the single pane of glass approach.
- ✅ **Real-time data flow**: Validates immediate alert availability in XDR.

###### Expected Results for Cross-Platform Integration Test

- Sample alerts with `ServiceSource == "Microsoft Defender for Cloud"` in the AlertInfo table.
- Alert counts grouped by ServiceSource and Severity showing multi-product integration.
- Timestamp-based data confirming real-time alert flow from Defender for Cloud.
- Correlation data showing alerts from Defender for Endpoint, Identity, and other integrated products.
- Cross-platform alert count comparison demonstrating unified security operations.

#### Key Differences Between Query Methods

   | Aspect | Sentinel SecurityAlert Table | Defender XDR AlertInfo Table |
   |--------|----------------------------|-------------------------------|
   | **Data Source** | Sentinel workspace (SIEM) | XDR unified platform |
   | **Query Location** | Sentinel Logs interface | XDR Advanced Hunting |
   | **Purpose** | SIEM integration testing | Cross-platform correlation |
   | **Data Retention** | Long-term (workspace config) | XDR retention policy |
   | **Schema** | SecurityAlert table | AlertInfo table |
   | **Field Names** | ProductName, TimeGenerated | ServiceSource, Timestamp |
   | **Integration Testing** | Tests Sentinel connector | Tests XDR integration |
   | **Correlation Capability** | Limited to Sentinel data | Full Microsoft security stack |

#### Benefits of XDR Verification

- ✅ **Real-time validation**: Immediate confirmation of data flow.
- ✅ **Cross-platform correlation**: Verify alerts appear across all integrated security tools.
- ✅ **Unified investigation**: Single pane of glass for all security data.
- ✅ **Advanced analytics**: More sophisticated hunting capabilities than individual tools.
- ✅ **Incident correlation**: Confirms automatic incident creation and alert grouping.

#### Troubleshooting XDR Data Sync

- **No results**: Wait 5-10 minutes after sample alert generation - XDR ingestion is typically faster than Sentinel.
- **Missing correlation**: Ensure all Microsoft Defender products are properly licensed and configured.
- **Partial data**: Verify Defender for Cloud plans are enabled on all relevant subscriptions.

---

#### Multiple SIEM Integration (Advanced Scenarios)

For organizations requiring integration with multiple SIEM platforms or third-party security tools.

Microsoft Defender for Cloud supports data export to multiple destinations simultaneously through Continuous Export functionality. This advanced capability is designed for enterprise environments that need to:

- **Stream data to third-party SIEMs** (Splunk, QRadar, ServiceNow, etc.) via Azure Event Hubs.
- **Apply custom filtering** to reduce data volume and costs.
- **Support hybrid security operations** with both Microsoft and non-Microsoft tools.
- **Maintain compliance** with specific data residency or retention requirements.

##### Key Integration Methods

- **Azure Event Hubs**: High-volume streaming to external SIEM platforms.
- **Microsoft Graph Security API**: Native connectors for major SIEM vendors.
- **Custom filtering**: Export only specific alert severities or recommendation types.
- **Cross-tenant support**: Export data to workspaces in different Azure tenants.

Since this lab focuses on Microsoft-native security operations with Defender XDR and Sentinel, multiple SIEM configuration is beyond our current scope.

📸 **[Learn More: Continuous Export for Multiple SIEMs](https://learn.microsoft.com/en-us/azure/defender-for-cloud/continuous-export)**

### Step 2: Configure File Integrity Monitoring (Modern Approach)

**2025 Update**: FIM now uses the Defender for Endpoint agent and agentless scanning instead of the deprecated Log Analytics agent.

#### Enable Modern FIM

- Navigate to **Microsoft Defender for Cloud** → **Environment settings**.
- Select your subscription → **Defender for Servers** → **Settings**.
- Toggle **File Integrity Monitoring** to **On**.
- **Configuration panel will automatically appear** when you enable FIM.

#### Configure FIM Workspace and Settings

When you toggle FIM to **On**, a configuration panel opens automatically:

##### Workspace Configuration

- **Select workspace**: Choose the Log Analytics workspace you created earlier.

##### Monitoring Recommendations

- **Use default recommendations**: ✅ **Recommended for new lab configurations**.
- The default settings include monitoring for:
  - **Windows**: System files, registry keys, and application directories.
  - **Linux**: System binaries, configuration files, and log directories.
- **Custom rules**: Not needed for initial lab setup - defaults provide comprehensive coverage.

##### Essential Lab Configuration Rules

**Note**: The following rules are already included in the default configuration:

###### Windows VMs

- `C:\Windows\System32\` (system files).
- Registry keys for system configuration.
- `C:\Program Files\` and `C:\Program Files (x86)\` (application changes).

###### Linux VMs

- `/bin/`, `/sbin/`, `/usr/bin/`, `/usr/sbin/` (system binaries).
- `/etc/` (configuration files).
- `/var/log/` (log file changes).

#### Save Configuration

- Click **Continue** to save the FIM configuration with your selected workspace and monitoring settings.
- **Modern Data Collection Benefits**:
  - Uses Defender for Endpoint agent (real-time monitoring).
  - Uses agentless scanning (24-hour comprehensive scans).
  - No Log Analytics agent required.
  - **Free Data Benefit**: FIM data is included in the 500MB/day benefit for Defender for Servers Plan 2.

#### Verify FIM Data Collection

- Data appears in the designated workspace automatically.
- Initial data collection begins within 15-30 minutes.
- Query FIM data using modern tables and schemas in your Log Analytics workspace.

#### Azure Monitor Agent (AMA) - When Needed (Reference Only)

**Important Note**: This lab uses Microsoft Defender for Cloud's modern agentless architecture for all security capabilities. Azure Monitor Agent (AMA) is **not required** for the basic Defender for Cloud deployment covered in this guide.

##### When AMA is Required (Advanced Scenarios)

AMA is only needed for specific use cases that extend beyond this foundational lab:

- **Defender for SQL Servers on Machines** - Required for database security posture assessment and threat detection on SQL Server instances.
- **500MB Data Ingestion Benefit** - To leverage specific Log Analytics data collection scenarios with Defender for Servers Plan 2.

##### Modern 2025 Architecture Approach

✅ **What this lab uses**: Agentless scanning for comprehensive security coverage

- Vulnerability assessments.
- Malware detection.
- Software inventory.
- File integrity monitoring (via Defender for Endpoint agent).
- Security recommendations.

❌ **What this lab doesn't need**: Azure Monitor Agent (AMA) deployment

- Not required for basic VM protection.
- Not needed for modern File Integrity Monitoring.
- Replaced by agentless scanning for most security scenarios.

##### For Production SQL Server Environments

If you plan to protect SQL Server instances in production environments, you'll need to configure AMA specifically for Defender for SQL Servers on Machines.

📖 **[Complete AMA Configuration Guide for SQL Servers](https://learn.microsoft.com/en-us/azure/defender-for-cloud/auto-deploy-azure-monitoring-agent)**

📖 **[Migrate from Legacy MMA to AMA](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-sql-autoprovisioning)**

##### Key Benefits of Modern Agentless Approach

- **No agent management overhead**: Eliminates deployment, maintenance, and troubleshooting of agents.
- **Instant onboarding**: Immediate protection without pipeline changes.
- **Better performance**: No impact on VM performance or resource consumption.
- **Comprehensive coverage**: Full security assessment without agent dependencies.

### Step 3: Analytics and KQL Queries for Security Data

#### Introduction to KQL (Kusto Query Language)

KQL is Microsoft's powerful query language used across Defender for Cloud, Microsoft Sentinel, and Azure Monitor. It uses a simple, intuitive syntax that flows data through operators using the pipe (`|`) character, making it easy to filter, analyze, and visualize security data.

#### KQL Basics

- **Tables**: Your data sources (SecurityAlert, ConfigurationChange, etc.).
- **Operators**: Filter and transform data (`where`, `project`, `summarize`, etc.).
- **Pipe (`|`)**: Connects operators to build query pipelines.
- **Case-sensitive**: Table names, column names, and functions are case-sensitive.

📸 **[Learn More: KQL Tutorial - Common Operators](https://learn.microsoft.com/en-us/kusto/query/tutorials/learn-common-operators)**

#### Sample Security Queries with Expected Results

Use these queries in Microsoft Sentinel workspace or Log Analytics workspace depending on your configuration:

> **Note**: For alert verification and data flow testing, see the comprehensive verification queries in Step 4 below.

##### 1. File Integrity Monitoring Analysis

```kql
// Query: Monitor critical file changes on your VMs
ConfigurationChange
| where TimeGenerated > ago(24h)
| where ConfigChangeType == "Files"
| where Computer contains "vm-"
| project TimeGenerated, Computer, ChangeCategory, FileSystemPath, FieldsChanged
| order by TimeGenerated desc
```

#### What This Query Provides

- **Real-time file monitoring** - Shows recent file system changes.
- **Security incident detection** - Identifies unauthorized modifications.
- **Compliance tracking** - Documents system changes for audit purposes.
- **Expected results**: Timestamped list of file changes across your VMs with specific paths and change details.

##### 2. Security Recommendations Trend Analysis

```kql
// Query: Track security recommendation patterns over time
SecurityRecommendation
| where TimeGenerated > ago(7d)
| summarize count() by RecommendationSeverity, RecommendationName
| order by count_ desc
```

#### Security Recommendations Query Results

- **Security posture trends** - Shows improvement or degradation over time.
- **Prioritization insights** - Highlights most frequent recommendations.
- **Compliance gap analysis** - Identifies recurring security issues.
- **Expected results**: Recommendation frequencies by severity, helping focus remediation efforts.

##### 3. Secure Score Progress Tracking

```kql
// Query: Monitor your security posture improvements
SecureScoreControlDetails
| where TimeGenerated > ago(30d)
| summarize arg_max(TimeGenerated, *) by ControlName
| project ControlName, CurrentScore, MaxScore, ControlType
| order by CurrentScore asc
```

#### Secure Score Query Results

- **Security posture measurement** - Quantifies your security improvements.
- **Control effectiveness** - Shows which security controls need attention.
- **Progress tracking** - Monitors security score changes over time.
- **Expected results**: Security controls ranked by current score, identifying areas for improvement.

### Step 4: Azure Resource Graph Explorer for Cross-Subscription Security Analysis

Beyond the Sentinel and Defender XDR verification covered in Step 1, Azure Resource Graph Explorer provides programmatic access for cross-subscription security analysis.

> **Prerequisites**: Complete Step 1d verification first to ensure basic Sentinel and XDR data flow is working correctly.

#### When to Use Resource Graph Explorer

- **Multi-subscription environments**: Query security alerts across multiple Azure subscriptions simultaneously.
- **Enterprise governance**: Centralized security posture management across complex Azure environments.
- **Compliance reporting**: Generate cross-subscription security reports for audit purposes.
- **Custom automation**: Build automated security workflows that span multiple subscriptions.

#### Basic Cross-Subscription Query

##### Access Resource Graph Explorer

- Navigate to [portal.azure.com](https://portal.azure.com).
- Search for **Resource Graph Explorer**.

##### Query Security Alerts Across Subscriptions

```kql
// Query all security resources across subscriptions to understand your security posture
securityresources
| where type startswith "microsoft.security"
| summarize count() by type
| order by count_ desc
```

#### Security Resources Query Results

This query shows you all security-related resources in your environment, including:

- `microsoft.security/alerts` - Security alerts from Defender for Cloud.
- `microsoft.security/assessments` - Security recommendations and assessments.
- `microsoft.security/securitystatuses` - Overall security status of resources.
- `microsoft.security/complianceresults` - Compliance assessment results.
- `microsoft.security/locations` - Security center locations and configurations.

#### Drill Down Query Results

Next: Drill down into specific resource types that show results:

```kql
// Query security assessments (recommendations) across subscriptions
securityresources
| where type == "microsoft.security/assessments"
| project subscriptionId, resourceGroup,
    assessmentName = tostring(properties.displayName),
    status = tostring(properties.status.code),
    severity = tostring(properties.metadata.severity),
    category = tostring(properties.metadata.categories[0])
| order by severity desc
```

#### Expected Results

- **Security resource inventory** showing counts of each resource type in your environment.
- **Security assessments** (recommendations) with severity levels and current status.
- **Cross-subscription visibility** of your complete security posture.
- **Actionable recommendations** prioritized by severity for immediate remediation.

📸 **[Learn More: Azure Resource Graph Explorer Quickstart](https://learn.microsoft.com/en-us/azure/governance/resource-graph/first-query-portal)**

> **Note**: For single-subscription environments, use the Sentinel and XDR verification methods from Step 1 instead, as they provide more detailed analysis capabilities.

### Step 5: Cost Optimization and Best Practices

#### Estimated Solution Cost Summary (July 2025 Pricing)

#### Current Lab Configuration Cost Breakdown

##### Core Microsoft Defender for Cloud Costs

- **Foundational CSPM**: **Free** (included with Azure subscription).
- **Defender for Servers Plan 2**: **~$15 USD/server/month**.
  - For 2-3 VMs = **$30-45 USD/month**.
  - Includes 500MB/day free Log Analytics data ingestion.
  - Includes agentless scanning, vulnerability assessment, and endpoint protection.

##### Additional Services (Optional)

- **Microsoft Sentinel**: **$2.76 USD/GB ingested** (if configured).
  - Estimated 1-2GB/month for small lab = **$2.76-5.52 USD/month**.
  - First 10GB/month often included with certain plans.
- **Log Analytics Workspace**: **$2.76 USD/GB ingested** beyond free allowances.
  - File Integrity Monitoring data typically under 100MB/month = **Minimal cost**.
- **Virtual Machines**: **Standard costs apply** based on your VM size selection.
  - B2s VMs: ~$30-40 USD/month each (varies by region).
  - **Cost Optimization Tip**: These estimates assume VMs run continuously 24/7. **Stop VMs when not actively using the lab** to significantly reduce infrastructure costs. Defender for Cloud protection and configuration remain intact when VMs are stopped.

##### Total Estimated Monthly Cost

- **Defender for Cloud only**: **$30-45 USD/month** (core security).
- **With Sentinel integration**: **$33-51 USD/month** (comprehensive SIEM).
- **Virtual Machine costs**: **Additional $60-120 USD/month** (if VMs are left running continuously).

> **Important**: These are estimated costs as of July 2025. Actual pricing varies by region, commitment tiers, and usage patterns. For current pricing and regional variations, visit the official pricing calculator.

📸 **[Current Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)** - Configure your specific requirements for accurate cost estimates

📸 **[Microsoft Defender for Cloud Pricing Details](https://azure.microsoft.com/en-us/pricing/details/defender-for-cloud/)** - Current plan pricing and feature comparisons

#### Modern Cost Benefits

##### Agentless Architecture (2025)

- **Comprehensive coverage without agents**: Agentless scanning for vulnerabilities, malware, secrets, and software inventory.
- **No performance impact**: Scanning runs independently without affecting machine performance.
- **Reduced operational overhead**: No agent licensing, deployment, or maintenance costs.
- **Simplified deployment**: Instant onboarding without pipeline changes or agent installation.

##### Data Ingestion Benefits

- **500MB/day free data ingestion** with Defender for Servers Plan 2 per protected machine.
- **File Integrity Monitoring data included** in the free allowance.
- **Optimized data streaming** reduces Log Analytics costs through native connectors.
- **Eliminated duplicate data ingestion** via direct Microsoft security stack integration.

##### Unified Security Operations Integration (2025)

- **Microsoft Defender XDR native integration**: Automatic cross-platform correlation without additional configuration.
- **Microsoft Sentinel unified experience**: New customers (July 2025+) automatically redirected to Defender portal for unified operations.
- **Continuous Export precision**: Custom filtering reduces data volume and third-party SIEM costs.
- **Event Hubs optimization**: High-volume streaming for enterprise scenarios without data transformation overhead.

##### Modern File Integrity Monitoring

- **Dual approach**: Both agentless scanning (24-hour cadence) and Defender for Endpoint agent (real-time) available.
- **Custom path monitoring**: Agentless FIM (Preview June 2025) supports custom file and registry monitoring.
- **Legacy agent elimination**: No more Log Analytics agent (MMA) or Azure Monitor agent (AMA) required.

## 💡 Best Practices for 2025

> **Note**: This is a comprehensive list of best practices for consideration when deploying Microsoft Defender for Cloud in production environments. Not all features and configurations mentioned here are explored within this lab - this guide focuses on foundational deployment while these best practices provide broader strategic guidance for enterprise implementations.

### 1. Embrace Unified Security Operations

- **Prioritize Defender portal experience**: New Sentinel workspaces (July 2025+) automatically onboard to unified Defender portal.
- **Plan Sentinel migration timeline**: Microsoft Sentinel experience in Azure Portal being transitioned to unified Defender portal by July 2026 - start planning transition now.
- **Use native XDR integration**: Automatic incident correlation across Defender for Cloud, Endpoint, Identity, and Office 365.
- **Prefer automated Data Collection Rules**: For Defender for Cloud features, let the service auto-create DCRs rather than manual Log Analytics agent configuration (Note: Sentinel still requires a Log Analytics workspace).
- **Integrated threat hunting**: Use Defender XDR for advanced hunting across cloud and endpoints.
- **Plan integration with existing SIEM tools**: Configure API access for programmatic management.

### 2. Optimize Modern Architecture and Data Collection

- **Enable agentless scanning first**: Comprehensive security coverage without agent overhead and eliminates agent sprawl.
- **Selective AMA deployment**: Only deploy Azure Monitor Agent where specifically required (SQL servers, data benefits).
- **Use hybrid File Integrity Monitoring**: Combine real-time Defender for Endpoint monitoring with agentless custom path scanning.
- **Monitor data ingestion**: Track usage against the 500MB/day free allowance per machine.
- **Regional considerations**: Agentless scanning respects data residency requirements.
- **Enhanced coverage**: Multi-cloud and hybrid protection without complex agent management.

### 3. Leverage Modern Security Features

- **Deploy Defender for Endpoint integration**: Essential for real-time threat protection and advanced EDR capabilities.
- **Enable automatic incident creation**: Streamline security operations with native Sentinel integration.
- **Use Azure Policy for scale**: Deploy compliance configurations across multiple subscriptions automatically.
- **Implement Logic Apps automation**: Automate common response actions like VM isolation and security team notifications.
- **Modern network security**: Implement micro-segmentation with NSGs and Azure Firewall.
- **Leverage agentless recommendations**: Act on comprehensive security findings without agent dependencies.

### 4. Cost Optimization and Performance

- **Agentless benefits**: Reduced operational overhead and management costs with no VM performance impact.
- **Filter Continuous Export strategically**: Export only high-severity alerts to reduce third-party SIEM costs.
- **Monitor scanning costs**: Use agentless scanning efficiently with built-in cost controls.
- **Automated remediation**: Leverage enhanced automation capabilities in 2025 features.

### 5. Migration and Modernization

- **Migrate from legacy agents**: Transition File Integrity Monitoring from Log Analytics agent (MMA) to modern Defender for Endpoint approach.
- **Disable MMA auto-provisioning**: Ensure deprecated Log Analytics Agent auto-provisioning is disabled.
- **Remove legacy agents**: Use Microsoft's MMA removal utility for cleanup.
- **Update minimum versions**: Ensure Defender for Endpoint meets June 2025 requirements (Windows: 10.8760+, Linux: 30.124082+).
- **Replace manual connectors**: Use tenant-based Defender for Cloud connectors instead of subscription-based legacy connectors.
- **Validate agentless coverage**: Confirm all security capabilities are covered by agentless scanning.
- **Update monitoring queries**: Transition from MMA-based queries to agentless data sources.

### 6. Monitoring, Compliance, and Automation

- **Continuous agentless assessment**: Security posture evaluation without maintenance overhead.
- **Modern compliance reporting**: Use updated compliance frameworks and automated reporting.
- **Set up automation for common security tasks**: Document incident response procedures.
- **Configure API access for programmatic management**: Enable scalable security operations.

---

## 🧹 Lab Cleanup and Cost Management

### Immediate Cost Reduction

#### Stop Virtual Machines When Not in Use

**Critical for Cost Optimization**: Virtual machines continue to incur compute charges even when idle. Stopping VMs when not actively using the lab significantly reduces infrastructure costs while preserving your Defender for Cloud configuration.

##### How to Stop VMs

- Navigate to **Virtual machines** in the Azure Portal.
- Select each VM used in this lab.
- Click **Stop** to deallocate the VM.
- **Status should show**: **Stopped (deallocated)** to ensure no compute charges.

##### Benefits of Stopping VMs

- ✅ **Eliminated compute costs**: No charges for stopped (deallocated) VMs.
- ✅ **Defender for Cloud configuration preserved**: All security settings remain intact.
- ✅ **Agentless scanning continues**: Security assessments work on stopped VMs.
- ✅ **Quick restart capability**: VMs can be restarted when needed for continued lab work.
- ✅ **Data persistence**: All VM data and configurations are preserved.

#### Expected Cost Reduction

- **Running VMs**: $60-120 USD/month (continuous operation).
- **Stopped VMs**: $0 USD/month for compute + minimal storage costs (~$5-10 USD/month).
- **Defender for Cloud costs continue**: $30-45 USD/month (required for security monitoring).

### Complete Lab Cleanup (Optional)

#### When to Consider Full Cleanup

- **Completed all learning objectives** and no longer need the lab environment.
- **Want to start fresh** with a clean deployment for practice.
- **Need to eliminate all costs** associated with the lab.
- **Organization policy** requires removal of non-production security tools.

#### Full Decommission Process

For complete removal of all Defender for Cloud resources and costs, follow the comprehensive decommission guide:

📖 **[Complete Decommission Guide: Remove Defender for Cloud](../Decommission/decommission-defender-for-cloud.md)**

##### What Full Decommission Includes

- **Disable all Defender for Cloud plans** across subscriptions.
- **Remove Log Analytics workspaces** and associated data.
- **Delete resource groups** and all contained resources.
- **Clean up Microsoft Sentinel workspaces** if configured.
- **Remove Azure Policy assignments** for Defender for Cloud.
- **Verify complete cost elimination** through billing analysis.

##### Decommission Timeline

- **Immediate**: VM deletion and Defender plan disabling.
- **24-48 hours**: Final billing cycle and cost elimination.
- **30 days**: Complete data deletion from Microsoft systems.

### Restart Lab Environment

#### When You Want to Continue

- **Restart stopped VMs**: Simply start the VMs from the Azure Portal when ready to continue.
- **All configurations preserved**: Defender for Cloud, Sentinel, and security settings remain intact.
- **Resume from any point**: Continue with Week 2 objectives or repeat sections as needed.

#### Fresh Start Option

- **Follow decommission guide**: Complete cleanup of existing environment.
- **Redeploy using this guide**: Start fresh with updated knowledge and refined configuration.
- **Compare approaches**: Use both Azure Portal and Infrastructure-as-Code methods for comparison.

---

## 📚 Next Steps - Complete Week 1 Objectives

After successful Defender for Cloud deployment via Azure Portal:

### Immediate Week 1 Tasks

#### Deploy via Infrastructure-as-Code

- Complete Defender for Cloud deployment using Bicep or Terraform.
- Compare IaC approach with Azure Portal deployment.
- Document configuration differences and automation benefits.

#### Simulate Benign Threat Scenario

- Generate sample security alerts (as covered in Step 11).
- Observe AI-driven insights and recommendations.
- Document Defender for Cloud's response to simulated threats.
- Capture screenshots and analysis for documentation.

### Prepare for Week 2 - AI Foundation & Secure Model Deployment

#### Defender XDR Foundation

- Ensure Microsoft Defender XDR integration is working (as configured in Step 1c).
- Validate cross-platform alert correlation.
- Test incident creation and management workflows.

#### Microsoft Copilot for Security Prerequisites

- Review Copilot for Security licensing requirements.
- Understand integration touchpoints with current Defender for Cloud setup.
- Identify prompt engineering opportunities for security automation.

### Resources for Continuation

- [Week 2: AI Foundation & Secure Model Deployment](../../../../02-AI-Foundation-&-Secure-Model-Deployment/README.md)
- [Main Project Roadmap](../../../../README.md)
- [Prompt Library Template](../../../../Prompt-Library/README.md)

---

## 🔗 Additional Resources (Updated 2025)

### Core Documentation and Modern Deployment

- [Microsoft Defender for Cloud Documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Agentless Machine Scanning Concepts](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-agentless-data-collection)
- [Enable Agentless Scanning for VMs](https://learn.microsoft.com/en-us/azure/defender-for-cloud/enable-agentless-scanning-vms)
- [Test Agentless Malware Scanning](https://learn.microsoft.com/en-us/azure/defender-for-cloud/test-agentless-malware-scanning)

### Advanced File Integrity Monitoring

- [File Integrity Monitoring Overview (2025)](https://learn.microsoft.com/en-us/azure/defender-for-cloud/file-integrity-monitoring-overview)
- [Enable File Integrity Monitoring with Defender for Endpoint Agent](https://learn.microsoft.com/en-us/azure/defender-for-cloud/file-integrity-monitoring-enable-defender-endpoint)
- [Review Changes in File Integrity Monitoring](https://learn.microsoft.com/en-us/azure/defender-for-cloud/file-integrity-monitoring-review-changes)

### Microsoft Sentinel and XDR Unified Experience

- [Microsoft Defender XDR Integration with Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/microsoft-365-defender-sentinel-integration)
- [Connect Microsoft Sentinel to the Microsoft Defender Portal](https://learn.microsoft.com/en-us/unified-secops-platform/microsoft-sentinel-onboard)
- [Microsoft Sentinel in the Defender Portal (Unified Experience)](https://learn.microsoft.com/en-us/azure/sentinel/microsoft-sentinel-defender-portal)

### Migration from Legacy Agents

- [Migrate File Integrity Monitoring from MMA/AMA to Modern Approach](https://learn.microsoft.com/en-us/azure/defender-for-cloud/migrate-file-integrity-monitoring)
- [Prepare for Log Analytics Agent (MMA) Retirement](https://learn.microsoft.com/en-us/azure/defender-for-cloud/prepare-deprecation-log-analytics-mma-agent)
- [Azure Monitor Agent (AMA) for Specific Use Cases](https://learn.microsoft.com/en-us/azure/defender-for-cloud/auto-deploy-azure-monitoring-agent)

### Visualization and Automation

- [Defender for Cloud Workbooks and Interactive Reports](https://learn.microsoft.com/en-us/azure/defender-for-cloud/custom-dashboards-azure-workbooks)
- [What's New in Defender for Cloud (2025 Features)](https://learn.microsoft.com/en-us/azure/defender-for-cloud/release-notes)
- [Azure Security Best Practices and Patterns](https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)

---

## 🤖 AI-Assisted Content Generation

This comprehensive deployment guide was updated for 2025 with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Defender for Cloud architecture changes, MMA deprecation, and modern agentless capabilities.

*AI tools were used to enhance productivity and ensure comprehensive coverage of current Microsoft Defender for Cloud deployment procedures while maintaining technical accuracy and reflecting the latest Microsoft security architecture.*

---

**Note**: This guide reflects the modern Microsoft Defender for Cloud architecture as of 2025, including the deprecation of Log Analytics Agent (MMA) and transition to agentless scanning with Defender for Endpoint integration. Always refer to the latest Microsoft documentation for the most current procedures as Microsoft continues to evolve their security platform.
