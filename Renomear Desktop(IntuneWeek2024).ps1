#Intune Week 2024 (Verificação)

#Download Arquivo de Seriais
mkdir C:\temp
(new-object System.Net.WebClient).DownloadFile(‘https://xxxx.blob.windows.net/renomeardesktop/xxxx.txt’,’C:\temp\Seriais.txt’)

#Variáveis Globais
$Seriais = Get-content -Path c:\temp\seriais.txt
$Hostname = Get-WmiObject Win32_ComputerSystem | Select-Object Name
$SerialHostname = Get-WmiObject Win32_BIOS | Select SerialNumber

##Avaliação de Hostname
foreach($Serial in $Seriais){
$SerialID = @($Serial -split ";")[0]
$HostnameID = @($Serial -split ";")[1]
    If ($SerialHostname.SerialNumber -eq $SerialID){
        if ($Hostname.Name -eq $HostnameID){
        exit 0}
    else{
    $Saida = $HostnameID
    $Saida | Out-File -FilePath c:\temp\LogIntune.txt
    exit 1}
}}

#Intune Week 2024 (Correção)

#Variáveis Globais
$HostnameCorrecao = Get-content -Path C:\temp\LogIntune.txt
$Usuario = "Dmonínio.com.br\usuario"

#Download Arquivo de Senha (Primeira Opção)
mkdir C:\temp
(new-object System.Net.WebClient).DownloadFile(‘https://xxxx.blob.windows.net/renomeardesktop/xxxx.txt’,’C:\temp\.txt’)
$Senha = "c:\temp\.txt"
$SenhaCriptografada = Get-Content $Senha | ConvertTo-SecureString
$Credencial = new-object -typename System.Management.Automation.PSCredential -argumentlist $Usuario, $SenhaCriptografada

#KeyVault com Senha (Segunda Opção)
#$TenantID = "14c17b65-fcb9-xxxx-adf4-861xxxx76082"
#$App_ID = "42a79888-1e63-4097-8dd0-a443c7278ded"
#$ThumbPrint = "617FCE0529xxxxxx68F380A1405B868E8B7Axxxx"
#Connect-AzAccount -tenantid $TenantID -ApplicationId $App_ID -CertificateThumbprint $ThumbPrint
#$Cofre = (Get-AzKeyVaultSecret -vaultName "KVRenomearDesktop" -name "RenomearDesktopsUser") | select *
#$BuscaCofre = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Cofre.SecretValue) 
#$Senha = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BuscaCofre)
#$SenhaCriptografada = ConvertTo-SecureString "$Senha" -AsPlainText -Force
#$Credencial = new-object -typename System.Management.Automation.PSCredential -argumentlist $Usuario, $SenhaCriptografada

#Alterar Hostname
Rename-Computer -NewName $HostnameCorrecao -DomainCredential $Credencial

#Remover Arquivos
Remove-Item -Path C:\temp\.txt