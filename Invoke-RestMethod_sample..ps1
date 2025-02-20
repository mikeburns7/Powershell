<#
# API Delete Request Script

A simple PowerShell script that executes a DELETE request to an API endpoint using Bearer token authentication.

## Usage

The script will:
1. Prompt for an access token
2. Make a DELETE request to the specified API endpoint using the provided token
3. Include proper authorization and content-type headers

## Request Details

- Method: DELETE
- URL: https://myapiurl.api
- Headers:
 - Authorization: Bearer token
 - Content-Type: application/json

## Security Note

The access token is collected via secure input and is not displayed on screen when typed.

## Requirements

- PowerShell
- Internet connectivity
- Valid API access token

## Example Usage

```powershell
.\delete-api-resource.ps1
Provide App Access Token: **********************
#>

$access_token = Read-Host "Provide App Acccess Token"

Invoke-RestMethod -Method "DELETE" -Uri "https://myapiurl.api" -Headers @{Authorization = "Bearer $($access_token)"; "Content-Type" = "application/json"}
