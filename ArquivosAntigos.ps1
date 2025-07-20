#Limpeza de Variáveis
$Origem = @();
$Destino = @();
$DataDeCorte = @();
$ArquivosParaMover = @();
$Arquivo = @();
$CaminhoAtual = @();
$CaminhoArquivo = @();
$Relatorio = @();
$Movimentacao = @();
$Dia = @();
$Mes = @();
$Ano = @();
$Hora = @();
$Minuto = @();
$Segundo = @();
$Data = @();
$NovaData = @();

#Definição de Diretório de Origem e Destino
$Origem = "I:\DEINFRA"
$Destino = "\\172.28.1.122\D$\ARQUIVOS_SIE\DEINFRA"

#Geração de Arquivo de Log
$Data = Get-Date
[string]$Dia = $Data 
[string]$Mes = $Data 
[string]$Ano = $Data 
[string]$Hora = $Data 
[string]$Minuto = $Data 
[string]$Segundo = $Data 
[string]$Movimentacao = $Dia.substring(3,2) + $Mes.substring(0,2) + $Ano.substring(6,4) + "_" + $Hora.substring(11,2) + $Minuto.substring(14,2) + $Segundo.substring(17,2)

#Definição de Data de Corte (5 Anos)
$DataDeCorte = (Get-Date).AddDays(-1825)

#Levantamento de Arquivos pela Data de Corte (5 Anos)
$ArquivosParaMover = Get-ChildItem -Path $Origem -File -Recurse | Where-Object { $_.LastWriteTime -lt $DataDeCorte }

#Movimentação de Arquivos
foreach ($Arquivo in $ArquivosParaMover) {
    $CaminhoAtual = $Arquivo.DirectoryName
    $CaminhoDestino = $CaminhoAtual.Replace("I:\DEINFRA",$Destino)
    New-Item $CaminhoDestino -ItemType directory -Force 
    Move-Item -LiteralPath $Arquivo.FullName -Destination $CaminhoDestino -Force
    $CaminhoArquivo = Join-Path -Path $CaminhoDestino -ChildPath $Arquivo.Name
    $NovaData = Get-Date
    (Get-Item -Path $CaminhoArquivo).LastWriteTime = $NovaData
    $Relatorio += $Arquivo.FullName
}

#Geração de Relatório de Arquivos Movidos
$Relatorio | Out-File -FilePath "c:\Scripts\Log\ArquivosSIE_$Movimentacao.txt"