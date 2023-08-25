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
            [PSCustomObject]@{
                'SiteName' = $_.Name
                'BindingInformation' = $_.Bindings.Collection | ForEach-Object { "$($_.BindingInformation) ($($_.Protocol))" } -join '; '
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
