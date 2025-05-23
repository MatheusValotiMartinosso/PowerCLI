# Lista de VMs que deseja desligar
$vms = @("MTZ-MAILRELAY-02", "MTZ-CHKP-BK-01", "MTZ-NPS-01", "MTZ-MGRSNR-TEMP", "MAR-WERBSERVICE-002")

# Desliga as VMs (sem confirmação interativa)
Stop-VM -Name $vms -Confirm:$false

# Aguarda alguns segundos para garantir que as VMs sejam desligadas
Start-Sleep -Seconds 30

# Verifica e exibe o status atual de cada VM
Get-VM -Name $vms | Select-Object Name, PowerState
