# Purview Data Governance Simulation Project - Creation Prompt Template

This specialized prompt template provides structured guidance for creating a comprehensive Microsoft Purview data governance simulation project. It focuses on scripted SharePoint site creation, realistic HR/PII data generation, classification workflows, and DLP policy implementation using PowerShell automation.

---

## 🎯 Purview Data Governance Simulation Project Creation Prompt

```markdown
I need your help creating a Microsoft Purview Data Governance Simulation project from scratch. This project will simulate enterprise data governance scenarios through scripted site creation, bulk document generation with HR-related PII data, and comprehensive classification/DLP workflows. Please follow this structured approach:

## PROJECT CONTEXT

**Skill Area / Domain Expertise Required:**
Microsoft Purview Information Protection, Data Loss Prevention (DLP), custom Sensitive Information Types (SITs), Exact Data Match (EDM), PowerShell automation for SharePoint Online governance, and enterprise-scale data classification

**Specific Targeted Content:**
Create a comprehensive simulation environment demonstrating Microsoft Purview's data governance capabilities through scripted automation. The project should include:

1. **SharePoint Site Provisioning Automation:**
   - PowerShell scripts to create 5-50 SharePoint sites (configurable scale: Small/Medium/Large)
   - Simulates organizational departments (HR, Finance, Legal, Marketing, IT, Operations)
   - Uses PnP PowerShell for site creation with appropriate templates
   - Implements browser-based authentication (no hardcoded secrets)
   - Variable-driven configuration for site definitions

2. **Realistic HR/PII Document Generation:**
   - Document generation engines creating varied file types (.docx, .xlsx, .pdf, .txt, .msg)
   - Embedded HR-related SIT data: SSNs, credit cards, passport numbers, employee IDs, driver's licenses, healthcare identifiers, ITIN numbers, ABA routing numbers
   - Configurable document quantities (500 to 50,000+ documents based on scale selection)
   - Realistic data sprawl simulation across multiple sites and folders
   - Template-based generation with programmatic PII insertion

3. **Custom Sensitive Information Types (SITs):**
   - Custom SIT creation for simulation-specific PII patterns
   - Regex-based SITs with confidence level tuning
   - Exact Data Match (EDM) implementation for employee databases
   - Variable-driven SIT definitions loaded from configuration files
   - Flexible search capabilities allowing users to specify which SITs to target

4. **Bulk Upload and Distribution Automation:**
   - Mass document upload scripts with PnP PowerShell batch operations
   - Distribution algorithms spreading documents across sites realistically
   - Throttling and retry logic for large-scale operations
   - Nested folder structure creation simulating organizational hierarchies
   - Progress tracking and upload verification

5. **Classification and Validation Workflows:**
   - On-Demand Classification triggering across simulated sites
   - Content Explorer API integration for classification validation
   - Activity Explorer queries for compliance monitoring
   - Classification coverage metrics and reporting
   - Variable-driven site/SIT filtering for targeted operations

6. **DLP Policy Implementation:**
   - DLP policy creation targeting custom SITs and built-in HR-related SITs
   - Policy application across simulated SharePoint sites
   - Test mode vs enforcement mode configuration
   - DLP incident reporting and effectiveness validation
   - Extensibility for future retention label integration

7. **Monitoring, Reporting, and Analytics:**
   - PowerShell-driven dashboards showing classification metrics
   - DLP incident analysis and trending reports
   - Coverage metrics across sites and document types
   - Executive-level summary reports suitable for demonstrations
   - Export capabilities for external analysis

8. **Cleanup and Reset Automation:**
   - Targeted cleanup: Remove specific sites, documents, or policies based on variables
   - Full automated cleanup: One-click complete environment reset
   - Safety checks to prevent accidental production data deletion
   - Cleanup verification and reporting
   - Support for repeatable simulation runs

9. **Configuration-Driven Architecture:**
   - Centralized variables/configuration file (`simulation-config.json` or `simulation-variables.ps1`)
   - Users define sites, SITs, DLP policies, scale level, and search criteria ahead of time
   - Scripts read configuration at runtime (no prompts or hardcoded values)
   - Environment-specific settings (tenant URLs, admin emails, simulation parameters)
   - Easy configuration updates without script modifications

**Target File Types to Create:**
PowerShell scripts (.ps1), JSON configuration files (.json), CSV data files for EDM (.csv), Markdown documentation (.md), document generation templates (.docx, .xlsx), sample text files for testing (.txt, .pdf templates)

**Organization & Structure Requirements:**
Follow Infrastructure-as-Code patterns with:
- Numbered lab directories (00-Prerequisites-Setup/ through 08-Cleanup-Reset/)
- scripts/ subdirectory in each lab with comprehensive PowerShell automation
- Shared-Utilities/ directory for reusable modules (authentication, logging, configuration loading)
- configs/ or variables/ directory containing centralized configuration files
- data-templates/ directory with sample HR/PII data templates
- Comprehensive root-level README with architecture overview, quick start, and scaling guidance
- Each lab README with step-by-step instructions, prerequisites, and expected outcomes
- Variable-driven script execution (no interactive prompts)
- Browser-based authentication patterns matching existing Purview projects

**Content Reuse Strategy:**
- Review the Purview-Classification-Lifecycle-Labs project in Microsoft/Purview/ directory
- Review the Purview-Skills-Ramp-OnPrem-and-Cloud project in Microsoft/Purview/ directory
- Leverage authentication patterns (Connect-IPPSSession, Connect-PnPOnline with browser auth)
- Adapt custom SIT creation and EDM implementation workflows
- Reuse bulk operation architectures (error handling, logging, progress tracking)
- Extract PowerShell module patterns for shared utilities
- **CRITICAL**: Duplicate and customize content rather than linking to it - this project must be fully self-contained
- Extract applicable authentication, bulk upload, and classification validation patterns
- Adapt to simulation-specific workflows (parameterized scaling, variable-driven execution)
- Do NOT assume any work from reference projects has been completed
- Do NOT create references or links to other projects - embed all necessary content directly
- Treat this as a "from scratch" implementation that reuses proven patterns but stands alone completely

**Additional Context:**
This is a "from scratch" simulation project - do not assume any prior Purview configuration or existing production environment. All prerequisites, environment setup, and foundational steps must be included. The project emphasizes **scripting automation** over manual processes, with heavy use of configuration files to drive script behavior. Target audience includes Purview administrators, security engineers, and consultants who need repeatable demonstration/testing environments. The simulation approach avoids the cost and complexity of deploying actual "hundreds of sites with petabytes of data" by using parameterized scripting to create realistic but manageable data scenarios (5-50 sites, 500-50K documents).

**CRITICAL PORTABILITY REQUIREMENT**: All scripts must be **100% environment-agnostic** and portable across any Microsoft 365 tenant. Every environment-specific value (tenant URLs, domain names, admin emails, site names, SIT names, policy names, etc.) MUST be defined in configuration files. Scripts should work in any environment by simply updating the config file - no code changes required. This enables consultants to reuse scripts across client environments and administrators to migrate simulation setups between dev/test/prod tenants.

## COMPLIANCE REQUIREMENTS

Before creating any content, you MUST:

1. **Review Repository Style Guides:**
   - Read and understand the Markdown Style Guide (Style Guides/markdown-style-guide.md)
   - Read and understand the PowerShell Style Guide (Style Guides/powershell-style-guide.md)
   - Read and understand the Parameters File Style Guide (Style Guides/parameters-file-style-guide.md) for configuration file standards
   - Follow all style guide requirements for headers, formatting, punctuation, and structure

2. **Review Existing Reference Projects:**
   - Examine Purview-Classification-Lifecycle-Labs for authentication patterns, SIT creation, EDM workflows, bulk operations
   - Examine Purview-Skills-Ramp-OnPrem-and-Cloud for SharePoint site configuration, document generation, cleanup procedures
   - Use semantic_search or read_file to extract relevant PowerShell modules, error handling patterns, documentation structures
   - **CRITICAL**: Extract and duplicate content - do not reference projects by name or create links
   - Identify browser-based authentication patterns (`Connect-PnPOnline -Interactive`, `Connect-IPPSSession` without credential parameters)
   - Extract configuration loading patterns and adapt to centralized variables file approach

3. **Follow Copilot Instructions:**
   - Adhere to all standards defined in .github/copilot-instructions.md
   - Apply appropriate style guide compliance for each file type
   - Use proper formatting, headers, punctuation, and structure
   - Include AI-assisted content generation acknowledgments where required

4. **Apply Best Practices:**
   - Use proper naming conventions for files and resources
   - Implement consistent formatting and organization
   - Include comprehensive documentation and comments
   - Follow industry standards for PowerShell scripting and SharePoint automation

5. **Research and Validate Before Creating:**
   - **NEVER rely on training data** for step-by-step instructions, code examples, or technical procedures
   - **USE DEEP REASONING AGENTS**: Always use deep reasoning models (e.g., Claude with extended thinking) when performing research, analysis, or architectural decisions
   - **PRIMARY SOURCE**: Always use Microsoft Learn (learn.microsoft.com) as the primary validation source
   - Research PnP PowerShell cmdlets: [pnp.github.io/powershell/](https://pnp.github.io/powershell/)
   - Research Security & Compliance PowerShell: [learn.microsoft.com/powershell/exchange/](https://learn.microsoft.com/en-us/powershell/exchange/)
   - Research custom SIT creation: [learn.microsoft.com/purview/create-a-custom-sensitive-information-type](https://learn.microsoft.com/en-us/purview/create-a-custom-sensitive-information-type)
   - Research EDM configuration: [learn.microsoft.com/purview/sit-get-started-exact-data-match-based-sits-overview](https://learn.microsoft.com/en-us/purview/sit-get-started-exact-data-match-based-sits-overview)
   - Research DLP policies: [learn.microsoft.com/purview/dlp-learn-about-dlp](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)
   - Research Content Explorer API: [learn.microsoft.com/graph/api/resources/contentexplorer](https://learn.microsoft.com/en-us/graph/api/resources/security-api-overview)
   - **Document Type Distribution Research**: Use Microsoft Learn or industry sources to determine realistic organizational document type distributions
   - **Built-in HR SIT Research**: Research all built-in HR-related Sensitive Information Types from Microsoft Purview documentation to ensure comprehensive coverage

## REQUIRED ITERATIVE APPROVAL PROCESS

**Phase 1: Project Structure Proposal**

Before creating ANY files or content:

1. **Engage deep reasoning** for architectural analysis and simulation scaling strategy
2. **Research document type distributions** for large organizations to inform generation ratios
3. **Research built-in HR-related SITs** to ensure comprehensive PII data type coverage
4. **Review existing Purview projects** to identify authentication, bulk operation, and configuration patterns
5. **Suggest a descriptive project name** following repository naming conventions
6. **Propose a complete directory structure** showing all folders and key files
7. **Explain the purpose** of each major directory and file type
8. **Describe the organization rationale** and how it meets simulation requirements
9. **Detail the configuration file architecture** (JSON/PS1 structure, variable definitions, scale parameters)
10. **Explain authentication approach** (browser-based, no secrets, matching existing patterns)
11. **Identify content to duplicate** from reference projects and how it will be adapted
12. **Wait for my approval or feedback** before proceeding

**Phase 2: Iterative Refinement**

If I request changes:

1. **Revise the proposed structure** based on my feedback
2. **Explain the changes made** and why they address my concerns
3. **Present the updated proposal** for review
4. **Repeat this process** until I explicitly approve the structure

**Phase 3: Implementation**

Only after I provide explicit approval:

1. **Create the directory structure** as approved
2. **Generate all files** following the repository style guides
3. **Implement variable-driven configuration architecture**
4. **Create comprehensive documentation** with setup, usage, and troubleshooting guidance
5. **Ensure compliance** with all formatting and documentation standards
6. **Provide a summary** of what was created and next steps

## OUTPUT FORMAT REQUIREMENTS

### For Project Structure Proposal:

```text
## Proposed Project Structure

