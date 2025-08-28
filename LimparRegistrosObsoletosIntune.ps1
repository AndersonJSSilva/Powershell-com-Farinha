#Salvar Usuário e Senha
$Credencial = Get-Credential

#Coletar Máquinas
$Computadores = Get-Content -Path c:\temp\computadores.txt
Foreach ($Computador in $Computadores){

#Script que será executado remotamente
$ScriptBlock = {
$baseKey = "HKLM:\SOFTWARE\Microsoft\Enrollments"

# Verifica se a chave existe
if (Test-Path $baseKey) {
    # Lista todas as subchaves
    $subKeys = Get-ChildItem -Path $baseKey
    
    foreach ($subKey in $subKeys) {
        if (($subKey.Name -notlike "*Context") -or ($subKey.Name -notlike "*Ownership") -or ($subKey.Name -notlike "*Status") -or ($subKey.Name -notlike "*ValidNodePaths")){
        $fullPath = $subKey.PSPath
        try {
            Remove-Item -Path $fullPath -Recurse -Force
            Write-Host "Subchave removida: $fullPath"
        } catch {
            Write-Host "Erro ao remover: $fullPath - $_"
        }}}}}}