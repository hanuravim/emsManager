Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)
#DISABLE UAC
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 0
shutdown /r

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

#DISABLE AUTO UPDATES
sc.exe stop wuauserv

#REMOTE DESKTOP GATEWAY
Install-WindowsFeature -Name 'RDS-Gateway' -IncludeAllSubFeature

#MOUNT AZURE FILE SHARE
$acctKey = ConvertTo-SecureString -String $SAKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azure\$SAName", $acctKey
New-PSDrive -Name X -PSProvider FileSystem -Root "\\$SAName.file.core.windows.net\$AzureFileShareName" -Credential $credential

#ENABLE UAC
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 1
shutdown /r
