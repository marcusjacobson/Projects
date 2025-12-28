# Classification Design & Taxonomy

This section defines the governance framework for the Retail Data Protection Masterclass. We use a 4-Tier Sensitivity Label taxonomy aligned with industry standards and PCI-DSS requirements.

## 🏷️ Sensitivity Label Taxonomy

| Label Name | Scope | Encryption | Visual Marking | Auto-Labeling Condition |
|------------|-------|------------|----------------|-------------------------|
| **Public** | File, Email | None | None | None |
| **General** | File, Email | None | Footer: "Internal Use Only" | Default Label |
| **Confidential** | File, Email | Co-Authoring | Header: "Confidential - PII" | Contains PII (SSN, Passport) |
| **Highly Confidential** | File, Email | Co-Authoring + Watermark | Watermark: "Restricted" | Contains Credit Card Number (PCI-DSS) |

### Sub-Labels (Scoped)
- **Highly Confidential \ Project Falcon**: Scoped to "Strategy Team" only.
- **Highly Confidential \ PCI Data**: Scoped to "Finance" and "Compliance" teams.

## 🔍 Sensitive Information Types (SITs)

### Built-in SITs Used
- **Credit Card Number**: Used for PCI-DSS detection.
- **U.S. Social Security Number (SSN)**: Used for PII detection.
- **ABA Routing Number**: Used for financial data.

### Custom SITs (Regex)
- **Retail Loyalty ID**: Matches the pattern `RET-\d{6}-[A-Z]`.
    - Regex: `RET-\d{6}-[A-Z]`
    - Keyword Proximity: "Loyalty", "Member", "Rewards"

## 🧩 Exact Data Match (EDM) Schema

To reduce false positives for customer PII, we use EDM.

**Schema Name**: `RetailCustomerDB`

| Field Name | Searchable? | Case Insensitive? | Ignored Delimiters? |
|------------|-------------|-------------------|---------------------|
| **CustomerId** | Yes | Yes | No |
| **FirstName** | No | Yes | No |
| **LastName** | No | Yes | No |
| **Email** | Yes | Yes | No |
| **CreditCardNumber** | No | No | No |

**Rule Package**:
- **Match**: `CustomerId` OR `Email`
- **Supporting Evidence**: `FirstName`, `LastName` within 300 characters.

## 🛡️ Data Loss Prevention (DLP) Strategy

### Policy 1: PCI-DSS Protection (Financial)
- **Workloads**: Exchange, SharePoint, OneDrive, Teams, Endpoint.
- **Condition**: Contains `Credit Card Number` OR `Highly Confidential \ PCI Data` label.
- **Action**:
    - **External**: Block with Override.
    - **Internal**: Audit only.

### Policy 2: PII Protection (Privacy)
- **Workloads**: Exchange, OneDrive.
- **Condition**: Contains `U.S. SSN` OR `RetailCustomerDB` (EDM Match).
- **Action**:
    - **External**: Block.
    - **Internal**: Encrypt (Apply "Confidential" label).

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for information architecture and taxonomy design.

*AI tools were used to enhance productivity and ensure comprehensive coverage of classification requirements while maintaining technical accuracy.*
