# ============================================
# Script: compliance-report.ps1
# Purpose: Generate security compliance report
# ============================================

Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$reportDate = Get-Date -Format yyyy-MM-dd
$reportPath = "$HOME\Desktop\compliance-report-$reportDate.html" 

Write-Host "Generating Compliance Report..." -ForegroundColor Cyan

# 1. Get security assessments
$assessments = Get-AzSecurityAssessment

# 2. Categorize findings
$critical = $assessments | Where-Object { $_.Status.Code -eq "Unhealthy" -and $_.Metadata.Severity -eq "High" }
$medium   = $assessments | Where-Object { $_.Status.Code -eq "Unhealthy" -and $_.Metadata.Severity -eq "Medium" }
$healthy  = $assessments | Where-Object { $_.Status.Code -eq "Healthy" }

# 3. Pre-calculate counts (Fixes parser errors)
$critCount = if ($critical) { $critical.Count } else { 0 }
$medCount  = if ($medium) { $medium.Count } else { 0 }
$passCount = if ($healthy) { $healthy.Count } else { 0 }

# 4. Calculate scores
$totalControls = if ($null -ne $assessments) { $assessments.Count } else { 0 }
if ($totalControls -gt 0) {
    $complianceScore = [math]::Round(($passCount / $totalControls) * 100, 2)
} else {
    $complianceScore = 0
}

# 5. Generate HTML Report
$htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Hybrid Security Compliance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #0078d4; }
        h2 { color: #333; border-bottom: 2px solid #0078d4; }
        .score { font-size: 48px; font-weight: bold; color: #0078d4; }
        .critical { color: red; }
        .medium { color: orange; }
        .healthy { color: green; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background: #0078d4; color: white; padding: 10px; text-align: left; }
        td { padding: 8px; border: 1px solid #ddd; }
        tr:nth-child(even) { background: #f5f5f5; }
        .header-box { background: #f0f8ff; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class='header-box'>
        <h1>Azure Hybrid Security Baseline Report</h1>
        <p><strong>Environment:</strong> Hybrid (Azure Arc + Windows Server 2022)</p>
        <p><strong>Report Date:</strong> $reportDate</p>
        <p><strong>Subscription:</strong> $subscriptionId</p>
    </div>

    <h2>Overall Compliance Score</h2>
    <p class='score'>$complianceScore%</p>
    <p>$passCount of $totalControls controls passed</p>

    <h2>Critical Findings ($critCount)</h2>
    <table>
        <tr>
            <th>Control</th>
            <th>Resource</th>
            <th>Severity</th>
            <th>Status</th>
        </tr>
"@

if ($critical) {
    foreach ($finding in $critical) {
        $resName = $finding.ResourceDetails.Id.Split('/')[-1]
        $htmlReport += @"
        <tr>
            <td>$($finding.Metadata.DisplayName)</td>
            <td>$resName</td>
            <td class='critical'>HIGH</td>
            <td class='critical'>Unhealthy</td>
        </tr>
"@
    }
}

$htmlReport += @"
    </table>

    <h2>Medium Findings ($medCount)</h2>
    <table>
        <tr>
            <th>Control</th>
            <th>Resource</th>
            <th>Severity</th>
            <th>Status</th>
        </tr>
"@

if ($medium) {
    foreach ($finding in $medium) {
        $resName = $finding.ResourceDetails.Id.Split('/')[-1]
        $htmlReport += @"
        <tr>
            <td>$($finding.Metadata.DisplayName)</td>
            <td>$resName</td>
            <td class='medium'>MEDIUM</td>
            <td class='medium'>Needs Attention</td>
        </tr>
"@
    }
}

$htmlReport += @"
    </table>

    <h2>Passed Controls ($passCount)</h2>
    <p class='healthy'>$passCount controls are compliant</p>

    <h2>Recommendations</h2>
    <ol>
        <li>Remediate all Critical findings within 24 hours</li>
        <li>Address Medium findings within 7 days</li>
        <li>Schedule weekly compliance scans</li>
    </ol>

    <footer>
        <p><em>Report generated automatically by Azure Hybrid Security Baseline Script</em></p>
        <p><em>Generated $reportDate</em></p>
    </footer>
</body>
</html>
"@

# 6. Save and Finish
$htmlReport | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Compliance report generated successfully." -ForegroundColor Green
Write-Host "Report saved to $reportPath" -ForegroundColor Cyan
