# Lab 05: Data Discovery Paths

## 📚 Overview

After uploading documents in Lab 03, you need to choose how to **discover and report** on sensitive data across your SharePoint environment. This lab provides **three core discovery approaches** plus an **optional temporal analysis lab**, each with different timing characteristics and use cases.

**Critical Timing Context**: Microsoft Purview data discovery timing varies significantly based on the method used:

- **PnP Direct File Access (Lab 05a)**: Results **immediately** (✅ Fastest - no indexing wait)
- **eDiscovery Compliance Search (Lab 05b)**: Results within **24 hours** (SharePoint Search indexing)
- **Graph API Search (Lab 05c)**: Requires **7-14 days** for Microsoft Search unified index, then enables fast queries
- **On-Demand Classification (Lab 04)**: Results within **7 days** (proactive portal-based scan)
- **Temporal Analysis (Lab 05-Temporal)**: **Optional 2-3 week** longitudinal study tracking classification evolution (supplemental)

**Duration**: Varies by path (5 minutes to 14 days depending on indexing requirements)

**Prerequisites**:

- Completed Lab 03 (Document Upload & Distribution)
- Understanding of your discovery timing requirements (immediate vs. 24 hours vs. 7 days vs. 7-14 days)
- Understanding of your reporting requirements (one-time vs recurring, manual vs automated)
- Understanding of accuracy requirements (regex estimation vs official Purview SIT detection)

---

## 🎯 Choose Your Discovery Path

Lab 05 offers **three core discovery approaches** plus an **optional temporal analysis** for longitudinal studies. **Choose based on your timing requirements, accuracy needs, and technical comfort level**:

| Path | Method | Timeline | SIT Accuracy | Best For | Setup Time |
|------|--------|----------|--------------|----------|------------|
| **[05a: PnP Direct File Access](05a-PnP-Direct-File-Access/)** | Direct file enumeration + regex | **Immediate** | 94-95% (regex) | Immediate discovery, learning | 5-10 minutes |
| **[05b: eDiscovery Compliance Search](05b-eDiscovery-Compliance-Search/)** | Portal-based search with Purview SITs | **24 hours** | ~100% (Purview) | Official compliance searches | 30-45 minutes |
| **[05c: Graph API Discovery](05c-Graph-API-Discovery/)** | Microsoft Graph Search API automation | **7-14 days** (initial) | ~100% (Purview) | Automated recurring monitoring | 2-3 hours setup |
| **[05-Temporal: Longitudinal Analysis](05-Temporal-Classification-Analysis/)** *(Optional)* | 4-interval temporal tracking (24hr, 7d, 14d, 21d) | **2-3 weeks** | ~100% (Purview) | Classification drift research | 2-4 hours total |

---

## 📊 Path Comparison

### Lab 05a: PnP PowerShell Direct File Access (Immediate Regex-Based Discovery)

**Method**: Direct file enumeration via PnP PowerShell with custom regex pattern matching

**Timeline**: **Immediate** - works minutes after Lab 03 file uploads complete (no indexing wait)

**Advantages**:

- ⚡ **Fastest possible discovery method** - no indexing delays whatsoever
- 🚀 Works immediately after document upload (minutes, not days)
- 📚 Educational - shows how SIT detection works "under the hood"
- 🔧 Simple setup - 5-10 minutes to start scanning
- 💰 No additional licensing requirements beyond SharePoint access

**Limitations**:

- ⚠️ 70-90% accuracy due to regex pattern limitations (no context awareness, no validation logic)
- ⚠️ Higher false positive rate compared to official Purview SIT engine
- ⚠️ Best for learning and immediate interim results, not for compliance reporting
- ⚠️ Pattern-based detection may miss SIT variations

**Choose this path if**:

- You need discovery results **immediately** after Lab 03 upload
- You want to understand how SIT detection works at a fundamental level
- You're comfortable with ~70-90% accuracy for learning purposes
- You need interim results while waiting for Lab 04 (7-day scan) to complete

**[→ Go to Lab 05a: PnP Direct File Access](05a-PnP-Direct-File-Access/)**

---

### Lab 05b: eDiscovery Compliance Search (24-Hour Official SIT Detection)

**Method**: Microsoft Purview eDiscovery portal-based search with official Purview SITs

**Timeline**: **24 hours** after Lab 03 upload (SharePoint Search indexing delay)

**Advantages**:

- ✅ **100% Purview SIT accuracy** - uses official Purview classification engine
- ⚡ Much faster than waiting 7-14 days for Microsoft Search unified index
- 🖱️ Portal-based workflow - no PowerShell or coding required
- 📊 Export CSV results for compliance reporting
- 🎯 Official compliance search suitable for legal hold and eDiscovery workflows

**Limitations**:

- ⏱️ Requires 24-hour wait for SharePoint Search index to populate new content
- 👤 Requires eDiscovery Manager role
- 📏 Export limit (1,000 items per export batch)
- 🔄 Manual search initiation (not automated recurring)

