# Generate-CustomSITTestDocuments.ps1
# Creates test documents with custom SIT patterns (Contoso Project Codes) for validation

# Connect to SharePoint
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/TestSite" -Interactive

# Create documents with custom SIT patterns
$testDocs = @(
    @{
        Name = "Finance_Project_Proposal.txt"
        Content = @"
FINANCE PROJECT PROPOSAL

Project Code: PROJ-2025-FIN-001
Project Name: Accounting System Modernization
Budget: `$250,000
Timeline: 6 months

This project will modernize our accounting infrastructure.
Contact: finance@contoso.com
"@
    },
    @{
        Name = "HR_Initiative_Overview.txt"
        Content = @"
HR DEPARTMENT INITIATIVE

Project ID: PROJ-2025-HR-015
Initiative: Employee Self-Service Portal
Project Manager: Sarah Johnson

Timeline and deliverables for this project are outlined below.
"@
    },
    @{
        Name = "IT_Infrastructure_Plan.txt"
        Content = @"
IT INFRASTRUCTURE PROJECT

Reference: PROJ-2024-IT-042
Description: Network upgrade initiative
Budget: `$500,000

This program will improve network performance.
"@
    },
    @{
        Name = "Mixed_Content_Report.txt"
        Content = @"
QUARTERLY REPORT

Multiple projects are underway:
- PROJ-2025-FIN-001 (Finance)
- PROJ-2025-FIN-002 (Audit)
- PROJ-2025-HR-015 (HR Portal)
- PROJ-2024-LEG-008 (Legal)

All project codes are tracking on schedule.
"@
    },
    @{
        Name = "Medium_Confidence_Test.txt"
        Content = @"
TECHNICAL DOCUMENT

Random reference: PROJ-2025-IT-123

No project-related keywords in this document, should trigger medium confidence only.
"@
    }
)

# Upload test documents
$testDocs | ForEach-Object {
    $fileName = $_.Name
    $content = $_.Content
    
    # Create local file
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    # Upload to SharePoint
    Add-PnPFile -Path $tempPath -Folder "Documents" | Out-Null
    
    # Cleanup
    Remove-Item -Path $tempPath -Force
    
    Write-Host "✅ Created: $fileName" -ForegroundColor Green
}

Write-Host "`n✅ All test documents created successfully" -ForegroundColor Green
Write-Host "`nExpected Files Created:" -ForegroundColor Cyan
Write-Host "   - 5 test documents with varying project code patterns" -ForegroundColor White
Write-Host "   - Mix of high confidence and medium confidence scenarios" -ForegroundColor White
Write-Host "   - Ready for SharePoint reindexing and Content Explorer validation" -ForegroundColor White
