
 # Requiires https://github.com/PowerShell/GPRegistryPolicy
 # Install-Module <path>\GPRegistryPolicy
 # Import-Module GPRegistryPolicy

$files = @(Get-Childitem C:\Windows\System32\GroupPolicy -recurse -filter "*.pol")

$auditpolfile = "C:\users\mike\Desktop\AudtPolOutput.txt"
New-Item $auditpolfile

foreach ($file in $files) {
    
    $polpath = $file.FullName
    $polsettings = Parse-PolFile -path $polpath
    $polsettingtext = $polsettings | Out-String  
    
    
    $polpath | Add-Content -Path $auditpolfile  
    $polsettingtext | Add-Content -Path $auditpolfile
}

<# 
$files = @(Get-Childitem C:\Windows\System32\GroupPolicy -recurse -filter "*.inf")

$GptTmplfile = "C:\users\mike\Desktop\GptTmpl.txt"
New-Item $GptTmplfile

foreach ($file in $files) {
    
    $GptTmplpath = $file.FullName
    copy-item -path $GptTmplpath -destination "C:\users\mike\documents\$file.txt"
    #$GptTmplsettingstext = Get-Content $polpath
    #$polsettingtext = $polsettings | Out-String  
    
    
    #$GptTmplpath | Add-Content -Path $GptTmplfile  
    #$GptTmplsettingtext | Add-Content -Path $GptTmplfile
}
