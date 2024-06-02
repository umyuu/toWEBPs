Add-Type -AssemblyName System.Windows.Forms

# toWEBPs.ps1のディレクトリ
[string]$ParentDirectory = Split-Path $PSScriptRoot -Parent
# ショートカット名
[string]$ShortcutLink = [string]"$env:appdata\Microsoft\Windows\SendTo\toWEBPs.lnk"

if (Test-Path -Path $ShortcutLink) {
    $result = [System.Windows.Forms.MessageBox]::Show("`ショートカットファイルが存在します。ファイルを上書きしますか？`n$($ShortcutLink)`n`nはい:上書きする、、いいえ:アプリを終了する。", "toWEBPs:確認", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-Output "Script execution cancelled by user."
        exit 1
    }
}

[string]$TargetPath = $ParentDirectory + "\toWEBPs.bat"

$WshShell = New-Object -comObject WScript.Shell

$Shortcut = $WshShell.CreateShortcut($ShortcutLink)
$Shortcut.TargetPath = $TargetPath
$Shortcut.WorkingDirectory = $ParentDirectory
$Shortcut.Save()

$_ = [System.Windows.Forms.MessageBox]::Show("`インストールしました。WebPに変換したいファイルを選択し送るメニューからtoWEBPsを選択すると実行します。", "toWEBPs:正常終了", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
