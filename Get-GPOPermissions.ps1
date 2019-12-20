<#
    .SYNOPSIS
        Retreieve all Group Policy Object Permissions
    .DESCRIPTION
        The script will output all of a domain's group policy objects and their associated security permissions. Results will be saved to a csv file
    .PARAMETERS
        None
    .INPUTS
        None
    .OUTPUTS
        Csv file
    .NOTES
        Version:        1.0
        Release Date: 2019-12-20
        Updated: 2019-12-20
        Author: Mike Burns
        Credit: https://social.technet.microsoft.com/Forums/lync/en-US/31e654d7-ac06-4269-b837-14c1e0b35ffb/exporting-all-gpo-permissions-into-a-csv?forum=winserverpowershell
#>

$gpos = Get-GPO -All
$info = foreach ($gpo in $gpos)
{
    Get-GPPermissions -Guid $gpo.Id -All | Select-Object `
    @{n='GPOName';e={$gpo.DisplayName}},
    @{n='AccountName';e={$_.Trustee.Name}},
    @{n='AccountType';e={$_.Trustee.SidType.ToString()}},
    @{n='Permissions';e={$_.Permission}}
}
$info | Export-Csv -Path 'C:\GPOPermissions.csv' -NoTypeInformation