**Choose this path if**:

- You need **official Purview SIT detection** faster than 7-day Lab 04 scan
- You can wait 24 hours after Lab 03 upload
- You want portal-based workflow without scripting
- You need compliance-quality results for reporting

> **💡 Validation Strategy**: Use Lab 05b to validate Lab 05a regex accuracy by comparing results after 24 hours.

**[→ Go to Lab 05b: eDiscovery Compliance Search](05b-eDiscovery-Compliance-Search/)**

---

### Lab 05c: Graph API Discovery (7-14 Day Post-Indexing Automated Recurring Reports)

**Method**: Use Microsoft Graph Search API with PowerShell automation scripts

**Timeline**: Requires **7-14 days** for initial Microsoft Search unified index, then enables fast automated queries

**Advantages**:

- ⚡ Fast programmatic queries **after initial indexing** (minutes to scan entire tenant)
- 🔄 Fully automatable for recurring scans (daily/weekly/monthly)
- ✅ 100% Purview SIT accuracy (queries same index as Content Explorer)
- 📊 Custom reporting with trend analysis over time
- 🔗 Easy integration with SIEM, dashboards, or ticketing systems
- ✅ No WAM authentication issues (uses standard Graph API)

**Limitations**:

- ⏱️ **7-14 day initial Microsoft Search unified indexing wait** before Graph API returns results for new content
- ⚙️ Requires one-time Graph API permissions setup
- 📚 PowerShell/API knowledge helpful (scripts provided)
- ⏱️ Initial setup takes 2-3 hours

**Choose this path if**:

- You need automated recurring monitoring **after initial indexing completes** (weekly security reports)
- You want to integrate with SIEM or security dashboards
- You have large-scale tenant-wide discovery needs (10K+ documents)
- Your team has PowerShell/API expertise or wants to learn
- You're willing to wait 7-14 days for Microsoft Search unified index to populate

> **⏱️ Timing Strategy**: Start Lab 05a for immediate results or Lab 05b for 24-hour official results. Then implement Lab 05c for ongoing automated monitoring after 7-14 days.

**[→ Go to Lab 05c: Graph API Discovery](05c-Graph-API-Discovery/)**

---

### Lab 05-Temporal: Longitudinal Classification Analysis (Optional/Advanced - 2-3 Week Study)

**Method**: Track Purview SIT classification evolution across 4 temporal intervals (24-hour, 7-day, 14-day, 21-day)

**Timeline**: **2-3 weeks** - requires periodic scans at 24 hours, 7 days, 14 days, and 21 days after Lab 03 upload

**Advantages**:

- 📈 Measures classification drift and index maturation patterns over time
- ✅ Validates classification stability and convergence point (14-21 days typically)
- 📊 Provides production deployment insights (optimal scan timing, maturation periods)
- 🔬 Research-quality longitudinal data for governance strategy planning
- 📉 Tracks false positive/negative rates as indexes mature
- 💡 Informs enterprise migration and compliance audit timing decisions

**Limitations**:

- ⏱️ **2-3 week commitment** - requires periodic scans at 4 intervals (not acceleratable)
- ⚠️ **Optional/supplemental** - not required to proceed to Lab 06 or complete core Lab 05
- 📅 Requires Lab 03 completed at least 21 days ago for full analysis
- 🔄 Manual scan execution required at each interval (24hr, 7d, 14d, 21d)
- 📚 Advanced use case - most users will complete Labs 05a/05b/05c only

**Choose this path if**:

- You want to understand **how Purview classification evolves over time** (research/planning)
- You need **production deployment insights** for enterprise migration planning
- You're planning **long-term governance strategy** and need maturation timeline data
- You're interested in **classification stability validation** for compliance auditing
- You have **2-3 weeks to commit** to periodic scanning (cannot be accelerated)
- This is **supplemental research** - not blocking Lab 06 or core Lab 05 completion

> **📌 Optional Lab Status**: This lab is **supplemental/optional** and provides advanced insights into classification drift for users planning production deployments. Most users will complete Labs 05a, 05b, and 05c, then proceed to Lab 06. Lab 05-Temporal can be run in parallel or deferred for future research.

**[→ Go to Lab 05-Temporal: Longitudinal Classification Analysis](05-Temporal-Classification-Analysis/)**

---

## 🧭 Decision Guide

### Quick Decision Tree

**Question 1: How quickly do you need results?**

- **Immediately (minutes after Lab 03)** → Go to **Lab 05a: PnP Direct File Access**
- **Within 24 hours** → Go to **Lab 05b: eDiscovery Compliance Search**
- **Within 7 days** → Go to **[Lab 04: On-Demand Classification](../04-On-Demand-Classification/)**
- **Can wait 7-14 days** → Go to **Lab 05c: Graph API Discovery**

**Question 2: Are you interested in longitudinal research (optional)?**

- **Yes, want to track classification evolution over time** → Consider **Lab 05-Temporal** (2-3 week study, optional)
- **No, just need core discovery methods** → Complete Labs 05a, 05b, 05c and proceed to Lab 06

