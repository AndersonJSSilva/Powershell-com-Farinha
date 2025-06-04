#Instalação de Módulo Az
Install-Module Az

#Conexão no Portal Azure
Connect-AzAccount

#Buscar Subscrição
$Subscricao = Get-Azsubscription

#Conexão na Subscrição com o Azure Blob
Set-AzContext -Subscription 99e09fb4-fxx1-4xxc-91db-8ca7dxxxxx7d

#Buscar Resource Group
New-AzResourceGroup -Name RecursoTeste -Location EastUS
Get-azResourceGroup

#Criar/Buscar Storage Account
New-AzStorageAccount -ResourceGroupName RecursoTeste -Name StorageAccountTeste -Location eastus -SkuName Standard_RAGRS -Kind StorageV2
Get-AzStorageAccount

#Criar Container
$Context = (Get-AzStorageAccount -ResourceGroupName RecursoTeste -Name StorageAccountTeste).Context
New-AzStorageContainer -Name ContainerTeste -Context $Context
Get-AzStorageContainer -Context $Context
$ContainerName = "PastaTeste"

#Upload/Download Vários Arquivos
$Arquivos = Get-ChildItem -Path "C:\Temp"
Foreach($Arquivo in $Arquivos){

#Upload de Arquivos no Azure Blob
$UploadArquivo = @{
  File             = $Arquivo.FullName
  Container        = $ContainerName
  Blob             = $Arquivo.Name
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @UploadArquivo -Force
}

#Download de Arquivos no Azure Blob
$DownloadArquivo = @{
  Blob        = $Arquivo.Name
  Container   = $ContainerName
  Destination = $Arquivo.DirectoryName+"\Download"
  Context     = $Context
}
Get-AzStorageBlobContent @DownloadArquivo -Force
