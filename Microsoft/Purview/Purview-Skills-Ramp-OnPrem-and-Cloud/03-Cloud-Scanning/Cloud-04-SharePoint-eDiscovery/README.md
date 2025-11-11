# Cloud-04: eDiscovery for SharePoint and OneDrive

## ⚠️ CRITICAL: Cloud-Only Data Sources

> **⚠️ Important Limitation**: Microsoft Purview eDiscovery (Standard) searches **ONLY cloud-based Microsoft 365 content**. This lab covers searching SharePoint Online, OneDrive for Business, and Exchange Online.
>
> **❌ NOT SUPPORTED**: On-premises file shares discovered by the Information Protection Scanner (OnPrem-01, OnPrem-02) **CANNOT** be searched using Microsoft Purview cloud eDiscovery.
>
> **Why This Matters**: If you completed OnPrem-01 and OnPrem-02, those file shares were scanned for classification purposes only. To search on-premises data, you would need SharePoint Server eDiscovery Center (an on-premises product), which is not covered in this lab series.

## 🎯 Lab Objectives

- Create and configure eDiscovery (Standard) case in Microsoft Purview portal.
- Search cloud content locations (SharePoint Online, OneDrive, Exchange Online).
- Use Keyword Query Language (KQL) to find sensitive information types.
- Preview search results for credit card and SSN data.
- Export search results for legal/compliance review.
- Understand eDiscovery vs. retention label differences.

## ⏱️ Estimated Duration

45-60 minutes

## 📋 Prerequisites

**Required Prerequisites**:

- **Cloud-01 completed**: SharePoint "Retention Testing" site with sample documents containing credit card/SSN data
- **Microsoft 365 E5 Compliance licensing**: Required for eDiscovery (Standard) access
- **eDiscovery permissions**: eDiscovery Manager role group membership
- **Azure AD account**: With appropriate eDiscovery permissions

**Recommended (but not required)**:

- Cloud-02 completed (retention labels understanding).
- Cloud-03 completed (auto-apply policies understanding).
- Familiarity with SharePoint Online navigation.

> **💡 Note**: This lab searches the SharePoint site created in Cloud-01. If you haven't completed Cloud-01, you'll need to create a test SharePoint site with sample documents containing sensitive information types (credit card numbers, SSNs).

## 🔍 eDiscovery Overview

### What is eDiscovery (Standard)?

Microsoft Purview eDiscovery (Standard) provides organizations with a tool to search, preserve, and export content from cloud-based Microsoft 365 locations for legal investigations, compliance audits, and data subject access requests.

**Core Capabilities**:

- **Search**: Find content across Exchange Online mailboxes, SharePoint sites, OneDrive accounts, Microsoft Teams, and Microsoft 365 Groups
- **Preserve**: Place eDiscovery holds on content locations to prevent deletion during investigations
- **Preview**: Review search results before exporting
- **Export**: Download content to local computer for legal review

**Supported Cloud Data Sources**:

| Data Source | Description | Search Capability |
|-------------|-------------|-------------------|
| **Exchange Online mailboxes** | User mailboxes, group mailboxes, Teams channel messages | ✅ Supported |
| **SharePoint Online sites** | Team sites, communication sites, Hub sites | ✅ Supported |
| **OneDrive for Business** | Individual user OneDrive accounts | ✅ Supported |
| **Microsoft Teams** | Teams channel messages, 1:1 chats, group chats | ✅ Supported |
| **Microsoft 365 Groups** | Unified group mailboxes and SharePoint sites | ✅ Supported |
| **Viva Engage** | Viva Engage team content | ✅ Supported |
| **Exchange Public Folders** | Organization-wide public folders | ✅ Supported |
| **On-premises file shares** | Network file shares scanned by Information Protection Scanner | ❌ NOT Supported |
| **On-premises mailboxes** | Exchange hybrid on-premises mailboxes | ❌ NOT Supported |

