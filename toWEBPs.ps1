Add-Type -AssemblyName System.Windows.Forms
class WebpConverter {
    # WebPの実行ファイルのダウンロードページ
    [string]$DownloadPageUrl
    # WebPの実行ファイル
    [string]$ExecutablePath
    # 処理除外対象の拡張子の配列
    [string[]]$ExcludedFileExtensions
    #[string]$Arguments

    WebpConverter(){
        $this.DownloadPageUrl = [string]"https://developers.google.com/speed/webp/download?hl=ja"
        $this.ExecutablePath = [string]$PSScriptRoot + "\third_party\cwebp.exe"
        $this.ExcludedFileExtensions = @(".webp", ".exe", ".bat", ".ps1", ".zip")
	#$this.Arguments = ""
    }
    [bool]IsExecutableExists(){
        return Test-Path -Path $this.ExecutablePath
    }
    [string]ToString(){
        return $this.ExecutablePath
    }
}

function Convert-ToWebp {
    param ([WebpConverter]$webp, [string]$FileName)
    Write-Output "#Convert-Webp Start"
    if ($FileName.length -eq 0) {
        Write-Output "Skipping empty filename"
        return;
    }

    Write-Output "source: $FileName"

    $Extension = [System.IO.Path]::GetExtension($FileName)
    if ($webp.ExcludedFileExtensions -contains $Extension) {
        Write-Output "Skipping file with extension $($Extension):  $($FileName)"
        return;
    }

    $FilePath = [System.IO.Path]::GetDirectoryName($FileName)
    $GenerateFileName = [System.IO.Path]::ChangeExtension($FileName, ".webp")    
    $Arguments = @("-preset photo", "-metadata icc", "-sharp_yuv", "-o" + $GenerateFileName, "-progress", "-short", "" +$FileName) -join " "
    Write-Output $webp.ToString()
    Write-Output $Arguments
    Start-Process -FilePath $webp.ExecutablePath -ArgumentList $Arguments
    #$webp.Convert($FileName)
    Write-Output "#Convert-Webp End"
}

# 主処理
$args = @($args)
Write-Output "#Display Run Params $($PSScriptRoot) $($args)"

[WebpConverter]$webp = [WebpConverter]::new()
Write-Output "#WebP Check configuration"

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

Write-Output "#Main"
foreach ($v in $args) {
  Convert-ToWebp -webp $webp -FileName $v
}
Write-Output "#Main End"

Write-Output "Sleep 15sec"
Start-Sleep -s 15
