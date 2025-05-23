$vmsComCampoVazio = Get-VM | Where-Object {
    $_.PowerState -eq "PoweredOff" -and $_.Name -notmatch "TEMPLATE|vCLS"
}

if ($vmsComCampoVazio.Count -eq 0) {
    Write-Output ""
    Write-Output "Nenhuma VM desligada encontrada"
    Write-Output ""
} else {
    $vmsComCampoVazio
}
