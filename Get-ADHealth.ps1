  <#
    .SYNOPSIS
    Creates an HTML report for ALL Domain Controllers in the domain. 
    

    .DESCRIPTION
    Script - Not fully containted, need to Import ActiveDirectory
    Script meant to run on an "admin server" with AD tools installed
    Script is meant to be run from a scheduled task but can be run standalone
    Script will take a long time (1 - 3 hours) depending on size for domain. 
    
    
    Modified by: Mike Burns
    Created by: Michael Lindsley
    Org Date: 07/01/14
    https://gallery.technet.microsoft.com/AD-Mega-Domain-Report-ad7dbada
    Edited date: 12/10/19
    Org Version 1.00.00
    Version 1.01.03
    
    Edit Notes:
    12/10/19 - Modified by Mike BUrns
    08/19/14 - Domain Tweak - Michael Lindsley
    08/26/14 - Modifed alert threshold to 15% and added verbage to html output for threshold - ver 1.01.01
    09/23/14 - Modified/fixed Summary and Failure counts - ver 1.01.02
    12/10/14 - Removed 3rd IPv4 Address from report - ver 1.01.03

    .PARAMETER $null
    
    .Example
    WPMonsterDomainReport.ps1
    .Example
    WPMonsterDomainReport.ps1 -Debug
      
    

#>
# Increase buffer width/height to avoid PowerShell from wrapping the text before
# sending it back to PHP (this results in weird spaces).

$dnsdomainsuffix = Read-Host -Prompt 'Input your domain suffix e.g. burns.local'
$OutFilePath = Read-Host -Prompt 'Input the path where you would like to save the output'

$pshost = Get-Host
$pswindow = $pshost.ui.rawui
$newsize = $pswindow.buffersize
$newsize.height = 3000
$newsize.width = 400
$pswindow.buffersize = $newsize

#variables
$ScriptVer = "1.01.03"
[int]$AlertThreshold = 12
[int]$UrgentThreshold = 8
Import-Module active*
$ADInfo = Get-ADDomain
$AllDCs = $ADInfo.ReplicaDirectoryServers
$AllDCs += $ADInfo.ReadOnlyReplicaDirectoryServers
$Date = Get-Date
$ShortDate = $Date.ToShortDateString()
$ShortTime = $Date.ToShortTimeString()
$StartShortTime = $ShortTime

#HTML Table Header and CSS
$Style ="<Style>"
$Style +="TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;Margin-left:50px;}"
$Style +="TH{border-width: 1px;padding: 15px;border-style: solid;border-color: black;background-color:thistle}"
$Style +="TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black}"
$Style +="</style>"
$StaticCSS = @"
    <html>
    <head>
    <style type='text/css'>
    div.red { background-color:#B22222;
      float:left;
      text-align:right;
    }
    div.green { background-color:#32CD32;
      float:left; 
    }
    div.free { background-color:#7FFF00;
      float:left;
      text-align:right;
    }
    div.warn { background-color: orange;
      float:left;
      font-weight: bold;
    }
    div.urgent { background-color: red;
      float:left;
      font-weight: bold;
    }
    div.serverOK{ background-color:#32CD32;
      float:left; 
    }
    </style>
    </head>
    <body>
"@



$ResultArray = @()

#Functions
Function PingTest($name){
    $Return = $null
    $Return = Test-Connection -ComputerName $name -Count 2 -BufferSize 16 -Quiet
    If ($Return -match 'True'){
        Return "SUCCESS"
    }
    Else{
        Return "FAILED"
    }
}

Function DCInfo($name){
    $DCInfoGathering = $null
    $DCInfoGathering = Get-ADDomainController -Identity $name |Select hostname, Site, enabled, OperatingSystem,isglobalcatalog,isReadOnly,ldapPort, IPv6Address 
    Return $DCInfoGathering.hostname, $DCInfoGathering.site, $DCInfoGathering.enabled, $DCInfoGathering.OperatingSystem, $DCInfoGathering.isGlobalCatalog, $DCInfoGathering.isReadOnly, $DCInfoGathering.ldapPort, $DCInfoGathering.IPv6Address
}

Function isSYSVOLPresent ($name) {
    $FolderResult = $null
    $FolderResult = Test-Path "\\$name\SYSVOL" -ErrorAction SilentlyContinue
    If ($FolderResult){
        Return "SUCCESS"
    }
    Else{
        Return "FAILED"
    }
}

