# AI Skilling Roadmap – Marcus Jacobson

Welcome to the AI Skilling Roadmap repository! This project outlines a **9-week journey** to build deep, hands-on expertise in secure AI deployment, Microsoft Security tools, and Copilot integration. It aligns with Microsoft's AI Transformation strategy and EAG Security's FY26 objectives, with a strong emphasis on practical delivery, governance, and reusable prompt engineering.

## 🌍 **Important: Regional Deployment Guidance**

**⚠️ CRITICAL**: This project deploys infrastructure to **East US** region for complete AI security coverage and curriculum compliance.

**Why East US is Required:**

- **Unified Security Operations**: Required for Week 2 modern security operations platform integration with complete regional feature availability.
- **Complete AI Coverage**: Ensures all advanced security features are available for hands-on learning and enterprise deployment scenarios.
- **Curriculum Alignment**: Week 2 explicitly requires modern unified security operations integration and validation.
- **Future-Proofing**: Optimal foundation for Weeks 3-9 advanced AI security scenarios.

**Regional Impact**: Deploying in regions with limited modern security operations features would create a curriculum compliance gap and prevent completion of required Week 2 deliverables.

📖 **Learn More**: [Microsoft Defender XDR unified security operations platform](https://learn.microsoft.com/en-us/defender-xdr/)

## 📌 Project Goals

- Build a structured, week-by-week AI skilling plan tailored to security-focused consulting.
- Integrate Microsoft Defender, Purview, Priva, Fabric, and Copilot Studio into real-world scenarios.
- Develop and publish reusable prompt libraries and deployment guides.
- Automate publishing workflows using GitHub Pages and Hugo.
- Share learnings and artifacts incrementally to support internal enablement and customer delivery.

## 🎯 **9-Week Learning Path Structure**

This roadmap has been optimized for working professionals with a logical progression through **4 distinct phases**:

### **Phase 1: Security Infrastructure Foundations (Weeks 1-3)**

- **Week 1**: Master Defender for Cloud deployment mastery with modern unified security operations foundation
- **Week 2**: Implement AI integration and enhanced security operations platform
- **Week 3**: Deploy advanced XDR + Security Copilot integration

### **Phase 2: Data Governance & Analytics (Weeks 4-5)**

- **Week 4**: Microsoft Purview for comprehensive data governance
- **Week 5**: Microsoft Priva and responsible AI governance frameworks

### **Phase 3: Advanced Analytics & AI Development (Weeks 6-7)**

- **Week 6**: Microsoft Fabric for secure analytics and data pipelines
- **Week 7**: Azure AI Foundry and secure AI workload deployment

### **Phase 4: Applied AI & Enterprise Delivery (Weeks 8-9)**

- **Week 8**: Copilot Studio for security agents and AI automation
- **Week 9**: Secure Copilot deployment and comprehensive delivery practices

## ⚡ **Key Benefits of This Structure**

- **Realistic Time Investment**: Each week designed for 8-12 hours total (manageable with full-time work)
- **Logical Learning Flow**: Each phase builds methodically on previous knowledge
- **Balanced Workload**: Complex deployment work separated from AI integration
- **Practical Outcomes**: Every week delivers deployable solutions and reusable assets
- **Enterprise Ready**: Progresses from foundational skills to customer-facing delivery capability

## 🌐 Project Site

All publications and guides will be integrated into the main Hugo site.  
🔗 **Site URL:** _[Coming Soon – Placeholder for Hugo site link]_

## 🗂️ Repository Structure

Each week is organized as a separate folder to support modular development and publishing.

## ✅ Project Status

As project weeks are completed, the **Completed** checkbox will be marked.

**Status Legend:**

- [x] = Completed
- [🔄] = In Progress (core deliverables complete, final items pending)
- [ ] = Not Started

| Week | Focus Area | Completed |
|------|------------|--------|
| 0 | [Project Setup & Admin](./00%20-%20Project%20Setup%20&%20Admin/README.md) | [x] |
| 1 | [Defender for Cloud Deployment Mastery](./01%20-%20Defender%20for%20Cloud%20Deployment%20Mastery/README.md) | [x] |
| 2 | [AI Integration & Enhanced Security Operations](./02%20-%20AI%20Integration%20&%20Enhanced%20Security%20Operations/README.md) | [🔄] |
| 3 | [Defender XDR + Security Copilot Integration](./03%20-%20Defender%20XDR%20+%20Security%20Copilot%20Integration/README.md) | [ ] |
| 4 | [Microsoft Purview for Data Governance](./04%20-%20Microsoft%20Purview%20for%20Data%20Governance/README.md) | [ ] |
| 5 | [Microsoft Priva and Responsible AI](./05%20-%20Microsoft%20Priva%20and%20Responsible%20AI/README.md) | [ ] |
| 6 | [Microsoft Fabric for Secure Analytics](./06%20-%20Microsoft%20Fabric%20for%20Secure%20Analytics/README.md) | [ ] |
| 7 | [Azure AI Foundry & Secure AI Workloads](./07%20-%20Azure%20AI%20Foundry%20&%20Secure%20AI%20Workloads/README.md) | [ ] |
| 8 | [Copilot Studio for Security Agents](./08%20-%20Copilot%20Studio%20for%20Security%20Agents/README.md) | [ ] |
| 9 | [Secure Copilot Deployment & Delivery Practices](./09%20-%20Secure%20Copilot%20Deployment%20&%20Delivery%20Practices/README.md) | [ ] |

## 🚀 Enhanced Setup and Validation Tools

The project includes comprehensive automation and validation tools to ensure reliable setup and deployment success:

### Week 00 - Automated Environment Setup

#### Comprehensive Environment Validation

- **[Test-EnvironmentValidation.ps1](./00%20-%20Project%20Setup%20&%20Admin/scripts/Test-EnvironmentValidation.ps1)** - Advanced 9-step environment validation script that checks:
  - Azure CLI installation and authentication
  - PowerShell Az module configuration
  - Subscription permissions (Owner/Contributor validation)
  - East US region access and AI service availability
  - Visual Studio Code and required extensions
  - Git configuration and development tools
  - Comprehensive JSON export capabilities for detailed analysis

#### Automated Development Environment Installation

- **[Install-DevelopmentEnvironment.ps1](./00%20-%20Project%20Setup%20&%20Admin/scripts/Install-DevelopmentEnvironment.ps1)** - Complete 7-step automated installation covering:
  - Azure CLI latest version installation
  - PowerShell Az module setup
  - Visual Studio Code with Azure extensions
  - Git configuration and authentication
  - Development tools optimization

### Week 01 - Security Infrastructure Mastery

#### Complete Deployment Portfolio

- **Azure Portal Deployment** - Comprehensive step-by-step learning path with detailed screenshots and validation
- **Modular Infrastructure-as-Code** - Professional PowerShell + Bicep automation with parameter-driven configuration
- **Enterprise Complete Automation** - Production-ready deployment with advanced error handling and validation
- **Professional Decommission Tools** - Safe cleanup scripts with confirmation workflows and cost optimization

#### Bridge Validation to Week 2

- **Unified Security Operations Readiness** - Validates modern security operations platform capabilities required for AI integration

### Week 02 - AI Integration & Cost Management

#### Cost-Effective AI Foundation

- **Azure OpenAI Service** with GPT-4o-mini deployment optimized for cost control and budget management
- **Storage Account Foundation** for AI workload data processing and Defender XDR integration state management
- **Comprehensive Cost Monitoring** with automated alerts and budget controls

#### Professional AI-Security Integration

- **Azure OpenAI + Defender XDR Integration** - Logic Apps-based automation for intelligent incident analysis through unified portal
- **AI Prompt Template Library** - Security-optimized prompts with cost-effective token usage patterns
- **Built-in AI Features Enablement** - UEBA, Fusion, and Anomaly Detection validation within unified security operations

### Enterprise-Ready Features Across All Weeks

#### Professional PowerShell Standards

- **Industry-Standard Preambles** - Complete comment-based help with SYNOPSIS, DESCRIPTION, EXAMPLES, and NOTES
- **Consistent Terminology** - "Phase" for orchestrators, "Step" for components, "Action" for pipeline scripts
- **Professional Color Schemes** - Magenta for phases, Green for steps, Blue for notifications, Red for errors
- **Comprehensive Error Handling** - Try-catch blocks with detailed logging and recovery guidance

#### Advanced Validation and Testing

- **Multi-Scenario Testing** - Simulation capabilities for various failure conditions and partial setup scenarios
- **JSON Export Capabilities** - Detailed validation results with success rates and targeted recommendations
- **Performance Optimization** - Scripts optimized to avoid timeouts and provide clear progress indicators

#### Documentation Excellence

- **[Markdown Style Guide](../../Style%20Guides/markdown-style-guide.md)** compliance across all documentation
- **[PowerShell Style Guide](../../Style%20Guides/powershell-style-guide.md)** implementation in all automation scripts
- **Comprehensive AI-Assisted Content Attribution** - Transparency in AI tool usage for content generation

This enhanced tooling ensures reliable setup, deployment success, and professional-grade automation throughout the 9-week learning journey.

## 🎉 Recent Achievements and Updates

### Comprehensive Environment Foundation (August 2025)

- **Advanced Validation Framework**: 9-step environment validation with comprehensive error handling and JSON export capabilities
- **Optimized Performance**: Resolved script performance issues including PowerShell module loading optimization and Azure CLI timeout protection  
- **Professional Automation**: Enhanced PowerShell scripts following industry-standard preambles and consistent terminology
- **Multi-Scenario Testing**: Comprehensive simulation capabilities for various setup and failure conditions
- **Cost Management Integration**: Advanced cost monitoring and budget controls throughout AI integration workflows

### Technical Excellence Standards

- **Style Guide Compliance**: All documentation follows centralized [Markdown](../../Style%20Guides/markdown-style-guide.md) and [PowerShell](../../Style%20Guides/powershell-style-guide.md) style guides
- **AI-Assisted Development**: Transparent acknowledgment of GitHub Copilot usage in content generation and script development
- **Enterprise Deployment Readiness**: Production-ready automation with comprehensive error handling and validation
- **Modern Security Integration**: Complete unified security operations platform foundation for Weeks 1-2

## � Documentation Standards

This project follows established style guides to ensure consistency and professionalism across all documentation and code:

- **[Markdown Style Guide](../../Style%20Guides/markdown-style-guide.md)** - Formatting, punctuation, and tone standards for all markdown documentation
- **[PowerShell Style Guide](../../Style%20Guides/powershell-style-guide.md)** - Consistent visual and organizational patterns for PowerShell scripts

These guides define comprehensive standards for headers, lists, code blocks, interface elements, and professional documentation practices.

## 📬 Contributions & Feedback

This is a personal skilling initiative, but collaboration and feedback are welcome! If you’re working on similar goals or want to reuse parts of this roadmap, feel free to fork or adapt.

