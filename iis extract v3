#Extract APP POOL
msdeploy -verb:get -source:appPoolConfig='YourAppPoolName' -dest:package=AppPoolConfig.zip
msdeploy -verb:get -source:appPoolConfig='YourAppPoolName' -source:appPoolExtension='YourAppPoolName' -dest:package=AppPoolConfig.zip

#Extract SITE
msdeploy -verb:get -source:webServer,computerName='YourServerName',siteName='YourSiteName' -dest:package=SiteConfig.zip
msdeploy -verb:get -source:webServer,computerName='YourServerName',siteName='YourSiteName' -source:contentPath='YourSiteName' -dest:package=SiteConfig.zip
