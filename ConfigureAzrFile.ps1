Param (
  [Parameter()]
  [String]$SAKey,
  [String]$SAName,
  [String]$AzureFileShareName
)
#CONFIGURE AZURE FILE SHARE ON PORTAL
Set-MpPreference -DisableRealtimeMonitoring $true