Function CheckPort389 ($name) {
    $ip = $null
    Try{
        $ip = [System.Net.Dns]::GetHostAddresses($name) 
        If ($ip.IPAddressToString.count -gt 1) {
            %{$o=new-object Net.Sockets.TcpClient -ErrorAction SilentlyContinue;$o.Connect($ip.IPAddressToString[0], 389)} -ErrorAction SilentlyContinue
            %{$p=new-object Net.Sockets.TcpClient -ErrorAction SilentlyContinue;$p.Connect($ip.IPAddressToString[1], 389)} -ErrorAction SilentlyContinue
            if ($o.Connected -and $p.Connected){
                $o.Dispose()
                $p.Dispose()
                Return "SUCCESS", $ip.IPAddressToString[0], $ip.IPAddressToString[1]#, $ip.IPAddressToString[2]
            }
            else{
                $o.Dispose()
                $p.Dispose()
                Return "FAILED", $ip.IPAddressToString[0], $ip.IPAddressToString[1]#, $ip.IPAddressToString[2]
            }
         }
        else{
            %{$o=new-object Net.Sockets.TcpClient -ErrorAction SilentlyContinue;$o.Connect($ip.IPAddressToString, 389)} -ErrorAction SilentlyContinue
            if ($o.Connected){
                $o.Dispose()
                Return "SUCCESS", $ip.IPAddressToString, "-"#,"-"
            }
            else{
                $o.Dispose()
                Return "FAILED", $ip.IPAddressToString, "-"#,"-"
            }
        }
    }
    catch {}

}

Function CheckLDAP ($name) {
    $LDAPConnection = $null
    Try {$LDAPConnection = [adsi]("LDAP://"+$name+":389")}
    Catch{}
    if ($LDAPConnection.Path){
        Return "SUCCESS"
        }
    Else{
        Return "FAILED"
        }
}

Function CheckWSMAN ($name) {
    $WSMANConnection = $null
    Try {$WSMANConnection = Test-WSMan -ComputerName $name -ErrorAction Stop}
    Catch{}
    If ($WSMANConnection) {
        [regex]$rx="\d\.\d$"
        $WSMANVer = $rx.match($WSMANConnection.productversion).value
        Return "RUNNING", $WSMANVer
    }
    Else{
        Return "Failed to get result", "0.0"
    }
}

