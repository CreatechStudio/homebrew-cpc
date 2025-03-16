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

# SIG # Begin signature block
# MIIEIgYJKoZIhvcNAQcCoIIEEzCCBA8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaQWh/zanyzvmVxnl2DsLwV/c
# eESgggJOMIICSjCCAbOgAwIBAgIQYLJ1zsLlBqJJ+B8r/WQkMzANBgkqhkiG9w0B
# AQQFADAwMS4wLAYDVQQDEyVDcmVhdGVjaCBJbnRlbGxpZ2VuY2UgKFVuaXRlZCBT
# dGF0ZXMpMB4XDTI1MDMxNjE0MjUxNVoXDTM5MTIzMTIzNTk1OVowMDEuMCwGA1UE
# AxMlQ3JlYXRlY2ggSW50ZWxsaWdlbmNlIChVbml0ZWQgU3RhdGVzKTCBnzANBgkq
# hkiG9w0BAQEFAAOBjQAwgYkCgYEAreo/3LMA+fTcuaqnDMusLAhl0FN+m1OD6L/4
# g5BqS7lWbAnAcF1wYU2sCVtu7Gabagclj9VxgSz3sCsovBk5V0nLFUS1AAzAnuVp
# HG+wixtj1FpjqWZ+i1Vl8tVN2LAnPM6pH3jjYerjZzrqmi19G0wdx0K6NLxR40Ei
# 0cSaD2UCAwEAAaNlMGMwYQYDVR0BBFowWIAQ6aj0yXQHUiuWaeFAScIOGaEyMDAx
# LjAsBgNVBAMTJUNyZWF0ZWNoIEludGVsbGlnZW5jZSAoVW5pdGVkIFN0YXRlcymC
# EGCydc7C5QaiSfgfK/1kJDMwDQYJKoZIhvcNAQEEBQADgYEAe+oetGbYIu2SlwKU
# nHlSv/RWbdAA9+Y+97pV/dgw/NOia2+UIHSSWiV1W04jxGEni4TqfadzXTt5EF75
# iR3+RMV8LNl5DtSRszMAibm0+wiHqHXGnsLiDnwNq0xu7lBJq3p1pRsKDRNnhcNT
# fFBh12CI9mKY32znj259RDJsQ4sxggE+MIIBOgIBATBEMDAxLjAsBgNVBAMTJUNy
# ZWF0ZWNoIEludGVsbGlnZW5jZSAoVW5pdGVkIFN0YXRlcykCEGCydc7C5QaiSfgf
# K/1kJDMwCQYFKw4DAhoFAKBSMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMCMGCSqGSIb3DQEJBDEWBBThONYULsT1Q3bCJTQzs6qE
# t7eVgzANBgkqhkiG9w0BAQEFAASBgIru1L0VxCrlw7UHhLWKiMNeIlPluoDg4XoO
# 3bC39xfq843IeWsrrrL2r0QBLvNVkgkWl/HTsQyMnFwDikbl3E4o1IuMKc7UXQrn
# WACKwQlzZXQhA0sxSZlu3ZjAb9kKR2jdTeUPLq4Vq2kBrGDCmYujBAhE1T7O09PG
# ZJB57kLq
# SIG # End signature block
