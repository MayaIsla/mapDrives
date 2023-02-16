<#param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'running with full privileges'#>

#extract domain with Login ID (BECN\LOGINID)
$CurrentUserLoggedIn = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object username).username

#Splits domain from LoginID, "\" as the delim. 
$output = $CurrentUserLoggedIn.split("\")[0]

#Outputs everything AFTER the delim ("\"), outputting the loginID of the computer.
$userExtracted = $CurrentUserLoggedIn.split("\")[1]



#Map common drives
New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\server\public" -Persist
New-PSDrive -Name "S" -PSProvider "FileSystem" -Root "\\server\" -Persist
New-PSDrive -Name "O" -PSProvider "FileSystem" -Root "\\server\ops\" -Persist


#map home drive

try {
    New-PSDrive -Name "H" -PSProvider "FileSystem" -Root "\\server\home$\$userExtracted" -Persist -ErrorAction Stop
    
}
catch [System.Management.Automation.ActionPreferenceStopException]
{ 
    Write-Host "Drive does not exist. Cannot be mapped, dummy."
}

