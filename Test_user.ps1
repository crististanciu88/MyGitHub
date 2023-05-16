function Update-ServicePasswordAndRestart {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ServerName,

        [Parameter(Mandatory=$true)]
        [string]$Username,

        [Parameter(Mandatory=$true)]
        [string]$NewPassword
    )

    try {
        $scriptBlock = {
            param($user, $password)
            $services = Get-WmiObject -Class Win32_Service -Filter "StartName='$user'"

            if ($services) {
                foreach ($service in $services) {
                    Write-Host "Updating password for service $($service.Name)..."
                    $service.Change($null, $null, $null, $null, $null, $null, $null, $password)
                    
                    if ($service.State -eq "Running") {
                        Write-Host "Restarting service $($service.Name)..."
                        $service.StopService()
                        Start-Sleep -Seconds 2  # Adjust the delay as needed
                        $service.StartService()
                    }
                }
            }
            else {
                Write-Host "No services found running under user $user."
            }
        }

        Invoke-Command -ComputerName $ServerName -ScriptBlock $scriptBlock -ArgumentList $Username, $NewPassword
    }
    catch {
        Write-Host "An error occurred while updating services: $($_.Exception.Message)"
    }
}
