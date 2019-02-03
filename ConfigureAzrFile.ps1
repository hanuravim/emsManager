Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)
#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true

#INITIAIZE ADI VOLUME
$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
$count = 0
    $letter = "F"
    foreach ($disk in $disks) {
        $drive = $letter.ToString()
        $disk | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $drive |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $letter -Confirm:$false -Force
    $count++
    }
$ADI = Get-CimInstance -Class Win32_Volume -Filter "driveletter='F:'"
Set-CimInstance -InputObject $ADI -Arguments @{Label="ADI"}

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
New-PSDrive -Name X -PSProvider FileSystem -Root "\\$SAName.file.core.windows.net\$AzureFileShareName" -Credential $credential

#REMOTE DESKTOP GATEWAY
#Add-WindowsFeature –Name 'RDS-Gateway' -IncludeAllSubFeature
