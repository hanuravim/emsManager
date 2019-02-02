$SAKey = 'azkvrE9mzuijmBT+/B+ho3P80xY5p0P4UsmvMfUjqqF8Ybt27K6RWVT8kz7KPsCOdLxDiWJ9EWUilOE7ZtYBfA=='
$SAName = 'emswu2trprdemsstr001'
$AzureFileShareName = 'fsshare'

#CONFIGURE AZURE FILE SHARE ON PORTAL
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Import-Module Azure
$storageContext = New-AzureStorageContext -StorageAccountName $SAName -StorageAccountKey $SAKey
$storageContext |  New-AzureStorageShare -Name $AzureFileShareName

#MOUNT AZURE FILE SHARE
$acctKey = ConvertTo-SecureString -String $SAKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$SAName", $acctKey
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$SAName.file.core.windows.net\$AzureFileShareName" -Credential $credential -Persist 

#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true
#################################################
#DISABLE AUTO UPDATES
Stop-Service -Name "wuauserv" -Force
#################################################
