function Get-IISInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName
    )

    $iisInfo = Invoke-Command -ComputerName $ServerName -ScriptBlock {
        Import-Module WebAdministration

        $iisSites = Get-Website
        $iisAppPools = Get-WebAppPoolState

        $iisSitesInfo = $iisSites | ForEach-Object {
            $bindings = $_.Bindings.Collection | ForEach-Object {
                $bindingInfo = $_.EndPoint
                [PSCustomObject]@{
                    'Protocol' = $bindingInfo.Protocol
                    'Port' = $bindingInfo.Port
                }
            }

            [PSCustomObject]@{
                'Name' = $_.Name
                'State' = $_.State
                'Bindings' = $bindings
            }
        }

        [PSCustomObject]@{
            'ServerName' = $env:COMPUTERNAME
            'IIS_Sites' = $iisSitesInfo
            'IIS_AppPools' = $iisAppPools
        }
    }

    $iisInfo
}

# Usage
# $iisInfo = Get-IISInfo -ServerName "ServerName"
