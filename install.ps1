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

choco install caie-code -s "'$tempDir;https://community.chocolatey.org/api/v2/'" -y

Write-Output "CAIE_Code Downloaded"
Write-Output "Creating Git Repository"

$toolsdir = "$env:LOCALAPPDATA\CAIE_Code"

function Update-SessionEnvironment {
    $envKeys = [System.Environment]::GetEnvironmentVariables("User").Keys + [System.Environment]::GetEnvironmentVariables("Machine").Keys
    foreach ($key in $envKeys) {
        $envValue = [System.Environment]::GetEnvironmentVariable($key, "User")
        if (-not $envValue) {
            $envValue = [System.Environment]::GetEnvironmentVariable($key, "Machine")
        }
        Set-Item -Path "Env:\$key" -Value $envValue -ErrorAction SilentlyContinue
    }
}

Update-SessionEnvironment

git config --global --add safe.directory "$toolsdir\CAIE_Code-stable"

Set-Location "$toolsdir\CAIE_Code-stable"

$response = Invoke-WebRequest -Uri "https://cdn.createchstudio.com/cdn-cgi/trace" -UseBasicParsing
$location = ($response.Content -split "`n" | Where-Object { $_ -match "^loc=" }) -replace "loc=",""

if ($location -eq "CN") {
    $remote = "http://gitee.com/ricky-tap/CAIE_Code.git"
} else {
    $remote = "https://github.com/iewnfod/CAIE_Code.git"
}

git init
git remote add origin https://github.com/iewnfod/CAIE_Code.git
git fetch origin
git reset --hard origin/stable
git checkout -b stable origin/stable

Write-Output "Initializing Pip"
pypy3 -m ensurepip

Write-Output "Installing Dependencies"
cpc -init

Write-Output "CAIE_Code Installed Successfully"

Set-Location $env:USERPROFILE
