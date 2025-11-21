# Lab 06: Power BI Visualization for Compliance Reporting

This lab focuses on creating Power BI dashboards to visualize sensitive data discovery results from Lab 05. You'll transform CSV discovery reports into interactive dashboards for executive presentations, compliance audits, and ongoing data governance monitoring.

## 📋 Overview

**Objective**: Build interactive Power BI dashboards that visualize SIT discovery data, track compliance posture, and provide actionable insights for data governance stakeholders.

**Duration**: 2-3 hours

**Prerequisites**:
- Completed Lab 05 (any discovery path: 05a, 05b, or 05c)
- CSV discovery reports generated from Lab 05
- Power BI Desktop installed (free download from Microsoft)
- Basic understanding of Power BI concepts

## 🎯 Learning Objectives

By completing this lab, you will:

1. **Install Power BI Desktop**: Set up the free Power BI reporting tool for dashboard creation
2. **Import Discovery Data**: Load CSV reports from Lab 05 into Power BI datasets
3. **Create Data Models**: Define relationships and calculated measures for analysis
4. **Build Discovery Dashboard**: Create visualizations showing SIT distribution, trends, and hotspots
5. **Design Compliance Reports**: Generate audit-ready reports for regulatory requirements
6. **Publish Dashboards**: Export dashboards for sharing with stakeholders

## 📊 Dashboard Architecture

### Dashboard Types

```
Power BI Visualization
├── Discovery Overview Dashboard
│   ├── Total documents scanned
│   ├── Documents with sensitive data
│   ├── SIT type distribution
│   └── Discovery coverage by site/library
├── Compliance Posture Dashboard
│   ├── Compliance score calculation
│   ├── Risk heat map by site
│   ├── SIT confidence analysis
│   └── Remediation priority matrix
├── Trend Analysis Dashboard
│   ├── Discovery trends over time
│   ├── New sensitive data detection
│   ├── Classification improvements
│   └── Month-over-month comparisons
└── Executive Summary Dashboard
    ├── KPI scorecards
    ├── Top 10 risk documents
    ├── Compliance status indicators
    └── Strategic recommendations
```

### Visualization Types

| Visual Type | Use Case | Example |
|-------------|----------|---------|
| **Bar Charts** | SIT type distribution, site comparisons | SIT Types by Count |
| **Pie/Donut Charts** | Proportion analysis, confidence levels | High/Medium/Low Confidence |
| **Heat Maps** | Risk identification, site coverage | Risk by Site & Library |
| **Line Charts** | Trend analysis, historical comparisons | Discovery Over Time |
| **Cards** | KPIs, total counts, compliance scores | Total Documents: 1,234 |
| **Tables** | Detailed drill-down, document listings | Top 50 High-Risk Documents |

## 🔧 Lab Workflow

### Step 1: Install Power BI Desktop

**Installation**:

- Navigate to the official Power BI Desktop download page.
- Download the free version from Microsoft Store or direct installer.
- Run installer and follow installation wizard.
- Launch Power BI Desktop after installation completes.

**Alternative**: Use Power BI Desktop from Microsoft Store for automatic updates.

**System Requirements**:
- Windows 10/11 (64-bit)
- 4 GB RAM minimum (8 GB recommended)
- 2.5 GB available disk space
- .NET Framework 4.7.2 or later

### Step 2: Import Lab 05 Discovery Data

**Load CSV Files**:

Launch Power BI Desktop.

- Click **Get Data** → **Text/CSV**.
- Navigate to your Lab 05 reports directory.
- Select discovery CSV file(s) from Lab 05a, 05b, or 05c.
- Click **Load** to import data into Power BI.

**Data Sources by Lab**:

- **Lab 05a**: `Content_Explorer_Export_[timestamp].csv` (manual export)
- **Lab 05b**: `SIT_Discovery_Summary_[timestamp].csv` (Graph API discovery)
- **Lab 05c**: `[SiteName]_[LibraryName]_[timestamp].csv` (SharePoint Search discovery)

**Data Transformation**:

If needed, click **Transform Data** to access Power Query Editor.

- Remove unnecessary columns (keep: FileName, SITType, Instances, Confidence, Modified, FileSize).
- Change data types (Instances = Whole Number, Confidence = Whole Number, Modified = Date).
- Create calculated column for **Risk Level** based on SIT type and confidence.
- Filter out test data or irrelevant entries.
- Click **Close & Apply** to save transformations.

