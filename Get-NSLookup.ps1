#Reads CSV file with list of IPs and loops through each to perform an NSlookup to retreive FQDN if it exists

#headers: ip,dstport,hits
$ips = Import-csv ips.csv

$iparray = @()
foreach ($ip in $ips){
    $result = nslookup $ip.ip
    
   
    Try{
        $ipaddress = ($result | Select-String address | Where-Object LineNumber -eq 5).ToString().Split(' ')[-1]
        $dnsname = ($result | Select-String Name).ToString().Split(' ')[-1]
    }
    Catch  {
        $ipaddress = $ip.ip
        $dnsname = "Non-existent domain or Timeout"
    }

    $lookup = New-Object psobject
    $lookup | Add-Member -MemberType NoteProperty -Name "IP Address" -Value $ipaddress
    $lookup | Add-Member -MemberType NoteProperty -Name "DNS Name" -Value $dnsname
    $lookup | Add-Member -MemberType NoteProperty -Name "Destination Port" -Value $ip.dstport
    $lookup | Add-Member -MemberType NoteProperty -Name "Hits" -Value $ip.hits
    $iparray += $lookup 
}

$iparray | Export-Csv results.csv -NoTypeInformation
