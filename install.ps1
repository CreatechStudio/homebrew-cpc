if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey installed successfully"
}

$apiUrl = "https://api.github.com/repos/iewnfod/CAIE_Code/releases/latest"
$releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
$nupkgAsset = $releaseInfo.assets | Where-Object { $_.name -like "*.nupkg" } | Select-Object -First 1

if ($null -eq $nupkgAsset) {
    Write-Error "No matching release asset found"
    exit 1
}

$tempDir = [System.IO.Path]::GetTempPath()
$nupkgPath = Join-Path $tempDir $nupkgAsset.name
Invoke-WebRequest -Uri $nupkgAsset.browser_download_url -OutFile $nupkgPath

choco install caie_code -s "'$tempDir;https://community.chocolatey.org/api/v2/'"
