# Diagnostico com registro de logs

$PastaLog = "$env:USERPROFILE\Documents\LogsTI"
$ArquivoLog = Join-Path $PastaLog "diagnostico.log"

# Criar a pasta de logs, se necessario
if (-not (Test-Path $PastaLog)) {
    New-Item -Path $PastaLog -ItemType Directory -Force |
        Out-Null
}

# Funcao para registrar mensagens
function Write-Log {
    param(
        [string]$Mensagem,
        [string]$Nivel = "INFO"
    )

    $Data = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Linha = "[$Data] [$Nivel] $Mensagem"

    Add-Content -Path $ArquivoLog -Value $Linha
    Write-Host $Linha
}

Write-Log "Inicio do diagnostico."

try {
    Write-Log "Consultando informacoes do sistema."

    $Sistema = Get-CimInstance Win32_OperatingSystem `
        -ErrorAction Stop

    Write-Log "Sistema operacional: $($Sistema.Caption)"

    $Disco = Get-CimInstance Win32_LogicalDisk `
        -Filter "DeviceID='C:'" `
        -ErrorAction Stop

    $EspacoLivre = [math]::Round($Disco.FreeSpace / 1GB, 2)

    Write-Log "Espaco livre no disco C: $EspacoLivre GB"
}
catch {
    Write-Log "Falha no diagnostico: $($_.Exception.Message)" "ERRO"
}
finally {
    Write-Log "Fim do diagnostico."
}