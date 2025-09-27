#Limpeza de Variáveis
$UsuariosCriados = @();

#Validação de Último Usuário
$UltimoUsuario = Get-ADUser -Filter 'employeeID -like "*"' -Properties employeeID | Select-Object -ExpandProperty employeeID | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

#Configurações de conexão com o SQL Server
$connectionString = "Server=Pzxxx02;Database=Banco;User Id=ad.protheus;Password=$xxxx42YG;"

#Consulta SQL que retorna os dados dos usuários
$query = @"
SELECT * FROM View_Usr_Funcionarios
"@

#Conectar ao banco e obter os dados
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = $query
$reader = $command.ExecuteReader()

#Validação e Criação de Usuários
#O Atributo EmployeeID está com o Contador
while ($reader.Read()){
$Nome = $reader["ra_nome"]
$Contador = $reader["R_E_C_N_O_"]
$CentroDeCusto = $reader["RA_CC"]
$Matricula = $reader["RA_MAT"]
$Cargo = $reader["Cargo"]
$Departamento = $reader["CTT_DESC01"]
If($Contador -gt $UltimoUsuario){
$NomeCompleto = $Nome.split();
$PrimeiroNome = $NomeCompleto[0]
$PrimeiroEspaco = $Nome.IndexOf(' ')
$Sobrenome = $Nome.Substring($PrimeiroEspaco+1)
$Empresa = Microsoft 365 na Veia LTDA"
$Login = $NomeCompleto[0]+"."+$NomeCompleto[-1]
$LoginMinusculo = $Login.ToLower()
New-ADUser `
-Name $Nome `
-GivenName $PrimeiroNome `
-Surname $Sobrenome `
-Company $Empresa `
-Title $Cargo `
-Division $CentroDeCusto `
-Department $Departamento `
-EmployeeID $Contador `
-EmployeeNumber $Matricula `
-SamAccountName $LoginMinusculo `
-UserPrincipalName "$LoginMinusculo@ibratec.com.br" `
-AccountPassword (ConvertTo-SecureString "SenhaPadrão123!" -AsPlainText -Force) `
-Enabled $true `
-Path "OU=TESTE,OU=Usuarios,DC=Teste,DC=local"
$UsuariosCriados += $Nome
}else{
$Usuario = Get-ADUser -Filter "Name -like '$Nome'" -Properties *
if($Usuario.EmployeeID -eq ""){
$AlteracaoEmployeeID = Set-ADUser -Identity $Usuario.samaccountname -EmployeeID $Contador
}else{}
}}
$UsuariosCriados | Out-File -FilePath C:\TI\NovosUsuarios.txt

#Configurações de envio de e-mail
$SMTPServer = "xx2.xxx.0.203"
$From = "Anderson@dominio.com.br"
$To = "ti@dominio.com.br"
$body = "Novo Usuarios:`n`n" + ($UsuariosCriados -join "`n")
$Attachments = "C:\TI\NovosUsuarios.txt"
$Subject = "Resultado: Novos Usuarios Criados no AD"
Send-MailMessage -From $From -To $To -Subject $Subject -Attachments $Attachments -Body $body -SmtpServer $smtpServer -Port 25

#Validação de Usuários com Nome Diferente no AD
$NomesDiferentes = Get-ADUser -Filter 'employeeID  -notlike "*"' -Properties * | Where-Object {$_.Company -eq "Microsoft 365 na Veia LTDA"} |  Select Name
$NomesDiferentes | Out-File -FilePath C:\TI\NomesDiferentes.txt

#Finaliza Conexão com Banco
$reader.Close()
$connection.Close()