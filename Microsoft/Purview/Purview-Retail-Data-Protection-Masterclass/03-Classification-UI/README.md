# Classification UI Configuration

> **⏳ TIMING PREREQUISITE**: Before proceeding with this lab, verify that you've completed **01-Day-Zero-Setup** and that sufficient time has passed for backend processing:
>
> - **Audit Log**: 24 hours for initial enablement
> - **Test Data**: All files uploaded to SharePoint document library

## 🛑 Run the Prerequisite Validation Script

**Before starting any labs**, run the automated prerequisite checker to ensure everything is ready:

```powershell
cd 03-Classification-UI\scripts
.\Test-LabPrerequisites.ps1
```

**This script validates**:

- ✅ PowerShell modules installed (ExchangeOnlineManagement, PnP.PowerShell)
- ✅ Security & Compliance PowerShell connection (uses `Connect-PurviewIPPS.ps1` helper)
- ✅ Audit log enabled
- ✅ Test data availability in SharePoint
- ✅ Global configuration file

**Authentication Note**: The script automatically connects to Security & Compliance PowerShell and Exchange Online for validation. If you see a warning about MSAL assemblies being loaded, this is informational only - the script will still connect successfully.

**Expected Output**:

```text
✅ ALL PREREQUISITES MET!
You are ready to proceed with the 03-Classification-UI lab.
```

**If checks fail**: Follow the recommendations provided by the script before proceeding.

## 🎯 What This Lab Covers

This lab focuses on **configuring classifiers** in the Purview portal to detect sensitive information. You'll learn how to:

1. **Create Custom SITs** using regex patterns (Retail Loyalty ID)
2. **Build EDM-based Classifiers** (Rule Packages) to leverage exact-match customer data
3. **Create Document Fingerprints** to protect standardized forms and templates
4. **Configure BundledEntity classifiers** for ML-based PII detection
5. **Test classifiers** against the data generated in **02-Data-Foundation**
6. **Understand detection confidence levels** and supporting evidence

This is a hands-on UI lab that builds the foundation for Information Protection (labels) and DLP policies in subsequent labs.

## 📚 Lab Structure

### Lab 01: Custom Sensitive Information Types (SITs)

[Lab-01-Custom-SITs.md](Lab-01-Custom-SITs.md)

Create a regex-based custom SIT for the Retail Loyalty ID pattern (`RET-XXXXXX-X`).

**What You'll Learn**:

- Regex pattern creation in Purview
- Keyword list configuration for confidence boosting
- Testing classifiers against sample data

**Duration**: 15-20 minutes

### Lab 02: EDM-based Classifiers (Rule Packages)

[Lab-02-EDM-Classifiers.md](Lab-02-EDM-Classifiers.md)

Build an EDM classifier that uses the `RetailCustomerDB` schema created within this lab.

**What You'll Learn**:

- Creating EDM classifiers using the **New Experience** in Purview portal
- Configuring primary and supporting elements
- Setting confidence levels (High/Medium/Low)
- Testing EDM detection accuracy against uploaded customer data
- Understanding when to use EDM vs built-in SITs

**Duration**: 25-30 minutes

**Prerequisites**:

- This lab includes EDM schema creation and data upload as part of the workflow
- No pre-upload required from Day Zero Setup

### Lab 03: Document Fingerprinting

[Lab-03-Document-Fingerprinting.md](Lab-03-Document-Fingerprinting.md)

Create Document Fingerprinting classifiers to protect standardized retail forms and templates based on their structure and layout.

**What You'll Learn**:

- Understanding structure-based vs content-based detection
- Creating fingerprints for standardized forms (credit card applications, employee onboarding)
- Testing fingerprinting against document variations
- When to use document fingerprinting vs other classification methods
- Combining fingerprinting with SITs in DLP policies

**Duration**: 20-25 minutes

**Template Files Used**:

- Credit-Card-Application-Form.docx
- Employee-Onboarding-Form.docx
- Store-Audit-Report-Template.xlsx

### Lab 04: Named Entity Detection (BundledEntity Type)

[Lab-04-Named-Entities.md](Lab-04-Named-Entities.md)

Configure Named Entity detection using pre-built machine learning classifiers (BundledEntity type) for enhanced PII protection.

**What You'll Learn**:

- Understanding ML-based BundledEntity classifiers vs pattern-based SITs
- Testing Name and Address detection against retail customer data
- Combining BundledEntity classifiers with SITs for high-confidence classification
- Planning BundledEntity usage in Information Protection and DLP policies

**Duration**: 15-20 minutes

**BundledEntity Types Covered**:

- All Full Names (BundledEntity) - Focus for retail testing
- All Physical Addresses (BundledEntity) - Focus for retail testing
- All Medical Terms And Conditions (BundledEntity) - Available but not tested in retail scenario

## 🔍 Classification Design Overview

### Built-in SITs Used

- **Credit Card Number**: Luhn-valid cards in test data (PCI-DSS detection)
- **U.S. Social Security Number (SSN)**: PII detection
- **ABA Routing Number**: Financial data detection

