# Inventário automatizado de estação de trabalho

$computador = $env:COMPUTERNAME
$usuario = $env:USERNAME
$sistema = Get-CimInstance Win32_OperatingSystem
$rede = Get-NetIPConfiguration |
    Where-Object { $_.IPv4DefaultGateway -ne $null } |
    Select-Object -First 1

$disco = Get-CimInstance Win32_LogicalDisk `
    -Filter "DeviceID='C:'"

$inventario = [PSCustomObject]@{
    Computador = $computador
    Usuario = $usuario
    SistemaOperacional = $sistema.Caption
    VersaoWindows = $sistema.Version
    EnderecoIP = ($rede.IPv4Address.IPAddress -join ", ")
    Gateway = $rede.IPv4DefaultGateway.NextHop
    EspacoLivreGB = [math]::Round($disco.FreeSpace / 1GB, 2)
    DataColeta = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

$pasta = "$env:USERPROFILE\Documents"
$arquivo = Join-Path $pasta "inventario.csv"

$inventario | Export-Csv `
    -Path $arquivo `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host "Inventario concluido!" -ForegroundColor Green
Write-Host "Arquivo salvo em: $arquivo"