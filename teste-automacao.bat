
@echo off
echo ===== DIAGNOSTICO DE IMPRESSAO =====
echo.

powershell.exe -NoProfile -Command "$servico = Get-Service -Name Spooler; if ($servico.Status -eq 'Running') { exit 0 } else { exit 1 }"

if %ERRORLEVEL% EQU 0 (
    echo RESULTADO: Servico de impressao funcionando.
) else (
    echo ALERTA: Servico de impressao parado ou ocorreu um erro.
)

echo.
pause
