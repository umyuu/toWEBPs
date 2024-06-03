Add-Type -AssemblyName PresentationFramework

# XAMLの読み込み
# XAMLファイルのパス
$xamlFilePath = Join-Path $PSScriptRoot "\window.xaml"

# XAMLの読み込み
$xamlContent = Get-Content -Path $xamlFilePath -Raw
$xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
$window = [System.Windows.Markup.XamlReader]::Load($xr)

# イベントハンドラの設定
$installButton = $window.FindName("InstallButton")
$uninstallButton = $window.FindName("UninstallButton")

$installButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show("インストールしますか？", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if (-not ($result -eq [System.Windows.Forms.MessageBoxButtons]::Yes))
    {
        return;
    }

    # インストール処理をここに記述
    Start-Sleep -Seconds 2  # 処理のシミュレーション
    [System.Windows.MessageBox]::Show("Installation Completed", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    $window.Close()
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

# ウィンドウの表示
$window.ShowDialog() | Out-Null
