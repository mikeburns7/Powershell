<#
      .SYNOPSIS
        Check for trusted root certificate and add if missing 
      .DESCRIPTION
        The following script will set Powershell's location to the Trusted Root Certification Authorities Store iterate through the store
        looking for a specifie certificate thumbprint. If found, nothing will occur. If the certificate is not found, it will load the certificate from
        a specifed location.
      .NOTES
        Release Date: 2019-11-11
        Updated: 2019-11-11
        Author: Mike Burns

#iterate through the Trusted Root Certification Authorities Store to locate cert by thumbprint
$cert = Get-ChildItem -LiteralPath cert:\LocalMachine\root | Where-Object  {$_.thumbprint -eq "<CERTIFICATE THUMBRPINT>"}

#if certifiacte not found, load certificate to store
If(-not $cert){
        Import-Certificate -FilePath "C:\<CERTPATH>" -CertStoreLocation Cert:\LocalMachine\Root
}

