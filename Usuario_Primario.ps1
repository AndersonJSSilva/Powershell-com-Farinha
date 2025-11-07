<#
    .NOTES
        Criado por: Thiago Rufino e Adaptado por Anderson José para Tarefa no Active Directory para UserName diferente de Email
        https://thiagorufino.com/automatizando-atualizacao-primary-user-usuario-conectado/
        Data: 20/09/2025
        Version: 2.0
#>

#Criar Certificado para Aplicativo Registrado
#$cert = New-SelfSignedCertificate `
#-Subject "CN=GraphAppCert" `
#-CertStoreLocation "Cert:\CurrentUser\My" `
#-KeySpec KeyExchange `
#-KeyLength 2048 `
#-NotAfter (Get-Date).AddYears(2)
#$path = "$env:USERPROFILE\Desktop\GraphAppCert.pfx"
#$password = ConvertTo-SecureString -String "SenhaForte123!" -Force -AsPlainText
#Export-PfxCertificate -Cert $cert -FilePath $path -Password $password
#Import-PfxCertificate -FilePath $Path `
#-CertStoreLocation "Cert:\LocalMachine\My" `
#-Password $Password
#$certinstall = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=GraphAppCert" }
#$exportPath = "$env:USERPROFILE\Desktop\GraphAppCert.cer"
#Export-Certificate -Cert $certinstall -FilePath $exportPath

#Variáveis Globais
$ClientId = "0fa0dd54-3af8-4f93-9dcd-acbc24156585"
$ClientSecret = "6Tr8Q~ZOZJ_.gyduvo1Y4kVbmXs2P4pGVKGcsc~Z"
$TenantId = "1668c301-d212-4f0f-a4e4-4431d64bc0b7"
$Thumbprint = "18ddd98b20c166f3fc487dd4db2afece9d8536fb"
$Data = Get-Date -Format "dd/MM/yyyy - HH:mm:ss"
$NovosUsuariosPrimarios = @();

#Criação de Log com Novos Usuários Primários
mkdir "C:\Temp\Usuários Primários" -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "C:\Temp\Usuários Primários\NovosUsuariosPrimarios.txt" -ErrorAction SilentlyContinue | Out-Null

#Conectar Microsoft Graph e Azure AD
Connect-MgGraph -ClientId $ClientID -TenantId $TenantId -CertificateThumbprint $Thumbprint -NoWelcome

#Autenticação no Aplicativo
$authUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"

$authParams = @{
    client_id     = $clientId
    client_secret = $clientSecret
    grant_type    = "client_credentials"
    resource      = "https://graph.microsoft.com"
}

$tokenResponse = Invoke-RestMethod -Method Post -Uri $authUrl -Body $authParams
$accessToken = $tokenResponse.access_token
$headers = @{
    Authorization  = "Bearer $accessToken"
    'Content-Type' = 'application/json'
}

function Get-LocalDevice {
    try {
        $DeviceUri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$filter=deviceName eq '$DeviceName'"
        $DeviceResponse = (Invoke-RestMethod -Uri $DeviceUri -Headers $headers -Method Get)
        $Device = $DeviceResponse.value
        return $Device
    }
    catch {}
}

function Get-LocalUser {
    try {
        $UserUri = "https://graph.microsoft.com/v1.0/users?`$select=id,displayName,userPrincipalName&`$filter=startsWith(userPrincipalName,'$($LocalUser)')"
        $UserResponse = (Invoke-RestMethod -Uri $UserUri -Headers $headers -Method Get)
        $User = $UserResponse.value
        return $User
    }
    catch {}    
}

function Get-CurrentlyPrimaryUser {
    param (
        [string]$DeviceID
    )
    try {
        $PrimaryUserUri = "https://graph.microsoft.com/beta/deviceManagement/manageddevices('$DeviceID')/users"
        $PrimaryUserResponse = (Invoke-RestMethod -Uri $PrimaryUserUri -Headers $headers -Method Get)
        $PrimaryUser = $PrimaryUserResponse.value
        return $PrimaryUser
    }
    catch {}
}

