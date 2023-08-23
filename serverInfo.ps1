$services | Select-Object Name, StartMode, @{Name='PathName'; Expression={$_.PathName -replace '^"(.*)"$', '$1'}} | Format-Table -AutoSize


function Get-HardwareInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ServerNames
    )

    $results = @()

    foreach ($ServerName in $ServerNames) {
        $hardware = Invoke-Command -ComputerName $ServerName -ScriptBlock {
            $processor = Get-CimInstance -ClassName Win32_Processor
            $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
            $diskC = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'"
            $diskD = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'D:'"
                    
            [PSCustomObject]@{
                'ServerName' = $env:COMPUTERNAME
                'ProcessorName' = $processor.Name
                'NumberOfCores' = ($processor | Measure-Object -Property NumberOfCores -Sum).Sum
                'TotalPhysicalMemoryGB' = [Math]::Round($memory.Capacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum / 1GB)
                'DiskCSizeGB' = [Math]::Round($diskC.Size / 1GB)
                'DiskDSizeGB' = [Math]::Round($diskD.Size / 1GB)
            }
        }

        $results += $hardware
    }

    $results | Format-Table -AutoSize
}

# Usage
# $hardwareInfo = Get-HardwareInfo -ServerNames @("Server1", "Server2", "Server3")
