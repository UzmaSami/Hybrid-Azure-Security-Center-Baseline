
# ============================================
# Script: assign-security-baseline.ps1
# ============================================

Connect-AzAccount
$subscriptionId = (Get-AzContext).Subscription.Id
$targetResourceGroup = "rg-UzmaSami-security-baseline" 
$scope = "/subscriptions/$subscriptionId/resourceGroups/$targetResourceGroup"

Write-Host "🚀 Assigning Security Baselines (Fast Mode)..." -ForegroundColor Cyan

# 1. Direct Assignment of Microsoft Cloud Security Benchmark
# This ID is universal for all Azure accounts
$mcsbDefinitionId = $env:AZ_POLICY_ID

try {
    Write-Host "   -> Assigning Cloud Security Benchmark..." -ForegroundColor Yellow
    New-AzPolicyAssignment `
        -Name "mcsb-assignment" `
        -DisplayName "Microsoft Cloud Security Benchmark" `
        -PolicySetDefinition $mcsbDefinitionId `
        -Scope $scope `
        -Location "uksouth" `
        -IdentityType "SystemAssigned"
    Write-Host "   ✅ MCSB assigned successfully!" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️ MCSB might already be assigned or check permissions." -ForegroundColor Gray
}

# 2. Final List
Write-Host "`n=== Current Assignments ===" -ForegroundColor Cyan
Get-AzPolicyAssignment -Scope $scope | Select-Object Name, @{N="DisplayName";E={$_.Properties.DisplayName}} | Format-Table -AutoSize
