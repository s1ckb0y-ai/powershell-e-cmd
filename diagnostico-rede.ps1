# Diagnóstico automatizado de rede

Write-Host "`n=== DIAGNOSTICO DE REDE ===" -ForegroundColor Cyan

# 1. Obter configuração de rede
$config = Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -ne $null } |
    Select-Object -First 1

$ip = $config.IPv4Address.IPAddress
$gateway = $config.IPv4DefaultGateway.NextHop

Write-Host "Endereco IP: $ip"
Write-Host "Gateway: $gateway"

# 2. Testar conectividade com o gateway
Write-Host "`nTestando gateway..."

$testeGateway = Test-Connection `
    -ComputerName $gateway `
    -Count 2 `
    -Quiet `
    -ErrorAction SilentlyContinue

if ($testeGateway) {
    Write-Host "Gateway acessivel" -ForegroundColor Green
}
else {
    Write-Host "Falha ao acessar gateway" -ForegroundColor Red
}

# 3. Testar resolucao DNS
Write-Host "`nTestando DNS..."

try {
    Resolve-DnsName google.com -ErrorAction Stop | Out-Null
    $dnsStatus = "OK"
    Write-Host "Resolucao DNS funcionando" -ForegroundColor Green
}
catch {
    $dnsStatus = "Falha"
    Write-Host "Falha na resolucao DNS" -ForegroundColor Red
}

# 4. Gerar relatorio
$resultado = [PSCustomObject]@{
    Computador = $env:COMPUTERNAME
    EnderecoIP = $ip -join ", "
    Gateway = $gateway
    GatewayAcessivel = $testeGateway
    DNS = $dnsStatus
    DataTeste = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

$caminho = "$env:USERPROFILE\Documents\diagnostico-rede.csv"

$resultado | Export-Csv `
    -Path $caminho `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host "`nRelatorio salvo em: $caminho" -ForegroundColor Cyan