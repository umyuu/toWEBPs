Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

# WebPへの変換結果
enum ConversionResult {
    None # 未定義
    Success # 正常終了
    Skipped # スキップ
    Error # エラー
}

function Question-YesNo {
    param (
        [string]$Text,
        [string]$Title
    )
    retrun [System.Windows.MessageBox]::Show($Text, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
}

# JSON設定ファイルの読み込み
function Load-Config {
    param (
        [Parameter(Mandatory=$true)] #引数を必須に
        [string]$configFilePath
    )
    if (-not (Test-Path -Path $configFilePath)) {
        throw "設定ファイルが存在しません: $configFilePath"
    }

    return Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
}

function Load-Window {
    param(
        [Parameter(Mandatory=$true)] #引数を必須に
        [string]$xamlFilePath # XAMLファイルのパス
    )
    # XAMLの読み込み
    $xamlContent = Get-Content -Path $xamlFilePath -Encoding utf8
    $xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
    return [System.Windows.Markup.XamlReader]::Load($xr)
}
