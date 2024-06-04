Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

function Question-YesNo {
    param (
        [string]$Text,
        [string]$Title
    )
    retrun [System.Windows.MessageBox]::Show($Text, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
}

# JSON�ݒ�t�@�C���̓ǂݍ���
function Load-Config {
    param (
        [string]$configFilePath
    )
    if (-not (Test-Path -Path $configFilePath)) {
        throw "�ݒ�t�@�C�������݂��܂���: $configFilePath"
    }

    return Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
}

function Load-Window {
    param(
        [string]$xamlFilePath # XAML�t�@�C���̃p�X
    )
    # XAML�̓ǂݍ���
    $xamlContent = Get-Content -Path $xamlFilePath -Encoding utf8
    $xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
    return [System.Windows.Markup.XamlReader]::Load($xr)
}