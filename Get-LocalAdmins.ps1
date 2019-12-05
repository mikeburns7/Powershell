<#
    .SYNOPSIS
        Returns clean result of local admins on an endpoint
    .DESCRIPTION
        The script will return all memmbers of the local admins group on an endpoint without extra output
    .PARAMETERS
        None
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.0
        Release Date: 2019-12-5
        Updated: 2019-12-5
        Author: Mike Burns
#>

net localgroup administrators | where {$_ -AND $_ -notmatch "command completed successfully"} | select -skip 4