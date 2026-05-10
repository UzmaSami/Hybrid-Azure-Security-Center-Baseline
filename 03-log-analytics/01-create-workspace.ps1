# ============================================
# Script: create-workspace.ps1
# Purpose: Create Log Analytics Workspace
#          for hybrid security monitoring
# Author: Uzma Shabbir
# Date: April 2026
# ============================================

Connect-AzAccount

# Variables — customize these
$resourceGroup = "rg-UzmaSami-security-baseline"
$location = "uksouth"  # Change to your nearest region
$workspaceName = "law-UzmaSami-hybrid-security-2026"

# Create Resource Group if not exists
New-AzResourceGroup `
    -Name $resourceGroup `
    -Location $location `
    -ErrorAction SilentlyContinue

Write-Host "✅ Resource Group ready" -ForegroundColor Green

# Create Log Analytics Workspace
$workspace = New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $resourceGroup `
    -Name $workspaceName `
    -Location $location `
    -Sku "PerGB2018" `
    -RetentionInDays 90

Write-Host "✅ Log Analytics Workspace created!" -ForegroundColor Green
Write-Host "Workspace ID: $($workspace.CustomerId)" -ForegroundColor Cyan
Write-Host "Workspace Name: $($workspace.Name)" -ForegroundColor Cyan

# Enable security solutions on workspace
Set-AzOperationalInsightsIntelligencePack `
    -ResourceGroupName $resourceGroup `
    -WorkspaceName $workspaceName `
    -IntelligencePackName "Security" `
    -Enabled $true

Write-Host "✅ Security solution enabled on workspace!" -ForegroundColor Green

# Save workspace ID for later use
$workspace.CustomerId | 
    Out-File -FilePath ".\workspace-id.txt"

Write-Host "`nWorkspace setup complete!" -ForegroundColor Green

