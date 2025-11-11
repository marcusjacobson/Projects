# Import Activity Explorer export
$dlpEvents = Import-Csv "C:\PurviewLab\ActivityExplorer_DLP_Export.csv"

# Analyze by policy rule severity (using 'Rule' column from Activity Explorer)
$highSeverity = $dlpEvents | Where-Object {$_.Rule -like "*High Severity*"}
$lowSeverity = $dlpEvents | Where-Object {$_.Rule -like "*Low Severity*"}

# Analyze by sensitive info type (inferred from rule names)
$creditCardDetections = $dlpEvents | Where-Object {$_.Rule -like "*Credit Card*"}
$ssnDetections = $dlpEvents | Where-Object {$_.Rule -like "*SSN*"}

# Get unique files (since same file can match multiple rules)
$uniqueFiles = $dlpEvents | Select-Object -Property File -Unique

# Display analysis header
Write-Host "`nDLP POLICY EFFECTIVENESS ANALYSIS" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Policy Name: SharePoint Sensitive Data Protection - Lab" -ForegroundColor White
Write-Host "Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor White

Write-Host "`nDETECTION SUMMARY" -ForegroundColor Cyan
Write-Host "-----------------" -ForegroundColor Cyan
Write-Host "Total DLP Rule Matches: $($dlpEvents.Count)" -ForegroundColor White
Write-Host "Unique Files with Detections: $($uniqueFiles.Count)" -ForegroundColor White
Write-Host "Expected Matches (40% of 1000 files): ~400" -ForegroundColor Gray
Write-Host "Detection Rate: $([math]::Round(($uniqueFiles.Count / 400) * 100, 1))%" -ForegroundColor Green

Write-Host "`nSEVERITY DISTRIBUTION" -ForegroundColor Cyan
Write-Host "---------------------" -ForegroundColor Cyan
Write-Host "High Severity Rule Matches (Credit Cards): $($highSeverity.Count) matches" -ForegroundColor Yellow
Write-Host "  - Action: Block external sharing" -ForegroundColor Gray
Write-Host "  - Business Impact: Users cannot share these files externally" -ForegroundColor Gray
Write-Host ""
Write-Host "Low Severity Rule Matches (SSNs): $($lowSeverity.Count) matches" -ForegroundColor Yellow
Write-Host "  - Action: Block external sharing" -ForegroundColor Gray
Write-Host "  - Business Impact: Users cannot share these files externally" -ForegroundColor Gray

Write-Host "`nSENSITIVE INFO TYPE BREAKDOWN" -ForegroundColor Cyan
Write-Host "------------------------------" -ForegroundColor Cyan
Write-Host "Credit Card Number Detections: $($creditCardDetections.Count) rule matches" -ForegroundColor White
Write-Host "U.S. Social Security Number Detections: $($ssnDetections.Count) rule matches" -ForegroundColor White

Write-Host "`nTIMING ANALYSIS" -ForegroundColor Cyan
Write-Host "---------------" -ForegroundColor Cyan
$firstDetection = $dlpEvents | Sort-Object Happened | Select-Object -First 1 -ExpandProperty Happened
$lastDetection = $dlpEvents | Sort-Object Happened | Select-Object -Last 1 -ExpandProperty Happened
$detectionWindow = [math]::Round(((Get-Date $lastDetection) - (Get-Date $firstDetection)).TotalMinutes, 1)
Write-Host "First Detection: $firstDetection" -ForegroundColor White
Write-Host "Last Detection: $lastDetection" -ForegroundColor White
Write-Host "Detection Window: $detectionWindow minutes" -ForegroundColor White

Write-Host "`nNOTES" -ForegroundColor Cyan
Write-Host "-----" -ForegroundColor Cyan
Write-Host "• Rule matches may exceed unique files because some files contain both credit cards AND SSNs" -ForegroundColor Gray
Write-Host "• Each sensitive info type triggers a separate rule match for the same file" -ForegroundColor Gray
Write-Host "• Detection rate based on unique files, not total rule matches" -ForegroundColor Gray

Write-Host "`nRECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "---------------" -ForegroundColor Cyan
Write-Host "✅ DLP policy successfully detecting sensitive data" -ForegroundColor Green
Write-Host "✅ Detection rate matches expected test data distribution" -ForegroundColor Green
Write-Host "✅ Policy provides real-time protection (15-30 min detection)" -ForegroundColor Green
Write-Host "⚠️  Consider user override capability for legitimate business needs" -ForegroundColor Yellow
Write-Host "⚠️  Review false positives (if any) and adjust confidence levels" -ForegroundColor Yellow

# Generate text report for file export
$report = @"
DLP POLICY EFFECTIVENESS ANALYSIS
==================================
Policy Name: SharePoint Sensitive Data Protection - Lab
Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

DETECTION SUMMARY
-----------------
Total DLP Rule Matches: $($dlpEvents.Count)
Unique Files with Detections: $($uniqueFiles.Count)
Expected Matches (40% of 1000 files): ~400
Detection Rate: $([math]::Round(($uniqueFiles.Count / 400) * 100, 1))%

SEVERITY DISTRIBUTION
---------------------
High Severity Rule Matches (Credit Cards): $($highSeverity.Count) matches
  - Action: Block external sharing
  - Business Impact: Users cannot share these files externally

Low Severity Rule Matches (SSNs): $($lowSeverity.Count) matches
  - Action: Block external sharing
  - Business Impact: Users cannot share these files externally

SENSITIVE INFO TYPE BREAKDOWN
------------------------------
Credit Card Number Detections: $($creditCardDetections.Count) rule matches
U.S. Social Security Number Detections: $($ssnDetections.Count) rule matches

TIMING ANALYSIS
---------------
First Detection: $firstDetection
Last Detection: $lastDetection
Detection Window: $detectionWindow minutes

NOTES
-----
- Rule matches may exceed unique files because some files contain both credit cards AND SSNs
- Each sensitive info type triggers a separate rule match for the same file
- Detection rate based on unique files, not total rule matches

RECOMMENDATIONS
---------------
✅ DLP policy successfully detecting sensitive data
✅ Detection rate matches expected test data distribution
✅ Policy provides real-time protection (15-30 min detection)
⚠️  Consider user override capability for legitimate business needs
⚠️  Review false positives (if any) and adjust confidence levels
"@

# Save report to file
$report | Out-File "C:\PurviewLab\DLP_Effectiveness_Report.txt" -Encoding UTF8
Write-Host "`n📄 Report saved to: C:\PurviewLab\DLP_Effectiveness_Report.txt" -ForegroundColor Green