**Question 3: What accuracy do you need?**

- **100% Purview SIT accuracy** → Labs 05b (24hr), 04 (7 days), or 05c (7-14 days)
- **70-90% regex estimation is acceptable for learning** → Lab 05a (immediate)
- **Want to study classification stability over time?** → Lab 05-Temporal (2-3 weeks, supplemental/optional)

---

## 📈 Common Use Cases

| Your Scenario | Recommended Path | Timeline | Accuracy |
|---------------|------------------|----------|----------|
| "I need discovery results immediately after Lab 03 upload" | **Lab 05a: PnP Direct File Access** | Immediate | 70-90% regex |
| "I need official Purview SIT detection within 24 hours" | **Lab 05b: eDiscovery Compliance Search** | 24 hours | 100% Purview |
| "I need comprehensive portal-based scan with official SITs" | **Lab 04: On-Demand Classification** | 7 days | 100% Purview |
| "I need weekly automated scans sent to our security team" | **Lab 05c: Graph API Discovery** | 7-14 days initial + automated | 100% Purview |
| "I want to integrate sensitive data detection with our SIEM" | **Lab 05c: Graph API Discovery** | 7-14 days initial + automated | 100% Purview |
| "I'm not technical and just need portal-based CSV exports" | **Lab 05b: eDiscovery** (24hr) | 24 hours | 100% Purview |
| "I want to learn how SIT detection works under the hood" | **Lab 05a: PnP Direct File Access** | Immediate | 70-90% regex |
| "I need to validate my custom regex patterns" | **Lab 05a** (immediate) then **Lab 05b** (24hr validation) | Immediate + 24hr | Compare results |

---

## 💡 Path-Specific Learning Objectives

### After completing Lab 05a, you will

- Connect to SharePoint using PnP PowerShell with modern authentication
- Enumerate files directly from SharePoint document libraries (no search index)
- Implement custom regex patterns for immediate SIT detection
- Generate CSV reports with detection results and confidence levels
- Understand the tradeoffs between regex-based and official Purview SIT detection
- Compare regex results with official Purview results (via Lab 05b validation)

### After completing Lab 05b, you will

- Access Microsoft Purview Compliance Center for eDiscovery operations
- Create compliance searches targeting specific SharePoint sites and SIT types
- Monitor search execution and review detailed results in Compliance Center
- Export eDiscovery search results using the eDiscovery Export Tool
- Compare eDiscovery results with Lab 05a regex detection for accuracy validation
- Understand the 24-hour SharePoint Search indexing requirement

### After completing Lab 05c, you will

- Configure Microsoft Graph API permissions for search operations
- Write PowerShell scripts to query sensitive data programmatically via Graph API
- Schedule automated recurring scans using Task Scheduler or Azure Automation
- Generate trend reports showing sensitive data over time
- Integrate discovery results with security dashboards or SIEM
- **Understand the 7-14 day Microsoft Search unified indexing requirement** for Graph API queries

### After completing Lab 05-Temporal (Optional), you will

- Design longitudinal classification studies with weekly scan intervals
- Track SIT detection convergence and stability over 2-3 weeks
- Measure Microsoft Search index maturation patterns
- Analyze classification drift and false positive evolution
- Understand when classification results become reliable for production use
- Create temporal trend reports for compliance and operational planning

---

## 🔄 Can I Complete Multiple Paths?

**Yes!** You can explore multiple Lab 05 paths to understand different discovery approaches and timelines:

**Recommended Learning Sequence**:

1. **Lab 05a** (5-10 minutes) → Immediate results, learn SIT detection fundamentals with regex
2. **Lab 05b** (30-45 minutes, wait 24 hours) → Official Purview SIT results, validate Lab 05a accuracy
3. **Lab 05c** (2-3 hours setup, wait 7-14 days) → Automated recurring discovery after indexing
4. **Lab 05-Temporal** (optional, 2-3 weeks) → Longitudinal classification stability study

Many users complete:

- **Lab 05a** first for immediate learning and interim results
- **Lab 05b** after 24 hours to get official Purview SIT validation
- **Lab 05c** later when they need ongoing automation or recurring reports
- **Lab 05-Temporal** only if researching classification maturation patterns

---

## 🔑 Purview SIT GUID Mapping Reference

The `Purview-SIT-GUID-Mapping.json` file in this directory provides a comprehensive mapping of Microsoft Purview built-in Sensitive Information Type (SIT) GUIDs to their human-readable friendly names.

### Why This File Exists

**eDiscovery exports contain GUIDs, not friendly names**: When you export sensitive data from eDiscovery Compliance Search (Lab 05b), the "Sensitive type" column contains GUIDs like `a44669fe-0d48-453d-a9b1-2cc83f2cba77` instead of friendly names like "U.S. Social Security Number (SSN)".

