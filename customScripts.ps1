Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)
$path = $env:APPDATA + '\persistvar.txt'
$SAKey,$SAName,$AzureFileShareName | Out-File -FilePath $path
$vars = Get-Content -Path $path
$SAKey = $vars[0];$SAName = $vars[1];$AzureFileShareName = $vars[2]


#DISABLE WINDOWS DEFENDER
Set-MpPreference -DisableRealtimeMonitoring $true

#DISABLE AUTO UPDATES
sc.exe stop wuauserv
sc.exe config wuauserv start= disabled

#REMOTE DESKTOP GATEWAY
Install-WindowsFeature -Name 'RDS-Gateway' -IncludeAllSubFeature

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


