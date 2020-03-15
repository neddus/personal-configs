function prompt {
    if ($null -ne $GitPromptScriptBlock) {
        & $GitPromptScriptBlock
    }
    else {
        "$($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1))"
    }
    $path = $executionContext.SessionState.Path.CurrentLocation
    $segments = [uri]::new($path).Segments
    $prompt = ""
    for ($i = $segments.Count - 1; $i -gt 1; $i--) {
        $prompt += $segments[$i].Trim('/') + "←"
    }
    $prompt += $segments[1].Trim('/')

    $Host.UI.RawUI.WindowTitle = $prompt # Display path components in reverse order in window title
}

function pg {
    Import-Module posh-git
}

function google {
    param (
        [string]$Query
    )
    $UrlEncodedQuery = [uri]::EscapeDataString($Query)
    ff -Arguments "https://www.google.com/search?q=$UrlEncodedQuery"
}

function editprofile {
    &code $m.profile
}

function New-PowerShell {
    param(
        [String]$WorkingDirectory = $PWD
    )
    Start-Process pwsh -WorkingDirectory $WorkingDirectory
}

function ff {
    param(
        [String[]]$Arguments
    )
    Start-Process -FilePath $m.firefox -ArgumentList $Arguments
}

function ga() { git.exe add -A }
function gst() { git.exe status }
function gas() { git.exe add -A; git.exe status }
function glog() { Clear-Host; git.exe --no-pager log --oneline --graph -n 20 --all --format=format:"%<(60,trunc)%s %Cgreen%<(40,ltrunc)%d%Creset" --date-order; Write-Output "`n" }


Set-Alias grep Select-String
Set-Alias ep editprofile
Set-Alias np New-PowerShell
Set-Alias which where.exe
Set-Alias tail Get-FileTail
Set-Alias gh Get-Help




Function Invoke-RDP {
    param
    (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            Mandatory = $true,
            HelpMessage = "Server"
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,
        [Parameter(
            Position = 1,
            ValueFromPipeline = $true,
            Mandatory = $true,
            HelpMessage = "Credentials"
        )]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $Credentials
    )
    $user = $Credentials.GetNetworkCredential().UserName
    $password = $Credentials.GetNetworkCredential().Password
    cmdkey.exe /generic:TERMSRV/$server /user:$user /pass:$password
    mstsc.exe /v:$Server /f /admin
    Wait-Event -Timeout 5
    cmdkey.exe /Delete:TERMSRV/$server
}

Function Map-Unc {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path,
        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credentials
    )
    if (!([Uri]::new($Path).IsUnc)) {
        return
    }
    $user = $Credentials.GetNetworkCredential().UserName
    $password = $Credentials.GetNetworkCredential().Password
    net.exe use $Path /user:$user $password
}

$myDictionary = @{ }
$myDictionary.profile = $profile.CurrentUserAllHosts
$myDictionary.firefox = "C:\Program Files\Mozilla Firefox\firefox.exe"
$myDictionary.sysinternals = "C:\ProgramData\chocolatey\lib\sysinternals"
$m = $([PSCustomObject]$myDictionary) # Less members for autocompletion compared to the hash
