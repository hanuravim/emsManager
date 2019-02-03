Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)
#MOUNT AZURE FILE SHARE
$acctKey = ConvertTo-SecureString -String $SAKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$SAName", $acctKey
New-PSDrive -Name X -PSProvider FileSystem -Root "\\$SAName.file.core.windows.net\$AzureFileShareName" -Credential $credential -Persist 
