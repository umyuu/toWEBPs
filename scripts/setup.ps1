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

$installfinishButton = $window.FindName("installfinishButton")
$uninstallfinishButton = $window.FindName("uninstallfinishButton")



#イベントハンドラーの設定
$nextButton.Add_Click({
    if ($Install.IsChecked)
    {
        $tabControl.SelectedIndex = 1;
    }else {
        $tabControl.SelectedIndex = 2;
    }
})

# インストール処理
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
        if (Test-Path -Path $ShortcutLink) {
            $result = [System.Windows.Forms.MessageBox]::Show("`ショートカットファイルが存在します。ファイルを上書きしますか？`n$($ShortcutLink)`n`nはい:上書きする、いいえ:閉じる。",  $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                Write-Output "Script execution cancelled by user."
                return;
            }            
        }

        [string]$TargetPath = $ParentDirectory + "\toWEBPs.bat"

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut($ShortcutLink)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.WorkingDirectory = $ParentDirectory
        $Shortcut.Save()
    }

    $tabControl.SelectedIndex += 2
})
$installCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

# アンインストール処理
$uninstallButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show("アンインストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        return;
    }

    $tabControl.SelectedIndex += 2
})

$uninstallCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

$installfinishButton.Add_Click({
    $window.Close()
})
$uninstallfinishButton.Add_Click({
    $window.Close()
})

# ウィンドウの表示
$window.ShowDialog() | Out-Null