### Custom SITs Created

- **Retail Loyalty ID**: Pattern `RET-\d{6}-[A-Z]`
  - Keywords: Loyalty, Member, Rewards
  - Confidence: 85% (High)

### EDM Schema (Created in Day Zero Setup)

**Schema Name**: `RetailCustomerDB`

| Field Name | Searchable? | Case Insensitive? | Purpose |
|------------|-------------|-------------------|---------|
| **CustomerId** | Yes | Yes | Primary matching field |
| **FirstName** | No | Yes | Supporting evidence |
| **LastName** | No | Yes | Supporting evidence |
| **Email** | Yes | Yes | Alternative matching field |
| **PhoneNumber** | No | No | Supporting evidence |
| **CreditCardNumber** | No | No | High-confidence PCI-DSS match |
| **LoyaltyId** | Yes | No | Custom business identifier |

### EDM Classifier Configuration

**Rule Package Details**:

- **Primary Elements**: `CustomerId` OR `Email` OR `LoyaltyId` (at least one must match)
- **Supporting Elements**: `FirstName`, `LastName`, `PhoneNumber` within 300 characters
- **Confidence Levels**:
  - **High (85%)**: Primary element + 2 supporting elements
  - **Medium (75%)**: Primary element + 1 supporting element
  - **Low (65%)**: Primary element only

### Document Fingerprints Created

**Template-Based Protection**:

- **Credit Card Application Form (Retail)**: Detects credit card applications based on document structure
- **Employee Onboarding Form (Retail)**: Detects employee onboarding forms based on structure
- **Store Audit Report (Retail)**: Detects store audit reports based on spreadsheet structure

### BundledEntity Classifiers Used

**Pre-built ML Classifiers (BundledEntity Type)**:

- **All Full Names (BundledEntity)**: Detects person names with ML context awareness - retail focus
- **All Physical Addresses (BundledEntity)**: Detects street addresses and locations - retail focus
- **All Medical Terms And Conditions (BundledEntity)**: Available in Purview but not tested in retail scenario

> **Note**: BundledEntity is the technical type name in Purview for ML-based entity classifiers. Our retail scenario focuses on Names and Addresses as these align with our test data.

## 🛑 Before You Begin

### Required Permissions

- **Global Administrator** or **Compliance Administrator** role
- Access to Purview compliance portal (purview.microsoft.com)

### Prerequisites Checklist

- [ ] Completed **01-Day-Zero-Setup** (audit log enabled, global config created)
- [ ] Wait time elapsed: 24 hours for audit log enablement
- [ ] Completed **02-Data-Foundation** (test files generated and uploaded)
- [ ] **Ran prerequisite validation script** (see above)

### Test Data Validation

Before starting, verify your test data is available in SharePoint:

1. Navigate to your **Retail-Operations** site
2. Confirm you can see the 13 test files uploaded
3. Note which files contain which SIT types (see 02-Data-Foundation README)

## 📝 General Lab Instructions

1. Navigate to the **Microsoft Purview compliance portal** (purview.microsoft.com)
2. Follow the step-by-step instructions in each lab document
3. Use the **Test Data** from 02-Data-Foundation to validate classifiers
4. **Be Patient**: Classifier changes can take 1-2 hours to propagate

## 🎓 Recommended Lab Sequence

Complete the labs in this order for optimal learning progression:

1. **Lab 01: Custom SITs** (15-20 min) - Pattern-based detection foundation
2. **Lab 02: EDM Classifiers** (25-30 min) - High-precision database matching (includes schema creation)
3. **Lab 03: Document Fingerprinting** (20-25 min) - Structure-based form protection
4. **Lab 04: Named Entities** (15-20 min) - ML-based PII enhancement

**Total Time**: ~75-95 minutes for complete classification configuration

## 📚 Next Steps

After completing these classification labs:

1. **Lab 04-Information-Protection-UI**: Create sensitivity labels that use these classifiers for auto-labeling
2. **Lab 05-Data-Loss-Prevention-UI**: Build DLP policies that enforce sharing restrictions based on SIT detection
3. **Lab 06-Exfiltration-Simulation**: Test your classifiers with real-world sharing scenarios
4. **IaC-Automation**: Automate classifier creation using PowerShell and Azure DevOps pipelines

## 🎯 Key Takeaways

- **Custom SITs** extend Purview detection beyond built-in classifiers (pattern-based)
- **EDM classifiers** reduce false positives by matching actual database records (high-precision)
- **Document Fingerprinting** protects standardized forms regardless of content (structure-based)
- **BundledEntity classifiers** use ML to detect PII in context (AI-based, context-aware)
- **Combination strategies** provide highest confidence detection (multiple classifiers together)
- **Confidence levels** are critical for balancing security and user experience
- **Testing is essential** - always validate against real data before deploying to production

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Purview classifier configuration.

*AI tools were used to enhance productivity and ensure comprehensive coverage of classification requirements while maintaining technical accuracy.*
