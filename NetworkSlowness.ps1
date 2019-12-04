<#
    .SYNOPSIS
        Run network diagnostic tools 
    .DESCRIPTION
        The script will perform DNS lookups and ping commands to mulitple servers and report results for each. Can be embedded into other scripts to provide statistics on network performance.
    .PARAMETERS
        None
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.0
        Release Date: 2017-4-18
        Updated: 2017-4-18
		Author: Mike Burns
		Credit: SatNaam WaheGuru
#>

$servers = "google.com","hotmail.com","msn.com"

Write-Host "========================= Computer IP Info========== `n" -ForegroundColor Green
ipconfig /all

foreach ( $server in $servers ) {
    Write-Host "========================= Testing $server========== `n" -ForegroundColor Green
	nslookup $server
    ping $server		
}

