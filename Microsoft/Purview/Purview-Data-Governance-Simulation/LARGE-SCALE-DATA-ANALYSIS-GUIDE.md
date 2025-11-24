# Large-Scale Data Analysis Guide for Microsoft Purview Simulation

## 📚 Overview

This guide provides a strategic approach for leveraging the project's existing discovery tools to analyze data at scale (hundreds of sites, petabytes of data). While the simulation scripts are designed for a controlled lab environment, they can be adapted for large-scale production analysis by following specific sharding and optimization strategies.

## 🎯 Core Strategy: The "Funnel Approach"

For large datasets, do not attempt to scan everything with client-side tools (Lab 05a). Instead, use a funnel approach:

1.  **Broad Server-Side Scanning (Lab 05c)**: Use the Graph API to leverage Microsoft's search index for the heavy lifting.
2.  **Targeted Sampling (Lab 05a)**: Use PnP PowerShell only for validating specific patterns on a small subset of files.
3.  **Batched Analysis**: Shard your execution by site or department to avoid timeouts and API throttling.

---

## 🚀 Phase 1: Server-Side Discovery (The Workhorse)

**Tool**: `05-Data-Discovery-Paths/05c-Graph-API-Discovery/scripts/Invoke-GraphSitDiscovery.ps1`

This script uses the Microsoft Graph eDiscovery API, which relies on the server-side SharePoint search index. This is the **only** viable method for scanning petabytes of data, as it does not download file contents to the client.

### Scaling Strategy

#### 1. Site Sharding (Batching)
The script reads from `global-config.json`. For hundreds of sites, processing them all in one eDiscovery case can be unwieldy and slow.

*   **Approach**: Create multiple configuration files (e.g., `config-finance.json`, `config-hr.json`) containing subsets of 50-100 sites each.
*   **Execution**: Run the script sequentially or in parallel (carefully) for each config.
    *   *Note*: You will need to temporarily swap the `global-config.json` or modify the script to accept a config path parameter.

#### 2. Timeout Management
Large tenants take longer to estimate search statistics.
*   **Parameter**: Use the `-MaxWaitMinutes` parameter to increase the timeout window.
*   **Recommendation**: For large sets, set this to 60 or higher.
    ```powershell
    .\Invoke-GraphSitDiscovery.ps1 -MaxWaitMinutes 60
    ```

#### 3. Query Optimization
The script generates a query combining all enabled SITs. For massive datasets, a broad query might return too many results to export efficiently.
*   **Refinement**: Edit `global-config.json` to enable only high-priority SITs (e.g., "Credit Card Number" only) for an initial pass.
*   **Confidence Levels**: The script currently uses `1..100` confidence. For large scale, consider modifying the script (Line 168) to use `65..100` (Medium/High) to reduce noise.

---

## 🔬 Phase 2: Targeted Client-Side Validation (Optional)

**Tool**: `05-Data-Discovery-Paths/05a-PnP-Direct-File-Access/scripts/Invoke-PnPDirectFileDiscovery.ps1`

**⚠️ WARNING**: This script downloads file content to memory. **DO NOT** run this against a large production environment or root site collection.

### When to Use Client-Side Scanning

Client-side scanning (Lab 05a) is **not** a primary discovery method for large datasets. It is a **validation tool** used only when:

1. **Validating Regex**: You need to test if a custom SIT pattern works on a specific folder known to contain test data.
2. **False Positive Analysis**: You need to scan a specific library where eDiscovery reported matches to verify them manually.

### Sharding Strategy for Client-Side Scanning

If you must use client-side scanning, you **must** break up the data to avoid memory exhaustion and throttling:

1. **Site-Level Sharding**: Never run against all sites. Modify `global-config.json` to target a **single site** at a time.
2. **Library-Level Targeting**: The current script iterates all libraries. For large sites, modify the script to target a specific library:

    ```powershell
    # In Invoke-PnPDirectFileDiscovery.ps1
    $lists = Get-PnPList | Where-Object { $_.Title -eq "SpecificHighRiskLibrary" }
    ```

3. **Folder-Level Targeting**: For massive libraries (>100k files), further modify the script to scan only specific folders or time ranges (e.g., "Modified > Last 30 Days").

---

## 📊 Phase 3: Analyzing Results at Scale

**Tools**:

* `05-Data-Discovery-Paths/05c-Graph-API-Discovery/scripts/Export-SearchResults.ps1`
* `05-Data-Discovery-Paths/05c-Graph-API-Discovery/scripts/Invoke-GraphDiscoveryAnalysis.ps1`

### Handling Large Exports (The "Reports Only" Strategy)

