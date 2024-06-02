class Webp {
    [string]$FilePath
    # èàóùèúäOëŒè€ÇÃägí£éqÇÃîzóÒ
    [string[]]$ExcludedExtensions
    #[string]$Arguments

    Webp(){
        $this.FilePath = [System.Environment]::GetFolderPath("Desktop") + "\ConvertWebp\cwebp.exe"
        $this.ExcludedExtensions = @(".webp", ".exe", ".bat", ".ps1")
	#$this.Arguments = ""
    }

    [string]ToString(){
        return $this.FilePath
    }
}

function Convert-Webp {
    param ([Webp]$webp, [string]$FileName)
    Write-Output "#Convert-Webp Start"
    if ($FileName.length -eq 0) {
        Write-Output "Skipping empty filename"
        return;
    }

    Write-Output "source: $FileName"

    $Extension = [System.IO.Path]::GetExtension($FileName)
    if ($webp.ExcludedExtensions -contains $Extension) {
        Write-Output "Skipping file with extension $($Extension):  $($FileName)"
        return;
    }

    $FilePath = [System.IO.Path]::GetDirectoryName($FileName)
    $GenerateFileName = [System.IO.Path]::ChangeExtension($FileName, ".webp")    
    $Arguments = @("-preset photo", "-metadata icc", "-sharp_yuv", "-o" + $GenerateFileName, "-progress", "-short", "" +$FileName) -join " "
    Write-Output $webp.ToString()
    Write-Output $Arguments
    Start-Process -FilePath $webp.FilePath -ArgumentList $Arguments
    #$webp.Convert($FileName)
    Write-Output "#Convert-Webp End"
}

function Process-Strings {
  param (
      $webp,
      $strings
  )
  Write-Output "Process-Strings"
  Write-Output $strings
  foreach ($string in $strings) {
    Convert-Webp -webp $webp -FileName $string
  }
}

$args = @($args)
Write-Output "#Script Start"
Write-Output $args
Write-Output "----Start-Sleep--------"
Write-Output $MyInvocation.MyCommand.Path
Write-Output "webp"
[Webp]$webp = [Webp]::new()
Write-Output $webp.ToString()
Write-Output "Process-Strings"

foreach ($v in $args) {
  Write-Output "Process-Strings END"
  Write-Output $v
  Convert-Webp -webp $webp -FileName $v
}
Process-Strings -webp $webp -strings $args
#Convert-Webp $webp $args[1]
Write-Output "#Script End"
Write-Output "Sleep 15sec"
Start-Sleep -s 15