### Step 3: Create Data Model and Measures

**Define Calculated Measures**:

In Power BI Desktop, go to **Modeling** tab → **New Measure**.

Create the following DAX measures for analysis:

```DAX
Total Documents = COUNTROWS('Discovery Data')

Documents with Sensitive Data = CALCULATE(COUNTROWS('Discovery Data'), 'Discovery Data'[SITType] <> BLANK())

High Risk Documents = CALCULATE(COUNTROWS('Discovery Data'), 'Discovery Data'[Risk Level] = "High")

Average Confidence = AVERAGE('Discovery Data'[Confidence])

Compliance Score = DIVIDE([Documents with Sensitive Data], [Total Documents], 0) * 100
```

**Create Risk Level Column**:

In Power Query Editor or as calculated column:

```DAX
Risk Level = 
SWITCH(TRUE(),
    'Discovery Data'[SITType] IN {"Credit Card Number", "U.S. Social Security Number", "U.S. Bank Account Number"}, "High",
    'Discovery Data'[SITType] IN {"U.S. Driver's License Number", "U.S. Passport Number"}, "Medium",
    "Low"
)
```

### Step 4: Build Discovery Overview Dashboard

**Page Layout**: Create first dashboard page named "Discovery Overview".

**Add KPI Cards** (Top Row):

- **Card 1**: Total Documents (use `Total Documents` measure)
- **Card 2**: Documents with Sensitive Data
- **Card 3**: Unique SIT Types (`DISTINCTCOUNT('Discovery Data'[SITType])`)
- **Card 4**: Average Confidence

**Add SIT Distribution Chart**:

- **Visual Type**: Clustered Bar Chart
- **Axis**: SITType
- **Values**: COUNT of FileName
- **Sort**: Descending by count
- **Title**: "SIT Types Detected"

**Add Confidence Level Pie Chart**:

- **Visual Type**: Donut Chart
- **Legend**: Create confidence buckets (High: 90-100%, Medium: 75-89%, Low: <75%)
- **Values**: COUNT of FileName
- **Title**: "Confidence Level Distribution"

**Add Site/Library Coverage Table**:

- **Visual Type**: Table or Matrix
- **Rows**: Site, Library (if available in CSV)
- **Values**: COUNT of FileName, `High Risk Documents`
- **Title**: "Discovery Coverage by Location"

### Step 5: Build Compliance Posture Dashboard

**Page Layout**: Create second dashboard page named "Compliance Posture".

**Add Compliance Score Card**:

- **Visual Type**: Card with background color
- **Value**: `Compliance Score` measure
- **Format**: Conditional formatting (Red <70%, Yellow 70-85%, Green >85%)
- **Title**: "Overall Compliance Score"

**Add Risk Heat Map**:

- **Visual Type**: Matrix with conditional formatting
- **Rows**: Site or Library
- **Columns**: Risk Level (High, Medium, Low)
- **Values**: COUNT of documents
- **Conditional Formatting**: Color scale (Red = High count, Green = Low count)
- **Title**: "Risk Distribution by Location"

**Add Top 10 Risk Documents Table**:

- **Visual Type**: Table
- **Columns**: FileName, SITType, Instances, Confidence, Modified
- **Filter**: Top 10 by Instances (descending)
- **Conditional Formatting**: Highlight high instance counts
- **Title**: "Top 10 High-Risk Documents"

**Add Remediation Priority Matrix**:

- **Visual Type**: Scatter Chart
- **X-Axis**: Instances (number of SIT occurrences)
- **Y-Axis**: Confidence level
- **Details**: FileName
- **Size**: FileSize (if available)
- **Title**: "Remediation Priority (High Instances + High Confidence = Priority)"

### Step 6: Build Trend Analysis Dashboard (Optional)

**Requirements**: Multiple discovery reports from different dates.

**Page Layout**: Create third dashboard page named "Trend Analysis".

**Add Discovery Timeline**:

- **Visual Type**: Line Chart
- **X-Axis**: Modified date (group by week or month)
- **Y-Axis**: COUNT of documents
- **Legend**: SIT Type
- **Title**: "Sensitive Data Discovery Over Time"

**Add Month-over-Month Comparison**:

- **Visual Type**: Clustered Column Chart
- **X-Axis**: Month
- **Y-Axis**: COUNT of documents
- **Legend**: Risk Level
- **Title**: "Risk Level Trends"