Function GetUptime ($name) {
    $WMIGather =$null
    Try{$WMIGather = gwmi Win32_OperatingSystem -computer $name}
    Catch{}
    If ($WMIGather){
        $LBTime = $WMIGather.ConvertToDateTime($WMIGather.Lastbootuptime) 
        [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
        Return "$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
    }
    Else{
        Return "Unknown Connection Error"
    }
}

Function GetNetworkInformation($name){
    $NetItems = $null
    Try {$NetItems = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $name | ? {$_.IPEnabled}}
    Catch{}
    [STRING]$DNS = @()
    [STRING]$DNSSuffix = @()
    If ($NetItems){
        foreach ($objItem in $NetItems){
            if ($objItem.{DNSServerSearchOrder}.Count -gt 1){
                $TempDNSAddresses = [STRING]$objItem.DNSServerSearchOrder
                $TempDNSAddresses = $TempDNSAddresses.Replace(" ", "; ")
                $DNS += $TempDNSAddresses 
            }
            else{
                $DNS += $objItem.{DNSServerSearchOrder}
            }
        
            if ($objItem.DNSDomainSuffixSearchOrder.Count -gt 1){
                $TempDNSSuffixes = [STRING]$objItem.DNSDomainSuffixSearchOrder
                $TempDNSSuffixes = $TempDNSSuffixes.Replace(" ", "; ")
                $DNSSuffix += $TempDNSSuffixes
            }
            else{
                $DNSSuffix += $objItem.DNSDomainSuffixSearchOrder
            }

        }


        If ($objItem.FullDNSRegistrationEnabled -eq $true){
            $RegisterDNS = "YES"
        }
        else{
            $RegisterDNS = "FAILED"
        }
        
        If($objItem.DNSDomain -like $dnsdomainsuffix){
            $DNSSuffixForThisConnection = $objItem.DNSDomain
        }
        else{
            $DNSSuffixForThisConnection = "FAILED"
        }

        Return $DNS, $RegisterDNS, $DNSSuffix, $DNSSuffixForThisConnection

    }
    Else{
        Return "Unknown Connection Error", "-", "-", "-"
    }
}

Function GetDiskInformation($name){
    $Disks = $null
    Try{
        #Get disk information and pretty up the data
        $Disks = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $name | Select `
	     	     @{LABEL="Server";EXPRESSION={$Computer}},
		         @{LABEL="DriveLetter";EXPRESSION={$_.DeviceID}},
    		     @{LABEL="Size";EXPRESSION={[int]("{0:N0}" -f ($_.Size/1gb))}},
        	     @{LABEL="FreeSize";EXPRESSION={[int]("{0:N0}" -f ($_.FreeSpace/1gb))}},
    	         @{LABEL="perUsed";EXPRESSION={[int]("{0:N0}" -f ((($_.Size - $_.FreeSpace)/$_.Size)*100))}},
    		     @{LABEL="perFree";EXPRESSION={[int]("{0:N0}" -f (100-(($_.Size - $_.FreeSpace)/$_.Size)*100))}},
    		     VolumeName

        }
    Catch{}
    If ($Disks) {
        return $Disks
    }
    Else{ 
        Return "Unknown Connection Error"
    }
}

Function GetDCDiagFromDC($name){
    $DCDiag = $null
    Try{$DCDiag = (dcdiag.exe /s:$name)}
    Catch{}
    If ($DCDiag){
        Return $DCDiag
    }
    else{
        Return "Unknown Connection Error"
    }
}

Function RepAdminShowrepl(){
    #Check the Replication with Repadmin
    $repAdminWorkFile = repadmin.exe /showrepl * /csv
    $repAdminResults = ConvertFrom-Csv -InputObject $repAdminWorkFile | where {$_.'Number of Failures' -ge 1}

    if ($repAdminResults -ne $null ) {
        $returnResults = $repAdminResults | select "Source DSA", "Naming Context", "Destination DSA" ,"Number of Failures", "Last Failure Time", "Last Success Time", "Last Failure Status" 
    } 
    else {
        $returnResults = "There were no Replication Errors at the time the script ran"
    }
    return $returnResults
}


#MAIN CODE
#____________________________________________________________________________________________________________________________________________________________________
#Part 1 of Mega report does checks and lists information on the system. 

$FullReport = "`n<H2> <img src='.././logo.png'> </H2>`n"
$FullReport +=  "<b>Company Co Monster AD Domain Report - $ShortDate </b><br>`n"
$FullReport +=  "Start time: $ShortTime<br>`n"
$FullReport +=  "Script Version: $ScriptVer<br>`n"
$ScriptUser =  ([Environment]::UserDomainName + "\" + [Environment]::UserName)
$FullReport +=  "Script running as user: $ScriptUser"
$FullReport +=  " <br>`n"


foreach ( $DC in $AllDCs) {
        Write-Output "The server name for basic check is: $DC"
        $PingResult = PingTest($DC)
        $DCInfoResult = DCinfo($DC)
        $SysVolResult = isSYSVOLPresent($DC)
        $LdapPortOpen = CheckPort389($DC)
        $LdapConnected = CheckLDAP($DC)
        $WSMANResult = CheckWSMAN($DC)
        $UptimeResult = GetUptime ($DC)
        $NetworkInfoResult = GetNetworkInformation($DC)
        $Resultlist = New-Object System.Object
        $Resultlist | Add-Member -Type NoteProperty -Name ServerName -Value $DCInfoResult[0]
        $Resultlist | Add-Member -Type NoteProperty -Name IPv4Address1 -Value $LdapPortOpen[1]
        $Resultlist | Add-Member -Type NoteProperty -Name IPv4Address2 -Value $LdapPortOpen[2]
        #$Resultlist | Add-Member -Type NoteProperty -Name IPv4Address3 -Value $LdapPortOpen[3]
        $Resultlist | Add-Member -Type NoteProperty -Name IPv6Address -Value $DCInfoResult[7]
        $Resultlist | Add-Member -Type NoteProperty -Name IPv4DNSServers -Value $NetworkInfoResult[0]
        $Resultlist | Add-Member -Type NoteProperty -Name RegisterInDNS -Value $NetworkInfoResult[1] #Also known as "Register this connection in DNS checkbox"
        $Resultlist | Add-Member -Type NoteProperty -Name DomainSuffixSearchOrder -Value $NetworkInfoResult[2]
        $Resultlist | Add-Member -Type NoteProperty -Name DNSSuffixForThisConnection -Value $NetworkInfoResult[3]
        $Resultlist | Add-Member -Type NoteProperty -Name SiteName -Value $DCInfoResult[1]
        $Resultlist | Add-Member -Type NoteProperty -Name DCEnabled -Value $DCInfoResult[2]
        $Resultlist | Add-Member -Type NoteProperty -Name OperatingSystem -Value $DCInfoResult[3]
        If($DCInfoResult[4] -eq $true){$isGC = "True"} else {$isGC= "NOT GC"}
        $Resultlist | Add-Member -Type NoteProperty -Name isGlobalCatalog -Value $isGC
        $Resultlist | Add-Member -Type NoteProperty -Name isReadOnly -Value $DCInfoResult[5]
        $Resultlist | Add-Member -Type NoteProperty -Name LDAPport -Value $DCInfoResult[6]
        $Resultlist | Add-Member -Type NoteProperty -Name PingResult -Value $PingResult
        $Resultlist | Add-Member -Type NoteProperty -Name SysVolPresent -Value $SysVolResult
        $Resultlist | Add-Member -Type NoteProperty -Name CanAccessPort389 -Value $LdapPortOpen[0]
        $Resultlist | Add-Member -Type NoteProperty -Name LdapSSLAuthConnected -Value $LdapConnected
        $Resultlist | Add-Member -Type NoteProperty -Name WSMANRunning -Value $WSMANResult[0]
        $Resultlist | Add-Member -Type NoteProperty -Name WSMANVersion -Value $WSMANResult[1]
        $Resultlist | Add-Member -Type NoteProperty -Name SystemUptimeFromLastBoot -Value $UptimeResult
        $ResultArray += $Resultlist
                                    
        If ($SysVolResult -eq $true){$DCPingSuccess++}
        Else {$DCPingFailed++}
        
        }

$Part1Report = "<h2> DC Server Details and Basic Checks</h2>`n"
$Part1Report += $ResultArray | Sort-Object ServerName | ConvertTo-Html -Head $Style
$Part1Report = $Part1Report | `
                ? {$_ -match "<td>SUCCESS</td>" `
                         -or "<td>YES</td>" `
                         -or "<td>FAILED</td>" `
                         -or "<td>NOT GC</td>"}  | `
                %{$_ -Replace "<td>SUCCESS</td>", "<td bgcolor=""green"">SUCCESS</td>" `
                     -replace "<td>YES</td>", "<td bgcolor=""green"">YES</td>" `
                     -replace  "<td>FAILED</td>", "<td bgcolor=""red""><b>FAILED</b></td>" `
                     -replace "<td>NOT GC</td>", "<td bgcolor=""red""><b>NOT GC</b></td>"}



#____________________________________________________________________________________________________________________________________________________________________
#Part2 of mega report disk space sizes on all systems
$Part2Report = @"
<h2> Detailed Disk Space Status on DCs</h2>
<p>Disk space alert threshold: $AlertThreshold %
Disk space urgent threshold: $UrgentThreshold %</p>
<table>
<tr><th>ServerName</th><th>Drive Letter</th><th>Volume Name</th><th>Total Disk Space</th><th>Used</th><th>Free</th><th style="width:400px;">Usage</th></tr>`n
"@
foreach ( $DC in $AllDCs) {
    Write-Output "The server name for disk is: $DC"
    $DiskInfoResult = GetDiskInformation($DC)
    If ($DiskInfoResult -eq "Unknown Connection Error"){
        $Part2Report += "<tr><td bgcolor=""pink""><div class=""$ServerClass"">$($DC)</div></td><td>Unknown Connection Error</td><td>-</td><td>-</td><td>-</td><td>-</td>"
    }
    Else{
        $Disks = $DiskInfoResult | Sort DriveLetter
        ForEach ($Disk in $Disks){        
            If ($Disk.perFree -le $AlertThreshold){
                $FreeClass = "red"
                $ServerClass = "warn"
                $ServerTD = $null
            }
            Else {
                $FreeClass = "free"
                $ServerClass = $null
                $ServerTD =$null
            }
            If ($Disk.perFree -le $UrgentThreshold){
                $ServerClass = "urgent"
                $ServerTD = "Red"
            }
            $Part2Report += "<tr><td bgcolor=""$($ServerTD)""><div class=""$ServerClass"">$($DC)</div></td><td>$($Disk.DriveLetter)</td><td>$($Disk.VolumeName)</td><td>$($Disk.Size)gb</td><td>$($Disk.Size - $Disk.FreeSize)gb</td><td>$($Disk.FreeSize)gb</td>"
            $Part2Report += "<td><div class=""green"" style=""width:$($Disk.perUsed)%"">&nbsp;</div><div class=""$FreeClass"" style=""width:$($Disk.perFree)%"">$($Disk.perFree)%</div></td></tr>`n"
        }
    }
}
$Part2Report += "</table><br>`n"

