# Gerenciamento de aplicativos com winget

$comando = Get-Command winget -ErrorAction SilentlyContinue

if ($null -eq $comando) {
    Write-Host "winget nao encontrado neste ambiente." `
        -ForegroundColor Red
    exit 1
}

$aplicativo = "7zip.7zip"

Write-Host "Verificando instalacao do 7-Zip..."

winget list --id $aplicativo --exact

if ($LASTEXITCODE -ne 0) {
    Write-Host "Nao foi possivel confirmar a instalacao."
    Write-Host "Verifique o resultado antes de continuar."
}
else {
    $resposta = Read-Host "Deseja tentar instalar ou atualizar o aplicativo? (S/N)"

    if ($resposta -eq "S") {
        winget install --id $aplicativo --exact `
            --accept-source-agreements `
            --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Comando concluido com sucesso." `
                -ForegroundColor Green
        }
        else {
            Write-Host "A operacao retornou um codigo de erro." `
                -ForegroundColor Red
        }
    }
    else {
        Write-Host "Operacao cancelada pelo usuario."
    }
}