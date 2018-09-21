## || Messsaging  ||
## \/             \/

function Message{
    <#
    .SYNOPSIS
    Unified message
    #>
    param([String] $msg)
    process{
        Write-Output -ForegroundColor Green "[+] $msg"
    }
}

function Warning{
    <#
    .SYNOPSIS
    Unified Warning
    #>
    param([String] $warning)
    process{
        Write-Warning "$warning"
    }
}

function InstallActiveDirectoryTools {
    <#
    .SYNOPSIS
    Install Active Directory Tools
    .DESCRIPTION
    Install Active Directory Tools
    #>

    begin {
        Message "Checking for Active Directory Tools"
    }

    process {
        if ((gwmi win32_computersystem).partofdomain -eq $false)
        {
            Message("Installing Active Directory Tools")
            Import-Module ServerManager
            Install-WindowsFeature RSAT-AD-PowerShell, RSAT-AD-AdminCenter, RSAT
            Install-WindowsFeature AD-domain-services
        }
        else
        {
            Message("Active Directory Tools Installed")
        }
    }
}

## || Enable ||
## \/        \/

function EnableSharing {
    <#
    .SYNOPSIS
    Enable Sharing
    .DESCRIPTION
    Enable Sharing
    #>

    begin {
        Message "Checking Net Share"
    }

    process {
        $allshares = net share
        $autoshare = $false
        foreach ($share in $allshares) {
            if ($share -match 'autobot') {
                $autoshare = $true
            }
        }
        if ($autoshare -eq $true) {
            Write-Host "Share Has Been Enabled"
        } else{
            Write-Host "Enabling Sharing..."
            net share C=C:\ /grant:Everyone`,Full /remark:"autobot"
        }
    }
}

function EnableWDigestSupport {
    <#
    .SYNOPSIS
    Enables WDigest Support so Agent will Seed Process Honeytokens
    #>

    begin {
        Message "Checking for WDigest Support"
    }

    process {
        $val = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest
        if($val.UserLogonCredential) {
            Message "WDigest Support Enabled"
        } else {
            Message "Enabling WDigest Support"
            New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest -Name UserLogonCredential -PropertyType DWord -value 0x00000001
        }
    }
}


function Enable-PSScriptBlockLogging {
    <#
    .SYNOPSIS
    Enable Powershell Script Logging
    .DESCRIPTION
    Refer to Binary_Defense-Vision_Agent-Windows_Settings_for_Optimal_Impact.docx
    #>

    begin {
        Message "Enabling Powershell Script Blocking Logging"
    }

    process {
        $basePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'

        if(!(Test-Path $basePath)) {
            $null = New-Item $basePath -Force
        }

        Set-ItemProperty $basePath -Name EnableScriptBlockLogging -Value “1”
    }
}


function DisableFireWall {
    <#
    .SYNOPSIS
    Disable Fire Wall
    .DESCRIPTION
    Disable Fire Wall
    #>

    begin {
        Message "Stopping Firewall"
    }

    process {
        NetSh Advfirewall set allprofiles state off
    }

}

function DisableDefender{
    <#
    .SYNOPSIS
    Disable Defender
    .DESCRIPTION
    Disable Defender
    #>
    begin{
        Message "Disable Defender"
    }

    process{
        Set-MpPreference -DisableRealtimeMonitoring $true
    }
}

function DisablePasswdPolicy {
    <#
    .SYNOPSIS
    Disable Password Policy
    .DESCRIPTION
    Disable Password Policy
    #>

    begin {
        Message "Checking Current Password Policy"
    }

    process {
        if (Test-Path "C:\secpol.cfg" ) {
            Message "Password Policy Satasfactory"
        } else {
            Message "Disableing Password Policy"
            if ($env:COMPUTERNAME -eq "WIN2016"){
                secedit /configure /db C:\Windows\security\local.sdb /cfg C:\vagrant\scripts\secpol.cfg
            }
            else
            {
                secedit /export /cfg C:\secpol.cfg
                (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
                (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
                secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg
            }
            $adminPassword = "vagrant"
            Message "Setting Administrator Password to $adminPassword"
            $computerName = $env:COMPUTERNAME
            $adminUser = [ADSI]"WinNT://$computerName/Administrator,User"
            $adminUser.SetPassword($adminPassword)
        }
    }
}


## || Provisioners ||
## \/              \/

function ProvisionServer2012r2 {
    <#
    .SYNOPSIS
    Provision vagrant server 2012r2 Domain Controler
    .DESCRIPTION
    Provision vagrant server 2012r2 Domain Controler
    #>
    begin{
        Message "Provisioning server 2012r2"
    }

    process {
        EnableSharing
	Install-windowsfeature -name AD-Domain-Services –IncludeManagementTools
        EnableWDigestSupport
        DisablePasswdPolicy
        InstallActiveDirectoryTools

    }
}

function ProvisionWin10 {
    <#
    .SYNOPSIS
    Provision vagrant Windows 10
    .DESCRIPTION
    Provision vagrant Windows 10
    #>
    begin {
        Message "Provisioning Windows 10"
    }

    process {
        EnableSharing
        DisableFireWall

    }
 }