* **Export Limits**: The "Direct Export" method (Items_0.csv) used in Lab 05c is efficient but has limits.
* **CRITICAL WARNING**: The provided script `Export-SearchResults.ps1` is configured to export `searchHits` (actual file content) in PST format. **Do not use this script as-is for petabyte-scale datasets**, as it will attempt to package all data.
* **Production Strategy**:
    1. **Manual Export**: Go to the Microsoft Purview Compliance Portal.
    2. **Select "Reports Only"**: When exporting the search results, choose the option to export only the **Reports** (CSV), not the actual content. This provides the `Items.csv` needed for analysis without the massive data overhead.
    3. **Note on Review Sets**: While Review Sets (Advanced eDiscovery) offer robust processing, they are often used for legal review rather than pure SIT discovery. For SIT analysis, the standard "Reports Only" export is usually sufficient and faster.

### Strategies for Breaking Up Data (Chunking)

If your discovery results in millions of rows, a single CSV export will be unmanageable. Use these strategies to break the data into chunks **before** export:

1. **Query Partitioning (Pre-Export)**: Instead of one massive search, run multiple smaller searches:
    * **By Time**: Create searches for "Last 30 Days", "Last Quarter", "Last Year".
    * **By SIT Type**: Create separate searches for "Financial Data" vs. "PII Data".
    * **By Location**: Search specific departments (HR, Finance) separately.
    * *Result*: You get multiple smaller CSVs (e.g., `HR_Financial_Q1.csv`) that are easier to handle.

2. **Data Handling (Post-Export)**:
    * **Do Not Use Excel**: Excel has a row limit (1M rows).
    * **Do Not Use `Import-Csv`**: PowerShell's `Import-Csv` loads the entire file into RAM.
    * **Use Stream Readers**: If using PowerShell, use `.NET StreamReader` to process line-by-line.
    * **Database Import**: Import the resulting CSVs directly into **SQL Server**, **Azure SQL**, or a **Data Lake** for aggregation and visualization using Power BI.

---

## ⚖️ Strategic Decision: Manual vs. Graph API

When dealing with large datasets, choosing between the Manual Portal (UI) and the Graph API (Automation) is a critical strategic decision. Each has distinct advantages and hard limits.

| Feature | Manual Portal (Purview UI) | Graph API (Automation) | Large Scale Implication |
| :--- | :--- | :--- | :--- |
| **Configuration** | Visual, intuitive query builder. | JSON-based, requires precise syntax. | Use **Portal** to build/test complex queries, then copy syntax to **Graph** for execution. |
| **Batching** | Difficult. Creating 100 searches requires 100 manual clicks. | Excellent. Can loop through 100 configs in seconds. | Use **Graph** for repeating the same search across 100 different site batches. |
| **Throttling** | Browser timeouts, UI lag with many objects. | API throttling (429 errors), token expiry. | **Graph** is better for scale but requires robust error handling (retry logic) which scripts must implement. |
| **Export Limits** | UI often limits display to 10k items. Export tool handles more. | API has page limits. Direct export has size limits. | Use **Portal** "Reports Only" export for massive datasets to leverage Microsoft's backend export engine. |
| **Visibility** | Easy to see status of one job. | Hard to monitor 100 jobs without custom logging. | Use **Graph** to launch jobs, but consider using **Portal** to monitor their "Estimate" status if scripts fail. |

### Recommendation for Petabyte Scale

**Hybrid Approach**:

1. **Design in Portal**: Use the UI to perfect your SIT queries and validate them against a small test site.
2. **Execute via Graph**: Use the API scripts to deploy that validated query across 500 sites (sharded into 10 batches of 50).
3. **Export via Portal**: For the final massive data dump, use the Portal's "Reports Only" export feature to generate the CSVs, avoiding API timeout risks during file transfer.
4. **Analyze Externally**: Load the CSVs into a database/BI tool.

---

## 🏆 Summary Checklist for Large Scale

| Step | Action | Tool/Config |
| :--- | :--- | :--- |
| **1. Plan** | Segment sites into batches of 50-100. | `global-config.json` (Multiple versions) |
| **2. Scan** | Run server-side discovery with increased timeouts. | `Invoke-GraphSitDiscovery.ps1 -MaxWaitMinutes 60` |
| **3. Export** | Export results per batch. | `Export-SearchResults.ps1` |
| **4. Aggregate** | Combine CSVs externally (Power BI/Synapse). | External Tools |
| **5. Validate** | Spot-check specific high-risk libraries. | `Invoke-PnPDirectFileDiscovery.ps1` (Single site config) |

## ⚠️ Known Limitations & Guardrails

* **Throttling**: Microsoft Graph API has throttling limits. Avoid running more than 2-3 concurrent discovery jobs.
* **Indexing Latency**: New data takes 24 hours to be indexed. Real-time analysis is not possible for petabyte-scale data; rely on the index.
* **Memory**: The PnP script (05a) is memory-intensive. Run on a machine with at least 16GB RAM if scanning a large library.
