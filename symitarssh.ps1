<#
    .SYNOPSIS
        This script will enable the Symitar Client to use SSH protocol when communicating with the Symitar server 
    .DESCRIPTION
        The script will check the client architecture. Ten if the given registry key exists, the script will modify the registry key if not equal to 1. 
        Setting the UseSSH registry key value ot 1 will enable SSH for the Symitar client. 
    .PARAMETERS
        None
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.0
        Release Date: 2018-4-18
        Updated: 2018-4-18
        Author: Mike Burns
#>

#check for OS architecture
if($env:PROCESSOR_ARCHITECTURE -eq 'x86')
    {
        #check if registry path exists
        $pathexists = Test-Path 'HKLM:\SOFTWARE\Symitar\SFW\2.0\Logon Options'
        if($pathexists -eq $True)
        {
            #check if registry key value is not equal to 1
            if($val.UseSSH -ne 1)
            {
                #set registry key value to 1 - enables ssh for symitar client
                set-itemproperty -Path 'HKLM:\SOFTWARE\Symitar\SFW\2.0\Logon Options' -Name "UseSSH" -Value 1
            }
        }
        else
        {
            New-Item -Path "HKLM:\SOFTWARE\Symitar\SFW\2.0\Logon Options" -ItemType Key
            New-ItemProperty -Path "HKLM:\SOFTWARE\Symitar\SFW\2.0\Logon Options" -Value 1 -PropertyType dword -Name "UseSSH"
        }
       
    
    }
#64-bit OS architecture
else 
    {
        $pathexists = Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Symitar\SFW\2.0\Logon Options'
        if($pathexists -eq $True)
            {
                if($val.UseSSH -ne 1)
                {
                    Set-itemproperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Symitar\SFW\2.0\Logon Options' -Name "UseSSH" -Value 1
                }
            }
          else  
           {
                New-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Symitar\SFW\2.0\Logon Options' -ItemType Key
                New-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Symitar\SFW\2.0\Logon Options' -Value 1 -PropertyType dword -Name "UseSSH"
    }       }


