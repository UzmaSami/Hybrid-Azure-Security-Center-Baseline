
# ============================================
# Script: assign-windows-baseline.ps1
# ============================================

Connect-AzAccount
$subscriptionId = (Get-AzContext).Subscription.Id
$targetResourceGroup = "rg-UzmaSami-security-baseline" 
$scope = "/subscriptions/$subscriptionId/resourceGroups/$targetResourceGroup"

Write-Host "🚀 Searching for the latest Windows Security Baseline..." -ForegroundColor Cyan

# 1. Search for the definition by name (Smarter Search)
$winBaseline = Get-AzPolicySetDefinition | Where-Object { 
    $_.Properties.DisplayName -like "*Windows machines should meet requirements of the Azure compute security baseline*" -or
    $_.Properties.DisplayName -like "*Windows Server Security Baseline*"
} | Select-Object -First 1

if ($winBaseline) {
    Write-Host "   -> Found Baseline: $($winBaseline.Properties.DisplayName)" -ForegroundColor Yellow
    
    try {
        New-AzPolicyAssignment `
            -Name "win-baseline-assignment" `
            -DisplayName "Windows Server Security Baseline" `
            -PolicySetDefinition $winBaseline `
            -Scope $scope `
            -Location "uksouth" `
            -IdentityType "SystemAssigned"
            
        Write-Host "   ✅ Assignment COMPLETE!" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Assignment Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Could not find the Windows Baseline in the Azure library." -ForegroundColor Red
}

# 2. Final Verification Table
Write-Host "`n=== CURRENT ASSIGNMENTS IN $targetResourceGroup ===" -ForegroundColor Cyan
Get-AzPolicyAssignment -Scope $scope | Select-Object Name, @{N="DisplayName";E={$_.Properties.DisplayName}} | Format-Table -AutoSize
