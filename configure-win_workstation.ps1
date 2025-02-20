<#
# Development Environment Setup Script

This PowerShell script automates the setup of a development environment by installing and configuring essential development tools and VS Code extensions.

## Tools Installed

The script installs the following applications using Windows Package Manager (winget):
1. AWS CLI - For interacting with AWS services
2. Terraform - Infrastructure as Code tool (installed to C:\terraform)
3. Git - Version control system
4. Visual Studio Code - Code editor
5. Python 3.12 - Programming language (installed to C:\Python312)

## Path Configuration

- Adds Terraform installation directory to system PATH
- Python is installed to custom location for easier management

## VS Code Extensions

Installs the following VS Code extensions if not already present:
- SQL Server (ms-mssql.mssql)
- WSL Remote (ms-vscode-remote.remote-wsl)
- GitHub Pull Requests (GitHub.vscode-pull-request-github)

## Update Process

- Runs winget upgrade --all to ensure all installed packages are up to date
- Checks for existing VS Code extensions before installing to avoid duplicates
- Provides visual feedback during extension installation

## Usage

Run the script with administrative privileges. The script will:
1. Install all specified applications via winget
2. Configure necessary PATH variables
3. Install required VS Code extensions
4. Update all winget-managed applications

## Requirements

- Windows 10/11
- Windows Package Manager (winget)
- Administrative privileges
- Internet connection

Note: VS Code must be accessible via 'code' command in PowerShell for extension installation to work.
#>

winget install Amazon.AWSCLI
winget install Hashicorp.Terraform --location C:\terraform
$env:Path += ";C:\terraform"
winget install Git.git
winget install Microsoft.VisualStudioCode
winget install -e --id Python.Python.3.12 --location C:\Python312

winget upgrade --all

# Script for batch installing Visual Studio Code extensions
# Specify extensions to be checked & installed by modifying $extensions

$extensions =
    "ms-mssql.mssql",
    "ms-vscode-remote.remote-wsl",
    "GitHub.vscode-pull-request-github"

$cmd = "code --list-extensions"
Invoke-Expression $cmd -OutVariable output | Out-Null
$installed = $output -split "\s"

foreach ($ext in $extensions) {
    if ($installed.Contains($ext)) {
        Write-Host $ext "already installed." -ForegroundColor Gray
    } else {
        Write-Host "Installing" $ext "..." -ForegroundColor White
        code --install-extension $ext
    }
}