function Test-PrimaryUser {
    param(
        [string]$UserID,
        [string]$CurrentlyPrimaryUserID
    )
    if ($UserID -eq $CurrentlyPrimaryUserID) {
        return $true
    }
    else {
        return $false
    }
}

function Set-NewPrimaryUser {
    param (
        [string]$DeviceID,
        [string]$UserID
    )
    try {
        $DeviceIDUri = "https://graph.microsoft.com/beta/deviceManagement/manageddevices('$DeviceID')/users/`$ref"
        $UserIDUri = "https://graph.microsoft.com/beta/users/" + $UserID
        $id = "@odata.id"
        $Body = @{ $id = "$UserIDUri" } | ConvertTo-Json -Compress
        $response = (Invoke-RestMethod -Uri $DeviceIDUri -Headers $headers -Method POST -Body $Body)
        return $response
    }
    catch {}
}

#Pesquisa de Dispositivos Windows 10/11 e Email de Usuário para o Graph API
$Devices = Get-MgDevice -All

#Filtrar apenas Windows 10 e 11
$WindowsDevices = $Devices | Where-Object {
    $_.OperatingSystem -match "Windows" -and (
        $_.OperatingSystemVersion -like "10*" -or
        $_.OperatingSystemVersion -like "11*"
    )
}
#$WindowsDevices = @("bds05311171","BDS0531104");

#Identificação de Usuários Ativos
Foreach($WindowsDevice in $WindowsDevices){
If(Test-Connection -Count 1 $WindowsDevice.DisplayName){
$TesteOK += $WindowsDevice.DisplayName
Invoke-Command -ComputerName $WindowsDevice.DisplayName -ScriptBlock {
mkdir "c:\temp" -ErrorAction SilentlyContinue | Out-Null
$UsuarioTempoReal = Get-CimInstance Win32_Process -Filter 'name="explorer.exe"' | Invoke-CimMethod -MethodName GetOwner | select User
$QuantidadeUsuarios = $UsuarioTempoReal.Length
if($QuantidadeUsuarios -gt "1"){
$UsuarioTempoReal.user[-1] > "C:\Temp\Usuário Ativo.txt"
}else{
$UsuarioTempoReal.user > "C:\Temp\Usuário Ativo.txt"
}}}}

#Alteração de Usuários Primários
Foreach($WindowsDeviceAtivo in $TesteOK){
If(Test-Connection -Count 1 $WindowsDeviceAtivo){
$DeviceName = $WindowsDeviceAtivo
$UsuarioLogado = Get-Content -Path "\\$DeviceName\c$\temp\Usuário Ativo.txt"
if($UsuarioLogado -ne $null){
$UsuarioLogadoEmail = Get-Aduser -Identity $UsuarioLogado | select UserPrincipalName
$LocalUser = $UsuarioLogadoEmail.UserPrincipalName

#Definição de Dispositivo e Usuário Logado
$Device = Get-LocalDevice
$User = Get-LocalUser

#Avaliação de Usuário Logado
if ($Device) {
        if ($User) {
        $CurrentlyPrimaryUser = Get-CurrentlyPrimaryUser -DeviceID $Device.id
                if ($CurrentlyPrimaryUser) {
                $StatusPrimaryUser = Test-PrimaryUser -UserID $User.id -CurrentlyPrimaryUserID $CurrentlyPrimaryUser.id
                    if ($StatusPrimaryUser -eq $true) {}
                    else { 
                    Set-NewPrimaryUser -DeviceID $Device.id -UserID $User.id
                    $Data +" - "+ $User.displayName +" - "+ $Device.deviceName >> "C:\Temp\Usuários Primários\NovosUsuariosPrimarios.txt"
                    }}}}}}}