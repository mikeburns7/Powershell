configuration DSCWorkstationBaseline
{
    Import-DscResource -Module NetworkingDsc

    node localhost
    {
        Service XblGameSave
        {
            Name = 'XblGameSave'
            State = 'Stopped'
            StartupType = 'Disabled'
        }
        FirewallProfile ConfigureDomainFirewallProfile
        {
            Name = 'Domain'
            Enabled = 'True'
            DefaultInboundAction = 'Block'
            DefaultOutboundAction = 'Allow'
           AllowInboundRules = 'True'
           AllowLocalFirewallRules = 'True'
            AllowLocalIPsecRules = 'False'
            NotifyOnListen = 'True'
            LogFileName = '%systemroot%\system32\LogFiles\Firewall\pfirewall.log'
            LogMaxSizeKilobytes = 16384
            LogAllowed = 'False'
           LogBlocked = 'True'
           LogIgnored = 'NotConfigured'
        }

        FirewallProfile ConfigurePrivateFirewallProfile
        {
            Name = 'Private'
            Enabled = 'True'
            DefaultInboundAction = 'Block'
            DefaultOutboundAction = 'Allow'
            AllowInboundRules = 'True'
            AllowLocalFirewallRules = 'False'
            AllowLocalIPsecRules = 'False'
            NotifyOnListen = 'True'
            LogFileName = '%systemroot%\system32\LogFiles\Firewall\pfirewall.log'
            LogMaxSizeKilobytes = 16384
            LogAllowed = 'False'
            LogBlocked = 'True'
            LogIgnored = 'NotConfigured'
        }

        FirewallProfile ConfigurePublicFirewallProfile
        {
            Name = 'Public'
            Enabled = 'True'
            DefaultInboundAction = 'Block'
            DefaultOutboundAction = 'Allow'
            AllowInboundRules = 'True'
            AllowLocalFirewallRules = 'False'
            AllowLocalIPsecRules = 'False'
            NotifyOnListen = 'True'
            LogFileName = '%systemroot%\system32\LogFiles\Firewall\pfirewall.log'
            LogMaxSizeKilobytes = 16384
            LogAllowed = 'False'
            LogBlocked = 'True'
            LogIgnored = 'NotConfigured'
        }

       Registry Dot35NetForceStrongCrypto
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727"
            ValueType   = "Dword"
            ValueName   = "SchUseStrongCrypto"
            ValueData   = "1"
            
        }

        Registry Dot35NetForceStrongCrypto64
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727"
            ValueType   = "Dword"
            ValueName   = "SchUseStrongCrypto"
            ValueData   = "1"
           
        }

       Registry Dot4NetForceStrongCrypto
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
            ValueType   = "Dword"
            ValueName   = "SchUseStrongCrypto"
            ValueData   = "1"
           
        }

        Registry Dot4NetForceStrongCrypto64
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319"
            ValueType   = "Dword"
            ValueName   = "SchUseStrongCrypto"
            ValueData   = "1"
            
        }

        Registry AES128128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "ffffffff"
            Hex         = $true
        }

        Registry AES256256
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "ffffffff"
            Hex         = $true
        }

        Registry DES5656
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry NULL
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC2128128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC240128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC256128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC4128128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC440128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC456128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry RC464128
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry TripleDES168
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry PCT1ClientEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Client"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry PCT1ClientDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Client"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry PCT1ServerEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry PCT1ServerDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry SSL2ClientEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry SSL2ClientDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry SSL2ServerEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry SSL2ServerDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry SSL3ClientEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry SSL3ClientDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry SSL3ServerEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry SSL3ServerDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry TLS1ClientEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry TLS1ClientDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry TLS1ServerEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry TLS1ServerDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry TLS11ClientEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry TLS11ClientDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry TLS11ServerEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "0"
        }

        Registry TLS11ServerDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "1"
        }

        Registry TLS12ClientEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "1"
        }

        Registry TLS12ClientDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "0"
        }

        Registry TLS12ServerEnabled
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"
            ValueType   = "Dword"
            ValueName   = "Enabled"
            ValueData   = "1"
        }

        Registry TLS12ServerDisabledByDefault
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"
            ValueType   = "Dword"
            ValueName   = "DisabledByDefault"
            ValueData   = "0"
        }

        Registry ForcedotNet4TLS
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
            ValueType   = "Dword"
            ValueName   = "SystemDefaultTlsVersions"
            ValueData   = "1"
        }

        Registry ForcedotNet4TLS64bit
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319"
            ValueType   = "Dword"
            ValueName   = "SystemDefaultTlsVersions"
            ValueData   = "1"
        }

        Registry ForcedotNet35TLS
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727"
            ValueType   = "Dword"
            ValueName   = "SystemDefaultTlsVersions"
            ValueData   = "1"
        }

        Registry ForcedotNet35TLS64bit
        {
            Ensure      = "Present"  # You can also set Ensure to "Absent"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727"
            ValueType   = "Dword"
            ValueName   = "SystemDefaultTlsVersions"
            ValueData   = "1"
        }

    }
}