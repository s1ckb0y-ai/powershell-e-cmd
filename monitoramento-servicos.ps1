# Monitoramento de servicos do Windows

$servicos = @(
    "Spooler",
    "wuauserv",
    "BITS"
)

$resultados = foreach ($nome in $servicos) {

    $servico = Get-Service -Name $nome -ErrorAction SilentlyContinue

    if ($null -ne $servico) {
        [PSCustomObject]@{
            Computador = $env:COMPUTERNAME
            Servico    = $nome
            Status     = $servico.Status.ToString()
            Encontrado = $true
            DataColeta = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
    else {
        [PSCustomObject]@{
            Computador = $env:COMPUTERNAME
            Servico    = $nome
            Status     = "Nao encontrado"
            Encontrado = $false
            DataColeta = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

$resultados | Format-Table -AutoSize

$caminho = "$env:USERPROFILE\Documents\servicos.csv"

$resultados | Export-Csv `
    -Path $caminho `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host "`nRelatorio salvo em: $caminho" -ForegroundColor Green