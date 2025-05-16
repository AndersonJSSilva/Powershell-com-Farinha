param([string]$userName)

Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Install-Module -Name MSOnline
Install-Module -Name AzureAD
Connect-MSOLService
Connect-SPOService https://empresacombr-admin.sharepoint.com
$userName = "Anderson.Jose@empresa.com.br

$urlPrefix="https://empresacombr-my.sharepoint.com/personal/"

$url=$urlPrefix + $userName.Replace(".","_").Replace("@","_")

$OneDrive=Get-SPOSite $url

$ODBCurentUsage=$onedrive.StorageUsageCurrent

$ODBStorageQuota=$OneDrive.StorageQuota

$ODBLastContentModifiedDate=$OneDrive.LastContentModifiedDate

Write-Host "User: $userName, Used Space $ODBCurentUsage, Quota $ODBStorageQuota, Last Changed date $ODBLastContentModifiedDate"
