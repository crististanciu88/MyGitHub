param (
    [string]$appPoolName,
    [string]$outputXmlPath
)

# Get the application pool settings
$appPool = Get-Item "IIS:\AppPools\$appPoolName"
$appPoolSettings = $appPool | Get-ItemProperty

# Select specific properties for export
$selectedProperties = @{
    'Name' = $appPoolName
    'ManagedPipelineMode' = $appPoolSettings.ManagedPipelineMode
    'Enable32BitAppOnWin64' = $appPoolSettings.Enable32BitAppOnWin64
    'ProcessModel' = $appPoolSettings.ProcessModel
    'Recycling' = $appPoolSettings.Recycling
    'AutoStart' = $appPoolSettings.AutoStart
}

# Create a custom XML document
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlRoot = $xmlDoc.CreateElement('AppPoolSettings')
$xmlDoc.AppendChild($xmlRoot)

# Add selected properties to the XML
foreach ($property in $selectedProperties.Keys) {
    $xmlProperty = $xmlDoc.CreateElement($property)
    $xmlProperty.InnerText = $selectedProperties[$property]
    $xmlRoot.AppendChild($xmlProperty)
}

# Save the XML to the specified location
$xmlDoc.Save($outputXmlPath)

Write-Host "AppPool settings exported to: $outputXmlPath"
