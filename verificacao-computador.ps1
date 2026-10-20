
$PastaRelatorio = "$env:USERPROFILE\Documents\LogsTI"
$ArquivoCSV = Join-Path $PastaRelatorio "saude_computador.csv"

New-Item -Path $PastaRelatorio -ItemType Directory -Force | Out-Null

# Identifica o computador e testa a rede
$Computador = $env:COMPUTERNAME
$RedeOK = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet -ErrorAction SilentlyContinue

# Verifica o espaço livre do disco C:

$Disco = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$EspacoLivreGB = [math]::Round($Disco.FreeSpace / 1GB, 2)

if ($EspacoLivreGB -lt 5) {
    $AlertaDisco = "CRITICO"
}
elseif ($EspacoLivreGB -lt 10) {
    $AlertaDisco = "ATENCAO"
}
else {
    $AlertaDisco = "OK"
}


# Verifica o serviço de impressão

$Impressao = Get-Service -Name Spooler

if ($Impressao.Status -eq "Running") {
    Write-Log "Servico de impressao ja esta em execucao."
    $ResultadoImpressao = "OK"
}
else {
    Write-Log "Servico de impressao parado." "ALERTA"

    $Resposta = Read-Host "Deseja tentar iniciar o servico? (S/N)"

    if ($Resposta -eq "S") {
        try {
            Start-Service -Name Spooler -ErrorAction Stop
            $Impressao = Get-Service -Name Spooler

            if ($Impressao.Status -eq "Running") {
                Write-Log "Servico iniciado com sucesso."
                $ResultadoImpressao = "OK"
            }
            else {
                Write-Log "Servico nao iniciou." "ALERTA"
                $ResultadoImpressao = "Problema"
            }
        }
        catch {
            Write-Log "Erro ao iniciar servico: $($_.Exception.Message)" "ERRO"
            $ResultadoImpressao = "Problema"
        }
    }
    else {
        Write-Log "Usuario optou por nao iniciar o servico."
        $ResultadoImpressao = "Problema"
    }
}
# Monta o relatório
$Relatorio = [PSCustomObject]@{
    Computador       = $Computador
    DataVerificacao  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Rede             = if ($RedeOK) { "Respondendo" } else { "Sem resposta" }
    EspacoLivreGB    = $EspacoLivreGB
    AlertaDisco      = $AlertaDisco
    ServicoImpressao = $ResultadoImpressao
}


$Relatorio | Export-Csv -Path $ArquivoCSV -NoTypeInformation -Encoding UTF8

# Exibe os resultados
$Relatorio | Format-List
Write-Host "Relatorio salvo em: $ArquivoCSV"
