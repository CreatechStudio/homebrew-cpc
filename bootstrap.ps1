function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    $newProcess = Start-Process powershell -ArgumentList "irm https://atcrea.tech/cpc.ps1 | iex" -Verb RunAs -PassThru
    $newProcess.WaitForExit()
    exit
}

$tempDir = [System.IO.Path]::GetTempPath()
$scriptUrl = "https://cpc.atcrea.tech/install.ps1"
$scriptPath = Join-Path $tempDir "install.ps1"

Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath
