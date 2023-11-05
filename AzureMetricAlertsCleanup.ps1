# List metric alerts
$alerts = Get-AzMetricAlertRuleV2
Write-Host "Number of ALL Alerts Found: $($alerts.Count)"

# Filter alerts to only UAT RGs
$filteredAlerts = $alerts | Where-Object { $_.ResourceGroup -like "*uat*" -and $_.Scopes -like "*-la*" }
Write-Host "Number of Metric Alerts Found: $($filteredAlerts.Count)"

$allResources = Get-AzResource
$orphanedAlerts = @()

# Loop through the alerts and remove orphaned ones
foreach ($fa in $filteredAlerts)
{
    $targetResourceName = ($fa.Scopes -split '/')[-1]  
    $resource = $allResources | Where-Object { $_.Name -eq $targetResourceName }

    if (-not [string]::IsNullOrWhiteSpace($fa.Scopes)) 
    {        
        if ($null -eq $resource) 
        {          
            Remove-AzMetricAlertRuleV2 -Name $fa.Name -ResourceGroupName $fa.ResourceGroup
            Write-Host "$($fa.Name)"
            $orphanedAlerts += $fa.Name
        } 
        else 
        {

        }    
    }
}
Write-Host "Total removed orphaned alerts: $($orphanedAlerts.Count)"
