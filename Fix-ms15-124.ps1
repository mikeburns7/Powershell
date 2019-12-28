
<#
Requires PS Version 2
SYNOPSIS
  Your system is not protected from this ASLR Bypass unless you install the applicable updates and then enable the User32 Exception Handler Hardening Feature
DESCRIPTION
    Iif the given registry key exists, the script will modify the registry key if not equal to 1. 
    https://docs.microsoft.com/en-us/security-updates/SecurityBulletins/2015/ms15-124#fix_6161 
PARAMETER 
    None
INPUTS
    None
OUTPUTS
    None
NOTES
  Version:        1.0
  Author:         Mike Burns
  Creation Date:  10/5/2018
  Purpose/Change: Initial script development
#>

#check for OS architecture
#if($env:PROCESSOR_ARCHITECTURE -eq 'x86')
    #{
        #check if registry path exists
        $pathexists = Test-Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING'
        if($pathexists -eq $True)
        {
            #check if registry key value is not equal to 1
            if($val.iexplorer.exe -ne 1)
            {
                #set registry key value to 1
                set-itemproperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING' -Name "iexplorer.exe" -Value 1
            }
        }
        else
        {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" -ItemType Key
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" -Value 1 -PropertyType dword -Name "iexplorer.exe"
        }
       
    
   # }
#64-bit OS architecture
else 
    {
        $pathexists = Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING'
        if($pathexists -eq $True)
            {
                if($val.iexplorer.exe -ne 1)
                {
                    Set-itemproperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING' -Name "iexplorer.exe" -Value 1
                }
            }
          else  
           {
                New-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING' -ItemType Key
                New-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING' -Value 1 -PropertyType dword -Name "iexplorer.exe"
    }       }


