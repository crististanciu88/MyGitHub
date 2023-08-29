function Get-IISInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    $iisSitesInfo = Invoke-Command -ComputerName $ServerName -ScriptBlock {
        Import-Module WebAdministration

        $iisSites = Get-Website

        $iisSites | ForEach-Object {
            $bindingsInfo = $_.Bindings.Collection | ForEach-Object { "$($_.BindingInformation) ($($_.Protocol))" }
            
            [PSCustomObject]@{
                'SiteName' = $_.Name
                'BindingInformation' = $bindingsInfo -join '; '
                'Protocol' = $_.Bindings.Collection.Protocol -join '; '
                'PhysicalPath' = $_.PhysicalPath
                'State' = $_.State
            }
        }
    }

    $iisAppPoolsInfo = Invoke-Command -ComputerName $ServerName -ScriptBlock {
        Import-Module WebAdministration

        $iisAppPools = Get-WebAppPool

        $iisAppPools | ForEach-Object {
            [PSCustomObject]@{
                'AppPoolName' = $_.Name
                'AppPoolState' = $_.State
            }
        }
    }

    $combinedInfo = $iisAppPoolsInfo | ForEach-Object {
        $appPool = $_
        $site = $iisSitesInfo | Where-Object { $_.SiteName -eq $appPool.AppPoolName }

        if ($site) {
            $site | Select-Object *, @{Name='AppPoolState'; Expression={$appPool.AppPoolState}}
        } else {
            [PSCustomObject]@{
                'SiteName' = $appPool.AppPoolName
                'BindingInformation' = ''
                'Protocol' = ''
                'PhysicalPath' = ''
                'State' = ''
                'AppPoolName' = $appPool.AppPoolName
                'AppPoolState' = $appPool.AppPoolState
            }
        }
    }

    $combinedInfo | Export-Csv -Path $OutputPath -NoTypeInformation
}

# Usage
# Get-IISInfo -ServerName "ServerName" -OutputPath "C:\Path\To\Output.csv"
