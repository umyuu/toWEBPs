Add-Type -AssemblyName System.Windows.Forms
$ConfigFilePath = Join-Path $PSScriptRoot "config.json"

# JSON設定ファイルの読み込み
if (-Not (Test-Path -Path $ConfigFilePath)) {
    Write-Output "設定ファイルが存在しません: $ConfigFilePath"
    exit
}
$config = Get-Content -Path $ConfigFilePath | ConvertFrom-Json

# Enumの定義
enum ConversionResult {
    None
    Success
    Skipped
    Error
}

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

        $sb.Append("WebpConverter: ")
        $sb.Append("DownloadPageUrl = $($this.DownloadPageUrl), ")
        $sb.Append("ExecutablePath = $($this.ExecutablePath), ")
        $sb.Append("ExcludedFileExtensions = $($this.ExcludedFileExtensions -join ", "), ")
        $sb.Append("DefaultArguments = $($this.DefaultArguments -join ", ")")

        # 余分なカンマとスペースを削除
        return $sb.ToString().TrimEnd(", ")
    }
}

function Convert-ToWebp {
    param (
        [WebpConverter]$webp,
        [string]$FileName
    )

    Write-Output "#Convert-Webp Start"
    if ([string]::IsNullOrEmpty($FileName)) {
        Write-Output "Skipping empty filename"
        return [ConversionResult]::Skipped
    }

    Write-Output "source: $FileName"

    $Extension = [System.IO.Path]::GetExtension($FileName)
    if ($webp.ExcludedFileExtensions -contains $Extension) {
        Write-Output "Skipping file with extension $($Extension):  $($FileName)"
        return [ConversionResult]::Skipped
    }

    #$FilePath = [System.IO.Path]::GetDirectoryName($FileName)
    $GenerateFileName = [System.IO.Path]::ChangeExtension($FileName, ".webp")
    $Arguments = $webp.DefaultArguments + @("-o", $GenerateFileName, $FileName) -join " "

    Write-Output $Arguments
    Start-Process -FilePath $webp.ExecutablePath -ArgumentList $Arguments
    #$webp.Convert($FileName)
    Write-Output "#Convert-Webp End"
    return [ConversionResult]::Success
}

# 主処理
#$args = @("20240529_003857.webp")
$args = @($args)
Write-Output "#Display Run Params $($PSScriptRoot) $($args)"

[WebpConverter]$webp = [WebpConverter]::new($config)
Write-Output "#WebP Check configuration"
Write-Output $webp.ToString()

if (-not $webp.IsExecutableExists()) {
    $result = [System.Windows.Forms.MessageBox]::Show("`WebPの実行ファイルが存在しません。`n$($webp.ExecutablePath)`n`nダウンロードページを開きますか？`n$($webp.DownloadPageUrl)`nはい:開く、いいえ:アプリを終了する。", "確認:toWEBPs", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -eq "Yes") {
        Start-Process $webp.DownloadPageUrl
        exit
    } else {
        Write-Output "Script execution cancelled by user."
        exit
    }
}
Write-Output "Exists OK $($webp.ExecutablePath)"

function Main {
    Write-Output "Exists OK $($webp.ExecutablePath)"
}

Write-Output "#Main"
# 結果カウンターの初期化
$resultsCount = @{
    "None" = 0
    "Success" = 0
    "Skipped" = 0
    "Error" = 0
}

foreach ($v in $args) {
  $result = Convert-ToWebp -webp $webp -FileName $v
  $resultsCount[$result.ToString()]++
}

[System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("Conversion Results: Total:$($args.Length), ")

foreach ($resultEntry in $resultsCount.GetEnumerator()) {
    if ($resultEntry.Key -ne "None") {
        $sb.Append("$($resultEntry.Key): $($resultEntry.Value), ")
    }
}
# 余分なカンマとスペースを削除
# 余分なカンマとスペースを削除
if ($sb.Length -gt 2) {
    [void]$sb.Remove($sb.Length -2, 2)
}

Write-Output $sb.ToString()
Write-Output "Sleep 15sec"
Start-Sleep -s 15
