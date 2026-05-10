# ============================================
# Script: enable-defender-plans.ps1
# Purpose: Enable Microsoft Defender plans
# Author: Uzma Shabbir
# Date: April 2026
# ============================================

# Connect to Azure
Connect-AzAccount

# Get your subscription ID
$subscriptionId = (Get-AzContext).Subscription.Id
Write-Host "Working on Subscription: $subscriptionId" -ForegroundColor Cyan

# Enable Defender for Servers
Set-AzSecurityPricing -Name "VirtualMachines" -PricingTier "Standard"
Write-Host "✅ Defender for Servers — ENABLED" -ForegroundColor Green

# Enable Defender for DNS
Set-AzSecurityPricing -Name "Dns" -PricingTier "Standard"
Write-Host "✅ Defender for DNS — ENABLED" -ForegroundColor Green

# Enable Defender for Resource Manager
Set-AzSecurityPricing -Name "Arm" -PricingTier "Standard"
Write-Host "✅ Defender for ARM — ENABLED" -ForegroundColor Green

# Verify all Defender plans status
Write-Host "`n=== Current Defender Plans Status ===" -ForegroundColor Cyan
Get-AzSecurityPricing | Select-Object Name, PricingTier | Format-Table

Write-Host "Defender plans configured successfully!" -ForegroundColor Green
