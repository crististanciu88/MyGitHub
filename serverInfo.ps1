function Get-HardwareInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName
    )

    $hardware = Invoke-Command -ComputerName $ServerName -ScriptBlock {
        $processor = Get-CimInstance -ClassName Win32_Processor
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
        $diskC = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'"
        $diskD = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'D:'"

        $services = Get-Service | Where-Object {$_.Name -like 'test*'} | ForEach-Object {
            $serviceInfo = Get-WmiObject -Class Win32_Service -Filter "Name = '$($_.Name)'"
            [PSCustomObject]@{
                'Name' = $serviceInfo.Name
                'Status' = $serviceInfo.State
                'BinaryPath' = $serviceInfo.PathName
                'StartName' = $serviceInfo.StartName
                'StartMode' = $serviceInfo.StartMode
            }
        }
                
        [PSCustomObject]@{
            'ServerName' = $env:COMPUTERNAME
            'ProcessorName' = $processor.Name
            'NumberOfCores' = $processor.NumberOfCores
            'TotalPhysicalMemoryGB' = [Math]::Round($memory.Capacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum / 1GB)
            'DiskCSizeGB' = [Math]::Round($diskC.Size / 1GB)
            'DiskDSizeGB' = [Math]::Round($diskD.Size / 1GB)
            'ServicesInfo' = $services
        }
    }

    $hardware
}

# Usage
# $hardwareInfo = Get-HardwareInfo -ServerName "ServerName"
