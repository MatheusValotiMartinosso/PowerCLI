param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$VMName,
    
    [Parameter(Mandatory=$false)]
    [string]$NewCostCenter,
    
    [Parameter(Mandatory=$false)]
    [string]$NewResponsibleArea,
    
    [Parameter(Mandatory=$false)]
    [string]$NewSite,
    
    [Parameter(Mandatory=$false)]
    [string]$NewCriticality,
    
    [Parameter(Mandatory=$false)]
    [string]$Server,
    
    [switch]$WhatIf,
    [switch]$OnlyIfEmpty
)

# Conectar ao vCenter se necess�rio
if ($Server -and (-not $global:DefaultVIServers)) {
    Connect-VIServer -Server $Server
}

if (-not $global:DefaultVIServers) {
    Write-Error "Nenhuma conex�o com o vCenter encontrada."
    exit 1
}

# Definir os atributos que ser�o modificados
$attributesToUpdate = @{
    "Centro de Custo" = $NewCostCenter
    "AreaResponsavel" = $NewResponsibleArea
    "Site" = $NewSite
    "Criticidade" = $NewCriticality
}

# Verificar quais atributos ser�o realmente modificados
$attributesToProcess = $attributesToUpdate.Keys | Where-Object { $null -ne $attributesToUpdate[$_] -and $attributesToUpdate[$_] -ne "" }

if (-not $attributesToProcess) {
    Write-Error "Nenhum valor novo foi fornecido para atualiza��o."
    exit 1
}

# Verificar se os atributos personalizados existem
foreach ($attr in $attributesToProcess) {
    if (-not (Get-CustomAttribute -Name $attr -ErrorAction SilentlyContinue)) {
        Write-Error "Atributo personalizado '$attr' n�o foi encontrado no vCenter."
        exit 1
    }
}

# Encontrar as VMs
$vms = Get-VM -Name $VMName -ErrorAction SilentlyContinue

if (-not $vms) {
    Write-Error "Nenhuma VM encontrada com o nome/padr�o '$VMName'."
    exit 1
}

# Processar cada VM
foreach ($vm in $vms) {
    Write-Host "`nProcessando VM: $($vm.Name)" -ForegroundColor Magenta
    
    foreach ($attr in $attributesToProcess) {
        $currentValue = $vm | Get-Annotation -CustomAttribute $attr | Select-Object -ExpandProperty Value
        $newValue = $attributesToUpdate[$attr]
        
        if ($OnlyIfEmpty -and $currentValue) {
            Write-Host "  [Pulando] $attr - j� possui valor: '$currentValue'" -ForegroundColor Yellow
            continue
        }
        
        if ($WhatIf) {
            Write-Host "  [WhatIf] Atualizaria $attr de '$currentValue' para '$newValue'" -ForegroundColor Cyan
        }
        else {
            try {
                Set-Annotation -Entity $vm -CustomAttribute $attr -Value $newValue -ErrorAction Stop
                Write-Host "  [Atualizado] $attr definido como: '$newValue'" -ForegroundColor Green
            }
            catch {
                Write-Error "  Falha ao atualizar $attr para a VM $($vm.Name): $_"
            }
        }
    }
}

Write-Host "`nProcessamento conclu�do para $($vms.Count) VMs." -ForegroundColor Blue