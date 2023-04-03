$ServerList = @("server1", "server2", "server3") # Replace with your list of servers
$ServiceList = @("service1", "service2", "service3") # Replace with your list of services to monitor
$SiteList = @("site1", "site2", "site3") # Replace with your list of IIS sites to monitor

$OutputFile = "ServerStatus.html" # Replace with the name and path of the output HTML file

# Function to check if a service is running on a server
function Check-Service {
    param (
        [string]$ServerName,
        [string]$ServiceName
    )
    $service = Get-Service -ComputerName $ServerName -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service.Status -eq "Running") {
        return "Running"
    } else {
        return "Not Running"
    }
}

# Function to check if a website is running on a server
function Check-Website {
    param (
        [string]$ServerName,
        [string]$SiteName
    )
    $site = Get-Website -ComputerName $ServerName -Name $SiteName -ErrorAction SilentlyContinue
    if ($site.State -eq "Started") {
        return "Running"
    } else {
        return "Not Running"
    }
}

# HTML table headers
$table = "<table><tr><th>Server Name</th><th>Service Status</th><th>Site Status</th></tr>"

foreach ($server in $ServerList) {
    # Get service status
    $serviceStatuses = @()
    foreach ($service in $ServiceList) {
        $serviceStatus = Check-Service -ServerName $server -ServiceName $service
        $serviceStatuses += $serviceStatus
    }
    $serviceStatusText = $serviceStatuses -join "<br>"

    # Get website status
    $siteStatuses = @()
    foreach ($site in $SiteList) {
        $siteStatus = Check-Website -ServerName $server -SiteName $site
        $siteStatuses += $siteStatus
    }
    $siteStatusText = $siteStatuses -join "<br>"

    # Add row to HTML table
    $table += "<tr><td>$server</td><td>$serviceStatusText</td><td>$siteStatusText</td></tr>"
}

$table += "</table>"

# Save output to HTML file
$html = "<html><body><h1>Server Status</h1>$table</body></html>"
$html | Out-File -FilePath $OutputFile -Encoding utf8
