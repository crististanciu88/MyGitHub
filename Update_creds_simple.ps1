# Specify the new password and the desired user
$newPassword = "NewPassword123"
$desiredUser = "mydomain\myuser"

# Get the current user's name
$currentUserName = (Get-WmiObject Win32_ComputerSystem).UserName

# Check if the current user is the desired user
if ($currentUserName -eq $desiredUser) {
    # Update the password for all application pools
    Get-ChildItem "IIS:\AppPools" | ForEach-Object {
        $poolName = $_.Name
        Write-Host "Updating password for application pool: $poolName"
        & "$env:SystemRoot\system32\inetsrv\appcmd.exe" set apppool "$poolName" -processModel.password:"$newPassword"
    }

    # Update the password for all IIS sites
    Get-ChildItem "IIS:\Sites" | ForEach-Object {
        $siteName = $_.Name
        Write-Host "Updating password for site: $siteName"
        & "$env:SystemRoot\system32\inetsrv\appcmd.exe" set site "$siteName" -applicationDefaults.password:"$newPassword"
    }

    # Update the password for all virtual directories
    Get-ChildItem "IIS:\Sites" | Get-ChildItem -Recurse | Where-Object { $_.PSIsContainer -eq $false } | ForEach-Object {
        $vdName = $_.Name
        $siteName = $_.PSPath.Split('/', 4)[-1]
        Write-Host "Updating password for virtual directory: $siteName/$vdName"
        & "$env:SystemRoot\system32\inetsrv\appcmd.exe" set vdir "$siteName/$vdName" -password:"$newPassword"
    }
} else {
    Write-Warning "This script can only be run by $desiredUser. Please run the script under $desiredUser's account."
}
