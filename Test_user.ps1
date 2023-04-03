function Test-IISUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    # Convert the password to a secure string
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Define a hash table to store the IIS settings
    $IISConfig = @{
        AppPools = @()
        Sites = @()
        VirtualDirectories = @()
    }

    # Get the list of application pools
    $AppPools = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-ChildItem IIS:\AppPools
    }

    foreach ($AppPool in $AppPools) {
        $AppPoolUser = $AppPool.processModel.userName
        if ($AppPoolUser -eq $UserName) {
            $IISConfig.AppPools += @{
                Name = $AppPool.Name
                UserName = $AppPoolUser
            }
        }
    }

    # Get the list of sites
    $Sites = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-ChildItem IIS:\Sites
    }

    foreach ($Site in $Sites) {
        $SiteUserName = $Site.applicationDefaults.applicationPool.processModel.userName
        if ($SiteUserName -eq $UserName) {
            $IISConfig.Sites += @{
                Name = $Site.Name
                UserName = $SiteUserName
            }
        }

        # Get the list of virtual directories for each site
        $VirtualDirectories = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            Get-ChildItem "IIS:\Sites\$($Site.Name)\"
        }

        foreach ($Vdir in $VirtualDirectories) {
            $VdirUserName = $Vdir.applicationPool.processModel.userName
            if ($VdirUserName -eq $UserName) {
                $IISConfig.VirtualDirectories += @{
                    Name = $Vdir.Path
                    UserName = $VdirUserName
                }
            }
        }
    }

    # Check if the user exists in any IIS setting
    $UserExists = $false
    if ($IISConfig.AppPools.Count -gt 0 -or $IISConfig.Sites.Count -gt 0 -or $IISConfig.VirtualDirectories.Count -gt 0) {
        $UserExists = $true
    }

    # Return the result and the IIS configuration
    [PSCustomObject]@{
        UserName = $UserName
        Exists = $UserExists
        IISConfig = $IISConfig
    }
}
# Invoke-Command -ComputerName COMPUTERNAME -ScriptBlock {Test-IISUser -ComputerName "COMPUTERNAME" -UserName "DOMAIN\USERNAME" -Password "PASSWORD"}

function Test-IISUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    # Convert the password to a secure string
    
  
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Check if the user exists in any IIS setting
    $UserExists = $false

    # Get the list of application pools, sites, and virtual directories
    $AppPools = Get-ChildItem IIS:\AppPools
    $Sites = Get-ChildItem IIS:\Sites

    foreach ($Site in $Sites) {
        # Check if the user is assigned to the site's application pool
        if ($Site.applicationDefaults.applicationPool.processModel.userName -eq $UserName) {
            $UserExists = $true
            break
        }

        # Get the list of virtual directories for the site
        $VirtualDirectories = Get-ChildItem "IIS:\Sites\$($Site.Name)\"

        foreach ($Vdir in $VirtualDirectories) {
            # Check if the user is assigned to the virtual directory's application pool
            if ($Vdir.applicationPool.processModel.userName -eq $UserName) {
                $UserExists = $true
                break
            }
        }

        if ($UserExists) {
            break
        }
    }

    foreach ($AppPool in $AppPools) {
        # Check if the user is assigned to the application pool
        if ($AppPool.processModel.userName -eq $UserName) {
            $UserExists = $true
            break
        }
    }

    # Return the result
    [bool]$UserExists
}


function Search-ConfigFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$true)]
        [string]$SearchString
    )

    $matchingFiles = @()

    $configFiles = Get-WmiObject -Class CIM_DataFile -Filter "Drive='C:' AND Extension='config'" -ComputerName $ComputerName | Select-Object -ExpandProperty Name

    foreach ($configFile in $configFiles) {
        $content = Get-Content -Path $configFile -ErrorAction SilentlyContinue
        if ($content -match $SearchString) {
            $matchingFiles += $configFile
        }
    }

    return $matchingFiles
}

$matchingFiles = Search-ConfigFiles -ComputerName "mycomputer" -SearchString "mysearchstring"
Write-Output "Matching files:"
$matchingFiles

function Search-GitLabRepositories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ApiToken,
        
        [Parameter(Mandatory=$true)]
        [string]$GitLabUrl,
        
        [Parameter(Mandatory=$true)]
        [string]$SearchString,
        
        [Parameter(Mandatory=$true)]
        [string[]]$RepositoryNames
    )

    $matchingFiles = @()

    $headers = @{
        "PRIVATE-TOKEN" = $ApiToken
    }

    foreach ($repoName in $RepositoryNames) {
        $url = "$GitLabUrl/api/v4/projects/$($repoName)/repository/files?per_page=100&page=1&ref=master&file_path=**/*&search=$($SearchString)"
        $response = Invoke-RestMethod -Uri $url -Headers $headers

        foreach ($result in $response) {
            if ($result.type -eq "blob" -and $result.content -match $SearchString) {
                $matchingFiles += $result.file_path
            }
        }
    }

    return $matchingFiles
}

$ApiToken = "mygitlabapitoken"
$GitLabUrl = "https://mygitlabinstance.com"
$SearchString = "mysearchstring"
$RepositoryNames = @("mygroup/myrepo1", "mygroup/myrepo2")

$matchingFiles = Search-GitLabRepositories -ApiToken $ApiToken -GitLabUrl $GitLabUrl -SearchString $SearchString -RepositoryNames $RepositoryNames
Write-Output "Matching files:"
$matchingFiles
