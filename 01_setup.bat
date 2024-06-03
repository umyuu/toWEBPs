@echo off
setlocal

:: PowerShellスクリプトのパスを設定
set "scriptPath=%~dp0\scripts\setup.ps1"

:: バッチファイルに渡されたすべての引数をPowerShellスクリプトに渡す
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%" %*

endlocal
exit /b
