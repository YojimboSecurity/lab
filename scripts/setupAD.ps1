
param ([String] $ip)

function SetUpAd
{

    param ([String] $ip)

    process {

        $subnet = $ip -replace "\.\d+$", ""

        if ((gwmi win32_computersystem).partofdomain -eq $false)
        {
            Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
	    Write-Host "[+] Setting Up Active Directory"
            Import-Module ServerManager
            Import-Module ADDSDeployment

            Write-Host '[+] Creating domain controller'

            $PlainPassword = "vagrant" # "P@ssw0rd"
            $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

            # Windows Server 2016 R2
            # Install-WindowsFeature AD-domain-services
            $Server = $env:ComputerName
            if ($Server -eq "Win2016")
            {
                $Server = "Win2012r2"
                Install-ADDSForest -SafeModeAdministratorPassword $SecurePassword -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode $Server -DomainName "windomain.local" -DomainNetbiosName "WINDOMAIN" -ForestMode $Server -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$true  -SysvolPath "C:\Windows\SYSVOL" -Force:$true
            }
            else
            {
                Install-ADDSForest -SafeModeAdministratorPassword $SecurePassword -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode $Server -DomainName "windomain.local" -DomainNetbiosName "WINDOMAIN" -ForestMode $Server -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$true  -SysvolPath "C:\Windows\SYSVOL" -Force:$true
            }
            $newDNSServers = "8.8.8.8", "4.4.4.4"
            $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
            if ($adapters)
            {
                Write-Host "[+] Setting DNS"
                $adapters | ForEach-Object { $_.SetDNSServerSearchOrder($newDNSServers) }
            }

            Write-Host "[+] Setting timezone to UTC"
            c:\windows\system32\tzutil.exe /s "UTC"
            Write-Host "[+] Excluding NAT interface from DNS"
        }
    }
}

SetUpAd $ip
