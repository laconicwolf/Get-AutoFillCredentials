# Get-AutoFillCredentials
Initializes a hidden Internet Explorer browser and browses to a list of specified URLs. For each URL, the DOM will be scraped in an attempt to find auto-filled credentials.

## Background
When logging into a site, a user can elect to store the credentials in the browser. Several security/hacking tools exist that will extract and decrypt those credentials, so the advice given today is to not store any credentials in your browser, and/or use a password manager to store the passwords. LastPass, for example, removes any credentials that you may have stored in your browser and instead stores them in its own vault upon install. I do not know of any tools that can extract and decrypt the credentials from a password vault.

This tool is a workaround for extracting passwords from systems that use password managers. The LastPass browser plugins by default will authenticate to your vault and unlock it when you open your browser. Additionally, LastPass by default will autofill your credentials that are saved for a site. This tool takes advantage of these default settings to extract credentials.

## Requirements/Notes
* This is a POC tool. There may be better ways to do this.
* This script does not work well on Windows 10. Microsoft disabled certain features of the IE COM object. All successfull testing was performed on Windows 7 against LastPass.
* The password manager browser plugin must be installed in IE.
