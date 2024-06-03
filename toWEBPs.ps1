Add-Type -AssemblyName System.Windows.Forms
$ConfigFilePath = Join-Path $PSScriptRoot "config.json"

# JSON�ݒ�t�@�C���̓ǂݍ���
if (-Not (Test-Path -Path $ConfigFilePath)) {
    Write-Output "�ݒ�t�@�C�������݂��܂���: $ConfigFilePath"
    exit
}
$config = Get-Content -Path $ConfigFilePath | ConvertFrom-Json

# Enum�̒�`
enum ConversionResult {
    None
    Success
    Skipped
    Error
}

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

        $sb.Append("WebpConverter: ")
        $sb.Append("DownloadPageUrl = $($this.DownloadPageUrl), ")
        $sb.Append("ExecutablePath = $($this.ExecutablePath), ")
        $sb.Append("ExcludedFileExtensions = $($this.ExcludedFileExtensions -join ", "), ")
        $sb.Append("DefaultArguments = $($this.DefaultArguments -join ", ")")

        # �]���ȃJ���}�ƃX�y�[�X���폜
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

# �又��
#$args = @("20240529_003857.webp")
$args = @($args)
Write-Output "#Display Run Params $($PSScriptRoot) $($args)"

[WebpConverter]$webp = [WebpConverter]::new($config)
Write-Output "#WebP Check configuration"
Write-Output $webp.ToString()

if (-not $webp.IsExecutableExists()) {
    $result = [System.Windows.Forms.MessageBox]::Show("`WebP�̎��s�t�@�C�������݂��܂���B`n$($webp.ExecutablePath)`n`n�_�E�����[�h�y�[�W���J���܂����H`n$($webp.DownloadPageUrl)`n�͂�:�J���A������:�A�v�����I������B", "�m�F:toWEBPs", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
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
# ���ʃJ�E���^�[�̏�����
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
# �]���ȃJ���}�ƃX�y�[�X���폜
# �]���ȃJ���}�ƃX�y�[�X���폜
if ($sb.Length -gt 2) {
    [void]$sb.Remove($sb.Length -2, 2)
}

Write-Output $sb.ToString()
Write-Output "Sleep 15sec"
Start-Sleep -s 15
