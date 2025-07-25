# Deploy Microsoft Defender for Cloud via Azure Portal (2025 Edition)

This guide provides a comprehensive walkthrough for deploying Microsoft Defender for Cloud in a fresh Azure environment using the Azure Portal, reflecting the latest architecture and features as of 2025.

## 📋 Prerequisites

Before starting, ensure you have:

- An active Azure subscription with Owner or Contributor permissions
- Access to the Azure Portal
- Basic understanding of Azure resources and security concepts
- 2-3 virtual machines ready for monitoring (or we'll create them as part of this guide)

## 🎯 Overview

Microsoft Defender for Cloud provides unified security management and advanced threat protection across hybrid cloud workloads. This deployment leverages the modern agentless architecture and native integrations available in 2025:

1. Enable Defender for Cloud on your subscription
2. Configure modern agent architecture (agentless + Defender for Endpoint)
3. Set up monitoring for virtual machines using current methods
4. Enable advanced threat protection features
5. Configure Azure Monitor Agent (AMA) only where specifically required

## ⚠️ Important Architecture Changes (2025)

**Key Updates from Previous Versions:**
- **Log Analytics Agent (MMA) Deprecated**: MMA was retired in August 2024 and is no longer supported
- **Agentless Scanning**: Primary data collection method for most security assessments
- **Defender for Endpoint Integration**: Single agent approach for endpoint protection
- **Azure Monitor Agent (AMA)**: Only required for specific scenarios (Defender for SQL on machines and data ingestion benefits)

---

## Step 1: Access Microsoft Defender for Cloud

1. **Sign in to Azure Portal**
   - Navigate to [https://portal.azure.com](https://portal.azure.com)
   - Sign in with your Azure account credentials

2. **Navigate to Defender for Cloud**
   - In the Azure Portal search bar, type "Microsoft Defender for Cloud"
   - Click on "Microsoft Defender for Cloud" from the search results
   - Alternatively, you can find it under "Security" in the Azure services menu

📸 **[View Screenshot: Azure Portal Search](https://learn.microsoft.com/en-us/azure/defender-for-cloud/media/get-started/defender-for-cloud-search.png)**

---

## Step 2: Enable Defender for Cloud

1. **Getting Started Page**
   - Upon first access, you'll see the Defender for Cloud Getting Started page
   - Review the overview of capabilities and benefits
   - Click on "Enable Defender for Cloud" if not already enabled

2. **Choose Your Plan**
   - You'll see the foundational CSPM (Cloud Security Posture Management) capabilities are free
   - For enhanced protection, you can enable Defender plans for specific resource types
   - For this guide, we'll start with the free tier and then upgrade specific plans

📸 **[View Screenshot: Defender Overview](https://learn.microsoft.com/en-us/azure/reusable-content/ce-skilling/azure/media/defender-for-cloud/overview.png)**

---

## Step 3: Configure Environment Settings

1. **Access Environment Settings**
   - In the Defender for Cloud left navigation pane, click on "Environment settings"
   - Select your subscription from the list
   - You'll see the current status of Defender plans

2. **Review Default Settings**
   - Examine the current configuration
   - Note which plans are enabled (typically CSPM is enabled by default)
   - Review the estimated monthly cost for enhanced plans

📸 **[View Screenshot: Environment Settings](https://learn.microsoft.com/en-us/azure/defender-for-cloud/media/get-started/environmental-settings.png)**

---

## Step 4: Enable Modern Defender for Servers Architecture

1. **Enable Server Protection**
   - In Environment Settings, find "Defender for Servers"
   - Toggle the status to "On" for Plan 2 (recommended for full features)
   - This automatically enables:
     - **Agentless scanning** for vulnerability assessment and security posture
     - **Defender for Endpoint integration** for endpoint protection
     - **Malware scanning** without performance impact

2. **Configure Agentless Scanning (Enabled by Default)**
   - Agentless scanning is automatically enabled with Defender for Servers Plan 2
   - This provides:
     - Vulnerability assessment without agents
     - Configuration assessment
     - Malware scanning
     - Software inventory
   - No additional configuration required - works out-of-the-box

3. **Enable Defender for Endpoint Integration**
   - Navigate to "Integrations" in Environment Settings
   - Ensure "Microsoft Defender for Endpoint" is enabled
   - This provides:
     - Real-time threat protection
     - Behavioral analysis
     - Advanced hunting capabilities
     - Single agent solution for endpoint protection

4. **Azure Monitor Agent (AMA) - Only When Required**
   - AMA is only needed for:
     - Defender for SQL servers on machines
     - Free 500MB data ingestion benefit (Defender for Servers Plan 2)
   - If you need AMA, it will be automatically configured when enabling relevant features
   - **Do NOT manually configure MMA** - it has been deprecated since August 2024

📸 **[View Screenshot: Enable All Plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/media/get-started/enable-all-plans.png)**

---

## Step 5: Create Virtual Machines for Monitoring

If you don't have existing VMs, create 2-3 virtual machines for testing:

### Create VM 1 - Windows Server

1. **Navigate to Virtual Machines**
   - In Azure Portal, search for "Virtual machines"
   - Click "Create" → "Azure virtual machine"

2. **Basic Configuration**
   - **Subscription**: Select your subscription
   - **Resource Group**: Create new "rg-defender-demo"
   - **Virtual machine name**: "vm-windows-web"
   - **Region**: Choose your preferred region
   - **Image**: "Windows Server 2022 Datacenter"
   - **Size**: "Standard_B2s" (cost-effective for testing)

3. **Administrator Account**
   - **Username**: "azureuser"
   - **Password**: Create a strong password
   - **Confirm password**: Re-enter password

4. **Inbound Port Rules**
   - Allow selected ports: RDP (3389), HTTP (80), HTTPS (443)
   - **Note**: This is for demo purposes; restrict access in production

5. **Review and Create**
   - Review settings and click "Create"
   - Wait for deployment to complete

### Create VM 2 - Ubuntu Linux

1. **Create Second VM**
   - Follow similar steps as above
   - **Virtual machine name**: "vm-linux-db"
   - **Image**: "Ubuntu Server 20.04 LTS"
   - **Authentication type**: SSH public key or Password
   - **Inbound ports**: SSH (22), HTTP (80)

### Create VM 3 - Windows Client (Optional)

1. **Create Third VM**
   - **Virtual machine name**: "vm-windows-client"
   - **Image**: "Windows 11 Pro"
   - **Inbound ports**: RDP (3389)

📸 **[View Azure VM Creation Guide](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal)**

---

## Step 6: Verify Modern Agent Architecture

1. **Check Agentless Scanning Status**
   - Navigate to "Environment settings" → Your subscription
   - Under "Monitoring coverage", verify agentless scanning is enabled
   - Check the "Agentless scanning for machines" status

2. **Verify Defender for Endpoint Integration**
   - Go to "Workload protections"
   - Check "Microsoft Defender for Endpoint" status
   - Verify that VMs show as "Protected" in the endpoints view

3. **Monitor VM Protection Status**
   - Navigate to "Inventory" in Defender for Cloud
   - Select your VMs to view protection status
   - You should see:
     - Agentless scanning: Enabled
     - Defender for Endpoint: Connected (if applicable)
     - Azure Monitor Agent: Only if specifically required for SQL or data benefits

4. **Verify Scanning Results**
   - Agentless scanning runs automatically and findings appear in:
     - Recommendations (security posture findings)
     - Security alerts (threat detections)
     - Vulnerability assessment results
   - Initial scans may take 15-30 minutes to complete

📸 **[View Data Collection Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/enable-data-collection)**

---

## Step 7: Configure Security Policies

1. **Access Security Policy**
   - In Defender for Cloud, navigate to "Security policy"
   - Select your subscription
   - Review the default Azure Security Benchmark policy

2. **Customize Policies (Optional)**
   - Click on "Azure Security Benchmark"
   - Review individual policy definitions
   - You can disable specific policies if not relevant to your environment
   - Click "Save" after making changes

3. **Add Custom Policies (Optional)**
   - Click "Add a custom initiative"
   - Browse available policy definitions
   - Create custom policy sets based on your compliance requirements

📸 **[View Security Policy Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/security-policy-concept)**

---

## Step 8: Review Modern Security Recommendations

1. **Access Recommendations**
   - Navigate to "Recommendations" in the Defender for Cloud menu
   - Wait 15-30 minutes after VM creation for initial agentless assessment
   - Review the list of security recommendations powered by agentless scanning

2. **Common Modern Recommendations (2025)**
   - Enable disk encryption on virtual machines
   - Install endpoint protection solution on machines (via Defender for Endpoint)
   - Apply system updates (now powered by Azure Update Manager integration)
   - Enable Network Security Groups on subnets
   - Enable backup on virtual machines
   - Resolve endpoint detection and response (EDR) solution recommendations
   - Remediate vulnerabilities found in container images (agentless)

3. **Implement High-Priority Recommendations**
   - Click on recommendations marked as "High" severity
   - Use "Quick fix" options where available (expanded automation in 2025)
   - Follow the modernized remediation steps that leverage agentless capabilities

📸 **[View Recommendations Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/review-security-recommendations)**

---

## Step 9: Configure Alerts and Notifications

1. **Set up Email Notifications**
   - Navigate to "Email notifications" in Environment settings
   - Add email addresses for security contact
   - Configure notification preferences:
     - High severity alerts
     - Alerts to subscription admins
     - Weekly digest emails

2. **Configure Workflow Automation**
   - Go to "Workflow automation"
   - Create logic apps for automated responses
   - Set up integrations with SIEM tools or ticketing systems

📸 **[View Email Notifications Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/configure-email-notifications)**

---

## Step 10: Configure Modern Advanced Threat Protection Features

1. **Just-in-Time VM Access**
   - Navigate to "Workload protections" → "Just-in-time VM access"
   - Select your VMs and click "Enable JIT on X VMs"
   - Configure allowed ports and time windows
   - This reduces attack surface by limiting VM access

2. **Agentless Malware Scanning**
   - Automatically enabled with Defender for Servers Plan 2
   - Provides comprehensive malware detection without performance impact
   - Integrates with Defender for Endpoint for enhanced protection
   - View results in Security Alerts and Defender XDR

3. **Modern File Integrity Monitoring**
   - **Note**: Legacy FIM based on Log Analytics Agent was deprecated November 2024
   - New FIM capabilities are delivered through Defender for Endpoint integration
   - Enable in "Workload protections" → "File integrity monitoring"
   - Configure monitoring rules through the modern interface

4. **Endpoint Detection and Response (EDR)**
   - Automatically available through Defender for Endpoint integration
   - Provides behavioral analysis and advanced threat hunting
   - No additional configuration required
   - Access advanced features through Microsoft Defender XDR portal

📸 **[View Just-in-Time Access Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)**

---

## Step 11: Monitor Security Alerts

1. **Access Security Alerts**
   - Navigate to "Security alerts" in Defender for Cloud
   - Initially, you may not see alerts (they appear as threats are detected)

2. **Generate Test Alerts (Optional)**
   - For testing purposes, you can trigger test alerts:
   - Run suspicious PowerShell commands on Windows VMs
   - Attempt unauthorized access patterns
   - Download known test malware (use test files, not real malware)

3. **Alert Investigation**
   - Click on any alert to view details
   - Review the attack timeline
   - Follow investigation steps
   - Mark alerts as resolved when appropriate

---

## Step 12: Set Up Workbooks and Dashboards

1. **Access Workbooks**
   - Navigate to "Workbooks" in Defender for Cloud
   - Explore pre-built workbooks:
     - Coverage workbook
     - Security alerts dashboard
     - Compliance dashboard

2. **Create Custom Dashboard**
   - Go to Azure Portal dashboard
   - Add Defender for Cloud tiles
   - Pin important metrics and alerts
   - Share dashboard with your security team

📸 **[View Workbooks and Dashboards Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/custom-dashboards-azure-workbooks)**

---

## Step 13: Compliance and Regulatory Standards

1. **Access Regulatory Compliance**
   - Navigate to "Regulatory compliance"
   - Review current compliance score
   - Add additional compliance standards if required:
     - PCI DSS
     - ISO 27001
     - SOC 2
     - HIPAA (if applicable)

2. **Download Compliance Reports**
   - Generate compliance reports
   - Schedule regular compliance assessments
   - Share reports with auditors and stakeholders

---

## Step 14: Modern Integration with Microsoft Sentinel and XDR

1. **Connect to Microsoft Sentinel**
   - If you have Microsoft Sentinel deployed
   - Navigate to "Security solutions" in Defender for Cloud
   - Configure improved data connectors that work with agentless architecture
   - Enable automatic incident creation from Defender for Cloud alerts

2. **Microsoft Defender XDR Integration**
   - Defender for Cloud now integrates natively with Defender XDR
   - Endpoint alerts from Defender for Endpoint appear in both portals
   - Cross-platform correlation for enhanced threat detection
   - Unified incident management across cloud and endpoint security

3. **Configure Analytics Rules**
   - Create correlation rules leveraging agentless data collection
   - Set up automated incident creation
   - Configure playbooks for automated response using modern APIs

---

## 🔍 Verification Steps (2025 Architecture)

After completing the deployment, verify everything is working with the modern architecture:

### Check Agentless Data Collection

1. **Verify Agentless Scanning**
   - Navigate to Environment Settings → Monitoring Coverage
   - Confirm agentless scanning is enabled and operational
   - Check that VMs appear in inventory with agentless data

2. **Review Agentless Findings**
   - Use KQL queries to verify data collection (if using Log Analytics for other purposes):

   ```kql
   // Check for agentless vulnerability assessments
   SecurityRecommendation
   | where TimeGenerated > ago(1h)
   | where RecommendationName contains "vulnerabilities"
   | take 10
   ```

3. **Defender for Endpoint Integration**
   - Verify endpoint status in Microsoft Defender XDR portal
   - Check device health and protection status
   - Confirm alert correlation between Defender for Cloud and Defender XDR

### Test Modern Security Features

1. **Generate Test Alert**
   - Create a test security event using Defender for Endpoint's test scenarios
   - Verify alert appears in both Defender for Cloud and Defender XDR
   - Test notification delivery through updated channels

2. **Agentless Scanning Validation**
   - Verify vulnerability scanning results appear without agents
   - Check malware scanning capabilities
   - Confirm configuration assessment data is populated

3. **JIT Access Test**
   - Request JIT access to a VM
   - Verify approval workflow functions correctly
   - Test automatic access revocation

---

## 💡 Best Practices and Tips (2025 Edition)

### Modern Architecture Benefits

- **Agentless scanning**: Eliminates agent sprawl and performance impact
- **Unified agent approach**: Single Defender for Endpoint agent for comprehensive protection
- **Enhanced coverage**: Multi-cloud and hybrid protection without complex agent management
- **Improved performance**: No impact on VM performance from security scanning

### Cost Optimization

- **Agentless benefits**: Reduced operational overhead and management costs
- **Selective AMA deployment**: Only deploy AMA where specifically required (SQL servers, data benefits)
- **Monitor scanning costs**: Use agentless scanning efficiently with built-in cost controls
- **Regional considerations**: Agentless scanning respects data residency requirements

### Security Hardening

- **Leverage agentless recommendations**: Act on comprehensive security findings without agent dependencies
- **Enable Defender for Endpoint integration**: Utilize single-agent approach for endpoint protection
- **Modern network security**: Implement micro-segmentation with NSGs and Azure Firewall
- **Azure Policy integration**: Use guest configuration for compliance without legacy agents

### Monitoring and Maintenance

- **Continuous agentless assessment**: Security posture evaluation without maintenance overhead
- **Integrated threat hunting**: Use Defender XDR for advanced hunting across cloud and endpoints
- **Automated remediation**: Leverage enhanced automation capabilities in 2025 features
- **Modern compliance reporting**: Use updated compliance frameworks and automated reporting

### Migration from Legacy Architecture

- **Disable MMA auto-provisioning**: Ensure deprecated Log Analytics Agent auto-provisioning is disabled
- **Remove legacy agents**: Use Microsoft's MMA removal utility for cleanup
- **Validate agentless coverage**: Confirm all security capabilities are covered by agentless scanning
- **Update monitoring queries**: Transition from MMA-based queries to agentless data sources

### Integration Considerations

- Plan integration with existing SIEM tools
- Configure API access for programmatic management
- Set up automation for common security tasks
- Document incident response procedures

---

## 🚨 Troubleshooting Common Issues (2025)

### Agentless Scanning Issues

- **Issue**: Agentless scanning not collecting data
- **Solution**: Check subscription permissions, verify Defender for Servers Plan 2 is enabled, ensure VMs are in supported regions

### Missing Security Recommendations

- **Issue**: No recommendations appearing after 30+ minutes
- **Solution**: Verify agentless scanning is enabled, check that VMs are properly registered in Azure, confirm subscription has appropriate permissions

### Defender for Endpoint Integration Problems

- **Issue**: Endpoint protection not showing as enabled
- **Solution**: Verify Defender for Endpoint integration is enabled in Environment Settings, check VM compliance with Defender for Endpoint requirements

### Legacy Agent Conflicts

- **Issue**: Old MMA agents still installed causing conflicts
- **Solution**: Use Microsoft's MMA removal utility, disable legacy auto-provisioning, ensure clean migration to agentless architecture

### High Scanning Costs

- **Issue**: Unexpected charges for agentless scanning
- **Solution**: Review scanning frequency settings, optimize regional scanning policies, monitor usage through Azure Cost Management

### Azure Monitor Agent (AMA) Issues

- **Issue**: AMA not collecting data for SQL servers
- **Solution**: Verify AMA auto-provisioning is enabled for Defender for SQL, check SQL server registration with Azure Arc if on-premises

---

## 📚 Next Steps (2025 Roadmap)

After successful deployment:

1. **Optimize Agentless Coverage**
   - Expand agentless scanning to multi-cloud environments
   - Configure advanced agentless malware scanning
   - Enable agentless code scanning for DevOps repositories
   - Implement agentless container image scanning

2. **Enhance Integration**
   - Connect to Microsoft Defender XDR for unified security operations
   - Integrate with Microsoft Purview for data governance
   - Configure Microsoft Copilot for Security for AI-powered threat analysis
   - Set up cross-platform security correlation

3. **Advanced Configuration**
   - Implement custom security policies using Azure Policy guest configuration
   - Configure advanced hunting queries in Defender XDR
   - Set up automated response playbooks using modern APIs
   - Implement threat intelligence feeds integration

4. **AI-Powered Security (2025 Features)**
   - Enable Microsoft Copilot for Security integration
   - Configure AI-powered threat analysis and response
   - Implement predictive security analytics
   - Use AI-assisted incident investigation workflows

5. **Continuous Improvement**
   - Regular security posture reviews using agentless insights
   - Update security policies based on AI-powered threat intelligence
   - Monitor and optimize costs using modern cost management tools
   - Stay updated with Microsoft's quarterly security feature releases

---

## 🔗 Additional Resources (Updated 2025)

- [Microsoft Defender for Cloud Documentation](https://docs.microsoft.com/en-us/azure/defender-for-cloud/)
- [Agentless Scanning Architecture](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-agentless-data-collection)
- [Defender for Endpoint Integration Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/integration-defender-for-endpoint)
- [Azure Monitor Agent (AMA) Migration Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/prepare-deprecation-log-analytics-mma-agent)
- [Microsoft Defender XDR Integration](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender)
- [Azure Security Best Practices 2025](https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [Microsoft Security Blog](https://www.microsoft.com/security/blog/)
- [MMA Deprecation Blog Post](https://techcommunity.microsoft.com/blog/microsoftdefendercloudblog/microsoft-defender-for-cloud---strategy-and-plan-towards-log-analytics-agent-mma/3883341)

---

## 🤖 AI-Assisted Content Generation

This comprehensive deployment guide was updated for 2025 with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Defender for Cloud architecture changes, MMA deprecation, and modern agentless capabilities.

*AI tools were used to enhance productivity and ensure comprehensive coverage of current Microsoft Defender for Cloud deployment procedures while maintaining technical accuracy and reflecting the latest Microsoft security architecture.*

---

**Note**: This guide reflects the modern Microsoft Defender for Cloud architecture as of 2025, including the deprecation of Log Analytics Agent (MMA) and transition to agentless scanning with Defender for Endpoint integration. Always refer to the latest Microsoft documentation for the most current procedures as Microsoft continues to evolve their security platform.
