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
$BacktButton = $window.FindName("BackButton")
$NextButton = $window.FindName("NextButton")

# TabControlのSelectionChangedイベントハンドラを追加
$tabControl.Add_SelectionChanged({
    param($sender, $e)
    
    # 選択されているタブのインデックスを取得
    $selectedIndex = [int]$tabControl.SelectedIndex

    # インデックスに基づいてボタンのコンテンツを変更
    switch ($selectedIndex) {
        0 { $nextButton.Content = "Next" }
        1 { $nextButton.Content = "Install" }
        2 { $nextButton.Content = "Uninstall" }
        3 { $nextButton.Content = "Finish" }
        4 { $nextButton.Content = "Finish" }
    }
})
# インストール処理
function setup-install {
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
    #$NextButton.Content = "Close"
}

# アンインストール処理
function setup-uninstall {
    $result = [System.Windows.MessageBox]::Show("アンインストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        return;
    }

    $tabControl.SelectedIndex += 2
}

#イベントハンドラーの設定
# 戻るボタン
$BacktButton.Add_Click({
    try{
        $selectedIndex = [int]$tabControl.SelectedIndex
        switch ($selectedIndex) {
            1 {
                $tabControl.SelectedIndex = 0;
            }
            2 {
                $tabControl.SelectedIndex = 0;
            }
       }
    }
    catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# 次へボタン
$NextButton.Add_Click({
    try{
        $selectedIndex = [int]$tabControl.SelectedIndex
        switch ($selectedIndex) {
            0 {
                $Install = $window.FindName("Install")
                if ($Install.IsChecked) {
                    $tabControl.SelectedIndex = 1;
                } else {
                    $tabControl.SelectedIndex = 2;
                }
            }
            1 {
                setup-install
            }
            2 {
                setup-uninstall
            }
            3 {
                $window.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $window.Close()
            }
            4 {
                $window.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $window.Close()
            }
            default { throw "Unknown index: $selectedIndex" } # その他の場合の処理
        }
    }
    catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# ウィンドウの表示
$window.ShowDialog() | Out-Null
