Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Runtime

Set-Location -Path $PSScriptRoot #�X�N���v�g�̎��s�f�B���N�g��
[System.Diagnostics.Stopwatch]$stopWatch = New-Object System.Diagnostics.Stopwatch
$stopWatch.Start()
. "$($ParentDirectory)\scripts\utils.ps1"

# Enum�̒�`
enum ConversionResult {
    None
    Success
    Skipped
    Error
}

# WebpConverter�N���X�̒�`
class WebpConverter {
    # WebP�̎��s�t�@�C���̃_�E�����[�h�y�[�W��URL
    [string]$DownloadPageUrl
    # WebP�̎��s�t�@�C���̃p�X
    [string]$ExecutablePath
    # �������O�Ώۂ̃t�@�C���g���q�̔z��
    [string[]]$ExcludedFileExtensions
    # WebP�ϊ����Ɏg�p����f�t�H���g�̃R�}���h���C�������̔z��
    [string[]]$DefaultArguments
    
    # �R���X�g���N�^
    WebpConverter([PSCustomObject]$config){
        $this.DownloadPageUrl = $config.DownloadPageUrl
        $this.ExecutablePath = Join-Path $PSScriptRoot $config.ExecutablePath
        $this.ExcludedFileExtensions = $config.ExcludedFileExtensions
        $this.DefaultArguments = $config.DefaultArguments
    }
    # ���s�t�@�C���̑��݊m�F
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

# Convert-ToWebp�֐��̒�`
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

# �X�N���v�g���s����

$args = @($args)
#$args = @("K:\GitHub\toWEBPs\20240529_003857.webp")

Write-Host "#Run Params $($PSScriptRoot) $($args)"
$config = Load-Config -configFilePath (Join-Path $PSScriptRoot "config.json")

# WebP�R���o�[�^�̃C���X�^���X���Ɛݒ�̊m�F
[WebpConverter]$webp = [WebpConverter]::new($config)
Write-Host "#WebP Check configuration"
Write-Host $webp.ToString()

if (-not $webp.IsExecutableExists()) {
    $result = [System.Windows.Forms.MessageBox]::Show("`WebP�̎��s�t�@�C�������݂��܂���B`n$($webp.ExecutablePath)`n`n�_�E�����[�h�y�[�W���J���܂����H`n$($webp.DownloadPageUrl)`n�͂�:�J���A������:�A�v�����I������B", "�m�F:toWEBPs", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
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

# ���ʃT�}���[�̏�����
$resultSummary = [ordered]@{}
[System.Enum]::GetValues([ConversionResult]) | ForEach-Object {
    $resultSummary.Add($_, [int]0)
}

# �又��
foreach ($v in $args) {
    $result = Convert-ToWebp -webp $webp -FileName $v
    $resultSummary[$result] += 1  
}

# �����������o��
[System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("Conversion Results: Total:$($args.Length), ")
foreach ($entry in $resultSummary.GetEnumerator()) {
    if ($entry.Key -ne "None") {
        [void]$sb.Append("$($entry.Key): $($entry.Value), ")
    }
}
# �]���ȃJ���}�ƃX�y�[�X���폜
if ($sb.Length -gt 2) {
    [void]$sb.Remove($sb.Length -2, 2)
}
Write-Host "Execution time: $($stopWatch.ElapsedMilliseconds)ms"
Write-Host $sb.ToString()

Write-Host "Sleep 15sec"
Start-Sleep -s 15
