function Get-HardwareInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName
    )

    $hardware = Invoke-Command -ComputerName $ServerName -ScriptBlock {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios = Get-CimInstance -ClassName Win32_BIOS
        $processor = Get-CimInstance -ClassName Win32_Processor
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'"

        [PSCustomObject]@{
            'ServerName' = $computerSystem.Name
            'Manufacturer' = $computerSystem.Manufacturer
            'Model' = $computerSystem.Model
            'BIOSVersion' = $bios.SMBIOSBIOSVersion
            'ProcessorName' = $processor.Name
            'NumberOfCores' = $processor.NumberOfCores
            'TotalPhysicalMemoryGB' = [Math]::Round($memory.Capacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum / 1GB)
            'DiskSizeGB' = [Math]::Round($disk.Size / 1GB)
        }
    }

    return $hardware
}
Get-HardwareInfo -ServerName "SERVER_NAME"
