# ============================================
# Script: Arc-tags-policy.ps1
# Purpose: Apply security tags to Arc servers
# Author: Uzma Shabbir
# Date: April 2026
# ============================================

# Connect to Azure
Connect-AzAccount

# Variables — change these to match yours
$resourceGroup = "SecureStorageLabUzma2"
$serverName = "UzmaSamiDC01"

# Apply security tags to Arc server
$tags = @{
    "Environment"    = "Hybrid-Production"
    "SecurityLevel"  = "High"
    "Compliance"     = "CIS-Baseline"
    "ManagedBy"      = "AzureArc"
    "Owner"          = "SecurityTeam"
    "CostCenter"     = "IT-Security"
}

# Get the Arc server resource
$arcServer = Get-AzResource `
    -ResourceGroupName $resourceGroup `
    -ResourceType "Microsoft.HybridCompute/machines" `
    -Name $serverName

# Apply tags
Update-AzTag `
    -ResourceId $arcServer.ResourceId `
    -Tag $tags `
    -Operation Merge

Write-Host "Tags applied successfully!" -ForegroundColor Green
Write-Host "Tagged server: $serverName" -ForegroundColor Cyan

# Verify tags
Get-AzResource `
    -ResourceId $arcServer.ResourceId | 
    Select-Object Name, Tags