**GUIDs are universal constants**: Built-in Purview SIT GUIDs are **identical across all Microsoft 365 tenants** (verified through Microsoft Learn documentation). This means a single mapping file works for everyone.

**Reports are more readable with friendly names**: Converting GUIDs to names improves terminal output, CSV reports, and markdown summaries, making analysis results immediately understandable.

### What's Included

The mapping file contains:

- **93+ built-in Purview SIT definitions** covering global regulatory standards
- **Personal identifiers**: SSN, passport numbers, driver's licenses, tax IDs across 50+ countries
- **Financial data**: Credit cards, bank accounts, IBAN, SWIFT codes
- **Healthcare data**: Medicare numbers, medical terms, drug names, ICD codes
- **Security credentials**: API keys, passwords, connection strings, tokens
- **Named entities**: Person names, physical addresses, medical conditions

### How It's Used

**Lab 05b Analysis Scripts**: The eDiscovery analysis scripts load this mapping file to translate GUIDs in the "Sensitive type" column to friendly SIT names during CSV generation.

**Cross-Lab Comparison**: The `Invoke-CrossLabAnalysis.ps1` script uses this mapping to ensure consistent SIT naming across all discovery methods (Labs 05a/b/c/d).

**Terminal Output**: Scripts display SIT names instead of GUIDs for better readability during analysis execution.

### Data Source

All GUID mappings are sourced from **official Microsoft Learn documentation**:

