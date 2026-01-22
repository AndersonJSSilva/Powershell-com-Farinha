#Variáveis Globais
$TenantId = "7xxxx479-ab5f-4vvf-94f9-eyuio7a9e011"
$AppClientId="7876052f-6b54-4846-82eb-4e90f4806181"
$ClientSecret ="Uv08Q~R48aMMb5674dffrltdresMX2moZ~ejQVaLu"

#Criando Variáveis
$Env:AZURE_CLIENT_ID = $AppClientId
$Env:AZURE_TENANT_ID = $TenantId
$Env:AZURE_CLIENT_SECRET = $ClientSecret

#Conectando no M365.
Connect-MgGraph -EnvironmentVariable

#Montando os Parâmetro do Graph API
$DisplayNames= Get-content -Path C:\Temp\Policies.txt
$Uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations"

Foreach($DisplayName in $DisplayNames){
$Json=  @"
{
            "@odata.type": "#microsoft.graph.windows10CustomConfiguration",
            "lastModifiedDateTime": "2025-07-28T21:22:44.6340438Z",
            "createdDateTime": "2025-07-28T21:22:44.6340438Z",
            "description": null,
            "displayName": "$displayname",
            "version": 1,
            "omaSettings": [
                {
                    "@odata.type": "#microsoft.graph.omaSettingInteger",
                    "displayName": "1.1.1 (L1) Ensure 'Enforce password history' is set to '24 or more passwords'",
                    "description": null,
                    "omaUri": "./Device/Vendor/MSFT/Policy/Config/DeviceLock/DevicePasswordHistory",
                    "value": 24
                },
                {
                    "@odata.type": "#microsoft.graph.omaSettingInteger",
                    "displayName": "1.1.2 (L1) Ensure 'Maximum password age' is set to '365 or fewer days, but not 0'",
                    "description": null,
                    "omaUri": "./Device/Vendor/MSFT/Policy/Config/DeviceLock/DevicePasswordExpiration",
                    "value": 0
                },
                {
                    "@odata.type": "#microsoft.graph.omaSettingInteger",
                    "displayName": "1.1.3 (L1) Ensure 'Minimum password age' is set to '1 or more day(s)'",
                    "description": null,
                    "omaUri": "./Device/Vendor/MSFT/Policy/Config/DeviceLock/MinimumPasswordAge",
                    "value": 1
                },
                {
                    "@odata.type": "#microsoft.graph.omaSettingInteger",
                    "displayName": "1.1.4 (L1) Ensure 'Minimum password length' is set to '14 or more characters'",
                    "description": null,
                    "omaUri": "./Device/Vendor/MSFT/Policy/Config/DeviceLock/MinDevicePasswordLength",
                    "value": 6
                },
                {
                    "@odata.type": "#microsoft.graph.omaSettingInteger",
                    "displayName": "1.1.5 (L1) Ensure 'Password must meet complexity requirements' is set to 'Numbers, lowercase, uppercase and special characters required'",
                    "description": null,
                    "omaUri": "./Device/Vendor/MSFT/Policy/Config/DeviceLock/MinDevicePasswordComplexCharacters",
                    "value": 1
                }
            ]
        }
"@

#Executando o Graph API
Invoke-MgGraphRequest -Uri $Uri -Method Post -Body $Json
}