**Project Name:** Purview-Data-Governance-Simulation

**Directory Tree:**

```text
Purview-Data-Governance-Simulation/
├── README.md
├── global-config.json
├── PORTABILITY-GUIDE.md
├── 00-Prerequisites-Setup/
│   ├── README.md
│   └── scripts/
│       ├── Test-Prerequisites.ps1
│       └── Initialize-SimulationEnvironment.ps1
├── 01-SharePoint-Site-Creation/
│   ├── README.md
│   └── scripts/
│       ├── New-SimulatedSharePointSites.ps1
│       ├── Set-SitePermissions.ps1
│       └── Verify-SiteCreation.ps1
├── 02-Test-Data-Generation/
│   ├── README.md
│   ├── data-templates/
│   │   ├── employee-records.csv
│   │   ├── financial-data-template.xlsx
│   │   ├── hr-document-templates/
│   │   └── mixed-content-samples/
│   └── scripts/
│       ├── New-SimulatedHRDocuments.ps1
│       ├── New-SimulatedFinancialRecords.ps1
│       ├── New-SimulatedPIIContent.ps1
│       ├── New-MixedContentDocuments.ps1
│       └── Invoke-BulkDocumentGeneration.ps1
├── 03-Document-Upload-Distribution/
│   ├── README.md
│   └── scripts/
│       ├── Invoke-BulkDocumentUpload.ps1
│       ├── Distribute-DocumentsAcrossSites.ps1
│       ├── Set-DocumentMetadata.ps1
│       └── Verify-UploadDistribution.ps1
├── 04-Custom-SIT-Creation/
│   ├── README.md
│   ├── configs/
│   │   ├── custom-sits-hr.json
│   │   ├── custom-sits-finance.json
│   │   └── edm-schema-employees.json
│   └── scripts/
│       ├── New-CustomSITsForSimulation.ps1
│       ├── New-EDMSchemaForEmployees.ps1
│       ├── Import-EDMData.ps1
│       └── Test-CustomSITAccuracy.ps1
├── 05-Classification-Validation/
│   ├── README.md
│   └── scripts/
│       ├── Invoke-OnDemandClassification.ps1
│       ├── Measure-ClassificationCoverage.ps1
│       ├── Export-ContentExplorerReport.ps1
│       └── Validate-SITDetection.ps1
├── 06-DLP-Policy-Implementation/
│   ├── README.md
│   └── scripts/
│       ├── New-SimulationDLPPolicies.ps1
│       ├── Apply-DLPPoliciesToSites.ps1
│       ├── Test-DLPPolicyEffectiveness.ps1
│       └── Get-DLPIncidentReport.ps1
├── 07-Monitoring-Reporting/
│   ├── README.md
│   └── scripts/
│       ├── Get-ClassificationMetrics.ps1
│       ├── Get-DLPIncidentSummary.ps1
│       ├── Measure-CoverageAcrossSites.ps1
│       └── Export-SimulationDashboard.ps1
├── 08-Cleanup-Reset/
│   ├── README.md
│   └── scripts/
│       ├── Remove-TargetedSimulationResources.ps1
│       ├── Reset-CompleteSimulationEnvironment.ps1
│       ├── Verify-CleanupCompletion.ps1
│       └── Export-CleanupReport.ps1
└── Shared-Utilities/
    ├── Connect-PurviewServices.ps1
    ├── Import-SimulationConfig.ps1
    ├── Write-SimulationLog.ps1
    ├── Test-ServiceConnection.ps1
    └── Get-SimulationProgress.ps1
```

**Directory Purpose Explanations:**

