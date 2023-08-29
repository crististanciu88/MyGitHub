# Import the IISAdministration module
Import-Module IISAdministration

# Get the computer name of the remote server
$computerName = "localhost"

# Connect to the remote server using Invoke-Command
Invoke-Command -ComputerName $computerName {

  # Get the application pool names
  Get-WebApplicationPool | Select-Object Name, State, Identity

  # Get the website names
  Get-IISSite | Select-Object Name, State, Bindings

  # Get the user under that application pool
  Get-WebApplicationPool -Name $_.Name | Select-Object Identity

  # Get the computer name
  Get-ComputerName
}

# Format the output as a table
$results | Format-Table -AutoSize
