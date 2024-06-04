Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Runtime

Set-Location -Path $PSScriptRoot #スクリプトの実行ディレクトリ
[System.Diagnostics.Stopwatch]$stopWatch = New-Object System.Diagnostics.Stopwatch
$stopWatch.Start()
. "$($ParentDirectory)\scripts\utils.ps1"

# Enumの定義
enum ConversionResult {
    None
    Success
    Skipped
    Error
}

# WebpConverterクラスの定義
class WebpConverter {
    # WebPの実行ファイルのダウンロードページのURL
    [string]$DownloadPageUrl
    # WebPの実行ファイルのパス
    [string]$ExecutablePath
    # 処理除外対象のファイル拡張子の配列
    [string[]]$ExcludedFileExtensions
    # WebP変換時に使用するデフォルトのコマンドライン引数の配列
    [string[]]$DefaultArguments
    
    # コンストラクタ
    WebpConverter([PSCustomObject]$config){
        $this.DownloadPageUrl = $config.DownloadPageUrl
        $this.ExecutablePath = Join-Path $PSScriptRoot $config.ExecutablePath
        $this.ExcludedFileExtensions = $config.ExcludedFileExtensions
        $this.DefaultArguments = $config.DefaultArguments
    }
    # 実行ファイルの存在確認
    [bool]IsExecutableExists(){
        return Test-Path -Path $this.ExecutablePath
    }
    [string]ToString(){
        [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder

        [void]$sb.Append("WebpConverter: ")
        [void]$sb.Append("DownloadPageUrl = $($this.DownloadPageUrl), ")
        [void]$sb.Append("ExecutablePath = $($this.ExecutablePath), ")
        [void]$sb.Append("ExcludedFileExtensions = $($this.ExcludedFileExtensions -join ", "), ")
        [void]$sb.Append("DefaultArguments = $($this.DefaultArguments -join ", ")")

        return $sb.ToString().TrimEnd(", ")
    }
}

# Convert-ToWebp関数の定義
function Convert-ToWebp {
    param (
        [WebpConverter]$webp,
        [string]$FileName
    )

    Write-Host "#Convert-Webp Start"
    if ([string]::IsNullOrEmpty($FileName)) {
        Write-Host "Skipping empty filename"
        return [ConversionResult]::Skipped
    }

    Write-Host "source: $FileName"

    $Extension = [System.IO.Path]::GetExtension($FileName)
    if ($webp.ExcludedFileExtensions -contains $Extension) {
        Write-Host "Skipping file with extension $($Extension):  $($FileName)"
        return [ConversionResult]::Skipped
    }

    #$FilePath = [System.IO.Path]::GetDirectoryName($FileName)
    $GenerateFileName = [System.IO.Path]::ChangeExtension($FileName, ".webp")
    $Arguments = $webp.DefaultArguments + @("-o", $GenerateFileName, $FileName) -join " "

    Write-Host $Arguments
    Start-Process -FilePath $webp.ExecutablePath -ArgumentList $Arguments
    #$webp.Convert($FileName)
    Write-Host "#Convert-Webp End"
    return [ConversionResult]::Success
}

# スクリプト実行部分

$args = @($args)
#$args = @("K:\GitHub\toWEBPs\20240529_003857.webp")

Write-Host "#Run Params $($PSScriptRoot) $($args)"
$config = Load-Config -configFilePath (Join-Path $PSScriptRoot "config.json")

# WebPコンバータのインスタンス化と設定の確認
[WebpConverter]$webp = [WebpConverter]::new($config)
Write-Host "#WebP Check configuration"
Write-Host $webp.ToString()

if (-not $webp.IsExecutableExists()) {
    $result = [System.Windows.Forms.MessageBox]::Show("`WebPの実行ファイルが存在しません。`n$($webp.ExecutablePath)`n`nダウンロードページを開きますか？`n$($webp.DownloadPageUrl)`nはい:開く、いいえ:アプリを終了する。", "確認:toWEBPs", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -eq "Yes") {
        Start-Process $webp.DownloadPageUrl
        exit
    } else {
        Write-Host "Script execution cancelled by user."
        exit
    }
}
Write-Host "Exists OK $($webp.ExecutablePath)"

Write-Host "#Main"

# 結果サマリーの初期化
$resultSummary = [ordered]@{}
[System.Enum]::GetValues([ConversionResult]) | ForEach-Object {
    $resultSummary.Add($_, [int]0)
}

# 主処理
foreach ($v in $args) {
    $result = Convert-ToWebp -webp $webp -FileName $v
    $resultSummary[$result] += 1  
}

# 処理件数を出力
[System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("Conversion Results: Total:$($args.Length), ")
foreach ($entry in $resultSummary.GetEnumerator()) {
    if ($entry.Key -ne "None") {
        [void]$sb.Append("$($entry.Key): $($entry.Value), ")
    }
}
# 余分なカンマとスペースを削除
if ($sb.Length -gt 2) {
    [void]$sb.Remove($sb.Length -2, 2)
}
Write-Host "Execution time: $($stopWatch.ElapsedMilliseconds)ms"
Write-Host $sb.ToString()

Write-Host "Sleep 15sec"
Start-Sleep -s 15
