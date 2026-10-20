
param(
    [string]$Destino = "8.8.8.8",
    [int]$Tentativas = 2
)

Write-Host "Destino: $Destino"
Write-Host "Tentativas: $Tentativas"

$Resultado = Test-Connection `
    -ComputerName $Destino `
    -Count $Tentativas `
    -Quiet `
    -ErrorAction SilentlyContinue

if ($Resultado) {
    Write-Host "SUCESSO: destino respondeu." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "FALHA: destino nao respondeu." -ForegroundColor Red
    exit 1
}
