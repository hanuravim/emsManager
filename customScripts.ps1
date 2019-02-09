#DISABLE UAC
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 0
shutdown /r
function Connect-AzureFileShare
{
    [CmdletBinding()]
    Param(
        
        [String]$SAName = 'emscutrdevemsstr001',
        [String]$AzureFileShareName = 'emsazrfileshare',
        [ValidateLength(1,2)]
        [String]$DriveLetter = 'Z'
    )
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Azure -Confirm:$False
Import-Module Azure

    $StorageAccount = Get-AzureRMStorageAccount | ?{$_.StorageAccountName -eq "$StorageAccountName"}
    If ($StorageAccountName -eq $StorageAccount.StorageAccountName)
        {

        Write-Verbose "StorageAccountName resolves correctly"
        Write-Debug "Entered [$StorageAccountName] and found [$($StorageAccount.StorageAccountName)]"
        } else {
            Write-Output "Storage Account Not Found"
            Break
        }

    # Validate DriveLetter and correct if needed
    If ($DriveLetter.Length -gt 1)
    {
        Write-Verbose "DriveLetter.Length was Greater than 1"
        If (!($DriveLetter.EndsWith(':')))
        {
            Write-Verbose "DriveLetter[1] was not ':'"
            $DriveLetter[1] = ":"
        }
    } else {

        $DriveLetter = $DriveLetter +":"
    }

    # Check DriveLetter is not currently in use 
    Write-Verbose "Checking drive letter is not in use"
    $DriveExists = (Get-PSDrive -Name $DriveLetter[0] -ErrorAction SilentlyContinue)
    if ($DriveExists)
    {
        Write-Output "DriveLetter $($DriveLetter[0]) is in use, please select another"
        break
    }
    $StorageAccountKey = (Get-AzureRmStorageAccountKey $StorageAccount.StorageAccountName -ResourceGroupName $StorageAccount.ResourceGroupName)[0].Value
    $StorageContext = (New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $StorageAccountKey)
    $UNCPath = "\\" +($StorageAccount.PrimaryEndpoints.File).SubString(8).TrimEnd('/')
    $Share = (Get-AzureStorageShare -Context $StorageContext)
    $CombinedPath = (Join-Path $UNCPath -ChildPath $ShareName)
    $UserName = "/u:" +$StorageAccount.StorageAccountName
    Write-Verbose "Executing: net use $DriveLetter $CombinedPath $UserName $StorageAccountKey"
    
    Return net use $DriveLetter $CombinedPath $UserName $StorageAccountKey
}
Connect-AzureFileShare
#ENABLE UAC
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 1
shutdown /r
