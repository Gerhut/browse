function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Administrator {
    $argumentList = @('-File', $Script:MyInvocation.MyCommand.Path) + $Script:args
    Start-Process -FilePath "PowerShell.exe" `
                  -ArgumentList $argumentList `
                  -Verb RunAs
}

function Register-Browse {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\browse" -Force
    New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\browse" `
        -Name "URL Protocol" `
        -Value ""
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\browse\shell\open\command" `
        -Value "PowerShell.exe -File ""$($Script:MyInvocation.MyCommand.Path)"" %1" `
        -Force

    Write-Host -Object "Register successfully, trying ""browse:C:\Program%20Files"""
    Start-Process -FilePath "browse:C:\Program%20Files"
}

function Unregister-Browse {
    Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\browse" -Recurse
    Write-Host -Object "Deregister successfully"
}

function Invoke-Browse {
    Add-Type -AssemblyName System.Web
    $path = $Script:args[0] -CReplace '^browse:', ''
    $path = [System.Web.HttpUtility]::UrlDecode($path)
    Write-Host "Opening", $path
    Invoke-Item -Path $path
}

if ($null -eq $args[0] -or "register" -eq $args[0]) {
    if (Test-Administrator) {
        Register-Browse
    }
    else {
        Invoke-Administrator
    }
}
elseif ("unregister" -eq $args[0]) {
    if (Test-Administrator) {
        Unregister-Browse
    }
    else {
        Invoke-Administrator
    }
}
elseif ($args[0] -CMatch '^browse:') {
    Invoke-Browse
}
else {
    Write-Error -Message "Invalid argument: $($args[0])"
}