> **📚 Important Distinction**: SharePoint Server (on-premises) has a separate eDiscovery Center feature that CAN search on-premises file shares. However, this is a different product from Microsoft Purview cloud eDiscovery and is not covered in this lab.

### eDiscovery vs. Auto-Apply Retention (Cloud-03)

Understanding the differences between eDiscovery and retention labels helps you choose the right tool:

| Feature | eDiscovery (Standard) | Auto-Apply Retention Labels (Cloud-03) |
|---------|----------------------|---------------------------------------|
| **Purpose** | Search and export content for investigations | Automatically manage content lifecycle |
| **Timing** | Immediate search results | Up to 7 days for auto-apply processing |
| **Action** | Read-only search and export | Apply labels that delete or retain content |
| **Use Case** | Legal investigations, GDPR requests, audits | Compliance policies, data minimization |
| **User Impact** | None (users don't see searches) | Labels visible to users in SharePoint |
| **Content Modification** | No changes to content | Can delete content based on retention settings |

**When to Use eDiscovery**:

- **Legal investigation**: Find all documents mentioning a specific term or person
- **Compliance audit**: Identify where sensitive data (credit cards, SSNs) exists
- **GDPR request**: Locate all content related to a specific data subject
- **Security incident**: Find leaked credentials or sensitive information

**When to Use Auto-Apply Retention**:

- **Data minimization**: Automatically delete old sensitive files after retention period
- **Compliance policy**: Ensure sensitive data is retained for specific duration
- **Information governance**: Manage content lifecycle across organization

> **💡 Pro Tip**: You can use eDiscovery to find sensitive data immediately (Cloud-04), then create auto-apply retention policies (Cloud-03) to manage that data's lifecycle going forward. They complement each other!

---

## 🚀 Lab Steps

### Step 1: Assign eDiscovery Manager Permissions

Before creating an eDiscovery case, you need the eDiscovery Manager role group membership. This role is separate from the Information Protection permissions configured in Setup-01.

> **📚 Licensing Note**: You should have already completed **Setup-01: Licensing and Auditing** which activated Microsoft 365 E5 (or E5 Compliance) licensing. If you skipped Setup-01, complete that lab first to ensure proper licensing.

Navigate to **Microsoft Purview portal** ([https://purview.microsoft.com](https://purview.microsoft.com)):

- In the left navigation, select **Settings** → **Roles & scopes**.
- Select **Role groups**.
- Search for **eDiscovery Manager** role group.

Check if you're already a member:

- Click on **eDiscovery Manager** to view details.
- Review the **Members** section.
- If your account is listed, you're ready to proceed to Step 2.

If you need to add yourself to the eDiscovery Manager role group:

- Click **Edit**.
- On the **Manage eDiscovery Manager** page, select **Choose users** (to add yourself as an eDiscovery Manager).
- Search for and select your user account.
- Click **Select**.
- Click **Next**.

> **📚 eDiscovery Subgroup Explanation**: The **eDiscovery Manager** role group contains two subgroups:
>
> - **eDiscovery Manager subgroup**: Can create and manage only their own cases
> - **eDiscovery Administrator subgroup**: Can access and manage ALL cases in the organization
>
> For this lab, adding yourself to the **eDiscovery Manager subgroup** is sufficient. If you need to manage other users' cases, you can add yourself to the **eDiscovery Administrator subgroup** by selecting **Choose users** under the "eDiscovery Administrator" section during the Edit process.

Continue the assignment process:

- Click **Save** to complete the role assignment.

> **⚠️ Permission Note**: Only users assigned to the eDiscovery Manager role group (either subgroup) can create and access eDiscovery cases. **Compliance Administrator**, **Organization Management**, and **Global Admin** roles can also create cases.
>
> **💡 Lab Tip**: If you see "Access Denied" when trying to add yourself to the role group, ensure you have Global Admin or a higher-level admin role. If working in a restricted tenant, ask your tenant administrator to grant you eDiscovery Manager permissions.

### Step 2: Create eDiscovery (Standard) Case

Navigate to **Microsoft Purview portal** ([https://purview.microsoft.com](https://purview.microsoft.com)):

- In the left navigation pane, select **Show all**.
- Under **Solutions**, select **eDiscovery**.
- Click **Cases** in the left navigation pane.
- Click **Create case**.

In the **New case** flyout:

- **Case name**: `Sensitive Data Investigation - Cloud Lab`
- **Case description**: `eDiscovery search for credit card and SSN data in SharePoint Retention Testing site created in Cloud-01`

Click **Save** to create the case.

The new case appears in the case list. Click **Refresh** if you don't see it immediately.

### Step 3: Configure Case Settings (Optional - Add Members)

> **💡 Lab Note**: For this lab, you're the only case member, so this step is optional. In production scenarios, you would add legal team members or other investigators to the case.
>
> **⏭️ Skip to Step 4**: If you don't need to practice adding case members, proceed directly to **Step 4: Create Content Search Query**.

If you want to practice adding case members:

- Click on your case name **Sensitive Data Investigation - Cloud Lab** to open it.
- Select the **Case settings** button at the top.
- Click the **Permissions** tab.
- Under **Users**, click **Add**.
- Search for and select additional users (if available in your test tenant).
- Click **Save**.

> **⚠️ Security Note**: In production, restrict case membership to authorized personnel only. Case members can see all search results and exported data.

### Step 4: Create Content Search Query

With your case open, navigate to the **Searches** tab:

- Click **Create a search**.

In the **New search** wizard:

**Search Name and Description**:

- **Name**: `Credit Card and SSN Search - SharePoint`
- **Description**: `Search for documents containing credit card numbers or SSNs in Cloud-01 Retention Testing site`
- Click **Create**.

**Define Data Source Locations**:

On the **Query** tab, you'll configure which content locations to search. For this lab, we'll search only the SharePoint site created in Cloud-01.

- Click **Add sources** to begin configuring data sources.
- The **Add data sources** pane opens with **Filter** options on the left side:
- Use the filters to scope your data sources:
  - **Scope items by**: Select **All sources in the tenant** (default).
    - **Note**: The default list shows 100 random people or groups. To find specific data sources, use the search bar in the next step.
  - **Show for**: Select **All people and groups** (default).
    - You can also choose **People only** or **Groups only** if needed.
  - **Exclude inactive users**: Leave unchecked for this lab.
  - **Locations to include**: Select **Sites only**.
    - This ensures only SharePoint/OneDrive sites are added (no mailboxes).
    - Other options: **Mailboxes and sites** (default) or **Mailboxes only**.

**Search for Your Cloud-01 SharePoint Site**:

In the **Search** section (right side of the pane):

- In the search field, enter your Cloud-01 SharePoint site URL:
  - Example: `https://[your-tenant].sharepoint.com/sites/RetentionTesting`
  - Replace `[your-tenant]` with your actual Microsoft 365 tenant name
- Click **Search** to find the site.
  - The site should appear in the search results below.
- Click the checkbox next to your **Retention Testing** site to select it.

**Add the Data Source**:

> After selecting your Cloud-01 site, you have two options:
>
> - **Save and close**: Adds the selected site to your search and closes the pane (recommended for this lab)
> - **Manage**: Opens a detailed view showing all sites/mailboxes for fine-tuning selections

- Click **Save and close** to add the Cloud-01 SharePoint site to your search.

**Define Search Conditions**:

This is where you specify what content to search for using Keyword Query Language (KQL).

For this lab, we'll search for sensitive information types (credit cards and SSNs) that we created sample files for in Cloud-01:

In the **Enter keywords** box, enter:

```kql
SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)"
```

> **📚 KQL Explanation**: This query searches for any documents that contain either credit card numbers or U.S. SSN patterns detected by Microsoft Purview's built-in sensitive information type classifiers.

**Review Search Configuration**:

Review your search configuration:

- **Name**: Credit Card and SSN Search - SharePoint
- **Data sources**: Your Cloud-01 SharePoint site
- **Query**: Sensitive information type search

**Run the Search**:

- Click **Run query** to execute the search.
- The **Choose search results** flyout pane appears. Select which type of results to generate:
- Choose **Statistics** (recommended for this lab):

- This view generates a summary of collected data estimates arranged by top indicators.
- Select the following options:
  - ✅ **Include categories**: Refine view to include people, sensitive information types, item types, and errors.
  - ✅ **Include query keywords report**: Assess keyword relevance for different parts of your search query.
  - ⬜ **Investigate partially indexed items**: Leave unchecked for this basic lab (adds processing time).

> **💡 Statistics vs. Sample**:
>
> - **Statistics**: Provides summary reports, item counts, and data distribution (recommended for initial review)
> - **Sample**: Generates a representative selection of actual documents for preview (useful for validating content)
>
> You can switch between views after the initial results are generated.

Click **Run query** to generate the statistics view.

> **⏰ Processing Time**: The search query assessment starts and calculates time remaining. For a small test site (Cloud-01), this typically completes in 1-3 minutes.

### Step 5: Review Search Statistics

After the query completes, you'll see results on the **Statistics** tab.

**Statistics Dashboard Sections**:

The eDiscovery Statistics tab includes four main sections in the **Summary** area:

**Total matches**:

- **Total search hit count**: Number of items matching your query
  - **Expected for this lab**: Number of documents you uploaded to Cloud-01 containing credit cards/SSNs
- **Total volume**: Total file size of matching content

**Locations**:

- **Locations with hits / Total locations searched**: Fraction showing how many locations contained matches
  - **Expected for this lab**: 1/1 (your Cloud-01 SharePoint site)
- **Locations with errors**: Any locations that couldn't be searched (shown in red)

**Data sources**:

- **Data sources with hits / Total data sources**: Fraction showing how many data sources contained matches.
  - **For this lab**: Should show 1/1 (your SharePoint site).
- Consistent with data sources selected in Step 4's "Add sources" filter panel.

- **Search hit trends section** displays:
  - **Top data sources** - Should just show the selected SharePoint site for this lab
  - **Top sensitive information types**: Should show detections for credit card, SSN, Taxpayer Identification and Full Names (based on the sample data we created)
  - **Top Item Classes**: File extensions (.docx, .txt, .xlsx, etc.)

If you selected **Include query keywords report**:

- **Top keywords** shows:
  - How many items matched "Credit Card Number" vs. "U.S. Social Security Number (SSN)"
  - Helps identify which keywords are most/least effective

> **📊 Understanding Statistics**: The Statistics dashboard provides a comprehensive overview without downloading files. This is essential for validating your search query found the expected content before proceeding to export. You can download detailed reports as CSV files for further analysis.

### Step 6: Preview Sample Results (Optional)

- Click the **Sample** tab at the top.
- Click **Generate sample results**.
- Configure sample settings:
  - **Number of sample items per location**: Choose 1, 10, or 100
  - **Number of locations to get samples from**: Choose 10, 100, 1000, or 10000
- Click **Run query** to generate sample results.

- Wait a few minutes for data to generate.
- Browse through the sample documents listed.
- Click on individual items to view content in the reading pane.
- Verify that documents contain credit card or SSN patterns.
- Keywords from your search query are highlighted in the preview.

> **📚 Sample vs. Full Export**: Sample view shows representative documents for quick validation. For comprehensive legal review, you would export all results (Step 7).

**Observations to Note**:

- Which documents contain credit card numbers vs. SSNs?
- Are there false positives (documents incorrectly matched)?
- Is the sensitive data clearly visible in the preview?
- Do the results match your expectations from Cloud-01 sample files?

### Step 7: Export Search Results (Optional)

For this lab, export is optional since we're primarily demonstrating search and statistics capabilities.

**If you want to practice exporting** (optional):

- With your search open, look for export options in the search interface.
- Export creates a downloadable package of all matching documents.
- In production environments, exported data would be provided to legal counsel for detailed review.

> **💡 Lab Completion Note**: Successfully generating **Statistics** results and reviewing the sensitive information type detections demonstrates eDiscovery search capability. Export is not required to complete this lab's objectives.

---

## ✅ Validation Checklist

Verify you've completed all Cloud-04 objectives:

**Step 1: eDiscovery Manager Permissions**:

- [ ] Assigned eDiscovery Manager role group membership to your account
- [ ] Successfully accessed eDiscovery (Standard) in Microsoft Purview portal
- [ ] Understand the difference between eDiscovery Manager and eDiscovery Administrator subgroups

**Step 2: Case Creation**:

- [ ] Created eDiscovery (Standard) case: "Sensitive Data Investigation - Cloud Lab"
- [ ] Case appears in the Cases list with appropriate description

**Step 3: Case Settings** (Optional):

- [ ] Reviewed case settings and permissions (optional for single-user lab)

**Step 4: Create Content Search Query**:

- [ ] Created search: "Credit Card and SSN Search - SharePoint"
- [ ] Added Cloud-01 SharePoint site as data source using Filter panel (Sites only)
- [ ] Defined KQL query to search for Credit Card Number and U.S. Social Security Number (SSN)
- [ ] Selected Statistics view in Choose search results flyout
- [ ] Successfully ran query and generated results

**Step 5: Review Search Statistics**:

- [ ] Reviewed Statistics dashboard showing Search hits, Locations, Data sources
- [ ] Verified search found expected documents from Cloud-01
- [ ] Reviewed categories (if selected): Sensitive information types, item types, people
- [ ] Reviewed query keywords report (if selected): Credit card vs. SSN matches

**Step 6: Preview Sample Results** (Optional):

- [ ] Generated sample results on Sample tab
- [ ] Previewed actual documents containing credit cards or SSNs
- [ ] Verified keywords highlighted in document preview

**Step 7: Export Search Results** (Optional):

- [ ] Reviewed export capabilities in new eDiscovery experience

**Key Learning Outcomes**:

- [ ] Understand eDiscovery provides **immediate search results** (vs. retention labels: up to 7 days)
- [ ] Know that eDiscovery searches **cloud-only** sources (SharePoint Online, OneDrive, Exchange Online, Teams)
- [ ] Understand eDiscovery does NOT search on-premises file shares from OnPrem-01/02
- [ ] Can explain when to use eDiscovery vs. auto-apply retention policies
- [ ] Understand eDiscovery use cases: legal holds, GDPR requests, compliance audits, security incidents

---

## 🔍 Troubleshooting

### Issue: Cannot Access eDiscovery (Standard)

**Symptoms**: eDiscovery menu option not visible or "Access denied" error

**Solution**:

- Navigate to Microsoft Purview portal → **Settings** → **Roles & scopes** → **Role groups**.
- Search for **eDiscovery Manager** and add your user account.
- Sign out and sign back in to refresh permissions.
- If still denied, verify you have Microsoft 365 E5 or E5 Compliance license assigned (see Setup-01).

### Issue: Search Returns No Results

**Symptoms**: Search shows 0 items and **Locations with hits** shows 0/1

**Common Causes**:

**Incorrect SharePoint site URL**:

- Verify the site URL is exact (copy from browser when viewing Cloud-01 site).
- Format: `https://[tenant].sharepoint.com/sites/RetentionTesting`.
- Use the Search field in "Add sources" to find the correct site.

**No sample documents uploaded**:

- Navigate to Cloud-01 SharePoint site and verify documents exist.
- Upload sample files containing credit card numbers (e.g., `4111-1111-1111-1111`) or SSNs (e.g., `123-45-6789`).
- Wait 5-15 minutes for SharePoint indexing, then re-run the search.

**KQL query syntax error**:

- Verify the query uses proper syntax: `SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)"`.
- Check for missing quotes or incorrect sensitive type names.

### Issue: Search Statistics Not Displaying

**Symptoms**: After running query, Statistics tab appears empty or incomplete

**Solution**:

- Ensure you selected **Statistics** in the Choose search results flyout.
- If you selected Sample instead, click the **Statistics** tab and select **Generate statistics results**.
- Refresh the browser if the dashboard doesn't load properly.

### Issue: Cannot Find Cloud-01 SharePoint Site in Search

**Symptoms**: Cloud-01 site doesn't appear when searching in "Add sources" panel

**Solution**:

- In the "Add sources" panel, ensure **Locations to include** is set to **Sites only** or **Mailboxes and sites**.
- Use the Search field on the right side to search for "Retention" or your site name.
- Try searching by site owner's email address instead of site name.
- Verify you have at least **Read** permissions on the Cloud-01 site by opening it directly in a browser.

### Issue: Understanding Statistics Dashboard Numbers

**Common Confusion**: "Items" vs "Locations with hits"

**Explanation**:

- **Search hits (Items)**: Total number of individual documents matching your query
  - Example: If 5 documents in Cloud-01 contain credit cards, Items = 5
- **Locations with hits**: Number of distinct sites/mailboxes containing matches
  - Example: If all 5 documents are in Cloud-01, Locations = 1/1 (1 location with hits out of 1 searched)
- **Expected for this lab**: Locations should show 1/1 (Cloud-01 SharePoint site only)

---

## Appendix 1: Advanced KQL Query Examples

Now that you've completed the basic search in Step 4, explore these advanced KQL patterns to enhance your eDiscovery skills.

### Basic Sensitive Information Type Searches

**Search for credit cards only**:

```kql
SensitiveType:"Credit Card Number"
```

**Search for SSNs only**:

```kql
SensitiveType:"U.S. Social Security Number (SSN)"
```

**Search for multiple information types** (used in Step 4):

```kql
SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)"
```

### Combining Sensitive Types with Keywords

**Credit cards in finance-related documents**:

```kql
SensitiveType:"Credit Card Number" AND (Finance OR Payment OR Transaction)
```

**SSNs in HR documents**:

```kql
SensitiveType:"U.S. Social Security Number (SSN)" AND (HR OR Employee OR Personnel)
```

**Sensitive data with specific terms**:

```kql
(SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)") AND Confidential
```

### File Type and Property Filters

**Search only text files**:

```kql
SensitiveType:"U.S. Social Security Number (SSN)" AND filetype:txt
```

**Search only Word documents**:

```kql
SensitiveType:"Credit Card Number" AND filetype:docx
```

**Search only Excel files**:

```kql
SensitiveType:"U.S. Social Security Number (SSN)" AND filetype:xlsx
```

**Search multiple file types**:

```kql
SensitiveType:"Credit Card Number" AND (filetype:docx OR filetype:pdf OR filetype:txt)
```

### Date Range Queries

**Documents modified in 2024**:

```kql
SensitiveType:"Credit Card Number" AND lastmodifiedtime>=2024-01-01
```

**Documents modified in last 30 days**:

```kql
SensitiveType:"U.S. Social Security Number (SSN)" AND lastmodifiedtime>=2024-10-01
```

**Documents created in specific date range**:

```kql
SensitiveType:"Credit Card Number" AND created>=2024-01-01 AND created<=2024-12-31
```

### Site-Specific Searches

**Search only Cloud-01 site** (useful when searching multiple locations):

```kql
SensitiveType:"U.S. Social Security Number (SSN)" AND site:"https://[tenant].sharepoint.com/sites/RetentionTesting"
```

> **💡 KQL Tip**: Replace `[tenant]` with your actual Microsoft 365 tenant name.

**Exclude specific sites**:

```kql
SensitiveType:"Credit Card Number" NOT site:"https://[tenant].sharepoint.com/sites/Archive"
```

### Advanced Pattern Combinations

**High-confidence matches only**:

```kql
SensitiveType:"Credit Card Number|85-100"
```

> **📚 Confidence Score Explanation**: The `|85-100` syntax filters for matches with 85-100% confidence. This reduces false positives.

**Multiple sensitive types with file restrictions**:

```kql
(SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)") AND filetype:docx AND lastmodifiedtime>=2024-01-01
```

**Keyword proximity search**:

```kql
"credit card" NEAR(5) "customer"
```

> **📚 NEAR Explanation**: Finds documents where "credit card" appears within 5 words of "customer".

### Practical Investigation Scenarios

**Scenario 1: GDPR Data Subject Request**:

Find all content related to a specific person:

```kql
"John Smith" OR "john.smith@domain.com" OR "123-45-6789"
```

**Scenario 2: Leaked Credentials Investigation**:

Find potential password disclosures:

```kql
(password OR pwd OR credentials) AND (SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)")
```

**Scenario 3: Compliance Audit - Find Old Sensitive Data**:

Locate sensitive data older than 1 year for retention review:

```kql
(SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)") AND lastmodifiedtime<2024-01-01
```

> **💡 Pro Tip**: This query helps identify candidates for Cloud-03 auto-apply retention policies!

---

## Appendix 2: eDiscovery Best Practices

### For Lab Environment

**Start Simple, Then Build Complexity**:

- Begin with basic sensitive type searches (Step 4 approach).
- Use Statistics and Sample views to validate results before adding query complexity.
- Test each KQL operator individually before combining multiple conditions.

**Scope Management**:

- Limit search scope to Cloud-01 SharePoint site for faster results and focused testing.
- Use Filter panel "Sites only" option when adding data sources.
- Start with small date ranges if using temporal queries, then expand as needed.

**Validation Before Actions**:

- Review Statistics dashboard to verify search found expected content (items count, locations).
- Check Sample results for false positives before considering export.
- Understand difference between Statistics (summary data) and Sample (actual documents).

### For Production Deployments

**Permission Management**:

- **Restrict eDiscovery access** to authorized legal/compliance personnel only.
- **Use role subgroups appropriately** (based on Microsoft Learn guidance):
  - **eDiscovery Manager subgroup**: For investigators managing only their own cases
  - **eDiscovery Administrator subgroup**: Can access and manage ALL cases in the organization after adding themselves as case members
- **Assign case-specific members**: Only add users to cases when they have legitimate need to access search results.
- **Audit access quarterly**: Review who has eDiscovery Manager/Administrator permissions regularly.

> **📚 Microsoft Learn Reference**: "eDiscovery Managers can only access and manage the cases they create. They can't access or manage cases created by other eDiscovery Managers. eDiscovery Administrators can access all cases listed on the eDiscovery page."

**Legal Hold Strategy**:

- **Create holds BEFORE searching** when investigation requires content preservation.
- **Understand hold behavior**: Content on eDiscovery hold cannot be deleted by users or retention policies.
- **Hold takes precedence**: eDiscovery holds override retention policies (content preserved until hold released).
- **24-hour activation**: Allow up to 24 hours for holds to take effect after creation.
- **Use for short-term preservation**: eDiscovery holds designed for legal investigations, NOT long-term retention.

> **⚠️ Microsoft Learn Guidance**: "For long term data retention not related to eDiscovery investigations, it is strongly advised to use retention policies and retention labels."

**Search Strategy**:

- **Data minimization**: Only search locations relevant to investigation (principle of least privilege).
- **Iterative refinement**: Start with broad queries, then narrow based on Statistics results.
- **Keyword lists**: Use keyword list feature to track which search terms find the most content.
- **Document thoroughly**: Maintain detailed notes of search queries, rationale, and legal basis.

**Export and Data Security**:

- **Secure handling**: Export sensitive data only when necessary for legal review.
- **Access control**: Limit export capabilities to authorized legal counsel only.
- **Chain of custody**: Document all export actions for legal defensibility.
- **Temporary storage**: Define retention period for exported data separate from source content.

**Compliance and Auditing**:

- **Audit logging enabled**: All eDiscovery searches logged in unified audit log (view in Microsoft Purview portal).
- **Regular monitoring**: Review eDiscovery search activities for unauthorized or inappropriate use.
- **Policy documentation**: Maintain written policies for when/why eDiscovery is performed.
- **Legal consultation**: Always consult legal counsel before conducting investigations involving privileged content.

**Integration with Retention Policies**:

- **eDiscovery holds override retention**: Content on legal hold won't be deleted by retention policies.
- **Coordinate lifecycle management**: After eDiscovery finds old sensitive data, consider Cloud-03 auto-apply retention policies for future data governance.
- **Different purposes**:
  - **Retention policies/labels**: Long-term data lifecycle management (compliance)
  - **eDiscovery holds**: Short-term preservation for legal investigations

**Summary Comparison** (from Microsoft Learn):

| Consideration | Retention Policies | eDiscovery Holds |
|--------------|-------------------|------------------|
| **Business need** | Compliance | Legal |
| **Time scope** | Long-term | Short-term |
| **Focus** | Broad, content-based | Specific, user-based |
| **Start/end configurable** | Yes | No (manual release) |
| **Content deletion** | Yes (optional) | No |
| **Administrative overhead** | Low | High |

> **⚠️ Production Warning**: eDiscovery searches can have significant legal implications. Consult with legal counsel before conducting investigations involving sensitive, confidential, or legally privileged content. Understand chain of custody requirements for potential litigation.

## ⏭️ Next Steps

eDiscovery search completed! You now have:

- ✅ Content Search capability for finding sensitive data.
- ✅ KQL query skills for credit card and SSN detection.
- ✅ Understanding of eDiscovery vs. retention labels.
- ✅ Search results showing sensitive content locations.
- ✅ Export knowledge for legal/compliance scenarios.

**Section 3 (Cloud Scanning) Complete!** You've mastered:

- SharePoint Online foundation (Cloud-01).
- Retention label configuration (Cloud-02).
- Auto-apply policies with up-to-7-day processing timeline (Cloud-03).
- eDiscovery content search (Cloud-04).

Proceed to **[Section 5: Supplemental Labs](../../05-Supplemental-Labs/README.md)** for optional advanced topics including Activity Explorer analysis, Data Classification dashboards, cross-platform reporting, and executive stakeholder reports.

**Optional Supplemental Lab**:

1. **[Advanced Reporting & Cross-Platform Analysis](../../05-Supplemental-Labs/Advanced-Reporting-Cross-Platform-Analysis/README.md)** - Activity Explorer analysis, Data Classification dashboards, and executive reporting combining on-prem scanner and cloud retention label results

> **⏰ Return Reminder**: Come back to Cloud-03 after up to 7 days to validate auto-apply retention label application to your SharePoint files.

## 📚 Reference Documentation

- [Microsoft Purview eDiscovery solutions](https://learn.microsoft.com/en-us/purview/ediscovery)
- [Content Search in eDiscovery](https://learn.microsoft.com/en-us/purview/search-for-content)
- [Keyword Query Language (KQL) syntax](https://learn.microsoft.com/en-us/sharepoint/dev/general-development/keyword-query-language-kql-syntax-reference)
- [Search for sensitive information types](https://learn.microsoft.com/en-us/purview/sit-search-for-data)
- [Export Content Search results](https://learn.microsoft.com/en-us/purview/export-search-results)

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of eDiscovery content search procedures while maintaining technical accuracy for compliance and legal hold scenarios.*