- **00-Prerequisites-Setup/**: Validates Microsoft 365 E5 licensing, required PowerShell modules (PnP.PowerShell, ExchangeOnlineManagement), admin permissions, and connectivity. Initializes logging infrastructure and verifies browser-based authentication works correctly. Creates initial configuration file from template if needed.

- **01-SharePoint-Site-Creation/**: Automated SharePoint site provisioning scripts that read site definitions from centralized config file. Creates 5-50 sites based on scale level selection (Small/Medium/Large). Uses PnP PowerShell with browser-based authentication (`Connect-PnPOnline -Interactive`). Implements department templates (HR, Finance, Legal, etc.) with appropriate site structures and permission configurations.

- **02-Test-Data-Generation/**: Core document generation engines that create realistic files with embedded HR-related PII data. Includes all built-in HR SIT types researched from Microsoft Purview documentation (SSNs, credit cards, passport numbers, ITIN, ABA routing, healthcare IDs, driver's licenses, employee IDs). Uses document type distribution researched from enterprise data patterns. Generates 500-50,000+ documents based on scale configuration. Template-driven with programmatic PII insertion at configurable density levels.

- **03-Document-Upload-Distribution/**: Bulk upload automation using PnP PowerShell batch operations. Reads upload distribution matrix from config file (sites, folders, document counts). Implements intelligent distribution algorithms simulating realistic data sprawl. Includes throttling, retry logic, and progress tracking for large-scale operations. Creates nested folder hierarchies matching organizational patterns.

- **04-Custom-SIT-Creation/**: Custom Sensitive Information Type creation for simulation-specific patterns. Reads SIT definitions from JSON config files. Implements regex-based SITs with confidence tuning and EDM-based SITs for employee databases. Uses browser-based Security & Compliance PowerShell authentication. Provides validation scripts to test SIT accuracy against generated documents. All SIT definitions are variable-driven from config files.

- **05-Classification-Validation/**: On-Demand Classification triggering across sites defined in config file. Content Explorer API integration for classification result queries. Flexible SIT filtering based on config variables (users specify which SITs to validate). Coverage metrics showing classification effectiveness. Activity Explorer queries for compliance monitoring. All operations read target sites/SITs from centralized configuration.

- **06-DLP-Policy-Implementation/**: DLP policy creation and management focused on HR-related SITs. Reads DLP policy definitions from config file (which SITs to target, which sites to apply to, test vs enforcement mode). Browser-based authentication for policy operations. DLP incident reporting and effectiveness analysis. Variable-driven policy targeting (no hardcoded values). Foundation for future retention label integration if needed.

- **07-Monitoring-Reporting/**: PowerShell-driven analytics pulling classification metrics, DLP incidents, and coverage statistics. Reads reporting parameters from config (which sites, which SITs, date ranges). Generates executive summaries and detailed technical reports. Export capabilities for external analysis tools. Dashboard-style output suitable for demonstrations.

- **08-Cleanup-Reset/**: Two cleanup modes: (1) Targeted removal reading specific resources from config file, (2) One-click full automation removing all simulation resources. Safety checks prevent accidental production deletion. Verification scripts confirm cleanup completion. Supports repeatable simulation runs. All cleanup operations are config-driven.

- **Shared-Utilities/**: Reusable PowerShell modules extracted from existing Purview projects. Browser-based authentication functions (`Connect-PurviewServices.ps1` wrapping Connect-IPPSSession and Connect-PnPOnline -Interactive). **Configuration loading module (`Import-GlobalConfig.ps1`) - CRITICAL for portability** - reads `global-config.json` from project root, merges with optional lab-specific configs, validates required sections, provides clear error messages for missing/invalid config, supports `-GlobalConfigPath` parameter for multi-tenant consultant scenarios. Includes `$GLOBAL:` reference resolver for lab configs that reference global values. Logging infrastructure following established patterns. Connection health checks. Progress tracking utilities. **All utilities designed for zero hardcoded values - complete environment agnosticism through global config pattern**.

**Configuration File Architecture:**

**Two-Tier Configuration System** for optimal portability and reusability:

**1. Global Configuration (`global-config.json`)** - Root level, shared across ALL labs:

Contains **ALL environment-specific values** that are reused throughout the project. Every script references this single source of truth.

```json
{
  "Environment": {
    "TenantUrl": "https://contoso.sharepoint.com",
    "TenantDomain": "contoso.onmicrosoft.com",
    "AdminEmail": "admin@contoso.onmicrosoft.com",
    "AdminCenterUrl": "https://contoso-admin.sharepoint.com",
    "ComplianceUrl": "https://compliance.microsoft.com",
    "OrganizationName": "Contoso Corporation",
    "EnvironmentType": "Development",
    "Region": "North America"
  },
  "Simulation": {
    "ScaleLevel": "Medium",
    "CompanyPrefix": "CONTOSO",
    "ResourcePrefix": "Dev-Sim",
    "DefaultOwner": "admin@contoso.onmicrosoft.com",
    "NotificationEmail": "compliance-team@contoso.onmicrosoft.com"
  },
  "SharePointSites": [
    {"Name": "HR-Simulation", "Template": "Communication", "Department": "HR", "Owner": "admin@contoso.onmicrosoft.com", "Description": "HR department simulation site"},
    {"Name": "Finance-Simulation", "Template": "Team", "Department": "Finance", "Owner": "admin@contoso.onmicrosoft.com", "Description": "Finance department simulation site"},
    {"Name": "Legal-Simulation", "Template": "Communication", "Department": "Legal", "Owner": "admin@contoso.onmicrosoft.com", "Description": "Legal department simulation site"},
    {"Name": "Marketing-Simulation", "Template": "Team", "Department": "Marketing", "Owner": "admin@contoso.onmicrosoft.com", "Description": "Marketing department simulation site"},
    {"Name": "IT-Simulation", "Template": "Team", "Department": "IT", "Owner": "admin@contoso.onmicrosoft.com", "Description": "IT department simulation site"}
  ],
  "CustomSITs": [
    {"Name": "Contoso-Employee-ID", "DisplayName": "Contoso Employee ID", "RegexPattern": "EMP-\\d{6}", "Confidence": 85, "Description": "Contoso employee identification number"},
    {"Name": "Contoso-Project-Code", "DisplayName": "Contoso Project Code", "RegexPattern": "PROJ-[A-Z]{3}-\\d{4}", "Confidence": 75, "Description": "Contoso internal project codes"},
    {"Name": "Contoso-Department-Code", "DisplayName": "Contoso Department Code", "RegexPattern": "DEPT-\\d{3}", "Confidence": 80, "Description": "Contoso department identification codes"}
  ],
  "Paths": {
    "LogDirectory": "./logs",
    "OutputDirectory": "./output",
    "GeneratedDocumentsPath": "./generated-documents",
    "ReportsPath": "./reports",
    "TempPath": "./temp"
  },
  "Logging": {
    "LogLevel": "Verbose",
    "RetainLogDays": 30,
    "EnableConsoleOutput": true,
    "EnableFileOutput": true
  }
}
```

**2. Lab-Specific Configuration Files** - Optional overrides and lab-specific parameters:

Each lab can optionally include a `lab-config.json` file for lab-specific settings that override or extend global config:

**Example: `02-Test-Data-Generation/lab-config.json`**

```json
{
  "DocumentGeneration": {
    "TotalDocuments": 5000,
    "FileTypeDistribution": {"docx": 45, "xlsx": 30, "pdf": 15, "txt": 10},
    "PIIDensity": "Medium",
    "IncludeSITTypes": ["SSN", "CreditCard", "PassportNumber", "EmployeeID"],
    "OutputPath": "$GLOBAL:Paths.GeneratedDocumentsPath"
  },
  "EmployeeDatabase": {
    "RecordCount": 1000,
    "DepartmentDistribution": {"HR": 15, "Finance": 20, "Legal": 10, "Marketing": 25, "IT": 30}
  }
}
```

**Example: `06-DLP-Policy-Implementation/lab-config.json`**

```json
{
  "DLPPolicies": {
    "PolicyPrefix": "$GLOBAL:Simulation.ResourcePrefix",
    "TargetSITs": ["U.S. Social Security Number", "Credit Card Number", "Contoso-Employee-ID"],
    "TargetSites": ["$GLOBAL:SharePointSites[0].Name", "$GLOBAL:SharePointSites[1].Name"],
    "Mode": "TestWithoutNotifications",
    "NotificationEmail": "$GLOBAL:Simulation.NotificationEmail"
  },
  "PolicyRules": [
    {"Name": "Block-SSN-External", "Action": "BlockAccess", "Condition": "SSN detected in external share"},
    {"Name": "Notify-CreditCard", "Action": "NotifyUser", "Condition": "Credit card number detected"}
  ]
}
```

**Example: `08-Cleanup-Reset/lab-config.json`**

```json
{
  "CleanupTargets": {
    "Sites": ["$GLOBAL:SharePointSites[*].Name"],
    "CustomSITs": ["$GLOBAL:CustomSITs[*].Name"],
    "DLPPolicies": ["All-Simulation-Policies"],
    "RetentionLabels": ["All-Simulation-Labels"]
  },
  "SafetyChecks": {
    "RequireConfirmation": true,
    "AllowProductionCleanup": false,
    "ValidateNamePatterns": ["Simulation", "$GLOBAL:Simulation.ResourcePrefix"]
  }
}
```

**Portability Features:**

- ✅ **Single source of truth**: All environment values in one `global-config.json` file at root
- ✅ **Cross-lab reusability**: Every script references global config - change once, apply everywhere
- ✅ **Zero hardcoded URLs**: All tenant URLs, admin centers, compliance portals from global config
- ✅ **Zero hardcoded domains**: Tenant domains, email addresses configurable per environment
- ✅ **Zero hardcoded names**: Site names, SIT names, policy names, label names all from global config
- ✅ **Environment markers**: OrganizationName, EnvironmentType, Region help identify config context
- ✅ **Prefix-based naming**: ResourcePrefix enables environment-specific naming (Dev-Sim-, Test-Sim-, Prod-Sim-)
- ✅ **Path flexibility**: All paths in Paths section - configurable for different file systems
- ✅ **Owner variablization**: DefaultOwner, NotificationEmail from global config (no admin@ hardcoding)
- ✅ **Company-specific patterns**: CompanyPrefix enables organization-specific document generation
- ✅ **Lab-specific overrides**: Optional lab-config.json files for lab-specific parameters
- ✅ **Config reference syntax**: `$GLOBAL:` notation allows lab configs to reference global values

**Authentication Approach:**

- **Browser-based authentication** matching existing Purview project patterns
- `Connect-PnPOnline -Url $siteUrl -Interactive` for SharePoint operations (no credentials passed)
- `Connect-IPPSSession` without credential parameters for Security & Compliance PowerShell
- No secrets, app registrations, or service principals required
- Shared-Utilities module provides consistent authentication wrapper functions
- All scripts call centralized authentication functions from Shared-Utilities/

**Organization Rationale:**

The structure follows proven patterns from existing Purview projects while adapting to simulation-specific requirements:

1. **Variable-Driven Architecture**: Centralized config file eliminates hardcoded values and interactive prompts. Users define all parameters once, scripts read at runtime.

2. **Scalable Design**: Scale level parameter (Small/Medium/Large) adjusts site counts, document quantities, and processing batches automatically.

3. **Browser-Based Security**: Matches authentication patterns from Classification-Lifecycle-Labs and Skills-Ramp projects (no secret management complexity).

4. **Progressive Workflow**: Numbered labs follow logical dependency chain with clear prerequisites and outcomes.

5. **Simulation-First Philosophy**: Emphasizes scripted automation and realistic data generation over manual processes or actual enterprise-scale deployment.

6. **Reusable Modules**: Shared-Utilities directory promotes DRY principles and maintains consistency with existing projects.

7. **Flexible Targeting**: Config-driven SIT selection, site filtering, and cleanup operations enable customized simulation scenarios.

8. **Enterprise-Grade Quality**: Production-quality error handling, logging, retry logic, and documentation suitable for professional portfolios.

**Key File Types to be Created:**

- **PowerShell scripts (.ps1)**: 35-40 files
  - Prerequisites validation and environment setup (2-3 scripts)
  - SharePoint site provisioning automation (3-4 scripts)
  - Document generation engines for varied PII types (5-6 scripts)
  - Bulk upload and distribution operations (4-5 scripts)
  - Custom SIT and EDM implementation (4-5 scripts)
  - Classification validation and Content Explorer queries (4-5 scripts)
  - DLP policy creation and management (4-5 scripts)
  - Monitoring, reporting, and analytics (4-5 scripts)
  - Cleanup automation (targeted and full) (4-5 scripts)
  - Shared utility modules (5-6 scripts)

- **Markdown documentation (.md)**: 10-12 files
  - Root README with architecture, quick start, scaling guide
  - Lab-specific README files with step-by-step instructions (9 files)
  - Configuration file documentation
  - Troubleshooting and FAQ guide

- **JSON configuration files (.json)**: 10-12 files
  - **Global configuration file (`global-config.json`)** - Single source of truth for all environment values
  - **Global config template (`global-config.template.json`)** - Documented template for new environments
  - **Lab-specific config files (`lab-config.json`)** - Optional overrides in 3-5 labs
  - Custom SIT definitions (regex patterns, confidence levels)
  - EDM schema definitions for employee databases
  - DLP policy templates
  - Document generation parameters
  - Upload distribution matrix
  - Scale level presets (small/medium/large)

- **CSV data files (.csv)**: 5-7 files
  - Employee database templates for EDM hashing (100-1000 records)
  - Sample PII datasets (synthetic SSNs, credit cards, healthcare IDs)
  - Site provisioning matrix (site names, templates, owners, departments)
  - Document type distribution templates
  - Classification results export templates

- **Document templates**: 12-15 files
  - Word document templates (.docx) with PII placeholders
  - Excel templates (.xlsx) for financial/HR data structures
  - Text file templates for varied content types
  - Sample PDF templates (if programmatic PDF generation included)

**Research Validation Performed:**

- ✅ **Document Type Distribution**: Research enterprise document type ratios from Microsoft 365 usage patterns and industry studies
- ✅ **Built-in HR SITs**: Comprehensive research of all built-in HR-related Sensitive Information Types from Microsoft Purview documentation (learn.microsoft.com/purview/sensitive-information-type-entity-definitions)
- ✅ **PnP PowerShell Cmdlets**: Validate site creation, document upload, and batch operation cmdlets against current PnP.PowerShell module documentation
- ✅ **Security & Compliance PowerShell**: Verify SIT creation, DLP policy, and classification cmdlets against ExchangeOnlineManagement module docs
- ✅ **Content Explorer API**: Research current Microsoft Graph Security API endpoints for classification data retrieval
- ✅ **Browser-Based Auth**: Validate Connect-PnPOnline -Interactive and Connect-IPPSSession authentication patterns from existing projects
- ✅ **EDM Configuration**: Verify EdmUploadAgent.exe usage, schema requirements, and hashing procedures from Microsoft Learn
- ✅ **SharePoint Throttling**: Research throttling limits, retry-after headers, and best practices for bulk operations

**Content Reuse from Reference Projects:**

- **Authentication patterns**: Browser-based Connect-IPPSSession and Connect-PnPOnline -Interactive wrappers from Classification-Lifecycle-Labs
- **Custom SIT creation**: Regex pattern development and confidence tuning from Lab 01-CustomSITs
- **EDM implementation**: Schema creation, hashing workflows, and upload procedures from Lab 02-CustomSITs-EDM
- **Bulk operations**: Error handling, progress tracking, and logging patterns from Lab 05-PowerShellAutomation
- **Content Explorer queries**: Classification validation and reporting from Lab 03-OnDemandClassification
- **SharePoint site operations**: Site creation and document upload patterns from Skills-Ramp Setup-02-Azure-Infrastructure
- **Cleanup procedures**: Resource removal with safety checks from Skills-Ramp cleanup scripts
- **Shared utilities**: Module structures and helper functions extracted from both reference projects
- **All content will be extracted and embedded directly** - no links or references to source projects

**Awaiting Approval:** Please review this structure and provide feedback or approval to proceed.
```

### For Iterative Refinement:

```text
## Revised Project Structure (Version [N])

**Changes Made Based on Feedback:**

1. [Specific change description with rationale]
2. [Specific change description with rationale]
3. [Continue for all changes]

**Updated Directory Tree:**

```text
[Updated structure here]
```

**Updated Rationale:**

[Explanation of how changes address feedback and improve the design]

**Awaiting Approval:** Please review these revisions and provide feedback or approval to proceed.
```

### For Implementation Summary

```text
## Project Implementation Complete

**Created Structure:**

- Created 9 numbered lab directories (00-Prerequisites-Setup through 08-Cleanup-Reset)
- Generated 38 PowerShell scripts across labs and shared utilities
- Created 11 markdown documentation files including comprehensive README files
- Built 9 JSON configuration files for simulation parameters, SIT definitions, DLP policies
- Created 6 CSV sample datasets for EDM and site provisioning
- Developed 14 document templates for HR/PII content generation
- Implemented centralized configuration architecture (simulation-config.json)
- Built shared utilities module with browser-based authentication wrappers

**Configuration-Driven Features:**

- ✅ **Global configuration architecture** - Single `global-config.json` at root, referenced by all scripts across all labs
- ✅ **Lab-specific config support** - Optional `lab-config.json` files with `$GLOBAL:` reference syntax
- ✅ **100% environment portability** - zero hardcoded tenant URLs, domains, email addresses, or resource names
- ✅ **Comprehensive PORTABILITY-GUIDE.md** - Step-by-step lift-and-shift instructions for environment migration
- ✅ **Multi-tenant support** - scripts accept -GlobalConfigPath for consultant scenarios across multiple clients
- ✅ **Config template included** - `global-config.template.json` with comprehensive documentation
- ✅ **Environment markers** - PolicyPrefix, LabelPrefix, CompanyPrefix enable dev/test/prod differentiation
- ✅ **Config validation** - Import-SimulationConfig validates all required sections, provides clear errors
- ✅ Scale level selection (Small/Medium/Large) adjusting document counts and site quantities
- ✅ Variable-driven site provisioning (no hardcoded site names)
- ✅ Flexible SIT targeting for classification and DLP operations
- ✅ Configurable cleanup targets (targeted vs full automation)
- ✅ Document type distribution based on enterprise research findings
- ✅ All built-in HR SIT types included in generation and policy options
- ✅ **Config template included** - simulation-config.template.json with comprehensive comments

**Authentication Implementation:**

- ✅ Browser-based authentication throughout (Connect-PnPOnline -Interactive, Connect-IPPSSession)
- ✅ No secrets, credentials, or app registrations required
- ✅ Shared-Utilities/Connect-PurviewServices.ps1 provides consistent auth wrappers
- ✅ All scripts call centralized authentication functions (matching existing project patterns)

**Style Guide Compliance:**

- ✅ PowerShell Style Guide: Proper preambles (.SYNOPSIS/.DESCRIPTION/.EXAMPLE), Step terminology with Green headers, comprehensive error handling, Marcus Jacobson authorship with GitHub Copilot acknowledgment
- ✅ Markdown Style Guide: Hash-based headers (####), bold interface elements, proper punctuation (periods on bullets), blockquotes with emoji categorization, AI-assisted content acknowledgments
- ✅ Parameters File Style Guide: Followed for JSON configuration file structure (camelCase naming, proper type definitions, descriptive documentation)

**Research Validation Performed:**

- ✅ Document type distribution validated: 45% .docx, 30% .xlsx, 15% .pdf, 10% .txt (based on Microsoft 365 enterprise usage research)
- ✅ Built-in HR SIT types researched: 15+ types including SSN, Credit Card, Passport, ITIN, ABA Routing, Healthcare IDs, Driver's License, Employee ID patterns
- ✅ PnP PowerShell cmdlets verified: New-PnPSite, Add-PnPFile, Connect-PnPOnline validated against v2.x documentation
- ✅ Security & Compliance PowerShell verified: New-DlpComplianceRule, New-DataClassification cmdlets validated
- ✅ Content Explorer API endpoints verified against Microsoft Graph Security API v1.0 documentation
- ✅ Browser authentication patterns validated from existing Classification-Lifecycle-Labs project
- ✅ SharePoint throttling limits researched: 600 requests per minute, 2500 requests per hour per user

**Simulation Scale Levels Implemented:**

| Scale | Sites | Documents | Est. Size | Classification Time |
|-------|-------|-----------|-----------|---------------------|
| **Small** | 5 sites | 500-1,000 docs | 100-500 MB | 15-30 min |
| **Medium** | 12 sites | 5,000 docs | 2-4 GB | 1-2 hours |
| **Large** | 25 sites | 20,000 docs | 10-15 GB | 4-6 hours |

**Next Steps:**

1. Review root README.md for comprehensive architecture overview and quick start instructions
2. Edit simulation-config.json to customize environment settings, scale level, and target parameters
3. Execute Lab 00-Prerequisites-Setup to validate licensing, modules, and connectivity
4. Run Lab 01-SharePoint-Site-Creation to provision simulated sites (reads from config file)
5. Execute Lab 02-Test-Data-Generation to create realistic HR/PII documents (scale-appropriate quantities)
6. Proceed through Labs 03-08 for upload, classification, DLP policies, monitoring, and cleanup

**Additional Notes:**

- All scripts are config-driven (no prompts or hardcoded values)
- Browser-based authentication eliminates secret management complexity
- Scale level selection automatically adjusts batch sizes and timeouts
- Cleanup scripts support both targeted and full automated reset
- Project is self-contained with no dependencies on other repository projects
- Professional-quality error handling, logging, and documentation throughout
- Suitable for demonstrations, testing, training, and consultant portfolios
```

## CRITICAL RULES

1. **Never skip the approval phase** - Always wait for explicit approval before creating files
2. **Never assume project structure** - Always propose and iterate based on feedback
3. **Always read style guides first** - Ensure compliance from the start
4. **Always review reference projects** - Extract authentication, bulk operation, and configuration patterns
5. **Always duplicate, never link** - Embed content directly; no references to other projects
6. **Always validate against official documentation** - Research PnP PowerShell, Security & Compliance PowerShell, Content Explorer APIs
7. **Always use deep reasoning agents** - Engage extended thinking for architectural decisions and research
8. **Always implement configuration-driven architecture** - No prompts or hardcoded values in scripts
9. **Always ensure complete environment portability** - Zero hardcoded tenants, domains, names, or paths; scripts must work across any M365 tenant by config update only
10. **Always use browser-based authentication** - Match existing project patterns (no secrets)
11. **Always research document distributions and built-in SITs** - Base generation parameters on validated data
12. **Always provide detailed explanations** - Help me understand your design decisions
13. **Always be ready to iterate** - Expect multiple rounds of refinement
14. **Never create partial implementations** - Wait for full approval of complete structure

## STYLE GUIDE COMPLIANCE CHECKLIST

Before implementing, verify:

- [ ] Reviewed Markdown Style Guide (Style Guides/markdown-style-guide.md)
- [ ] Reviewed PowerShell Style Guide (Style Guides/powershell-style-guide.md)
- [ ] Reviewed Parameters File Style Guide for JSON config structure
- [ ] Reviewed Purview-Classification-Lifecycle-Labs for authentication and bulk operation patterns
- [ ] Reviewed Purview-Skills-Ramp-OnPrem-and-Cloud for SharePoint site operations
- [ ] Identified browser-based authentication patterns (Connect-PnPOnline -Interactive, Connect-IPPSSession)
- [ ] Planned configuration-driven architecture (centralized variables file)
- [ ] **Validated complete environment portability** (zero hardcoded tenant/domain/name values)
- [ ] **Designed config structure for multi-tenant consultant scenarios**
- [ ] **Ensured all scripts accept -ConfigPath parameter** for environment flexibility
- [ ] **Created config validation functions** checking required sections
- [ ] Understood file naming conventions and directory organization
- [ ] Planned for AI-assisted content generation acknowledgments
- [ ] **Researched document type distributions** from enterprise data sources
- [ ] **Researched all built-in HR-related SITs** from Microsoft Purview documentation
- [ ] **Validated PnP PowerShell cmdlets** for site creation and document upload
- [ ] **Validated Security & Compliance PowerShell cmdlets** for SIT and DLP operations
- [ ] **Engaged deep reasoning** for simulation scaling strategy and architecture decisions

## ENVIRONMENT PORTABILITY REQUIREMENTS

### Complete Variablization Mandate

**CRITICAL**: Every script must be portable across any Microsoft 365 tenant without code modifications. This is achieved through comprehensive variablization:

**Environment-Specific Values That MUST Be in Config Files:**

1. **Tenant Information**:
   - SharePoint tenant URL (https://[tenant].sharepoint.com)
   - Admin center URL (https://[tenant]-admin.sharepoint.com)
   - Tenant domain ([tenant].onmicrosoft.com)
   - Organization name for display purposes

2. **User Accounts**:
   - Admin email addresses for site owners
   - Notification email addresses for policies
   - Compliance team contact emails
   - Service account identifiers (if applicable)

3. **Resource Names**:
   - SharePoint site names (with environment prefixes: Dev-HR-Sim, Prod-HR-Sim)
   - Custom SIT names (with organization prefixes: Contoso-EmployeeID, Fabrikam-EmployeeID)
   - DLP policy names (with environment markers: Dev-Simulation-DLP, Prod-Simulation-DLP)
   - Retention label names (with prefixes: Test-Financial-7yr, Prod-Financial-7yr)

4. **File System Paths**:
   - Log file directories (./logs, C:\Purview\Logs, /var/log/purview)
   - Generated document output paths
   - Template directories
   - Report export locations

5. **Company-Specific Patterns**:
   - Organization name in document templates (Contoso, Fabrikam, AdventureWorks)
   - Custom employee ID patterns (EMP-######, E######, CONT-######)
   - Department names and structures
   - Project code formats

**Values That Should NEVER Be Hardcoded:**

❌ **WRONG - Hardcoded Examples:**
```powershell
$siteUrl = "https://contoso.sharepoint.com/sites/HR-Simulation"  # Hardcoded tenant
$adminEmail = "admin@contoso.onmicrosoft.com"  # Hardcoded domain
$customSitName = "Contoso-Employee-ID"  # Hardcoded org name
$dlpPolicyName = "Production DLP Policy"  # Hardcoded environment marker
New-Item -Path "C:\Contoso\Logs" -ItemType Directory  # Hardcoded org path
```

✅ **CORRECT - Config-Driven Examples:**
```powershell
# Import config at script start
$config = Get-Content "./simulation-config.json" | ConvertFrom-Json

# Use config values throughout
$siteUrl = "$($config.Environment.TenantUrl)/sites/$($config.SharePointSites[0].Name)"
$adminEmail = $config.Environment.AdminEmail
$customSitName = $config.CustomSITs[0].Name
$dlpPolicyName = "$($config.DLPPolicies.PolicyPrefix)-DLP-Policy"
New-Item -Path $config.Logging.LogPath -ItemType Directory -Force
```

**Portability Validation Checklist:**

Before considering any script complete, verify:

- [ ] Script has NO hardcoded tenant URLs or domains
- [ ] Script has NO hardcoded email addresses
- [ ] Script has NO hardcoded site/SIT/policy/label names
- [ ] Script has NO hardcoded file system paths
- [ ] Script has NO hardcoded organization names
- [ ] Script imports config file at startup
- [ ] Script validates config structure before operations
- [ ] Script provides clear error if config file missing/invalid
- [ ] Script documentation explains required config file values
- [ ] Script includes config file template/example in comments

**Environment Migration Workflow (Lift-and-Shift):**

To move scripts from Dev → Test → Prod, users should only need to:

1. **Copy entire project directory** to new environment (no code modifications required)
2. **Update ONLY `global-config.json`** with new environment values (single file change):
   - Change `TenantUrl` from `contoso-dev.sharepoint.com` to `contoso-prod.sharepoint.com`
   - Change `TenantDomain` from `contoso-dev.onmicrosoft.com` to `contoso-prod.onmicrosoft.com`
   - Change `AdminEmail` from `admin-dev@` to `admin-prod@`
   - Update `ResourcePrefix` from `Dev-Sim` to `Prod-Sim`
   - Update `EnvironmentType` from `Development` to `Production`
   - Update `DefaultOwner` and `NotificationEmail` to production accounts
3. **Optional: Update site names** in SharePointSites array if production naming differs
4. **Run scripts exactly as before** - they work in new environment with zero code changes

**📋 Detailed Lift-and-Shift Portability Guide:**

The project includes a comprehensive `PORTABILITY-GUIDE.md` file with step-by-step instructions:

**PORTABILITY-GUIDE.md Contents:**

```markdown
# Environment Portability Guide

## Quick Start: Moving Between Environments

### Prerequisites
- Source environment scripts (complete project directory)
- Target environment credentials (admin access to Microsoft 365 tenant)
- 5-10 minutes for configuration updates

### Lift-and-Shift Process

#### Step 1: Copy Project Directory

```powershell
# Copy entire project to new environment
Copy-Item -Path "C:\Purview-Simulation-Dev" -Destination "C:\Purview-Simulation-Prod" -Recurse
cd "C:\Purview-Simulation-Prod"
```

#### Step 2: Update Global Configuration

Edit `global-config.json` at the root of the project:

**Development Environment (Before):**
```json
{
  "Environment": {
    "TenantUrl": "https://contoso-dev.sharepoint.com",
    "TenantDomain": "contoso-dev.onmicrosoft.com",
    "AdminEmail": "admin-dev@contoso-dev.onmicrosoft.com",
    "OrganizationName": "Contoso Corporation - DEV",
    "EnvironmentType": "Development"
  },
  "Simulation": {
    "ResourcePrefix": "Dev-Sim",
    "DefaultOwner": "admin-dev@contoso-dev.onmicrosoft.com",
    "NotificationEmail": "compliance-dev@contoso-dev.onmicrosoft.com"
  }
}
```

**Production Environment (After):**
```json
{
  "Environment": {
    "TenantUrl": "https://contoso.sharepoint.com",
    "TenantDomain": "contoso.onmicrosoft.com",
    "AdminEmail": "admin@contoso.onmicrosoft.com",
    "OrganizationName": "Contoso Corporation",
    "EnvironmentType": "Production"
  },
  "Simulation": {
    "ResourcePrefix": "Prod-Sim",
    "DefaultOwner": "admin@contoso.onmicrosoft.com",
    "NotificationEmail": "compliance@contoso.onmicrosoft.com"
  }
}
```

#### Step 3: Validate Configuration

```powershell
# Run prerequisite validation with new config
.\00-Prerequisites-Setup\scripts\Test-Prerequisites.ps1

# Expected output: All checks pass with production tenant details
```

#### Step 4: Execute Scripts

Run scripts normally - they automatically load production config:

```powershell
# All scripts automatically reference global-config.json
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1
.\02-Test-Data-Generation\scripts\Invoke-BulkDocumentGeneration.ps1
# ... etc
```

### Environment-Specific Configurations

#### Development Environment
- **Purpose**: Feature development, testing, experimentation
- **Scale**: Small (5 sites, 500-1000 documents)
- **Naming**: `Dev-Sim-*` resource prefix
- **Policies**: TestWithoutNotifications mode
- **Cleanup**: Frequent, automated cleanup enabled

#### Test/UAT Environment
- **Purpose**: User acceptance testing, validation
- **Scale**: Medium (10-12 sites, 3000-5000 documents)
- **Naming**: `Test-Sim-*` resource prefix
- **Policies**: TestWithNotifications mode
- **Cleanup**: Weekly cleanup schedule

#### Production/Demo Environment
- **Purpose**: Client demos, production simulations
- **Scale**: Large (20-25 sites, 15000-20000 documents)
- **Naming**: `Prod-Sim-*` resource prefix
- **Policies**: Enforce mode (if appropriate)
- **Cleanup**: Manual approval required

### Configuration Comparison Matrix

| Setting | Development | Test | Production |
|---------|------------|------|------------|
| TenantUrl | contoso-dev.sharepoint.com | contoso-test.sharepoint.com | contoso.sharepoint.com |
| ResourcePrefix | Dev-Sim | Test-Sim | Prod-Sim |
| ScaleLevel | Small | Medium | Large |
| DLP Mode | TestWithoutNotifications | TestWithNotifications | Enforce |
| Cleanup | Automated | Scheduled | Manual |
| NotificationEmail | dev-team@ | test-team@ | compliance@ |

### Troubleshooting

**Issue**: Scripts still reference old tenant
**Solution**: Verify global-config.json was updated, check no cached connections exist

**Issue**: Permission errors in new environment
**Solution**: Verify AdminEmail has Global Admin and Compliance Admin roles

**Issue**: Site names conflict in production
**Solution**: Update SharePointSites array in global-config.json with production-specific names

**Issue**: Paths don't exist in new environment
**Solution**: Update Paths section in global-config.json or create directories before running scripts
```

**Multi-Tenant Consultant Scenario:**

Consultants working across multiple clients should be able to:

1. **Maintain single set of scripts** (portable, no client-specific code)
2. **Create separate global-config.json files per client** (renamed for clarity):
   - `contoso-global-config.json` (Client A: Contoso tenant)
   - `fabrikam-global-config.json` (Client B: Fabrikam tenant)
   - `adventureworks-global-config.json` (Client C: AdventureWorks tenant)
3. **Run same scripts with different global configs** using symbolic links or config parameter:

**Option A: Symbolic Link (Recommended)**
```powershell
# Switch to Contoso client
Remove-Item ./global-config.json -Force
New-Item -ItemType SymbolicLink -Path ./global-config.json -Target ./contoso-global-config.json
./01-SharePoint-Site-Creation/scripts/New-SimulatedSharePointSites.ps1

# Switch to Fabrikam client
Remove-Item ./global-config.json -Force
New-Item -ItemType SymbolicLink -Path ./global-config.json -Target ./fabrikam-global-config.json
./01-SharePoint-Site-Creation/scripts/New-SimulatedSharePointSites.ps1
```

**Option B: Config Path Parameter**
```powershell
# Each script accepts optional -GlobalConfigPath parameter
./01-SharePoint-Site-Creation/scripts/New-SimulatedSharePointSites.ps1 -GlobalConfigPath ./contoso-global-config.json
./01-SharePoint-Site-Creation/scripts/New-SimulatedSharePointSites.ps1 -GlobalConfigPath ./fabrikam-global-config.json
./01-SharePoint-Site-Creation/scripts/New-SimulatedSharePointSites.ps1 -GlobalConfigPath ./adventureworks-global-config.json
```

4. **Maintain client-specific config versions** in source control:
```
configs/
├── contoso-global-config.json
├── fabrikam-global-config.json
├── adventureworks-global-config.json
└── global-config.template.json
```

## SIMULATION-SPECIFIC REQUIREMENTS

### Scale Level Implementation

Scripts must support three scale levels through configuration file:

**Small Scale (Testing/Proof-of-Concept)**:

- 5 SharePoint sites
- 500-1,000 documents total
- 100-500 MB total data size
- Single-threaded upload operations
- 15-30 minute classification time
- Suitable for initial testing and validation

**Medium Scale (Demonstrations/Training)**:

- 10-12 SharePoint sites
- 3,000-5,000 documents total
- 2-4 GB total data size
- Batch upload operations (50 docs per batch)
- 1-2 hour classification time
- Suitable for live demonstrations and training sessions

**Large Scale (Realistic Simulation)**:

- 20-25 SharePoint sites
- 15,000-20,000 documents total
- 10-15 GB total data size
- Parallel batch operations with throttling
- 4-6 hour classification time
- Suitable for realistic organizational simulations

### Document Type Distribution Research

Research and implement realistic enterprise document type distribution:

- **Primary goal**: Find validated data from Microsoft 365 usage studies or enterprise content management research
- **Fallback approach**: Use reasonable estimates based on common organizational patterns
- **Expected distribution**: Word documents (most common), Excel spreadsheets (financial/data), PDFs (forms/scanned), text files (technical/logs)
- **Implement flexibility**: Allow config file override of default distribution ratios

### Built-in HR SIT Coverage Research

Research comprehensive list of built-in HR-related Sensitive Information Types from Microsoft Purview:

- **Primary source**: [learn.microsoft.com/purview/sensitive-information-type-entity-definitions](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- **Key categories**: Personal identification (SSN, passport, driver's license), Financial (credit card, ABA routing, ITIN), Healthcare (medical records, insurance), Employment (employee ID, organization-specific)
- **Implementation**: Document generation scripts should create realistic examples of ALL researched built-in HR SIT types
- **Flexibility**: Config file allows users to specify which SIT types to include in generation and which to target for classification/DLP

### Configuration File Architecture

**Two-tier configuration architecture** for **complete environment portability**:

**Global Configuration (`global-config.json`):**
- **Format**: JSON for structured data at project root
- **Purpose**: Single source of truth for ALL environment-specific values
- **Scope**: Referenced by every script across all labs
- **Primary goal**: Enable scripts to run in ANY Microsoft 365 tenant by updating ONE file only

**Lab-Specific Configuration (`lab-config.json`):**
- **Format**: JSON for structured data in individual lab directories
- **Purpose**: Lab-specific parameters that override or extend global config
- **Scope**: Optional - only needed for lab-specific settings
- **Reference syntax**: `$GLOBAL:` notation to reference global config values
- **Sections required**:
  - **Environment**: Tenant URLs, domains, admin emails, organization name, environment type
  - **SharePointSites**: Site names, templates, owners (all configurable per environment)
  - **DocumentGeneration**: Output paths, company prefixes, PII patterns (environment-specific)
  - **CustomSITs**: Names with org prefixes, regex patterns, descriptions (portable across orgs)
  - **DLPPolicies**: Policy names with environment prefixes, target resources, notification emails
  - **RetentionLabels**: Label names with environment/org prefixes, retention periods
  - **Logging**: Log paths, levels, retention (file system agnostic)
  - **CleanupTargets**: Environment-specific resource names for targeted cleanup

- **No hardcoded values**: All script operations read parameters from config file (zero code changes for environment migration)
- **Scale level integration**: Single parameter controls site counts, document quantities, batch sizes across all scripts
- **SIT flexibility**: Arrays of SIT names allow users to specify which types to generate, classify, or target with DLP
- **Site flexibility**: Arrays of site names allow targeted operations (specific sites for classification, DLP, cleanup)
- **Naming prefixes**: PolicyPrefix, LabelPrefix, CompanyPrefix enable environment-specific naming conventions
- **Multi-config support**: Scripts accept `-ConfigPath` parameter for consultant multi-tenant scenarios
- **Config validation**: Scripts validate all required config sections exist before operations commence
- **Template included**: Provide `simulation-config.template.json` with placeholder values and comprehensive comments

### Authentication Pattern Requirements

Browser-based authentication matching existing projects:

- **SharePoint**: `Connect-PnPOnline -Url $siteUrl -Interactive` (browser-based, no credentials)
- **Security & Compliance**: `Connect-IPPSSession` without credential parameters (browser-based)
- **Shared utility module**: `Connect-PurviewServices.ps1` wraps authentication calls consistently
- **No secrets**: Zero credential storage, app registrations, or service principals
- **Session management**: Scripts check for existing connections, reuse if available
- **Error handling**: Graceful failure with clear authentication error messages

### Cleanup Architecture Requirements

Two cleanup modes with safety features:

**Targeted Cleanup** (`Remove-TargetedSimulationResources.ps1`):

- Reads specific resources from config file `CleanupTargets` section
- Removes only specified sites, SITs, DLP policies
- Verbose logging showing what will be deleted before execution
- Confirmation prompt unless `-Force` parameter specified
- Verification report showing deleted vs remaining resources

**Full Automated Cleanup** (`Reset-CompleteSimulationEnvironment.ps1`):

- One-click removal of all simulation resources
- Safety checks: Confirms site names contain "Simulation" or match config patterns
- Optional `-WhatIf` parameter to preview without deleting
- Comprehensive cleanup report with counts and status
- Support for repeatable simulation runs

Both modes include:

- Pre-deletion validation (verify resources exist before attempting removal)
- Error handling for permission issues or locked resources
- Cleanup verification scripts to confirm successful removal
- Audit logs for compliance and troubleshooting

## RESEARCH VALIDATION REQUIREMENTS

Before suggesting any code or technical procedures:

### Required Research Topics

**Document Type Distribution**:

- Research enterprise document type usage patterns from Microsoft 365 studies or industry reports
- Validate realistic ratios for Word, Excel, PDF, text files in organizational content
- Document sources and rationale for chosen distribution percentages
- Implement as default in config file with clear documentation

**Built-in HR Sensitive Information Types**:
- Comprehensive research of ALL built-in HR-related SITs from Microsoft Purview documentation
- Document SIT names, regex patterns (if publicly available), and confidence levels
- Categorize by type (personal ID, financial, healthcare, employment)
- Create generation templates for realistic examples of each SIT type
- Validate current SIT names and patterns against November 2025 documentation

**PnP PowerShell Cmdlets**:
- Verify site creation cmdlets: `New-PnPSite`, `New-PnPWeb`
- Verify document upload: `Add-PnPFile`, `Add-PnPFolder`
- Verify batch operations: `New-PnPBatch`, `Invoke-PnPBatch`
- Confirm browser authentication: `Connect-PnPOnline -Interactive`
- Check throttling best practices and retry-after header handling

**Security & Compliance PowerShell**:
- Verify SIT creation: `New-DlpSensitiveInformationType`, `New-DlpKeywordDictionary`
- Verify EDM operations: EdmUploadAgent.exe usage, schema creation cmdlets
- Verify DLP policies: `New-DlpCompliancePolicy`, `New-DlpComplianceRule`
- Confirm browser authentication: `Connect-IPPSSession` without credentials
- Validate cmdlet availability in ExchangeOnlineManagement module v3.x

**Content Explorer API**:
- Research Microsoft Graph Security API endpoints for classification data
- Verify query syntax for Content Explorer data retrieval
- Validate authentication requirements (delegated vs application permissions)
- Check API throttling limits and best practices
- Document API version and endpoint URLs

## ADDITIONAL GUIDANCE FOR AI ASSISTANTS

### Deep Reasoning Integration

**When to Engage Deep Reasoning:**
- **Simulation scaling strategy**: Determining optimal site counts, document quantities, batch sizes for each scale level
- **Document type distribution**: Analyzing enterprise patterns and choosing realistic ratios
- **Configuration architecture**: Designing JSON structure balancing flexibility with usability
- **Authentication patterns**: Evaluating browser-based vs service principal approaches
- **Cleanup safety mechanisms**: Designing safeguards preventing accidental production data deletion

**How to Apply Deep Reasoning:**
- Break down complex problems (e.g., "How should scale levels affect batch sizes and timeouts?")
- Evaluate trade-offs (e.g., "JSON vs PowerShell hashtable for configuration")
- Consider edge cases (e.g., "What if user specifies invalid SIT names?")
- Synthesize research findings into actionable recommendations

### Content Extraction Best Practices

**From Purview-Classification-Lifecycle-Labs:**
- Extract authentication wrapper patterns from Shared-Utilities/ scripts
- Adapt custom SIT creation logic from Lab 01 and Lab 02
- Reuse bulk operation error handling from Lab 05 scripts
- Extract Content Explorer query patterns from Lab 03

**From Purview-Skills-Ramp-OnPrem-and-Cloud:**
- Extract SharePoint site creation patterns from Setup labs
- Adapt document upload logic for multi-site distribution
- Reuse cleanup script safety checks and verification patterns

**Integration Guidelines:**
- Never mention source project names in created documentation
- Adapt patterns to simulation context (config-driven vs hardcoded)
- Enhance with simulation-specific features (scale levels, flexible targeting)
- Maintain consistent style (preambles, colors, error handling)

### Configuration-Driven Development Principles

**All scripts must:**
- Import global configuration at startup: `$globalConfig = Import-GlobalConfig`
- Optionally merge with lab config: `$config = Merge-LabConfig -Global $globalConfig -LabConfigPath "./lab-config.json"`
- Use config values instead of hardcoded parameters: `$sites = $globalConfig.SharePointSites`
- Resolve global references in lab configs: `$policyPrefix = Resolve-GlobalReference "$GLOBAL:Simulation.ResourcePrefix"`
- Validate config structure: Check required global sections exist before operations
- Provide clear config documentation: Explain global vs lab config usage in script headers
- Support global config override: Allow `-GlobalConfigPath` parameter for consultant multi-tenant scenarios
- Handle missing lab config gracefully: Lab configs are optional extensions

**Global config (`global-config.json`) must contain:**
- **Environment section**: Tenant URL, tenant domain, admin email, admin center URL, organization name, environment type
- **Simulation section**: Scale level, company prefix, resource prefix, default owner, notification email
- **SharePointSites array**: Site names, templates, departments, owners, descriptions
- **CustomSITs array**: SIT names, display names, regex patterns, confidence levels, descriptions
- **Paths section**: Log directory, output directory, generated documents path, reports path, temp path
- **Logging section**: Log level, retention days, console/file output settings

**Lab config (`lab-config.json`) optionally contains:**
- **Lab-specific parameters**: Document generation settings, policy rules, cleanup targets
- **Global references**: Use `$GLOBAL:` notation to reference global config values
- **Overrides**: Lab-specific values that override global defaults for that lab only

### Common Pitfalls to Avoid

- Creating files before receiving approval
- Hardcoding values instead of using config file
- Using credential parameters instead of browser authentication
- Skipping research for document distributions or built-in SITs
- Creating interactive prompts instead of config-driven execution
- Linking to reference projects instead of duplicating content
- Assuming API versions or cmdlet syntax without validation
- Not engaging deep reasoning for architectural decisions

```

---

## 🤖 AI-Assisted Content Generation

This specialized Purview Data Governance Simulation project creation prompt template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview simulation strategies, configuration-driven architecture patterns, browser-based authentication requirements, and comprehensive coverage of HR-related Sensitive Information Types validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Purview data governance simulation requirements while maintaining technical accuracy, reflecting established repository PowerShell and Markdown style guide standards, and incorporating enterprise-grade automation patterns for SharePoint site provisioning, realistic data generation with HR/PII content, and flexible classification/DLP workflows suitable for demonstrations, testing, and professional consulting portfolios.*
