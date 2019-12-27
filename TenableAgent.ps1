$WebClient = New-Object System.Net.WebClient
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    if($env:PROCESSOR_ARCHITECTURE -eq 'x86')
    {
        
        #$WebClient.DownloadFile('https://www.tenable.com/downloads/nessus-agents', $env:windir+'\temp\windows6.1-kb4056894-x86_c4ea3ab351b1edb45c0977e0e2e4607b17eeaba7.msu')
        #$FilePath = $env:windir+'\temp\windows6.1-kb4056894-x86_c4ea3ab351b1edb45c0977e0e2e4607b17eeaba7.msu'
        #$FileMD5 = '3A-09-24-09-EE-A8-28-76-69-30-8E-7E-9F-77-EC-C0' 
   
    }
    else 
        {
            $WebClient.DownloadFile('https://www.dropbox.com/s/hnpoxuzint3nm5x/NessusAgent-7.1.1-x64.msi=dl=1', $env:windir+'\temp\NessusAgent-7.1.1-x64.msi')
            Rename-Item -Path $env:windir+'\temp\a064dbe366e9bfc196801f74624f46ae.apk' -NewName "NessusAgent-7.1.1-x64.msi"
            $FilePath = $env:windir+'\temp\NessusAgent-7.1.1-x64.msi'
            #$FileMD5 = 'E9-F5-FA-FF-D8-A3-F4-98-C7-5A-AA-E8-FA-4B-C3-67'

        }
    #Go To FileHashCheck

    #FileHashCheck



$MSIArguments =@(
                "/i"
                ('"{0}"' -f $FilePath)
                'NESSUS_GROUPS="<ENTER GROUP"'
                'NESSUS_SERVER="cloud.tenable.com:443"'
                "NESSUS_KEY=<ENTER Tenable.io KEY"
                "/qn"

)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments  -Wait -NoNewWindow
   