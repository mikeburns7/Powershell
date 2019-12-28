#Powershell script to set home folder permissions for all folders in the specified path

#get all folders in path set below and place in variable, enter the path to the home folder below
Add-Type -AssemblyName Microsoft.VisualBasic

#pop-up box to enter root directory
$HomeFoldersRoot = [Microsoft.VisualBasic.Interaction]::InputBox('Enter Parent Directory', 'Home Directory', "$env:HomeFolder")
$HomeFolders = GET-CHILDITEM $HomeFoldersRoot
#$HomeFolders = GET-CHILDITEM "C:\Users\mburns\Desktop\New folder"

#pop-up box to enter in fully qualified domain name
$FQDN = [Microsoft.VisualBasic.Interaction]::InputBox('Enter The Fully Qualified Domain for the Organization Example: ad.thinkstack.co', 'Home Directory', "$env:FQDN")
 
#Loop to modify each folder in the path set above
Foreach ($Folder in $HomeFolders)
{
    #set username to apply permissions
    $Username = $Folder.Name+"@"+$FQDN

    #error check to check format of directory
    $result = $HomeFoldersRoot.EndsWith("\") 
    If ($result -eq $false) {$HomeFoldersRoot = $HomeFoldersRoot+"\"}

    $Folder = $HomeFoldersRoot+$Folder

    Write-host $Folder.Name
     
    #retrieve current folder ACL's
    $Access = GET-ACL $Folder

    #Set Rights that will be changed in following variables
    #for rights available see http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx
    #Subfolders and Files only	InheritanceFlags.ContainerInherit, InheritanceFlags.ObjectInherit, PropagationFlags.InheritOnly
    #This Folder, Subfolders and Files   	InheritanceFlags.ContainerInherit, InheritanceFlags.ObjectInherit, PropagationFlags.None
    #This folder and subfolders	InheritanceFlags.ContainerInherit, PropagationFlags.None
    #Subfolders only	InheritanceFlags.ContainerInherit, PropagationFlags.InheritOnly
    #This folder and files	InheritanceFlags.ObjectInherit, PropagationFlags.None
    #This folder and files	InheritanceFlags.ObjectInherit, PropagationFlags.NoPropagateInherit
    $FileSystemRights = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles, Write, ReadAndExecute, Synchronize"
    $AccessControlType = [System.Security.AccessControl.AccessControlType]"Allow"
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"
    $IdentityReference = $Username

    #print what folder is being modified currently
    Write-host 'Modifying' $Username

    #Build command to modify folder ACL's and place in variable
    $FileSystemAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType
     
    $Access.AddAccessRule($FileSystemAccessRule)
    Write-host $Access | fl
     
    #Set ACL's on Folder being modified
    SET-ACL $Folder $Access
  
}

#NOTES

#use get-executionpolicy to view what the script execution polily is
#use Set-executionpolicy to set the policy options are Unrestricted | RemoteSigned | AllSigned | Restricted

#The possible values for Rights are 
# ListDirectory, ReadData, WriteData 
# CreateFiles, CreateDirectories, AppendData 
# ReadExtendedAttributes, WriteExtendedAttributes, Traverse
# ExecuteFile, DeleteSubdirectoriesAndFiles, ReadAttributes 
# WriteAttributes, Write, Delete 
# ReadPermissions, Read, ReadAndExecute 
# Modify, ChangePermissions, TakeOwnership
# Synchronize, FullControl
