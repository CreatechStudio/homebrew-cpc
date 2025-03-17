function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    $newProcess = Start-Process powershell -ArgumentList "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; irm https://atcrea.tech/cpc.ps1 | iex" -Verb RunAs -PassThru
    if ($newProcess -eq $null) {
        Write-Error "You must run this script as an administrator"
    }
    $newProcess.WaitForExit()
} else {
    $tempDir = [System.IO.Path]::GetTempPath()
    $scriptUrl = "https://cpc.atcrea.tech/install.ps1"
    $scriptPath = Join-Path $tempDir "install.ps1"

    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    & $scriptPath

    Write-Output "CAIE_Code Installed Successfully"
    Set-Location $env:USERPROFILE
}

Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
