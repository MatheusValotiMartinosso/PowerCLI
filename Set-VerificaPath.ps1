$filteredHosts = Get-VMHost | Where-Object { $_.Name -like "vmw-0*" }
$hostsComErro = @()

foreach ($vmhost in $filteredHosts) {
    $invalidPaths = Get-ScsiLun -VmHost $vmhost -LunType disk | Get-ScsiLunPath |
        Where-Object { $_.State -notin @("active", "active(i/o)", "standby") }

    if ($invalidPaths) {
        Write-Host "$($vmhost.Name): ERRO" -ForegroundColor Red
        $hostsComErro += $vmhost.Name
    } else {
        Write-Host "$($vmhost.Name): OK" -ForegroundColor Green
    }
}

if ($hostsComErro.Count -gt 0) {
    Write-Host "`nHosts com paths em estado anormal:" -ForegroundColor Yellow
    $hostsComErro
} else {
    Write-Host "`nTodos os hosts estão com os paths em estado normal." -ForegroundColor Cyan
}
