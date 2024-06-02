@powershell -NoProfile -ExecutionPolicy Unrestricted "$s=[scriptblock]::create((gc \"%~f0\"|?{$_.readcount -gt 1})-join\"`n\");&$s "%~dp1 %*&goto:eof

class Webp {
    [string]$FilePath
    #[string]$Arguments

    Webp(){
        $this.FilePath = [System.Environment]::GetFolderPath("Desktop") + "\ConvertWebp\cwebp.exe"
	#$this.Arguments = ""
    }

    [string]ToString(){
        return $this.FilePath
    }
}

function Convert-Webp {
  param ($webp, $FileName)
  Write-Output "=================="
  Write-Output $FileName
  Write-Output "=================="
  $Extension = [System.IO.Path]::GetExtension($FileName)
  if ($Extension -eq ".webp") {
    return;
  }

  $FilePath = [System.IO.Path]::GetDirectoryName($FileName)
  $GenerateFileName = [System.IO.Path]::ChangeExtension($FileName, ".webp")
  Write-Output "<source: $FileName>"
  $Arguments = @("-preset photo", "-metadata icc", "-sharp_yuv", "-o" + $GenerateFileName, "-progress", "-short", "" +$FileName) -join " "
  Write-Output $webp.ToString()
  Write-Output $Arguments
  Start-Process -FilePath $webp.FilePath -ArgumentList $Arguments
#$webp.Convert($FileName)
  Write-Output "----------------"
}

[Webp]$webp = [Webp]::new()
Write-Output $webp.ToString()

Convert-Webp $webp $args[1]
Start-Sleep -s 5
