Add-Type -AssemblyName System.Windows.Forms

# JSON�ݒ�t�@�C���̓ǂݍ���
function Load-Config {
    param (
        [string]$configFilePath
    )
    if (-not (Test-Path -Path $configFilePath)) {
        Write-Host "�ݒ�t�@�C�������݂��܂���: $configFilePath"
        exit
    }
    return Get-Content -Path $configFilePath | ConvertFrom-Json
}

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
    [PSCustomObject]$Messages
    
    # �R���X�g���N�^
    WebpConverter([PSCustomObject]$config){
        $this.DownloadPageUrl = $config.DownloadPageUrl
        $this.ExecutablePath = Join-Path $PSScriptRoot $config.ExecutablePath
        $this.ExcludedFileExtensions = $config.ExcludedFileExtensions
        $this.DefaultArguments = $config.DefaultArguments
        $this.Messages = $config.Messages
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

$configFilePath = Join-Path $PSScriptRoot "config.json"
$config = Load-Config $configFilePath

# �又��
#$args = @("K:\GitHub\toWEBPs\20240529_003857.webp")
$args = @($args)
Write-Host "#Display Run Params $($PSScriptRoot) $($args)"

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
# ���ʃJ�E���^�[�̏�����
$conversionResultDictionary = [ordered]@{}
[System.Enum]::GetValues([ConversionResult]) | ForEach-Object {
    $conversionResultDictionary.Add($_, [int]0)
}

foreach ($v in $args) {
  $result = Convert-ToWebp -webp $webp -FileName $v
  $conversionResultDictionary[$result] += 1  
}

# �����������o��
[System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("Conversion Results: Total:$($args.Length), ")
foreach ($entry in $conversionResultDictionary.GetEnumerator()) {
    if ($entry.Key -ne "None") {
        [void]$sb.Append("$($entry.Key): $($entry.Value), ")
    }
}
# �]���ȃJ���}�ƃX�y�[�X���폜
if ($sb.Length -gt 2) {
    [void]$sb.Remove($sb.Length -2, 2)
}

Write-Host $sb.ToString()

Write-Host "Sleep 15sec"
Start-Sleep -s 15
