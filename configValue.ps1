function Set-ConfigValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $xml = New-Object XML
    $xml.Load($Path)

    $found = $false

    foreach ($node in $xml.SelectNodes("//*")) {
        if ($node.Name -eq "add" -and $node.GetAttribute("key") -eq $Key) {
            $node.SetAttribute("value", $Value)
            $found = $true
        }
    }

    if ($found) {
        $xml.Save($Path)
        Write-Output "Value for key '$Key' in '$Path' was set to '$Value'"
    } else {
        Write-Warning "Key '$Key' was not found in '$Path'"
    }
}
