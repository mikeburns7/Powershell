<#
# Windows Firewall Logging Setup Script

## Purpose
This PowerShell script configures the Windows Firewall logging environment by creating the necessary directory and setting appropriate permissions.

This script ensures proper logging functionality for Windows Firewall by setting up the necessary directory structure and permissions, which is essential for firewall monitoring and troubleshooting.
## Overview

The script performs two main tasks:
1. Creates the Windows Firewall logging directory if it doesn't exist
2. Sets proper permissions for the Windows Firewall service (mpssvc) to write logs

## Path Configuration

The script operates on the following directory:
%windir%\System32\LogFiles\Firewall

## Permission Details

The script configures the following permissions:
- Account: NT SERVICE\mpssvc (Windows Firewall service) 
- Access Level: Full Control
- Inheritance: Container and Object Inherit
- Propagation: None
- Type: Allow

## Usage

Simply run the script with administrative privileges. The script will:
- Check if the logging directory exists and create it if necessary
- Configure the required permissions automatically
- Provide feedback on the directory creation status

## Requirements

- Windows operating system
- Administrative privileges
- PowerShell execution enabled
#>

if (-not (Test-Path -Path $env:windir\System32\LogFiles\Firewall)) {
  New-Item -ItemType Directory -Path $env:windir\System32\LogFiles\Firewall
  Write-Host "Folder 'Firewall' created successfully."
} else {
  Write-Host "Folder 'Firewall' already exists."
}


$LogPath = Join-Path -path $env:windir -ChildPath "System32\LogFiles\Firewall"
$NewAcl = Get-Acl -Path $LogPath


$identity = "NT SERVICE\mpssvc"
$fileSystemRights = "FullControl"
$inheritanceFlags = "ContainerInherit,ObjectInherit"
$propagationFlags = "None"
$type = "Allow"


$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $inheritanceFlags, $propagationFlags, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList


$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path $LogPath -AclObject $NewAcl
