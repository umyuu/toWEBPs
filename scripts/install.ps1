Add-Type -AssemblyName System.Windows.Forms

# toWEBPs.ps1�̃f�B���N�g��
[string]$ParentDirectory = Split-Path $PSScriptRoot -Parent
# �V���[�g�J�b�g��
[string]$ShortcutLink = [string]"$env:appdata\Microsoft\Windows\SendTo\toWEBPs.lnk"

if (Test-Path -Path $ShortcutLink) {
    $result = [System.Windows.Forms.MessageBox]::Show("`�V���[�g�J�b�g�t�@�C�������݂��܂��B�t�@�C�����㏑�����܂����H`n$($ShortcutLink)`n`n�͂�:�㏑������A�A������:�A�v�����I������B", "toWEBPs:�m�F", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-Output "Script execution cancelled by user."
        exit 1
    }
}

[string]$TargetPath = $ParentDirectory + "\toWEBPs.bat"

$WshShell = New-Object -comObject WScript.Shell

$Shortcut = $WshShell.CreateShortcut($ShortcutLink)
$Shortcut.TargetPath = $TargetPath
$Shortcut.WorkingDirectory = $ParentDirectory
$Shortcut.Save()

$_ = [System.Windows.Forms.MessageBox]::Show("`�C���X�g�[�����܂����BWebP�ɕϊ��������t�@�C����I�������郁�j���[����toWEBPs��I������Ǝ��s���܂��B", "toWEBPs:����I��", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