- [Sensitive Information Type Entity Definitions](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)
- Each SIT definition page includes the official GUID in the XML schema
- Example: [U.S. Social Security Number (SSN)](https://learn.microsoft.com/en-us/purview/sit-defn-us-social-security-number) shows `id="a44669fe-0d48-453d-a9b1-2cc83f2cba77"`

**Why GUIDs are universal**: When you customize or copy a built-in SIT, Microsoft requires generating **new GUIDs**, proving the originals are fixed global constants.

### Extending the Mapping

#### Adding Built-in SITs

If you encounter an unmapped built-in Purview SIT GUID:

1. Search Microsoft Learn for the GUID to find the official SIT name
2. Add the mapping to `Purview-SIT-GUID-Mapping.json` in the `sitMappings` section
3. Follow the format: `"guid": "Friendly SIT Name"`
4. Scripts will automatically pick up the new mapping on next run

**Example**:

```json
{
  "sitMappings": {
    "a44669fe-0d48-453d-a9b1-2cc83f2cba77": "U.S. Social Security Number (SSN)",
    "your-new-guid-here": "Your SIT Friendly Name"
  }
}
```

#### Adding Custom SITs (Tenant-Specific)

If you've created **custom SITs in your Microsoft 365 tenant**, you can add them to the mapping file exactly the same way:

1. **Find your custom SIT GUID**:
   - Go to Microsoft Purview Compliance Center → Data Classification → Sensitive info types
   - Click on your custom SIT to view details
   - Copy the GUID from the details pane or URL
   - **OR** check your eDiscovery export CSV - unmapped GUIDs appear as "Custom SIT (guid)"

2. **Add to mapping file**:

```json
{
  "sitMappings": {
    "a44669fe-0d48-453d-a9b1-2cc83f2cba77": "U.S. Social Security Number (SSN)",
    "12345678-abcd-1234-abcd-1234567890ab": "Employee ID Number (Custom)",
    "87654321-dcba-4321-dcba-0987654321ba": "Internal Project Code (Custom)"
  }
}
```

3. **Scripts automatically use it**: Re-run Lab 05b analysis or cross-lab comparison scripts - they will automatically detect and use your custom SIT mappings

**Best Practice**: Add a suffix like "(Custom)" to your friendly names to distinguish them from built-in Purview SITs in reports.

**Important**: Custom SIT GUIDs are **tenant-specific** (not universal like built-in SITs). If you share scripts with other organizations, they'll need to add their own custom SIT mappings to the file.

### How Scripts Use the Mapping

All Lab 05b analysis scripts and the cross-lab comparison orchestrator automatically:

1. **Load the mapping file** at script startup from `Purview-SIT-GUID-Mapping.json`
2. **Look up GUIDs** whenever processing the "Sensitive type" column from eDiscovery exports
3. **Replace GUIDs with friendly names** in CSV reports, JSON summaries, markdown reports, and terminal output
4. **Handle unmapped GUIDs gracefully** by preserving them as "Custom SIT (guid)" for easy identification

**Zero configuration needed** - just add mappings to the JSON file and re-run your scripts!

---

## 📊 Cross-Lab Analysis: Comparing Discovery Methods

If you've completed multiple Lab 05 paths, you can compare their results to understand accuracy differences, detection patterns, and method strengths/weaknesses.

### Why Compare Discovery Methods?

**Understanding Accuracy Trade-offs**:

- **Lab 05a (PnP regex)**: 70-90% accuracy - fast but approximate
- **Lab 05b (eDiscovery)**: 100% accuracy - official Purview SITs with 24-hour wait
- **Lab 04 (On-Demand)**: 100% accuracy - comprehensive portal-based scan with 7-day wait
- **Labs 05c/05d (Graph/SharePoint Search)**: 100% accuracy - automated with 7-14 day indexing

**Validation Use Cases**:

- Validate Lab 05a regex patterns against official Purview SIT detection
- Identify false positives (Lab 05a detected but eDiscovery didn't)
- Identify false negatives (eDiscovery detected but Lab 05a missed)
- Understand which files are consistently detected across all methods
- Measure accuracy improvements from regex to official SITs

### Comparison Analysis Options

#### Automated Cross-Lab Orchestrator (Recommended)

The `Invoke-CrossLabAnalysis.ps1` orchestrator script (in `scripts/` folder) automatically detects completed labs and generates comprehensive comparison analysis.

**Quick Start** (No configuration needed):

```powershell
# Navigate to Lab 05 directory
cd "Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths"

# Auto-detect all completed labs and generate comparison
.\scripts\Invoke-CrossLabAnalysis.ps1

# Generate HTML report with visualizations
.\scripts\Invoke-CrossLabAnalysis.ps1 -GenerateHtmlReport
```

**Advanced Configuration**:

For customized comparisons with filters, specific lab selection, and advanced settings, see the [Cross-Lab Analysis Configuration Guide](CROSS-LAB-ANALYSIS.md).

Common configuration scenarios:

- Compare only specific labs (Lab 05a and Lab 05b only).
- Filter by SIT type (SSN and Credit Cards only).
- Analyze specific SharePoint sites (HR and Finance departments).
- Set confidence thresholds for high-confidence detections.
- Time-based comparisons (recent detections only).

**What the orchestrator provides**:

- **Automatic lab detection**: Finds completed labs by searching report folders.
- **Multi-method comparison**: Compares all available Lab 05 methods (05a, 05b, 05c, 05d).
- **Accuracy metrics**: Calculates precision, recall, and accuracy for regex vs Purview SIT methods.
- **Overlap analysis**: Identifies files detected by all methods (high-confidence detections).
- **False positive/negative identification**: Shows what regex missed or over-detected.
- **SIT distribution**: Compares sensitive information type patterns across methods.
- **Consolidated reports**: Generates CSV summary and optional HTML visualization.

**Minimum requirement**: At least 2 completed Lab 05 paths for meaningful comparison.

See [CROSS-LAB-ANALYSIS.md](CROSS-LAB-ANALYSIS.md) for detailed configuration options, filter examples, troubleshooting, and interpreting results.

**Expected Results**: When comparing Lab 05a (regex) vs Lab 05b (Purview SITs), typical accuracy is 70-90% with some false positives (regex over-detection) and false negatives (regex missed SIT variations). See [CROSS-LAB-ANALYSIS.md](CROSS-LAB-ANALYSIS.md#-expected-comparison-results) for detailed accuracy patterns and interpretation guidance.

---

## 🎯 Understanding Regex vs Purview ML Detection Differences

### Expected Accuracy: Lab 05a (Regex) vs Lab 05b (Purview with ML)

When you run cross-lab analysis comparing Lab 05a and Lab 05b results, you'll see accuracy differences that are **expected and documented** due to fundamental technology differences:

#### Overall Expected Accuracy Metrics

After Phase 1 and Phase 2 regex improvements (ITIN pattern, Credit Card filtering, ABA checksum, Bank Account document filtering):

| Metric | Lab 05a (Regex) | Lab 05b (Purview ML) | Delta Explanation |
|--------|-----------------|----------------------|-------------------|
| **Overall Accuracy** | 88-95% of all files | ~100% of all files | Regex ceiling vs ML precision |
| **Precision** | 88-94% of regex detections are correct | ~99% of ML detections are correct | Regex has 6-12% false positive rate |
| **Recall** | 98-100% of true SITs found | ~100% of true SITs found | Regex misses 0-2% of true SITs |
| **False Positives** | 6-12% of regex detections | <0.2% of ML detections | Regex incorrectly flags non-SIT files |
| **False Negatives** | 0-2% of true SITs missed | <0.1% of true SITs missed | Regex misses context-dependent SITs |

> **📊 Scale Context**: In a typical Medium scale deployment (Lab 02: ~5,000 files uploaded, ~4,400 contain true SITs):
> - **Lab 05a** detects ~4,650-5,000 files (4,400 true positives + 250-600 false positives)
> - **Lab 05b** detects ~4,400 files (4,400 true positives + <10 false positives)
> - **Difference**: Lab 05a over-detects 250-600 files (6-12% of its detections) and misses 0-50 files (0-1% of true SITs)

#### SIT-Specific Variance Expectations

Different Sensitive Information Types show different variance patterns when comparing regex (Lab 05a) to Purview ML (Lab 05b). These ranges reflect actual cross-lab analysis results:

| SIT Type | Expected Variance | Regex vs ML Behavior | Cross-Lab Assessment |
|----------|------------------|----------------------|---------------------|
| **ABA Routing Number** | 5-10% | ✅ Checksum validation works well | Good agreement expected |
| **U.S. Driver's License** | 5-10% | ✅ State-specific patterns manageable | Good agreement expected |
| **Credit Card Number** | 15-25% | ⚠️ Luhn algorithm helps, but context matters | Review recommended |
| **U.S. Social Security Number** | 30-50% | ❌ Employee IDs create significant false positives | Significant variance expected |
| **U.S. ITIN** | 40-80% | ❌ ML better at ITIN-specific prefix patterns (9xx-7x/8x) | Significant variance expected |
| **U.S. Bank Account** | 40-60% | ❌ Order/tracking numbers create substantial false positives | Significant variance expected |
| **Passport Number** | 30-50% | ❌ Complex country-specific formats favor ML | Significant variance expected |

**Why These Variances Exist**:
- **Low Variance (5-10%)**: SITs with strong validation rules (checksums, fixed formats) where regex performs well
- **Medium Variance (15-25%)**: SITs where format helps but context would improve accuracy
- **High Variance (30-80%)**: SITs where similar formats exist (SSN vs Employee ID) or complex variations exist (international passports) - ML's context awareness and document classification provide significant advantage

> **💡 Production Guidance**: For compliance-critical SITs with >20% expected variance (SSN, ITIN, Bank Account, Passport), always use Purview ML methods (Labs 05b/05c) rather than regex approximations.

#### Why These Differences Exist

**Regex Detection (Lab 05a) Technology**:

- Pure pattern matching with no context awareness
- No document classification or semantic understanding
- No confidence scoring or validation beyond checksums
- Cannot distinguish between similar formats (SSN vs Employee ID vs Passport)
- Limited to format-based rules (9 digits, Luhn algorithm, etc.)

**Purview ML Detection (Lab 05b) Technology**:

- Machine learning document classification engine
- Context-aware SIT detection with keyword proximity
- Confidence scoring (Low/Medium/High) based on surrounding content
- Document type understanding (HR vs Financial vs Immigration)
- Semantic analysis of SIT meaning within document context
- Built-in checksum validation for Credit Card, ABA, etc.
- Evidence-based detection with corroborating keywords

#### Expected Detection Pattern Differences

##### Pattern 1: Regex Over-Detection (False Positives)

Lab 05a detects 6-12% more files than Lab 05b (250-600 extra files in Medium scale):

- **SSN**: Regex detects ~30-50% more files (employee IDs, reference numbers)
  - Example: "Employee ID 123-45-6789" matches SSN regex pattern
  - Purview ML: Understands context, rejects due to "Employee ID" keyword proximity
  
- **Bank Account**: Regex detects ~40-60% more files (order numbers, tracking IDs)
  - Example: "Order #1234567890123" matches bank account 10-14 digit range
  - Purview ML: Document type classification identifies e-commerce order, not financial document
  
- **Passport**: Regex detects ~40-45% more files (cannot distinguish from SSN format)
  - Example: "SSN: 123456789" in HR document matches US passport 9-digit pattern
  - Purview ML: Document classification + context identifies as SSN, not passport

##### Pattern 2: Regex Under-Detection (False Negatives)

Lab 05a misses 1-2% of files that Lab 05b correctly detects (50-100 missed files in Medium scale):

- **Driver's License**: Regex misses unusual state formats or variations
  - Example: Some states use alphanumeric formats not captured in standard regex
  - Purview ML: Trained on comprehensive state-specific patterns
  
- **Credit Card**: Regex misses cards with unusual spacing or embedded characters
  - Example: "4111-1111-1111-1111-" (trailing dash breaks regex pattern)
  - Purview ML: Normalizes formatting before validation
  
- **ITIN/SSN**: Regex misses context-implied references
  - Example: "Taxpayer identification: ending in 6789" (partial reference)
  - Purview ML: Understands partial reference context with high confidence

#### What "Good" Accuracy Looks Like

When you compare Lab 05a and Lab 05b results, these metrics indicate **successful regex implementation**:

| Comparison Metric | Target Range | What It Measures | Medium Scale Example |
|-------------------|--------------|------------------|----------------------|
| **Agreement Rate** | 90-95% of all detections | Files detected by both methods | 4,100-4,200 files found by both |
| **Lab 05a Precision** | 93-94% correct detections | True positives ÷ total regex detections | 4,400 correct ÷ 4,650 total = 94.6% |
| **Lab 05a Recall** | 98-99% coverage | True positives found ÷ all true SITs | 4,350 found ÷ 4,400 exist = 98.9% |
| **Lab 05a Unique Files** | 180-250 files (6-7% of detections) | False positives: regex-only detections | 250 files flagged incorrectly |
| **Lab 05b Unique Files** | 50-100 files (1-2% of true SITs) | False negatives: regex missed these | 50 SIT files that regex missed |

> **✅ Validation Strategy**: If your cross-lab analysis shows metrics within these target ranges, your regex patterns are performing optimally. Deviations beyond ±10% warrant investigation of specific SIT patterns or file-level detection issues.

### Understanding Expected Variance by SIT Type

Regex-based detection (Lab 05a) has different accuracy levels depending on the Sensitive Information Type (SIT). Understanding these limitations helps set realistic expectations:

#### Excellent Detection (0-10% variance)

- **ITIN (Individual Taxpayer ID)**: ~2% variance - Unique 9XX-XX-XXXX pattern with good discrimination
- **Credit Card**: ~2% variance - Luhn checksum validation + filename filtering eliminates most false positives
- **Driver's License**: ~8-9% variance - Diverse state formats provide natural discrimination

#### Good Detection (10-20% variance)

- **ABA Routing Number**: ~15% variance - Checksum validation eliminates most false positives (zip codes, phone numbers, employee IDs)

#### Acceptable Detection (20-30% variance)

- **Bank Account**: ~20-25% variance - Document type filtering helps, but 10-14 digit range still matches order numbers, tracking IDs
- **SSN**: ~30-35% variance - 9-digit pattern too generic, matches employee IDs, reference numbers without context

#### Known Limitations (30-50% variance)

- **Passport**: ~40-45% variance - US passport format identical to SSN (9 digits), cannot differentiate without document classification

#### Why These Variances Exist

**Regex Limitations**:

- No document classification (cannot understand if file is HR document vs financial document)
- No context awareness (cannot distinguish SSN context from employee ID context)
- No semantic understanding (cannot determine if 9 digits in immigration form is SSN or passport)
- Pattern-only matching (relies purely on format, not meaning)

**Purview Advantages** (Lab 05b):

- Machine learning document classification
- Confidence scoring with context analysis
- Keyword proximity detection
- Checksum validation for applicable SITs
- Understanding document type to infer SIT meaning

**Production Strategy**:

- Use **Lab 05a (regex)** for initial screening and bulk discovery (high recall, lower precision)
- Use **Lab 05b (Purview)** for compliance-critical validation (high precision, official SIT engine)
- Accept documented variances for SSN, Passport, Bank Account as inherent regex limitations
- For 95%+ accuracy requirements, rely on Purview SITs (Lab 05b) rather than regex patterns

> **💡 Accuracy Ceiling**: After Phase 1 and Phase 2 regex improvements (ITIN pattern, Credit Card filtering, ABA checksum, Bank Account document filtering), the realistic accuracy ceiling for regex-based detection is approximately **94-95%**. Further improvements require machine learning context awareness beyond regex capabilities.

---

## 🏁 Next Steps After Lab 05

After completing any Lab 05 path, you can proceed to:

- **Lab 06: Cleanup and Reset** - Safely decommission the simulation environment and generate final project documentation
- **Cross-Lab Analysis** - Compare results across multiple Lab 05 methods using the centralized analysis orchestrator
- **Additional Lab 05 Paths** - Explore alternative discovery methods to understand timing and accuracy tradeoffs

---

## 🏁 Next Steps

1. **Review the path comparison table** above to understand timing and accuracy differences
2. **Review the discovery method timeline comparison** to see all options side-by-side
3. **Use the decision guide** to identify the best path for your immediate needs
4. **Start with Lab 05a** if you want immediate results (5-10 minutes)
5. **Wait for Lab 05b** if you need official SITs within 24 hours (requires 24-hour indexing)
6. **Plan for Labs 05c/05d** if you need automated recurring discovery (requires 7-14 day indexing)

**Remember**: You can complete multiple paths to compare approaches:

- **Lab 05a** provides immediate learning and interim results
- **Lab 05b** validates Lab 05a accuracy with official Purview SITs (24 hours)
- **Labs 05c/05d** enable ongoing automation after 7-14 day indexing wait

---

## 🔧 Troubleshooting: Unmapped SIT GUIDs

### Problem: "Custom SIT (guid)" Appearing in Lab 05b Results

If your Lab 05b analysis shows entries like `Custom SIT (e09c07d3-66e5-4783-989d-49ac62748f5f)` instead of friendly SIT names, these are GUIDs that couldn't be resolved to known Sensitive Information Types.

**Common Causes:**

- **Deprecated SITs**: Microsoft occasionally deprecates or renames built-in SITs, leaving old GUIDs in historical exports
- **Tenant-specific Custom SITs**: Your organization created custom SIT definitions that use these GUIDs
- **JSON Mapping Gaps**: The cached GUID mapping file is missing entries for valid built-in SITs

### Solution: Run the Diagnostic Script

We provide a diagnostic script that analyzes unmapped GUIDs and helps you identify what they should be:

```powershell
# Navigate to scripts folder
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\scripts"

# Run diagnostic analysis
.\Resolve-UnmappedSITGuids.ps1 -ShowDetailedAnalysis
```

**What the script does:**

1. ✅ Extracts all unique GUIDs from your eDiscovery export
2. ✅ Queries your tenant for all available SIT definitions (using `Get-DlpSensitiveInformationType`)
3. ✅ Identifies which GUIDs couldn't be mapped
4. ✅ Analyzes file patterns and co-occurring SITs for context clues
5. ✅ Generates a JSON template for updating the mapping file

### Manual Investigation Steps

For each unmapped GUID, follow these steps:

#### Step 1: Look Up SIT in Purview Portal

1. Go to **Microsoft Purview Compliance Portal**: [https://compliance.microsoft.com/classifiers?viewid=sensitiveTypes](https://compliance.microsoft.com/classifiers?viewid=sensitiveTypes)
2. Search for keywords from file patterns (e.g., "ITIN", "Bank Account", "Tax")
3. Open the SIT definition and review:
   - **Description**: What data it detects
   - **Function processors**: Pattern matching logic (e.g., `Func_formatted_itin`)
   - **Keywords**: Supporting detection terms

**Note**: The Purview portal UI does NOT display GUIDs directly. You must match based on description and pattern logic.

#### Step 2: Cross-Reference with Co-Occurring SITs

The diagnostic script shows which other SITs frequently appear in the same files as the unmapped GUID. This provides context clues:

- **Example**: If an unmapped GUID frequently co-occurs with "U.S. Social Security Number (SSN)" in HR files, it's likely another identity-related SIT
- **Example**: If it appears with "ABA Routing Number" in Finance files, it's likely a banking-related SIT

#### Step 3: Use PowerShell to Search by Pattern

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession

# Get all SITs and search by keyword
$allSits = Get-DlpSensitiveInformationType
$allSits | Where-Object { $_.Name -match "Tax" } | Select-Object Id, Name | Format-Table

# Check if a specific GUID exists in your tenant
$targetGuid = "1771481d-a337-4dbf-8e64-af8da0cc3ee9"
$sit = $allSits | Where-Object { $_.Id -eq $targetGuid }
if ($sit) {
    Write-Host "✅ Found: $($sit.Name)"
} else {
    Write-Host "❌ GUID not found in tenant (deprecated or custom)"
}
```

### Updating the JSON Mapping File

Once you identify the correct SIT name:

#### Step 1: Open the Mapping File

```powershell
# Edit the JSON mapping file
notepad "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\Purview-SIT-GUID-Mapping.json"
```

#### Step 2: Add the Entry

Locate the `"sitMappings"` section and add your entry:

```json
{
  "sitMappings": {
    "existing-guid-1": "Existing SIT Name",
    "existing-guid-2": "Another SIT Name",
    "1771481d-a337-4dbf-8e64-af8da0cc3ee9": "U.S. Individual Taxpayer Identification Number (ITIN)",
    "your-new-guid-here": "Your Identified SIT Name"
  }
}
```

**Important**:

- Use lowercase GUIDs with hyphens
- Use the exact SIT name from Purview portal or `Get-DlpSensitiveInformationType`
- Add a comma after the previous entry (but not after the last entry)

#### Step 3: Validate JSON Syntax

```powershell
# Test if JSON is valid
$json = Get-Content "Purview-SIT-GUID-Mapping.json" -Raw | ConvertFrom-Json
Write-Host "✅ JSON is valid! Contains $($json.sitMappings.PSObject.Properties.Count) mappings"
```

#### Step 4: Re-Run Lab 05b Analysis

```powershell
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\scripts"
.\Invoke-eDiscoveryResultsAnalysis.ps1
```

Check the output - your newly mapped GUIDs should now show friendly names instead of "Custom SIT (guid)".

### Understanding Dynamic vs Cached Mapping

The Lab 05b analysis script uses a **hybrid approach**:

1. **Primary**: Queries tenant using `Get-DlpSensitiveInformationType` (retrieves 300+ current SITs)
2. **Fallback**: Loads cached mappings from `Purview-SIT-GUID-Mapping.json` if tenant query fails
3. **Both**: Cached mappings supplement tenant query for deprecated/renamed SITs

**Best Practice**: Even with dynamic tenant queries, maintain the JSON mapping file for:
- Historical GUIDs that Microsoft deprecated
- Consistency across different tenant environments
- Offline analysis when tenant connection isn't available

### When GUIDs Truly Can't Be Mapped

Some GUIDs may be legitimately unmappable:

- **Deprecated Microsoft SITs**: Microsoft removed/renamed the SIT definition
- **Cross-tenant GUIDs**: Export came from a different tenant with custom SITs
- **Data corruption**: GUID was malformed during export process

In these cases:
1. Document the GUID in your analysis notes
2. Contact Microsoft Support if the GUID appears in large volumes
3. Consider excluding these detections from compliance reports
4. Review the files manually to understand what data pattern triggered the detection

---

## 🤖 AI-Assisted Content Generation

This comprehensive data discovery path guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview discovery methodologies, data reporting best practices, and enterprise security operations workflows.

_AI tools were used to enhance productivity and ensure comprehensive coverage of data discovery approaches while maintaining technical accuracy and reflecting enterprise-grade sensitive information reporting standards._
