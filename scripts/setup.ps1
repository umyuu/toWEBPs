Add-Type -AssemblyName PresentationFramework

# XAMLの読み込み
# XAMLファイルのパス
$xamlFilePath = Join-Path $PSScriptRoot "\window.xaml"

# XAMLの読み込み
$xamlContent = Get-Content -Path $xamlFilePath -Encoding utf8
$xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
$window = [System.Windows.Markup.XamlReader]::Load($xr)

#
$tabControl = $window.FindName("tabControl")

$tabWelcome = $window.FindName("tabWelcome")
$nextButton = $window.FindName("nextButton")
$Install = $window.FindName("Install")
$installButton = $window.FindName("installButton")
$installCanecelButton = $window.FindName("installCanecelButton")
$uninstallButton = $window.FindName("uninstallButton")
$uninstallCanecelButton = $window.FindName("uninstallCanecelButton")
#イベントハンドラーの設定
$nextButton.Add_Click({
    if ($Install.IsChecked)
    {
        $tabControl.SelectedIndex = 1;
    }else {
        $tabControl.SelectedIndex = 2;
    }
})

# インストールボタン
$installButton.Add_Click({
    Write-Output "Script execution cancelled by user."
    $result = [System.Windows.MessageBox]::Show("インストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        Write-HOST "Script execution cancelled by user."
        return;
    }

    $shortcutLinkCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("shortcutLinkCheckBox")
    if ($shortcutLinkCheckBox.IsChecked) {
        Write-HOST $shortcutLinkCheckBox
        Write-Output "Script execution cancelled by user."
        # ショートカット名
        [string]$ShortcutLink = [string]"$env:appdata\Microsoft\Windows\SendTo\toWEBPs.lnk"

        $result = [System.Windows.Forms.MessageBox]::Show("`ショートカットファイルが存在します。インストールしますか？`n$($ShortcutLink)`n`nはい:上書きする、、いいえ:アプリを終了する。", "toWEBPs:確認", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

        if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
            Write-Output "Script execution cancelled by user."
            return;
            exit 1
        }

        if (Test-Path -Path $ShortcutLink) {
            $result = [System.Windows.Forms.MessageBox]::Show("`ショートカットファイルが存在します。ファイルを上書きしますか？`n$($ShortcutLink)`n`nはい:上書きする、、いいえ:アプリを終了する。", "toWEBPs:確認", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                Write-Output "Script execution cancelled by user."
                exit 2
            }
        }

        [string]$TargetPath = $ParentDirectory + "\toWEBPs.bat"

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut($ShortcutLink)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.WorkingDirectory = $ParentDirectory
        $Shortcut.Save()
    }



    $_ = [System.Windows.Forms.MessageBox]::Show("`インストールしました。WebPに変換したいファイルを選択し送るメニューからtoWEBPsを選択すると実行します。", $window.Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

    $window.Close()
})
$installCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

$uninstallButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show("アンインストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if (-not ($result -eq [System.Windows.Forms.MessageBoxButtons]::Yes))
    {
        return;
    }


    # アンインストール処理をここに記述
    Start-Sleep -Seconds 2  # 処理のシミュレーション
    [System.Windows.MessageBox]::Show("Uninstallation Completed", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    $window.Close()
})

$uninstallCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

# ウィンドウの表示
$window.ShowDialog() | Out-Null
