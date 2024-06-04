Add-Type -AssemblyName PresentationFramework

# XAML�̓ǂݍ���
# XAML�t�@�C���̃p�X
$xamlFilePath = Join-Path $PSScriptRoot "\window.xaml"

# XAML�̓ǂݍ���
$xamlContent = Get-Content -Path $xamlFilePath -Encoding utf8
$xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
$window = [System.Windows.Markup.XamlReader]::Load($xr)

#
$tabControl = $window.FindName("tabControl")

$tabWelcome = $window.FindName("tabWelcome")

$BacktButton = $window.FindName("BackButton")
$NextButton = $window.FindName("NextButton")

$Install = $window.FindName("Install")
$installButton = $window.FindName("installButton")
$installCanecelButton = $window.FindName("installCanecelButton")
$uninstallButton = $window.FindName("uninstallButton")
$uninstallCanecelButton = $window.FindName("uninstallCanecelButton")

$installfinishButton = $window.FindName("installfinishButton")
$uninstallfinishButton = $window.FindName("uninstallfinishButton")

function tabWelcome-Next {

}

#�C�x���g�n���h���[�̐ݒ�
# �߂�{�^��
$BacktButton.Add_Click({
    $SelectedIndex = [int]$tabControl.SelectedIndex
    if ($SelectedIndex -eq 0) {
            return
    }

    if ($SelectedIndex -eq 1 -or $SelectedIndex -eq 2) {
        # Welcome�^�u��
        $tabControl.SelectedIndex = 0;
        return
    }
})

# ���փ{�^��
$NextButton.Add_Click({
    $SelectedIndex = [int]$tabControl.SelectedIndex
    if ($SelectedIndex -eq 0) {
        if ($Install.IsChecked) {
            $tabControl.SelectedIndex = 1;
        }else {
            $tabControl.SelectedIndex = 2;
        }

        return
    }
})

# �C���X�g�[������
$installButton.Add_Click({
    Write-Output "Script execution cancelled by user."
    $result = [System.Windows.MessageBox]::Show("�C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        Write-HOST "Script execution cancelled by user."
        return;
    }

    $shortcutLinkCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("shortcutLinkCheckBox")
    if ($shortcutLinkCheckBox.IsChecked) {
        Write-HOST $shortcutLinkCheckBox
        Write-Output "Script execution cancelled by user."
        # �V���[�g�J�b�g��
        [string]$ShortcutLink = [string]"$env:appdata\Microsoft\Windows\SendTo\toWEBPs.lnk"
        if (Test-Path -Path $ShortcutLink) {
            $result = [System.Windows.Forms.MessageBox]::Show("`�V���[�g�J�b�g�t�@�C�������݂��܂��B�t�@�C�����㏑�����܂����H`n$($ShortcutLink)`n`n�͂�:�㏑������A������:����B",  $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                Write-Output "Script execution cancelled by user."
                return;
            }            
        }

        [string]$TargetPath = $ParentDirectory + "\toWEBPs.bat"

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut($ShortcutLink)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.WorkingDirectory = $ParentDirectory
        $Shortcut.Save()
    }

    $tabControl.SelectedIndex += 2
})
$installCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

# �A���C���X�g�[������
$uninstallButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show("�A���C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        return;
    }

    $tabControl.SelectedIndex += 2
})

$uninstallCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

$installfinishButton.Add_Click({
    $window.Close()
})
$uninstallfinishButton.Add_Click({
    $window.Close()
})

# �E�B���h�E�̕\��
$window.ShowDialog() | Out-Null
