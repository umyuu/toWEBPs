Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
# ���s�f�B���N�g����ύX���܂��B
Set-Location -Path (Split-Path $PSScriptRoot -Parent)
[string]$ParentDirectory = Get-Location
. "$($ParentDirectory)\scripts\utils.ps1"
$config = Load-Config -configFilePath (Join-Path $ParentDirectory "config.json")

$window = Load-Window -xamlFilePath (Join-Path $ParentDirectory "scripts\installWizard.xaml")

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
    $result = [System.Windows.MessageBox]::Show("�C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
    {
        Write-HOST "Script execution cancelled by user."
        return;
    }

    $shortcutLinkCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("ShortCutLinkCheckBox")
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

        [string]$TargetPath = Join-Path $ParentDirectory "toWEBPs.bat"

        $WshShell = New-Object -comObject WScript.Shell

        $Shortcut = $WshShell.CreateShortcut($ShortcutLink)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.WorkingDirectory = $ParentDirectory
        $Shortcut.Save()
    }
    
    $downloadLinkCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("DownloadLinkCheckBox")
    if ($downloadLinkCheckBox.IsChecked) {
        # WebP�̎��s�t�@�C���̃`�F�b�N
        $WebPExecutablePath = Join-Path $ParentDirectory $config.ExecutablePath
        if (-not (Test-Path -Path $WebPExecutablePath)) {
            $result = [System.Windows.Forms.MessageBox]::Show("`WebP�̎��s�t�@�C�������݂��܂���B`n$($WebPExecutablePath)`n`n�_�E�����[�h�y�[�W���J���܂����H`n$($config.DownloadPageUrl)`n�͂�:�J���A������:���s����B", "�m�F:toWEBPs", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                Start-Process $config.DownloadPageUrl
            } else {
                Write-Host "Script execution cancelled by user."
            }
        }    
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

    $oepnSendToCheckBox = [System.Windows.Controls.CheckBox]$window.FindName("OepnSendToCheckBox")
    if ($oepnSendToCheckBox.IsChecked) {
        Start-Process "$env:APPDATA\Microsoft\Windows\SendTo"    
    }

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
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_.Exception.Message",  $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        
    }
})

# �E�B���h�E�̕\��
$window.ShowDialog() | Out-Null
