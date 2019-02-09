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

