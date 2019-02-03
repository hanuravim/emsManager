Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)
#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true

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
New-PSDrive -Name X -PSProvider FileSystem -Root "\\$SAName.file.core.windows.net\$AzureFileShareName" -Credential $credential -Persist 

#DISABLE AUTO UPDATES
Stop-Service -Name "wuauserv" -Force