**Add New Detections Table**:

- **Visual Type**: Table
- **Columns**: FileName, SITType, Modified
- **Filter**: Modified date within last 30 days
- **Sort**: Modified descending
- **Title**: "Recently Detected Sensitive Data"

### Step 7: Create Executive Summary Dashboard

**Page Layout**: Create fourth dashboard page named "Executive Summary".

**Design for Leadership**:

- **Minimal text, maximum visual impact**
- **Large KPI cards with trend indicators**
- **Simple color coding (Red/Yellow/Green)**
- **High-level insights only**

**Add Executive KPI Cards** (Large Format):

- **Card 1**: Compliance Score with trend arrow
- **Card 2**: High Risk Documents count
- **Card 3**: Total Sensitive Data Instances
- **Card 4**: Coverage Percentage

**Add Executive Summary Visual**:

- **Visual Type**: Stacked Bar Chart
- **Axis**: Site or Department
- **Values**: Documents by Risk Level (stacked)
- **Colors**: Red (High), Yellow (Medium), Green (Low)
- **Title**: "Risk Distribution Across Organization"

**Add Strategic Recommendations Box**:

- **Visual Type**: Text Box or Table
- **Content**: Top 3-5 recommendations based on discovery data:
  - "Prioritize remediation for HR site (250 high-risk documents)"
  - "Implement DLP policies for Financial site (40% coverage gap)"
  - "Review classification rules for Mixed content (Low confidence)"

## 📊 Expected Dashboard Metrics

### Discovery Overview Metrics

| Metric | Expected Range | Data Source |
|--------|----------------|-------------|
| **Total Documents Scanned** | 800-1,200 | Lab 05 CSV |
| **Documents with Sensitive Data** | 500-800 (60-70%) | Lab 05 CSV |
| **Unique SIT Types** | 6-8 types | Lab 05 CSV |
| **Average Confidence** | 85-92% | Lab 05 CSV |
| **High Risk Documents** | 150-250 (15-20%) | Calculated |

### SIT Distribution

| SIT Type | Expected Count | Percentage |
|----------|----------------|------------|
| **Credit Card Number** | 180-220 | 22-27% |
| **U.S. Social Security Number** | 140-180 | 17-22% |
| **U.S. Bank Account Number** | 100-140 | 12-17% |
| **Phone Number** | 80-120 | 10-15% |
| **U.S. Driver's License** | 60-100 | 7-12% |
| **ABA Routing Number** | 50-90 | 6-11% |
| **Other SIT Types** | 40-80 | 5-10% |

### Compliance Posture

| Site/Library | Total Docs | High Risk | Compliance Score |
|--------------|------------|-----------|------------------|
| **HR Documents** | 250-300 | 75-100 | 90-95% |
| **Finance Reports** | 200-250 | 60-80 | 85-90% |
| **Legal Contracts** | 150-200 | 40-60 | 80-85% |
| **General Documents** | 200-450 | 30-50 | 65-75% |

## 🎨 Dashboard Design Best Practices

### Visual Design

- **Consistent Color Scheme**: Use organizational colors or standard compliance colors (Red/Yellow/Green)
- **Clear Labels**: Every visual should have descriptive title and axis labels
- **White Space**: Don't overcrowd dashboards - less is more for executive views
- **Font Hierarchy**: Larger fonts for KPIs, smaller for details

### Interactivity

- **Cross-Filtering**: Click on any visual to filter related visuals on the page
- **Drill-Down**: Enable drill-through for detailed document analysis
- **Slicers**: Add date range, site, or SIT type slicers for filtering
- **Tooltips**: Customize tooltips to show additional context

### Performance

- **Limit Data Volume**: If dataset >100,000 rows, consider aggregating or filtering
- **Optimize Measures**: Use efficient DAX formulas to avoid slow calculations
- **Reduce Visuals**: Keep 5-8 visuals per page maximum
- **Test Performance**: Check refresh time and responsiveness

### Accessibility

- **Color Blind Friendly**: Use patterns or shapes in addition to colors
- **Alt Text**: Add alternative text descriptions for screen readers
- **High Contrast**: Ensure sufficient contrast between text and backgrounds
- **Keyboard Navigation**: Test navigation with keyboard only

## 📤 Publishing and Sharing

### Export Options

**PDF Export** (for offline sharing):

