# Automacao de troubleshooting de impressao

$PastaLog = "$env:USERPROFILE\Documents\LogsTI"
$ArquivoLog = Join-Path $PastaLog "impressao.log"

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

Write-Log "Inicio do diagnostico de impressao."

try {
    $servico = Get-Service -Name "Spooler" -ErrorAction Stop

    Write-Log "Status atual: $($servico.Status)"

    if ($servico.Status -eq "Running") {
        Write-Log "Servico de impressao em execucao."
        Write-Host "O servico esta funcionando." `
            -ForegroundColor Green
    }
    else {
        Write-Log "Servico de impressao parado." "ALERTA"

        $resposta = Read-Host `
            "Deseja tentar iniciar o servico? (S/N)"

        if ($resposta -eq "S") {
            Start-Service -Name "Spooler" -ErrorAction Stop

            $servico = Get-Service -Name "Spooler"

            if ($servico.Status -eq "Running") {
                Write-Log "Servico iniciado com sucesso."
            }
            else {
                Write-Log "Servico ainda nao esta em execucao." "ERRO"
            }
        }
        else {
            Write-Log "Acao cancelada pelo usuario."
        }
    }
}
catch {
    Write-Log "Erro: $($_.Exception.Message)" "ERRO"
    Write-Host "Verifique as permissoes e o estado do servico." `
        -ForegroundColor Red
}
finally {
    Write-Log "Diagnostico finalizado."
}