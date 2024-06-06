Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
# 実行ディレクトリを変更します。
Set-Location -Path (Split-Path $PSScriptRoot -Parent)
[string]$ParentDirectory = Get-Location
. "$($ParentDirectory)\scripts\utils.ps1"
$config = Load-Config -configFilePath (Join-Path $ParentDirectory "config.json")

$window = Load-Window -xamlFilePath (Join-Path $ParentDirectory "scripts\installWizard.xaml")

#
$tabControl = $window.FindName("tabControl")
$tabWelcome = $window.FindName("tabWelcome")
$backtButton = $window.FindName("BackButton")
$nextButton = $window.FindName("NextButton")

# TabControlのSelectionChangedイベントハンドラを追加
$tabControl.Add_SelectionChanged({
    param($sender, $e)
    try {
        # 選択されているタブのインデックスを取得
        $selectedIndex = [int]$tabControl.SelectedIndex
        $backtButton.Visibility = [System.Windows.Visibility]::Hidden
        # インデックスに基づいてボタンのコンテンツを変更
        switch ($selectedIndex) {
            -1 {
                return;
            }
            0 { 
                $nextButton.Content = "Next"
            }
            1 { 
                $backtButton.Visibility = [System.Windows.Visibility]::Visible
                $nextButton.Content = "Install"
            }
            2 {
                $backtButton.Visibility = [System.Windows.Visibility]::Visible
                $nextButton.Content = "Uninstall"
            }
            3 {
                $nextButton.Content = "Finish"
            }
            4 {
                $nextButton.Content = "Finish"
            }
        }
    } catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# インストール処理
function setup-install {
    $result = [System.Windows.MessageBox]::Show("インストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        Write-HOST "Script execution cancelled by user."
        return;
    }

    $shortcutLinkCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("ShortCutLinkCheckBox")
    if ($shortcutLinkCheckBox.IsChecked) {
        # ショートカット名
        [string]$ShortcutLink = [string]"$env:appdata\Microsoft\Windows\SendTo\toWEBPs.lnk"
        if (Test-Path -Path $ShortcutLink) {
            $result = [System.Windows.Forms.MessageBox]::Show("`ショートカットファイルが存在します。ファイルを上書きしますか？`n$($ShortcutLink)`n`nはい:上書きする、いいえ:閉じる。",  $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                Write-Output "Script execution cancelled by user."
                return;
            }            
        }

        [string]$TargetPath = Join-Path $ParentDirectory "toWEBPs.bat"

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut($ShortcutLink)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.WorkingDirectory = $ParentDirectory
        $Shortcut.Save()
    }
    
    $downloadLinkCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("DownloadLinkCheckBox")
    if ($downloadLinkCheckBox.IsChecked) {
        # WebPの実行ファイルのチェック
        $WebPExecutablePath = Join-Path $ParentDirectory $config.ExecutablePath
        if (-not (Test-Path -Path $WebPExecutablePath)) {
            $result = [System.Windows.Forms.MessageBox]::Show("`WebPの実行ファイルが存在しません。`n$($WebPExecutablePath)`n`nダウンロードページを開きますか？`n$($config.DownloadPageUrl)`nはい:開く、いいえ:続行する。", "確認:toWEBPs", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                Start-Process $config.DownloadPageUrl
            } else {
                Write-Host "Script execution cancelled by user."
            }
        }    
    }

    $tabControl.SelectedIndex += 2
}

# アンインストール処理
function setup-uninstall {
    $result = [System.Windows.MessageBox]::Show("アンインストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        return;
    }

    $oepnSendToCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("OepnSendToCheckBox")
    if ($oepnSendToCheckBox.IsChecked) {
        Start-Process "$env:APPDATA\Microsoft\Windows\SendTo"    
    }

    $tabControl.SelectedIndex += 2
}

#イベントハンドラーの設定
# 戻るボタン
$backtButton.Add_Click({
    try{
        $selectedIndex = [int]$tabControl.SelectedIndex
        if ($selectedIndex -eq 1 -or $selectedIndex -eq 2) {
            $tabControl.SelectedIndex = 0
        }
    }
    catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# 次へボタン
$nextButton.Add_Click({
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
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_.Exception.Message",  $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        
    }
})

# ウィンドウの表示
$window.ShowDialog() | Out-Null