- Go to **File** → **Export** → **Export to PDF**.
- Select pages to include.
- Choose resolution (High Quality recommended).
- Save PDF to reports directory.

**PowerPoint Export** (for presentations):

- Go to **File** → **Export** → **Export to PowerPoint**.
- Each dashboard page becomes a PowerPoint slide.
- Edit in PowerPoint to add speaker notes or additional context.

**Publish to Power BI Service** (requires license):

- Click **Publish** button in Power BI Desktop.
- Sign in with Microsoft 365 account.
- Select workspace (My Workspace or shared workspace).
- View published dashboard at app.powerbi.com.
- Share dashboard link with stakeholders.

### Scheduled Refresh (Power BI Service)

If you have Power BI Pro license:

- Set up gateway for on-premises data sources.
- Configure scheduled refresh for automatic data updates.
- Set refresh frequency (daily, weekly).
- Enable email notifications on refresh failures.

### Distribution Strategy

**For Compliance Auditors**:
- Export PDF of Compliance Posture dashboard
- Include timestamp and data source details
- Provide supporting CSV files

**For Executive Leadership**:
- Export PowerPoint of Executive Summary
- Add executive summary slide with key takeaways
- Schedule monthly updates

**For Data Governance Team**:
- Provide .pbix file for interactive exploration
- Document data sources and refresh procedures
- Share update schedule

## ⚠️ Troubleshooting

### Issue 1: CSV Import Fails

**Symptoms**:
- Error loading CSV file
- Encoding issues with special characters
- Column headers not recognized

**Resolution**:
1. Open CSV in Notepad to verify UTF-8 encoding
2. Check for special characters in column names
3. Ensure first row contains headers
4. Try importing as Text/CSV with manual delimiter configuration
5. Use Transform Data to fix column names if needed

### Issue 2: Measures Calculate Incorrectly

**Symptoms**:
- Totals don't match expected values
- Percentages over 100% or negative
- Blank values in calculated columns

**Resolution**:
1. Verify measure DAX syntax is correct
2. Check for blank or null values in source data
3. Use DIVIDE function instead of / to handle divide-by-zero
4. Test measures with simple data subset
5. Use DAX Studio for advanced debugging

### Issue 3: Dashboard Performance Slow

**Symptoms**:
- Visuals take >5 seconds to render
- Clicking filters causes long delays
- Report refresh timeout errors

**Resolution**:
1. Reduce number of visuals per page (max 8)
2. Optimize DAX measures (avoid complex calculations)
3. Import only necessary columns from CSV
4. Use aggregated data instead of row-level detail where possible
5. Disable auto-refresh on slicers during design

### Issue 4: Visuals Don't Show Expected Data

**Symptoms**:
- Charts are blank or show "No data"
- Filters seem to exclude all data
- Incorrect data displayed

**Resolution**:
1. Check slicer and filter settings on visual
2. Verify column data types are correct
3. Check for hidden filters on page or report level
4. Validate relationships between tables if using multiple datasets
5. Review data transformations in Power Query

### Issue 5: Colors Don't Match Organization Branding

**Symptoms**:
- Default Power BI colors used
- Inconsistent color scheme across dashboards
- Colors not suitable for color-blind users

**Resolution**:
1. Go to **View** → **Themes** → **Customize Current Theme**
2. Set custom color palette with organization colors
3. Apply theme across all dashboard pages
4. Use conditional formatting for risk indicators (Red/Yellow/Green)
5. Test with color blindness simulator

### Issue 6: Cannot Export to PDF/PowerPoint

**Symptoms**:
- Export menu grayed out
- Export fails with error
- Exported file is corrupted

**Resolution**:
1. Verify Power BI Desktop is up to date
2. Check that all visuals have finished loading
3. Try exporting individual pages instead of full report
4. Reduce visual complexity if export times out
5. Save .pbix file and retry export

## 💡 Best Practices

### Dashboard Development

- **Start Simple**: Begin with basic KPIs and bar charts, add complexity gradually
- **Iterative Design**: Create draft, gather feedback, refine repeatedly
- **User Testing**: Have stakeholders test dashboards before final publication
- **Version Control**: Save dashboard versions with meaningful names (`Dashboard_v1.2_2025-11-17.pbix`)

### Data Refresh Strategy

- **Manual Refresh**: For lab environment, manually refresh when new Lab 05 data available
- **Scheduled Refresh**: For production, set up automated refresh daily or weekly
- **Data Validation**: Always validate data quality after refresh
- **Change Tracking**: Document when data sources or calculations change

