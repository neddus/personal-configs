# Prompt
# Displays path components in reverse order in window title
# "C:\temp\subfolder" becomes "subfolder<-temp<-C:"

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
    
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        $prompt = "[Admin] $prompt"
    }
    $Host.UI.RawUI.WindowTitle = $prompt
}

function wtwsl {
    wt -p "Ubuntu-20.04"
}

# Aliases

Set-Alias grep Select-String
Set-Alias which where.exe
Set-Alias gh Get-Help
Set-Alias ep edit-profile
Set-Alias pg import-poshgit
Set-Alias sudowt Invoke-Elevated 
Set-Alias ctj ConvertTo-Json
Set-Alias cfj ConvertFrom-Json
Set-Alias gh gh.exe

# Functions

function tail {
    param (
        [string]$FileName
    )
    Get-Content -Path $FileName -Tail 20 -Wait
}

function Invoke-Elevated {
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Start-Process -FilePath wt.exe -Verb Runas
    }
}

function Set-EnvironmentVariable {
    param (
        [string]$Key,
        [string]$Value,
        [switch]$Machine
    )
    if ($Machine) {
        [System.Environment]::SetEnvironmentVariable($Key, $Value, [System.EnvironmentVariableTarget]::Machine)
    }
    else {
        [System.Environment]::SetEnvironmentVariable($Key, $Value, [System.EnvironmentVariableTarget]::User)
    }
}

function explore {
    param([string]$Path)
    Start-Process explorer.exe -ArgumentList $Path
}

function .. {
    Set-Location ..
}

function killall {
    param(
        [string]$Name
    )
    $p = Get-Process -Name $Name | Where-Object { $_ -ne $PID } 
    $p.where{ $_.ID -ne $PID }.foreach{ $_.Kill() }
    $p.where{ $_.ID -eq $PID }.foreach{ $_.Kill() }
}

function touch {
    param (
        [string]$FileName
    )
    New-Item -Name $FileName -ItemType File
}

function edit-profile {
    &code $PROFILE.CurrentUserCurrentHost
}


function import-poshgit {
    Import-Module posh-git
}

function ga {
    git.exe add -A
}

function gst {
    git.exe status
}

function glog {
    Clear-Host; git.exe --no-pager log --oneline --graph -n 30 --all --format=format:"%<(60,trunc)%s %Cgreen%<(40,ltrunc)%d%Creset" --date-order; Write-Output "`n"
}

Function Invoke-RDP {
    param
    (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            Mandatory = $true

        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,
        [Parameter(
            Position = 1,
            ValueFromPipeline = $true,
            Mandatory = $true
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

Function Connect-Unc {
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
