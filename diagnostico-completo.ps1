# Diagnostico completo de rede

$PastaLog = "$env:USERPROFILE\Documents\LogsTI"
$ArquivoLog = Join-Path $PastaLog "rede-completo.log"
$ArquivoCSV = Join-Path $PastaLog "rede-completo.csv"

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

Write-Log "Inicio do diagnostico de rede."

$ip = $null
$gateway = $null
$gatewayStatus = "Nao testado"
$dnsStatus = "Nao testado"

try {
    $config = Get-NetIPConfiguration -ErrorAction Stop |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null
        } |
        Select-Object -First 1

    if ($null -eq $config) {
        $gatewayStatus = "Sem gateway configurado"
        Write-Log $gatewayStatus "ALERTA"
    }
    else {
        $ip = $config.IPv4Address.IPAddress -join ", "
        $gateway = $config.IPv4DefaultGateway.NextHop

        $testeGateway = Test-Connection `
            -ComputerName $gateway `
            -Count 2 `
            -Quiet `
            -ErrorAction SilentlyContinue

        if ($testeGateway) {
            $gatewayStatus = "Acessivel"
            Write-Log "Gateway acessivel: $gateway"
        }
        else {
            $gatewayStatus = "Sem resposta ao ping"
            Write-Log "Gateway nao respondeu ao ping." "ALERTA"
        }
    }

    try {
        Resolve-DnsName google.com -ErrorAction Stop |
            Out-Null

        $dnsStatus = "OK"
        Write-Log "Resolucao DNS funcionando."
    }
    catch {
        $dnsStatus = "Falha"
        Write-Log "Falha na resolucao DNS." "ERRO"
    }

    $resultado = [PSCustomObject]@{
        Computador = $env:COMPUTERNAME
        Usuario = $env:USERNAME
        IP = $ip
        Gateway = $gateway
        StatusGateway = $gatewayStatus
        StatusDNS = $dnsStatus
        DataTeste = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    $resultado | Export-Csv `
        -Path $ArquivoCSV `
        -NoTypeInformation `
        -Encoding UTF8

    Write-Log "Relatorio CSV gerado."
}
catch {
    Write-Log "Erro inesperado: $($_.Exception.Message)" "ERRO"
}
finally {
    Write-Log "Diagnostico finalizado."
}