function Get-IISInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName
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

    $iisSitesInfo | Format-Table -AutoSize
}

# Usage
# Get-IISInfo -ServerName "ServerName"
