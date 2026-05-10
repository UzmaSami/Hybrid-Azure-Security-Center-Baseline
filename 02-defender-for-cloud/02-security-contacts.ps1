# ============================================
# Script: security-contacts.ps1
# Purpose: Configure security alert contacts
# Author: Uzma Shabbir
# Date: April 2026
# ============================================

Connect-AzAccount

# Set security contact details correctly
# Set security contact details correctly
Set-AzSecurityContact `
    -Name "default" `
    -Email "uzma.khanXXXX@gmail.com" `
    -AlertAdmin `
    -NotifyOnAlert

Write-Host "✅ Security contacts configured!" -ForegroundColor Green

# Verify security contact
Get-AzSecurityContact | Format-List

