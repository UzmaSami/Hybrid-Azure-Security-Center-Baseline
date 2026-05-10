
# ============================================
# Script: connect-arc-servers.ps1
# Purpose: Connect Arc enabled servers to
#          Log Analytics for monitoring
# Author: Uzma Shabbir
# Date: April 2026
# ============================================

Connect-AzAccount

# Variables
$resourceGroup = "rg-UzmaSami-security-baseline"
$workspaceName = "law-UzmaSami-hybrid-security-2026"
$location = "uksouth"

# Get workspace details
$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $resourceGroup `
    -Name $workspaceName

$workspaceId = $workspace.CustomerId
$workspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey `
    -ResourceGroupName $resourceGroup `
    -Name $workspaceName).PrimarySharedKey

Write-Host "Workspace ID retrieved" -ForegroundColor Green

# Connect Arc servers to workspace
# Run this on your Domain Controller
$mmaInstallScript = @"
`$workspaceId = '$workspaceId'
`$workspaceKey = '$workspaceKey'

# Download MMA Agent
`$url = 'https://go.microsoft.com/fwlink/?LinkId=828603'
$installer = "$env:TEMP\MMASetup.exe"
Invoke-WebRequest -Uri `$url -OutFile `$installer

# Install MMA Agent
Start-Process -FilePath `$installer -ArgumentList `
    '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 ' + ``
    "OPINSIGHTS_WORKSPACE_ID=$workspaceId " + `
    "OPINSIGHTS_WORKSPACE_KEY=$workspaceKey" + `
    ' AcceptEndUserLicenseAgreement=1"' -Wait

Write-Host 'MMA Agent installed and connected!' -ForegroundColor Green
"@

# Save script for DC execution
$mmaInstallScript | Out-File ".\install-mma-on-dc.ps1"
Write-Host "✅ Run install-mma-on-dc.ps1 on your Domain Controller" -ForegroundColor Yellow
Write-Host "✅ Arc servers connection script ready!" -ForegroundColor Green