### Stakeholder Communication

- **Dashboard Training**: Provide brief training on how to interpret dashboards
- **Documentation**: Include README or guide explaining metrics and calculations
- **Feedback Loop**: Collect feedback and track requested enhancements
- **Regular Updates**: Communicate when dashboards are updated or data refreshed

### Compliance and Governance

- **Data Privacy**: Ensure dashboards don't expose sensitive document content (file names only)
- **Access Control**: Restrict dashboard access to authorized users only
- **Audit Trail**: Document who has access and when dashboards are viewed
- **Data Retention**: Follow organizational policies for dashboard data retention

## 🎯 Expected Results

After completing this lab, you should have:

- ✅ **Power BI Desktop Installed**: Free Power BI tool ready for dashboard creation
- ✅ **Discovery Data Imported**: Lab 05 CSV data loaded into Power BI datasets
- ✅ **Data Model Created**: Calculated measures and columns for analysis
- ✅ **4 Dashboard Pages**: Discovery Overview, Compliance Posture, Trend Analysis (optional), Executive Summary
- ✅ **10-15 Visualizations**: Charts, tables, cards showing sensitive data insights
- ✅ **Exportable Reports**: PDF and PowerPoint versions for offline sharing

### Success Indicators

```
Discovery Overview Dashboard:  5-7 visuals showing SIT distribution and coverage
Compliance Posture Dashboard:  5-7 visuals with risk analysis and priorities
Executive Summary Dashboard:   3-5 high-level visuals suitable for leadership
Export Functionality:          PDF and PowerPoint exports working correctly
Performance:                   Dashboard loads in <5 seconds, filters respond instantly
Data Accuracy:                 Metrics match Lab 05 source data within 1%
```

### Sample Dashboard Screenshots

While this lab doesn't include pre-built screenshots, your completed dashboards should resemble:

**Discovery Overview**:
- Top row: 4 KPI cards with large numbers
- Middle row: Horizontal bar chart (SIT types), Donut chart (confidence levels)
- Bottom row: Table (site/library coverage)

**Compliance Posture**:
- Top left: Large compliance score card with conditional formatting
- Top right: Risk heat map matrix
- Bottom left: Top 10 risk documents table
- Bottom right: Scatter chart (remediation priority)

**Executive Summary**:
- Top row: 4 large KPI cards with trend indicators
- Middle: Wide stacked bar chart showing risk distribution
- Bottom: Text box with 3-5 strategic recommendations

## 📚 Additional Resources

### Power BI Learning

- [Power BI Desktop Documentation](https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-what-is-desktop)
- [DAX Function Reference](https://learn.microsoft.com/en-us/dax/)
- [Power BI Visualization Best Practices](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-best-practices)
- [Power BI Community](https://community.powerbi.com/)

### Dashboard Design

- [Dashboard Design Patterns](https://www.storytellingwithdata.com/)
- [Color Blindness Simulator](https://www.color-blindness.com/coblis-color-blindness-simulator/)
- [Power BI Themes Gallery](https://community.powerbi.com/t5/Themes-Gallery/bd-p/ThemesGallery)

### Compliance Reporting

- [Compliance Dashboard Examples](https://learn.microsoft.com/en-us/purview/compliance-manager-dashboards)
- [GDPR Reporting Requirements](https://gdpr.eu/reporting-requirements/)
- [Data Governance Dashboard Templates](https://powerbi.microsoft.com/en-us/data-governance-dashboard/)

## ⏭️ Next Steps

After completing this lab:

1. **Review Lab 07**: Cleanup and Reset lab for environment decommissioning
2. **Share Dashboards**: Distribute PDF/PowerPoint exports to stakeholders
3. **Schedule Refresh**: Set up regular dashboard updates as new Lab 05 data arrives
4. **Gather Feedback**: Collect stakeholder input for dashboard improvements
5. **Expand Analysis**: Add custom visuals or advanced analytics as needed

---

## 🤖 AI-Assisted Content Generation

This comprehensive Power BI visualization guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Power BI best practices, compliance reporting standards, and enterprise-grade dashboard design methodologies for sensitive data discovery visualization.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Power BI visualization requirements while maintaining technical accuracy and reflecting Microsoft Power BI best practices for compliance dashboard creation and data governance reporting scenarios.*
