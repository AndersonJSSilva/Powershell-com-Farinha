#Conectar nos Serviços M365 e Exchange Online
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline
    Connect-IPPSSession -UserPrincipalName Usuario@dominio.com.br

#Script para descoberta de FolderIds para criação da pesquisa de conteúdo
   $emailAddress = Read-Host "Enter an email address"
   $folderQueries = @()
   $folderStatistics = Get-MailboxFolderStatistics $emailAddress
   foreach ($folderStatistic in $folderStatistics)
   {
       $folderId = $folderStatistic.FolderId;
       $folderPath = $folderStatistic.FolderPath;
       $encoding= [System.Text.Encoding]::GetEncoding("us-ascii")
       $nibbler= $encoding.GetBytes("0123456789ABCDEF");
       $folderIdBytes = [Convert]::FromBase64String($folderId);
       $indexIdBytes = New-Object byte[] 48;
       $indexIdIdx=0;
       $folderIdBytes | select -skip 23 -First 24 | %{$indexIdBytes[$indexIdIdx++]=$nibbler[$_ -shr 4];$indexIdBytes[$indexIdIdx++]=$nibbler[$_ -band 0xF]}
       $folderQuery = "folderid:$($encoding.GetString($indexIdBytes))";
       $folderStat = New-Object PSObject
       Add-Member -InputObject $folderStat -MemberType NoteProperty -Name FolderPath -Value $folderPath
       Add-Member -InputObject $folderStat -MemberType NoteProperty -Name FolderQuery -Value $folderQuery
       $folderQueries += $folderStat
   }
   Write-Host "-----Exchange Folders-----"
   $folderQueries |ft

#Link para Criação da Pesquisa
https://learn.microsoft.com/pt-br/purview/ediscovery-use-content-search-for-targeted-collections

#Buscar Tamanho de Caixa de Usuário
Get-MailboxStatistics -Identity Usuario@dominio.com.br | Select TotalDeletedItemSize, TotalItemSize, DeletedItemCount

#Deletar dados de pesquisa realizada
New-ComplianceSearchAction -SearchName "Discovery Holds" -Purge -PurgeType HardDelete -confirm:$false
Remove-ComplianceSearchAction "Discovery Holds"
Get-ComplianceSearchAction

####Limpar Discovery Holds####

#Pesquisar Pastas
Get-MailboxFolderStatistics -Identity Usuario@dominio.com.br | select name,foldersize

#Buscar Políticas de Retenção
Get-RetentionCompliancePolicy -Identity "Retenção de E-mails"
Set-RetentionCompliancePolicy -Identity "Retenção de E-mails" -AddExchangeLocationException Usuario@dominio.com.br

#Setar Pasta de Deletados para 0
Set-Mailbox -Identity Usuario@dominio.com.br -RetainDeletedItemsFor 14
Get-Mailbox -Identity Usuario@dominio.com.br | Select RetainDeletedItemsFor

#Rodar 2 vezes
Start-Managedfolderassistant -Identity Usuario@dominio.com.br
Start-Managedfolderassistant -Identity Usuario@dominio.com.br

#Esperar 2-3 minutos 
Get-Mailbox "Usuario@dominio.com.br" | FL DelayHoldApplied,DelayReleaseHoldApplied
 
#Aplicar Propriedades de Delay Hold
set-Mailbox Usuario@dominio.com.br -RemoveDelayHoldApplied
Set-Mailbox Usuario@dominio.com.br -RemoveDelayReleaseHoldApplied

#Rodar 2 vezes
Start-Managedfolderassistant -Identity Usuario@dominio.com.br
Start-Managedfolderassistant -Identity Usuario@dominio.com.br