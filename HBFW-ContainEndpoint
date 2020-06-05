
param(
   
    [Parameter()]
    [switch]$Restore
  )
#if -Restore switch is present, restore firewall config from backup
if($Restore.IsPresent){
$SourceBackupFile = read-host "Enter source file name"
netsh advfirewall import $SourceBackupFile
}

else{
 
$BackupFilePath = read-host "Enter a path to save firewall config export"

$BackupFile = $BackupFilePath + "\Firewallconfig.wfw"

#backup current firewall config
netsh advfirewall export $BackupFile

Write-Host "Backup Firewall Config has been saved: $BackupFile"


#enable windows firewall for all provides, set default actions for inbound and outbound to block
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Block -NotifyOnListen False -AllowUnicastResponseToMulticast False -LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log

#remove all firewall rules 
Remove-NetFirewallRule -All

#disable each rule - uncomment to use this 
<##
Get-NetFirewallRule -all | ForEach-Object { 
    If ($_.Enabled -eq 'True'){
    Disable-NetFirewallRule -Name $.Name
    Write-host $_.DisplayName 'Disabled'
    }

}
##>

#allow HX agent to communicate to controller - need RemoteAddress(s)
New-NetFirewallRule -DisplayName "Allow FireEye HX Agent to Controller" -Direction Outbound -Action Allow  -Protocol TCP -RemotePort 443 -RemoteAddress 8.8.8.8 -Program "C:\Program Files (x86)\FireEye\xagt\xagt.exe"
}
