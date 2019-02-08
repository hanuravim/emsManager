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
