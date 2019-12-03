<#
      .SYNOPSIS
        Import AD user and attributes from CSV 
      .DESCRIPTION
        The following script import a list of usesr and their associated attributes into Active Directory. This is useful for building or populating greenfield domains.
      .NOTES
        Release Date: 2019-12-3
        Updated: 2019-12-3
        Author: Mike Burns
#>


Import-Module activedirectory
Import-Csv "<ENTER PATH OF CSV FILE>" | ForEach-Object {
$upn = $_.SamAccountName + "<@DOMAIN.TLD>"
$uname = $_.LastName + " " + $_.FirstName
New-ADUser -Name $uname `
-DisplayName $uname `
-GivenName $_.FirstName `
-Surname $_.LastName `
-OfficePhone $_.Phone `
-Department $_.Department `
-Title $_.JobTitle `
-UserPrincipalName $upn `
-SamAccountName $_.samAccountName `
-Path $_.OU `
-AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -force) -Enabled $true
}