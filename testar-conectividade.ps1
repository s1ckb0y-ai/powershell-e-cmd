param(
    [Parameter(Mandatory = $true)]
    [string]$Destino,

    [int]$Tentativas = 4
)

$PastaLog = "$env:USERPROFILE\Documents\LogsTI"
$ArquivoLog = Join-Path $PastaLog "conectividade.log"

New-Item -Path $PastaLog -ItemType Directory -Force |
    Out-Null

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

Write-Log "Iniciando teste para $Destino."

try {
    $resultado = Test-Connection `
        -ComputerName $Destino `
        -Count $Tentativas `
        -ErrorAction SilentlyContinue

    if ($resultado) {
        Write-Log "$Destino respondeu ao teste de conectividade."
    }
    else {
        Write-Log "$Destino nao respondeu ao teste." "ALERTA"
    }
}
catch {
    Write-Log "Erro: $($_.Exception.Message)" "ERRO"
}

Write-Log "Teste finalizado."