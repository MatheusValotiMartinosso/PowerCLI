# Alertas – "Esta por sua conta e risco!"
write-host "IMPORTANTE" -ForegroundColor red -BackgroundColor Black
write-host "Este Script altera para Round Robin o MultiPath Policy de todas as Luns com estado MostRecentlyUsed com mais de 1TB." -ForegroundColor red -BackgroundColor white
write-host "Esta alteração é realizada apenas no ESXi, deve ser executada antes do Script para adicionar vLans." -ForegroundColor red -BackgroundColor white


Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true

# Coletando as informações do usuário.
$esxi = Read-Host -Prompt 'Insira o IP do ESXi:'

#
#

# Conecta ao ESXi.
Connect-VIServer $esxi -User mvmartinosso

Get-ScsiLun -LunType disk | Where {$_.MultipathPolicy -like "MostRecentlyUsed"} | Where {$_.CapacityGB -ge 1000} | Set-Scsilun -MultiPathPolicy RoundRobin

write-host "Alterado os MultiPaths das Luns para Round Robin, apenas disco Local não foi alterado."

Get-ScsiLun -LunType disk

Disconnect-VIServer -Server $esxi -confirm:$false



