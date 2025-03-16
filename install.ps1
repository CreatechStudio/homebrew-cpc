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

# SIG # Begin signature block
# MIIEIgYJKoZIhvcNAQcCoIIEEzCCBA8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKqbHu/d2N4YgQr4JzabbTNq6
# 9JegggJOMIICSjCCAbOgAwIBAgIQ0aLAFwfw061ERXUzh5mmyjANBgkqhkiG9w0B
# AQQFADAwMS4wLAYDVQQDEyVDcmVhdGVjaCBJbnRlbGxpZ2VuY2UgKFVuaXRlZCBT
# dGF0ZXMpMB4XDTI1MDMxNjE0MjczOVoXDTM5MTIzMTIzNTk1OVowMDEuMCwGA1UE
# AxMlQ3JlYXRlY2ggSW50ZWxsaWdlbmNlIChVbml0ZWQgU3RhdGVzKTCBnzANBgkq
# hkiG9w0BAQEFAAOBjQAwgYkCgYEAreo/3LMA+fTcuaqnDMusLAhl0FN+m1OD6L/4
# g5BqS7lWbAnAcF1wYU2sCVtu7Gabagclj9VxgSz3sCsovBk5V0nLFUS1AAzAnuVp
# HG+wixtj1FpjqWZ+i1Vl8tVN2LAnPM6pH3jjYerjZzrqmi19G0wdx0K6NLxR40Ei
# 0cSaD2UCAwEAAaNlMGMwYQYDVR0BBFowWIAQ6aj0yXQHUiuWaeFAScIOGaEyMDAx
# LjAsBgNVBAMTJUNyZWF0ZWNoIEludGVsbGlnZW5jZSAoVW5pdGVkIFN0YXRlcymC
# ENGiwBcH8NOtREV1M4eZpsowDQYJKoZIhvcNAQEEBQADgYEAjcP7NCLr45+ox8q5
# i+ynWd1Ri1zTdPDol6tQuLiEAuH2uWya0IDeUw/fdHziauNt6tmiCDtggId34rD+
# B2BJoGucp1TSLpQ8WLiuWTDGtEpW0zXEXPlBChl6DBPZLafvjjFCSbCULH1IOnUX
# haA8l0dX9BQ9dgxJegK0XZi5t0gxggE+MIIBOgIBATBEMDAxLjAsBgNVBAMTJUNy
# ZWF0ZWNoIEludGVsbGlnZW5jZSAoVW5pdGVkIFN0YXRlcykCENGiwBcH8NOtREV1
# M4eZpsowCQYFKw4DAhoFAKBSMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMCMGCSqGSIb3DQEJBDEWBBQH7/30PO66TABeffjk1znu
# GcC6tTANBgkqhkiG9w0BAQEFAASBgEIJml/L6pvDi3Afpoz3C0V+33wpFxxnCXCp
# v2smWJBSVP5DQDalf8LvGxcTTdhVveW0bO0k9kqfXTi7y+k6+LtIf+IMYM88aQXW
# d7wwpyH1OAy7eY2vDKh8Dw5ubCRkvCVjLA/+2Tt5RemMQeyLxsMhzl02zWLmS4I1
# UO1PVM5b
# SIG # End signature block
