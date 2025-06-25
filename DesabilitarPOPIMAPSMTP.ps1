#Conectar Exchange Online
Connect-ExchangeOnline

#Desabilitar SMTP, POP e IMAP por Usuário
Get-EXOCasMailbox -Filter {PrimarySmtpAddress -eq "Asilva.interop@es.sesc.com.br"} | Set-CASMailbox -ImapEnabled $false -PopEnabled $false -SmtpClientAuthenticationDisabled $true

#Desabilitar SMTP, POP e IMAP para Todos
Get-EXOCasMailbox -Filter {ImapEnabled -eq $True -or PopEnabled -eq $True} -ResultSize 5000 | Set-CASMailbox -ImapEnabled $false -PopEnabled $false -SmtpClientAuthenticationDisabled $true

#Desabilitar POP e IMAP para Novos Usuários
Get-CasMailboxplan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false

#Desabilitar SMTP para Novos Usuários
Set-TransportConfig -SmtpClientAuthenticationDisabled $true