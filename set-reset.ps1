# Requires: ActiveDirectory module; run as Domain Admin

param([string]$ServiceAccount)

Import-Module ActiveDirectory

if (-not $ServiceAccount) {
    $ServiceAccount = Read-Host "Enter service account name"
}

# Get required info
$user = Get-ADUser $ServiceAccount -ErrorAction Stop
Write-Host "✓ Found service account '$ServiceAccount'" -ForegroundColor Green  
$domain = Get-ADDomain
$domainDN = $domain.DistinguishedName

# Get current permissions for domain
$acl = Get-Acl "AD:\$domainDN"

# Permission GUIDs
$resetPasswordGUID = [GUID]"00299570-246d-11d0-a768-00aa006e0529"
$changePasswordGUID = [GUID]"ab721a53-1e2f-11d0-9819-00aa0040529b"
$userObjectGUID = [GUID]"bf967aba-0de6-11d0-a285-00aa003049e2"

# Create reset password permission for all users (descendents)
$descendentsResetAce = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $user.SID,
    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
    [System.Security.AccessControl.AccessControlType]::Allow,
    $resetPasswordGUID,
    [System.DirectoryServices.ActiveDirectorySecurityInheritance]::Descendents,
    $userObjectGUID
)

# Create change password permission for all users (descendents)
$descendentsChangeAce = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $user.SID,
    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
    [System.Security.AccessControl.AccessControlType]::Allow,
    $changePasswordGUID,
    [System.DirectoryServices.ActiveDirectorySecurityInheritance]::Descendents,
    $userObjectGUID
)

# ADD both permissions to domain (for all users)
$acl.AddAccessRule($descendentsResetAce)
$acl.AddAccessRule($descendentsChangeAce)
Set-Acl "AD:\$domainDN" $acl

Write-Host "✓ Granted Reset and Change Password rights to '$ServiceAccount' for all users" -ForegroundColor Green

# Apply same permissions to the service account itself
$userAcl = Get-Acl "AD:\$($user.DistinguishedName)"

# Create self permissions (no inheritance needed for direct object)
$resetAce = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $user.SID,
    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
    [System.Security.AccessControl.AccessControlType]::Allow,
    $resetPasswordGUID
)

$changeAce = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $user.SID,
    [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight,
    [System.Security.AccessControl.AccessControlType]::Allow,
    $changePasswordGUID
)

# Add permissions to service account
$userAcl.AddAccessRule($resetAce)
$userAcl.AddAccessRule($changeAce)
Set-Acl "AD:\$($user.DistinguishedName)" $userAcl
Write-Host "✓ Granted Reset and Change Password rights to '$ServiceAccount' on itself" -ForegroundColor Green

# Now apply to AdminSDHolder to persist through AdminSDHolder process
$adminSDHolderDN = "CN=AdminSDHolder,CN=System,$domainDN"

# Get current ACL on AdminSDHolder
$acl = Get-Acl "AD:\$adminSDHolderDN"

# Add (do not replace) both permissions and apply
$acl.AddAccessRule($selfResetAce)
$acl.AddAccessRule($selfChangeAce)
Set-Acl "AD:\$adminSDHolderDN" $acl

Write-Host "Granted Reset and Change Password rights to '$ServiceAccount' on AdminSDHolder." -ForegroundColor Green

# Create LDIF file to trigger SDProp
$domain = Get-ADDomain
$configNC = (Get-ADRootDSE).configurationNamingContext
$ldifContent = @'
dn:
changetype: modify
add: RunProtectAdminGroupsTask
RunProtectAdminGroupsTask: 1
-


'@

# Write to temp file and execute
$ldifFile = "c:\users\domainadmin1\Desktop\trigger_sdprop.ldf"
$ldifContent | Out-File -FilePath $ldifFile -Encoding ASCII

# Run ldifde
ldifde -i -f $ldifFile

# Clean up
#Remove-Item $ldifFile

Write-Host "SDProp triggered via ldifde" -ForegroundColor Green

#check SDProp
$domainDN = (Get-ADDomain).DistinguishedName
$adminSDHolder = Get-ADObject "CN=AdminSDHolder,CN=System,$domainDN" -Properties whenChanged
$adminSDHolderACLChangeTime = $adminSDHolder.whenChanged
Write-Host "AdminSDHolder ACL Changed: '$adminSDHolderACLChangeTime'"

# Sample protected account (Domain Admins member)
$admin = Get-ADUser -LDAPFilter "(memberOf=CN=Domain Admins,CN=Users,$domainDN)" -Properties whenChanged, nTSecurityDescriptor | Select-Object -First 1
$adminACLChangeTime = $admin.whenChanged
Write-Host "Domain Admin ACL Changed: '$adminACLChangeTime'"
