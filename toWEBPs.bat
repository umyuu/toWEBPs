@echo off
setlocal

:: PowerShellスクリプトのパスを設定
set "scriptPath=%~dp0\toWEBPs.ps1"

:: バッチファイルに渡されたすべての引数をPowerShellスクリプトに渡す
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%" %*

endlocal
TIMEOUT /T 10
exit /b
