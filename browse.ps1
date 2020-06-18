Function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    Return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Function Invoke-Administrator {
    $argumentList = @('-File', $Script:MyInvocation.MyCommand.Path) + $Script:args
    Start-Process -FilePath 'powershell.exe' `
                  -ArgumentList $argumentList `
                  -Verb RunAs
    Exit
}

If (-not (Test-Administrator)) {
    Invoke-Administrator
}

Function Register-Browse {
    New-Item -Path 'Registry::HKEY_CLASSES_ROOT\browse' -Force
    New-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\browse' `
                     -Name 'URL Protocol' `
                     -Value ''
    New-Item -Path 'Registry::HKEY_CLASSES_ROOT\browse\shell\open\command' `
             -Value 'cmd.exe /V:ON /C "set P=%1 && explorer.exe !P:~7!"' `
             -Force

    Write-Host -Object 'Register successfully, trying "browse:file:///C:/Program%20Files"'
    Start-Process -FilePath 'browse:file:///C:/Program%20Files'
}

Function Unregister-Browse {
    Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\browse' -Recurse
    Write-Host -Object 'Unregister successfully'
}

If ($null -eq $args[0] -or 'register' -eq $args[0]) {
    Register-Browse
}
Elseif ('unregister' -eq $args[0]) {
    Unregister-Browse
}
Else {
    Write-Error -Message "Invalid argument: $($args[0])"
}
