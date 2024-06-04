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

# TabControl��SelectionChanged�C�x���g�n���h����ǉ�
$tabControl.Add_SelectionChanged({
    param($sender, $e)
    
    # �I������Ă���^�u�̃C���f�b�N�X���擾
    $selectedIndex = [int]$tabControl.SelectedIndex

    # �C���f�b�N�X�Ɋ�Â��ă{�^���̃R���e���c��ύX
    switch ($selectedIndex) {
        0 { $nextButton.Content = "Next" }
        1 { $nextButton.Content = "Install" }
        2 { $nextButton.Content = "Uninstall" }
        3 { $nextButton.Content = "Finish" }
        4 { $nextButton.Content = "Finish" }
    }
})
# �C���X�g�[������
function setup-install {
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
    #$NextButton.Content = "Close"
}

# �A���C���X�g�[������
function setup-uninstall {
    $result = [System.Windows.MessageBox]::Show("�A���C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        return;
    }

    $tabControl.SelectedIndex += 2
}

#�C�x���g�n���h���[�̐ݒ�
# �߂�{�^��
$BacktButton.Add_Click({
    try{
        $selectedIndex = [int]$tabControl.SelectedIndex
        switch ($selectedIndex) {
            1 {
                $tabControl.SelectedIndex = 0;
            }
            2 {
                $tabControl.SelectedIndex = 0;
            }
       }
    }
    catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# ���փ{�^��
$NextButton.Add_Click({
    try{
        $selectedIndex = [int]$tabControl.SelectedIndex
        switch ($selectedIndex) {
            0 {
                $Install = $window.FindName("Install")
                if ($Install.IsChecked) {
                    $tabControl.SelectedIndex = 1;
                } else {
                    $tabControl.SelectedIndex = 2;
                }
            }
            1 {
                setup-install
            }
            2 {
                setup-uninstall
            }
            3 {
                $window.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $window.Close()
            }
            4 {
                $window.DialogResult = [System.Windows.Forms.DialogResult]::OK
                $window.Close()
            }
            default { throw "Unknown index: $selectedIndex" } # ���̑��̏ꍇ�̏���
        }
    }
    catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# �E�B���h�E�̕\��
$window.ShowDialog() | Out-Null
