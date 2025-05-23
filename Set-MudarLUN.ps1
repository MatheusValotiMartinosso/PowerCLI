write-host "IMPORTANTE" -ForegroundColor red -BackgroundColor Black
write-host "Este Script altera para Round Robin o MultiPath Policy de todas as LUNs com estado MostRecentlyUsed com mais de 1TB." -ForegroundColor red -BackgroundColor white
write-host "Esta alteração é realizada apenas no ESXi, deve ser executada antes do Script para adicionar vLans." -ForegroundColor red -BackgroundColor white

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true

# Coletando as informações do usuário.
$vcenter = Read-Host -Prompt 'Insira o IP ou FQDN do vCenter'

# Conecta ao vCenter.
Connect-VIServer $vcenter -User mvmartinosso

# Percorre todos os hosts conectados ao vCenter
$allHosts = Get-VMHost

foreach ($vmhost in $allHosts) {
    Write-Host "Processando host: $($vmhost.Name)" -ForegroundColor Cyan

    Get-ScsiLun -VmHost $vmhost -LunType disk |
        Where-Object { $_.MultipathPolicy -eq "MostRecentlyUsed" -and $_.CapacityGB -ge 1000 } |
        Set-ScsiLun -MultiPathPolicy RoundRobin
}

Write-Host "Alterado os MultiPaths das LUNs para Round Robin. Apenas discos locais não foram alterados." -ForegroundColor Green

# Exibe resultado final
$allHosts | ForEach-Object {
    Get-ScsiLun -VmHost $_ -LunType disk
}

