function Get-ServerInfo {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ServerName
    )

    $status = $null
    $serverInfo = $null

    if (Test-Connection -ComputerName $ServerName -Count 1 -Quiet) {
        try {
            $serverInfo = Invoke-Command -ComputerName $ServerName -ScriptBlock {
                $info = @{
                    'ServerName' = $env:COMPUTERNAME
                    'ProcessorName' = (Get-CimInstance -ClassName Win32_Processor).Name
                    'TotalPhysicalMemoryGB' = [Math]::Round((Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
                    'AvailablePhysicalMemoryGB' = [Math]::Round((Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Memory).AvailableBytes / 1GB)
                    'DiskCSizeGB' = [Math]::Round((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'").Size / 1GB)
                    'DiskCAvailableSpaceGB' = [Math]::Round((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'C:'").FreeSpace / 1GB)
                    'DiskDSizeGB' = [Math]::Round((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'D:'").Size / 1GB)
                    'DiskDAvailableSpaceGB' = [Math]::Round((Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = 'D:'").FreeSpace / 1GB)
                }
                New-Object PSObject -Property $info
            }
        }
        catch {
            $status = 'Unable to retrieve information'
        }
    }
    else {
        $status = 'Not Available'
    }

    if ($status) {
        [PSCustomObject]@{
            'ServerName' = $ServerName
            'Status' = $status
            'ProcessorName' = ''
            'TotalPhysicalMemoryGB' = ''
            'AvailablePhysicalMemoryGB' = ''
            'DiskCSizeGB' = ''
            'DiskCAvailableSpaceGB' = ''
            'DiskDSizeGB' = ''
            'DiskDAvailableSpaceGB' = ''
        }
    }
    else {
        $serverInfo
    }
}

# Usage
# $serverInfo = Get-ServerInfo -ServerName "ServerName"
