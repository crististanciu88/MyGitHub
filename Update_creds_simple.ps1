# Define variables
$username = "domain\username"
$newpassword = "newpassword"
$iisAppPools = Get-ChildItem IIS:\AppPools
$iisSites = Get-ChildItem IIS:\Sites
$iisVDirs = Get-ChildItem IIS:\Sites\*\*

# Update the credentials for the IIS app pools
foreach ($appPool in $iisAppPools) {
    Set-ItemProperty $appPool.PSPath -Name processModel.username -Value $username
    Set-ItemProperty $appPool.PSPath -Name processModel.password -Value $newpassword
}

# Update the credentials for the IIS sites
foreach ($site in $iisSites) {
    Set-ItemProperty $site.PSPath -Name applicationPool -Value $site.applicationPool.Replace($site.applicationPool.Split('\')[1], $username.Split('\')[1])
}

# Update the credentials for the IIS virtual directories
foreach ($vdir in $iisVDirs) {
    Set-ItemProperty $vdir.PSPath -Name applicationPool -Value $vdir.applicationPool.Replace($vdir.applicationPool.Split('\')[1], $username.Split('\')[1])
}

# Restart the IIS service
Restart-Service W3SVC
