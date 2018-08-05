# Source: https://github.com/StefanScherer/adfs2

param ([String] $ip)

function FixNetWork
{
    param ([String] $ip)

    process {

        Write-Host "[+] Attempting to Fix Second Network"
        $iplist = $ip -split '\.'
        $subnet = $iplist[0], $iplist[1], $iplist[2] -join "."
        $dns = "$subnet.2"

        Write-Host "[+] IP: $ip DNS: $dns Subnet: $subnet"
        try
        {
            $name = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript { ($_.IPAddress).startswith('192.168.32') }).InterfaceAlias
            Write-Host "[+] Ethernet: $name"
        }
        catch
        {
            Write-Error "Getting name failed"
        }
        try
        {
            Write-Host "[+] Set IP address to $ip of interface $name"
            & netsh.exe int ip set address "$name" static $ip 255.255.255.0 "$subnet.1"
        }
        catch
        {
            Write-Host "[+] Skipping set IP"
        }
        try
        {
            Write-Host "[+] Set DNS server address to $dns of interface $name"
            & netsh.exe interface ipv4 add dnsserver "$name" address = $dns index = 1
        }
        catch
        {
            Write-Warning "[!] Could not find a interface with subnet $subnet.xx"
        }
    }
}

FixNetWork $ip