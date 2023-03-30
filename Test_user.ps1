function Test-IISUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    # Convert the password to a secure string
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Define a hash table to store the IIS settings
    $IISConfig = @{
        AppPools = @()
        Sites = @()
        VirtualDirectories = @()
    }

    # Get the list of application pools
    $AppPools = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-ChildItem IIS:\AppPools
    }

    foreach ($AppPool in $AppPools) {
        $AppPoolUser = $AppPool.processModel.userName
        if ($AppPoolUser -eq $UserName) {
            $IISConfig.AppPools += @{
                Name = $AppPool.Name
                UserName = $AppPoolUser
            }
        }
    }

    # Get the list of sites
    $Sites = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-ChildItem IIS:\Sites
    }

    foreach ($Site in $Sites) {
        $SiteUserName = $Site.applicationDefaults.applicationPool.processModel.userName
        if ($SiteUserName -eq $UserName) {
            $IISConfig.Sites += @{
                Name = $Site.Name
                UserName = $SiteUserName
            }
        }

        # Get the list of virtual directories for each site
        $VirtualDirectories = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            Get-ChildItem "IIS:\Sites\$($Site.Name)\"
        }

        foreach ($Vdir in $VirtualDirectories) {
            $VdirUserName = $Vdir.applicationPool.processModel.userName
            if ($VdirUserName -eq $UserName) {
                $IISConfig.VirtualDirectories += @{
                    Name = $Vdir.Path
                    UserName = $VdirUserName
                }
            }
        }
    }

    # Check if the user exists in any IIS setting
    $UserExists = $false
    if ($IISConfig.AppPools.Count -gt 0 -or $IISConfig.Sites.Count -gt 0 -or $IISConfig.VirtualDirectories.Count -gt 0) {
        $UserExists = $true
    }

    # Return the result and the IIS configuration
    [PSCustomObject]@{
        UserName = $UserName
        Exists = $UserExists
        IISConfig = $IISConfig
    }
}
# Invoke-Command -ComputerName COMPUTERNAME -ScriptBlock {Test-IISUser -ComputerName "COMPUTERNAME" -UserName "DOMAIN\USERNAME" -Password "PASSWORD"}
