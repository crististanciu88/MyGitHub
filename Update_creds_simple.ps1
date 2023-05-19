# Define the path to the .config file
$configFilePath = "C:\path\to\your\config.file"

# Define the new password
$newPassword = "new_password"

# Read the .config file as text
$configContent = Get-Content -Path $configFilePath -Raw

# Find and replace the password value
$newConfigContent = $configContent -replace "(?<=<Webpassword>).*?(?=</Webpassword>)", $newPassword

# Save the updated content back to the .config file
$newConfigContent | Set-Content -Path $configFilePath

