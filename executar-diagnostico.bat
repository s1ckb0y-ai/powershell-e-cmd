
@echo off
echo =================================
echo   DIAGNOSTICO DE CONECTIVIDADE
echo =================================

powershell.exe -NoProfile -File "%~dp0diagnostico-parametros.ps1" -Destino "google.com" -Tentativas 2

set RESULTADO=%ERRORLEVEL%

echo.
if %RESULTADO% EQU 0 (
    echo Diagnostico concluido com sucesso.
) else (
    echo Diagnostico encontrou uma falha.
)

echo.
pause
exit /b %RESULTADO%
