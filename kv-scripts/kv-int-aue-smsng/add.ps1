# Connect-AzAccount -tenant c5360f6f-0bb5-46b9-a278-75619bfd2434
$keyVault = "kv-int-aue-smsng"
$subscriptionID = "65de260e-4df4-4b57-9aa6-726e772d3246"
$keysFile = "./keys.txt"
$valuesFile = "./values.txt"
[bool] $isTest = $true # Simulation: $false or $true

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
        # Check current version of KV secret and update if it different:
        $curretSecret = $(Get-AzKeyVaultSecret -VaultName $keyVault -Name $key -AsPlainText)
        if ($curretSecret -ne $value) {
            if (![string]::IsNullOrEmpty($value)) {
                $secure = ConvertTo-SecureString -String $value -AsPlainText -Force
                if (!$isTest){
                    Set-AzKeyVaultSecret -VaultName $keyVault -Name $key -SecretValue $secure
                }
                Write-Host "Updated: variable $key"
            } else {
                Write-Host "Skipped: Variable $key is empty or null."            
            }
        }
        else {
            Write-Host "Skipped: variable $key has the same value"
        }
    }
}

# Checking the results
Write-Host "Variables created"