#____________________________________________________________________________________________________________________________________________________________________
#Part 3 of Mega report that does DCDiag on all systems
$Part3Report = @"
<h2> DCDiags of all Domain Controllers</h2>
"@
$ArrDCDiag = @()
foreach ( $DC in $AllDCs) {
    Write-Output "The server name for DCDiag check is: $DC"
    $DCDiagResults = GetDCDiagFromDC($DC)
    
    $DCDiagObj = New-Object Object
    $DCDiagObj | Add-Member -Type NoteProperty -Name ServerName -Value $DC
    If ($DCDiagResults -eq "Unknown Connection Error"){
        $DCDiagObj |  Add-Member -Type NoteProperty -Name Connectivity -Value "Connection Error"
        #Write-Output "Connection error for $DC"
    }
    Else {
        #Write-Output "Results OK for $DC"
        $DCDiagResults | %{ Switch -Regex ($_){
                                                "Starting"       {$TestName = ($_ -replace ".*Starting test: ").Trim()}
                                                "passed|failed"  {If ($_ -match "passed") {$TestStatus = "Passed"}
                                                                  Else{$TestStatus = "Failed"}
                                                                  }
                                               }
                            If ($TestName -ne $null -and $TestStatus -ne $null){
                                  $DCDiagObj | Add-Member -Name $("$TestName".Trim()) -Value $TestStatus -type NoteProperty -Force
                            }
                           }
    }
    $ArrDCDiag += $DCDiagObj
    #Write-Output $ArrDCDiag
}

