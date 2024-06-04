Add-Type -AssemblyName PresentationFramework

function load-window {
    param($xamlFilePath)# XAML�t�@�C���̃p�X

    # XAML�̓ǂݍ���
    $xamlContent = Get-Content -Path $xamlFilePath -Encoding utf8
    $xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
    return [System.Windows.Markup.XamlReader]::Load($xr)
}

$window = load-window -xamlFilePath (Join-Path $PSScriptRoot "\window.xaml")
#
$tabControl = $window.FindName("tabControl")
$tabWelcome = $window.FindName("tabWelcome")
$backtButton = $window.FindName("BackButton")
$nextButton = $window.FindName("NextButton")

# TabControl��SelectionChanged�C�x���g�n���h����ǉ�
$tabControl.Add_SelectionChanged({
    param($sender, $e)
    try {
        # �I������Ă���^�u�̃C���f�b�N�X���擾
        $selectedIndex = [int]$tabControl.SelectedIndex
        $backtButton.Visibility = [System.Windows.Visibility]::Hidden
        # �C���f�b�N�X�Ɋ�Â��ă{�^���̃R���e���c��ύX
        switch ($selectedIndex) {
            -1 {
                return;
            }
            0 { 
                $nextButton.Content = "Next"
            }
            1 { 
                $backtButton.Visibility = [System.Windows.Visibility]::Visible
                $nextButton.Content = "Install"
            }
            2 {
                $backtButton.Visibility = [System.Windows.Visibility]::Visible
                $nextButton.Content = "Uninstall"
            }
            3 {
                $nextButton.Content = "Finish"
            }
            4 {
                $nextButton.Content = "Finish"
            }
        }
    } catch {
        Write-Host "An error occurred: $_.Exception.Message"
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
}

# �A���C���X�g�[������
function setup-uninstall {
    $result = [System.Windows.MessageBox]::Show("�A���C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        return;
    }
    Start-Process "$env:APPDATA\Microsoft\Windows\SendTo"

    $tabControl.SelectedIndex += 2
}

#�C�x���g�n���h���[�̐ݒ�
# �߂�{�^��
$backtButton.Add_Click({
    try{
        $selectedIndex = [int]$tabControl.SelectedIndex
        if ($selectedIndex -eq 1 -or $selectedIndex -eq 2) {
            $tabControl.SelectedIndex = 0
        }
    }
    catch {
        Write-Host "An error occurred: $_.Exception.Message"
    }
})

# ���փ{�^��
$nextButton.Add_Click({
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
