<#
    .SYNOPSIS
        Returns clean result of local admins on an endpoint in the following format: "admin1;admin2"
    .DESCRIPTION
        The script will return all memmbers of the local admins group on an endpoint without extra output
    .PARAMETERS
        None
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.1
        Release Date: 2019-12-5
        Updated: 2019-12-27
        Author: Mike Burns
#>

#net localgroup administrators | where {$_ -AND $_ -notmatch "command completed successfully"} | select -skip 4 

#output results in a csv like format
$admin=net localgroup administrators | Where-Object {$_ -AND $_ -notmatch "command completed successfully"} | Select-Object -skip 4
$administrator = [string]::Join(';',$admin)
$administrator