$Part3Report += $ArrDCDiag | Sort-Object ServerName | ConvertTo-Html -Head $Style
$Part3Report = $Part3Report | `
                ? {$_ -match  "<td>Failed</td>" `
                         -or  "<td>Connection Error</td>"}  | `
                %{$_ -replace "<td>Failed</td>", "<td bgcolor=""red""><b>FAILED</b></td>" `
                     -replace "<td>Connection Error</td>", "<td bgcolor=""orange""><b>Connection Error</b></td>"}



#____________________________________________________________________________________________________________________________________________________________________
#Finish and Build HTML Site for OUTPUT

$TotalDcs = [int]$DCPingFailed + [int]$DCPingSuccess

$FullReport +="<br>`n"

$TempCombineReport = $Part1Report
$TempCombineReport += $Part2Report
$TempCombineReport += $Part3Report

#Calculate Failed, Warn Etc. 
[int]$FailedIssues = 0
[int]$WarningIussues = 0
$ArrSummary = @()
$holderOfFailures = [regex]::Matches($TempCombineReport, '<td bgcolor="red"><b>FAILED</b></td>')
$holderOfWarnings = [regex]::Matches($TempCombineReport, '<div class="warn">')
$FailedIssues = $holderOfFailures.Count
$WarningIussues = $holderOfWarnings.Count

$SummaryList = New-Object System.Object
$SummaryList | Add-Member -Type NoteProperty -Name "Total DCs" -Value $TotalDcs
$SummaryList | Add-Member -Type NoteProperty -Name "Possible Failures" -Value $FailedIssues
$SummaryList | Add-Member -Type NoteProperty -Name "Possible Warnings" -Value $WarningIussues
$ArrSummary += $SummaryList

#$FullReport += "FAILED DCs = $DCPingFailed<br> SUCCESSFUL DCs = $DCPingSuccess<br> Total = $TotalDcs`n"
$FullReport += "<h2> Summary of of Mega DC report</h2>"
$FullReport += $ArrSummary | ConvertTo-Html -Head $Style
$FullReport += "</p>`n"
$FullReport +="</body>"
$FullReport += $Part1Report
$FullReport += $Part2Report
$FullReport += $Part3Report

$Date = Get-Date
$shortTime = $Date.ToShortTimeString()
$ShortDate = $Date.ToShortDateString()


$FullReport += "<br>Completed time: $ShortTime`n"
$FullReport += "<br><b>END</b>`n"
$FullReport += "</p>`n"


$HTML = $StaticCSS + $FullReport
$ShortDate = $ShortDate -replace ("/","")
$StartShortTime = $StartShortTime -replace (":","")
$StartShortTime = $StartShortTime -replace (" ","")
$Filename = "MegaADReport_$ShortDate"
$Filename += "_$StartShortTime.html"
Write-Output "The file name is: $Filename"
$HTML | Out-File $OutFilePath"\$Filename"