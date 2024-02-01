# Connect-AzAccount -tenant c5360f6f-0bb5-46b9-a278-75619bfd2434
$keyVault = "kv-int-uks-busby"
$subscriptionID = "3e666fda-71e2-4986-a467-29053c2daea3"
$keysFile = "./keys.txt"
$valuesFile = "./values.txt"
[bool] $isTest = $false # Simulation: $false or $true

Select-AzSubscription -SubscriptionId $subscriptionID

# Loading file contents into arrays
$keys = @(Get-Content -Path $keysFile)
$values = @(Get-Content -Path $valuesFile)

# Write-Host $keys.Count
# Write-Host $values.Count

# Checking that the number of keys and values match
if ($keys.Count -ne $values.Count) {
    Write-Host "Error: Number of keys and values do not match"
    exit
}

# Creating variables based on file content
for ($i = 0; $i -lt $keys.Count; $i++) {
    $key = $keys[$i]
    $value = $values[$i]

    if (![string]::IsNullOrEmpty($key)) {
        if (![string]::IsNullOrEmpty($value)) {
            if (!$isTest){
                Remove-AzKeyVaultSecret -VaultName $keyVault -Name $key -PassThru -InRemovedState
            }
            Write-Host "Removed: variable $key"
        } else {
            Write-Host "Skipped: Variable $key is empty or null."            
        }
    }
}

# Checking the results
Write-Host "Variables have been removed."