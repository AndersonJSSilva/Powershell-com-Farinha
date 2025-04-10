#Limpeza de Variáveis
$Recebimentos = @();
$Recebimento = @();
$Saida = @();
$IdAplicativo = @();
$ThumbprintCertificado = @();
$Organizacao = @(); 

#Importação de Módulos Exchange Online
$IdAplicativo = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxx"
$ThumbprintCertificado = "xxxxxxxxxxxxxxxxx"
$Organizacao = "Dominio.com.br"
Connect-ExchangeOnline -AppId $IdAplicativo -CertificateThumbprint $ThumbprintCertificado -Organization $Organizacao -ShowBanner:$false

#Pesquisa de Emails interceptados nas últimas 24 Horas
$Recebimentos=Get-MessageTrace -RecipientAddress usuario@dominio.com.br -StartDate (Get-Date).AddHours(-24) -EndDate (Get-Date) | Select Subject, Status, Received

#Exportação de Emails com erro nos últimos 30 Dias
Foreach ($Recebimento in $Recebimentos) {
If (($Recebimento.Status -eq "Failed") -or ($Recebimento.Status -eq "FilteredAsSpam") -or ($Recebimento.Status -eq "Quarantined")){
Write-Output "1" }
else{
Write-Output "0"}}