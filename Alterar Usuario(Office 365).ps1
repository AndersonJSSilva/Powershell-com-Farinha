#Importação de Módulos Office 365
$Credential=Get-Credential
Import-Module ExchangeOnlineManagement
Install-Module MSOnline
Connect-MsolService -Credential $Credential

#Limpeza de Variáveis
$Usuarios = @();
$Usuario = @();
$Nome = @();
$Sobrenome = @();
$Cargo = @();
$Email = @();

#Entrada de Grupos
$Usuarios = Get-Content -Path c:\temp\Usuarios.txt

#Alteração de Usuários
Foreach ($Usuario in $Usuarios){
$Nome = @($Usuario -split ";")[0]
$Sobrenome = @($Usuario -split ";")[1]
$Cargo = @($Usuario -split ";")[2]
$Email = @($Usuario -split ";")[3]
Get-MSOLUser -UserPrincipalName $Email | Set-MSOLUser -FirstName $Nome -LastName $Sobrenome -Title $Cargo
}