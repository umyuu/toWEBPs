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
$nextButton = $window.FindName("nextButton")
$Install = $window.FindName("Install")
$installButton = $window.FindName("installButton")
$installCanecelButton = $window.FindName("installCanecelButton")
$uninstallButton = $window.FindName("uninstallButton")
$uninstallCanecelButton = $window.FindName("uninstallCanecelButton")
#�C�x���g�n���h���[�̐ݒ�
$nextButton.Add_Click({
    if ($Install.IsChecked)
    {
        $tabControl.SelectedIndex = 1;
    }else {
        $tabControl.SelectedIndex = 2;
    }
})

# �C���X�g�[���{�^��
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

        $result = [System.Windows.Forms.MessageBox]::Show("`�V���[�g�J�b�g�t�@�C�������݂��܂��B�C���X�g�[�����܂����H`n$($ShortcutLink)`n`n�͂�:�㏑������A�A������:�A�v�����I������B", "toWEBPs:�m�F", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

        if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
            Write-Output "Script execution cancelled by user."
            return;
            exit 1
        }

        if (Test-Path -Path $ShortcutLink) {
            $result = [System.Windows.Forms.MessageBox]::Show("`�V���[�g�J�b�g�t�@�C�������݂��܂��B�t�@�C�����㏑�����܂����H`n$($ShortcutLink)`n`n�͂�:�㏑������A�A������:�A�v�����I������B", "toWEBPs:�m�F", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                Write-Output "Script execution cancelled by user."
                exit 2
            }
        }

        [string]$TargetPath = $ParentDirectory + "\toWEBPs.bat"

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut($ShortcutLink)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.WorkingDirectory = $ParentDirectory
        $Shortcut.Save()
    }



    $_ = [System.Windows.Forms.MessageBox]::Show("`�C���X�g�[�����܂����BWebP�ɕϊ��������t�@�C����I�������郁�j���[����toWEBPs��I������Ǝ��s���܂��B", $window.Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

    $window.Close()
})
$installCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

$uninstallButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show("�A���C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if (-not ($result -eq [System.Windows.Forms.MessageBoxButtons]::Yes))
    {
        return;
    }


    # �A���C���X�g�[�������������ɋL�q
    Start-Sleep -Seconds 2  # �����̃V�~�����[�V����
    [System.Windows.MessageBox]::Show("Uninstallation Completed", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    $window.Close()
})

$uninstallCanecelButton.Add_Click({
    $tabControl.SelectedIndex = 0
})

# �E�B���h�E�̕\��
$window.ShowDialog() | Out-Null
