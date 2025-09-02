#Instalação de Módulo Az
Install-Module Az

#Conexão no Portal Azure
Connect-AzAccount

#Buscar Subscrição
$Subscricao = Get-Azsubscription

#Conexão na Subscrição com o Azure Blob
Set-AzContext -Subscription 99e09fb4-f771-4a5c-91db-8ca7d7ceca7d

#Buscar Resource Group
New-AzResourceGroup -Name AzureFloripars -Location EastUS
Get-azResourceGroup

#Criar/Buscar Storage Account
New-AzStorageAccount -ResourceGroupName AzureFloripars -Name azfloripateste -Location eastus -SkuName Standard_RAGRS -Kind StorageV2
Get-AzStorageAccount

#Criar Container
$Context = (Get-AzStorageAccount -ResourceGroupName AzureFloripars -Name azfloripateste).Context
New-AzStorageContainer -Name globalazure -Context $Context
Get-AzStorageContainer -Context $Context
$ContainerName = "globalazure"

#Upload/Download Vários Arquivos
$Arquivos = Get-ChildItem -Path "C:\Azure Floripa"
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

##########################################################

#Download Arquivo
mkdir "C:\Azure Floripa"
(new-object System.Net.WebClient).DownloadFile(‘https://andersonjosesa.blob.core.windows.net/atalho/chamados.ico’,’C:\Azure Floripa\Download\chamados.ico’)
