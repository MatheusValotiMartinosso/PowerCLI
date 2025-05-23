$snapshotsAntigos = Get-VM | Get-Snapshot | Where-Object {
    $_.Created -lt (Get-Date).AddDays(-1)
} | Select-Object VM, Name, Created, Description

if ($snapshotsAntigos.Count -eq 0) {
    Write-Output "`nNenhuma VM com snapshot antigo encontrada.`n"
} else {
    $snapshotsAntigos
}
