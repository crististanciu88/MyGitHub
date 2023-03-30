function Update-IISCredentials {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string]$Username,

        [Parameter(Mandatory=$true)]
        [string]$NewPassword
    )

    Process {
        foreach ($computer in $ComputerName) {
            Write-Host "Updating credentials on $computer"

            # Get the SID of the user account
            $user = Get-ADUser -Identity $Username
            $userSID = $user.SID.Value

            # Update the credentials for the IIS app pools
            $iisAppPools = Get-ChildItem "IIS:\AppPools" -PSProvider WebAdministration -ComputerName $computer
            foreach ($appPool in $iisAppPools) {
                $appPoolIdentity = $appPool.processModel.userName
                if ($appPoolIdentity -eq $Username) {
                    Set-ItemProperty $appPool.PSPath -Name processModel.username -Value $Username
                    Set-ItemProperty $appPool.PSPath -Name processModel.password -Value $NewPassword
                }
            }

            # Update the credentials for the IIS sites
            $iisSites = Get-ChildItem "IIS:\Sites" -PSProvider WebAdministration -ComputerName $computer
            foreach ($site in $iisSites) {
                $siteIdentity = (Get-ItemProperty $site.PSPath -Name applicationPool).applicationPool
                if ($siteIdentity -eq $Username) {
                    Set-ItemProperty $site.PSPath -Name applicationPool -Value $site.applicationPool.Replace($site.applicationPool.Split('\')[1], $Username.Split('\')[1])
                }
            }

            # Update the credentials for the IIS virtual directories
            $iisVDirs = Get-ChildItem "IIS:\Sites\*\*" -PSProvider WebAdministration -ComputerName $computer
            foreach ($vdir in $iisVDirs) {
                $vdirIdentity = (Get-ItemProperty $vdir.PSPath -Name applicationPool).applicationPool
                if ($vdirIdentity -eq $Username) {
                    Set-ItemProperty $vdir.PSPath -Name applicationPool -Value $vdir.applicationPool.Replace($vdir.applicationPool.Split('\')[1], $Username.Split('\')[1])
                }
            }

            # Restart the IIS service
            Invoke-Command -ComputerName $computer -ScriptBlock { Restart-Service W3SVC }
        }
    }
}
