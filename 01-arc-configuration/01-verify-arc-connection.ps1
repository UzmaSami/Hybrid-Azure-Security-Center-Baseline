# ============================================
# Script: verify-arc-connection.ps1
# Purpose: Verify Azure Arc agent health
# Author: Uzma Shabbir
# Date: April 2026
# ============================================

Write-Host "=== Azure Arc Agent Health Check ===" -ForegroundColor Cyan

# Check agent status
$agentStatus = azcmagent show
Write-Host $agentStatus

# Check agent version
$version = azcmagent version
Write-Host "Agent Version: $version" -ForegroundColor Green

# Check connected Azure details
Write-Host "`n=== Connected Azure Details ===" -ForegroundColor Cyan
azcmagent show --json | ConvertFrom-Json | Select-Object `
    resourceName, `
    resourceGroup, `
    subscriptionId, `
    location, `
    status

