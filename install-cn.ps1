if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey installed successfully"
}

Write-Output "Detecting Dependencies"
Write-Output "Checking for Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Git..."
    choco install git -y
} else {
    Write-Output "Git is already installed"
}
Write-Output "Checking for Python 3..."
$interpreters = @("python", "python3", "pypy", "pypy3")
$min_version = [version]"3.10.0"
$found = $false
$python_exe = ""
foreach ($exe in $interpreters) {
    try {
        if (Get-Command $exe -ErrorAction SilentlyContinue) {
            $version_string = & $exe --version 2>$null
            if ($version_string -match "Python (\d+)\.(\d+)\.(\d+)") {
                $version = [version]"$($matches[1]).$($matches[2]).$($matches[3])"
                if ($version -ge $min_version) {
                    $found = $true
                    $python_exe = $exe
                    break
                }
            }
        }
    }
    catch {
        continue
    }
}
if ($found) { 
    Write-Output "Python 3 is already installed"
} else {
    Write-Output "Installing Python 3..."
    choco install python -y
    $python_exe = "python"
}

$apiUrl = "https://cpc.atcrea.tech/release_api.json"
$releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
$nupkgAsset = $releaseInfo.assets | Where-Object { $_.name -like "*.nupkg" } | Select-Object -First 1

if ($null -eq $nupkgAsset) {
    Write-Error "No matching release asset found"
    exit 1
}

Write-Output "Downloading CAIE_Code"
$tempDir = [System.IO.Path]::GetTempPath()
$nupkgPath = Join-Path $tempDir $nupkgAsset.name
$nupkgWebPath = $nupkgAsset.browser_download_url
Invoke-WebRequest -Uri "https://github.createchstudio.com/$nupkgWebPath" -OutFile $nupkgPath

choco install caie-code -s "'$tempDir;https://community.chocolatey.org/api/v2/'" -y


$toolsdir = "$env:LOCALAPPDATA\CAIE_Code"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

git config --global --add safe.directory "$toolsdir\CAIE_Code-stable"

Set-Location "$toolsdir\CAIE_Code-stable"

$remote = "https://gitee.com/ricky-tap/CAIE_Code.git"

Write-Output "Initializing Git Repository"
git init
git remote add origin $remote
git fetch origin
git reset --hard origin/stable
git checkout -b stable origin/stable

Write-Output "Initializing Pip"
& $python_exe -m ensurepip
& $python_exe -m pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/

Write-Output "Installing Dependencies"
cpc -init
