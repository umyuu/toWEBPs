Add-Type -AssemblyName PresentationFramework

# XAML�̓ǂݍ���
# XAML�t�@�C���̃p�X
$xamlFilePath = Join-Path $PSScriptRoot "\window.xaml"

# XAML�̓ǂݍ���
$xamlContent = Get-Content -Path $xamlFilePath -Raw
$xr = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlContent))
$window = [System.Windows.Markup.XamlReader]::Load($xr)

# �C�x���g�n���h���̐ݒ�
$installButton = $window.FindName("InstallButton")
$uninstallButton = $window.FindName("UninstallButton")

$installButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show("�C���X�g�[�����܂����H", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if (-not ($result -eq [System.Windows.Forms.MessageBoxButtons]::Yes))
    {
        return;
    }

    # �C���X�g�[�������������ɋL�q
    Start-Sleep -Seconds 2  # �����̃V�~�����[�V����
    [System.Windows.MessageBox]::Show("Installation Completed", $window.Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    $window.Close()
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

# �E�B���h�E�̕\��
$window.ShowDialog() | Out-Null
