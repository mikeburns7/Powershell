#script to add to csp (azure, aws, gcp) vm's bootstrap process to deploy a VM then configure that VM as a domain controller
New-NetIPAddress –InterfaceAlias “Ethernet0” –IPAddress “10.0.10.20” –PrefixLength 24 -DefaultGateway 10.0.10.253

Set-DnsClientServerAddress -InterfaceAlias “Ethernet0” -ServerAddresses 10.0.10.10, 127.0.0.1

Rename-Computer -NewName "dc2" -Force -Restart

Add-WindowsFeature AD-Domain-Services
