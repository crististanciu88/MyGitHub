@echo off
setlocal

set "username=DOMAIN\USERNAME"
set "newPassword=NEW_PASSWORD"

for /f "tokens=2" %%i in ('appcmd list apppool /state:Started /text:ProcessModel.UserName /value') do (
    if /i "%%i"=="%username%" (
        appcmd set apppool /apppool.name:"%%~i" /processmodel.username:"%username%" /processmodel.password:"%newPassword%"
    )
)

for /f "tokens=2" %%i in ('appcmd list site /state:Started /text:applicationPool /value') do (
    set "siteAppPool=%%i"
    set "siteAppPoolUsername=!siteAppPool:%username:~8%=%username%!"
    if /i "!siteAppPoolUsername!"=="%username%" (
        appcmd set site /site.name:"%%~nxi" /applicationPool:"!siteAppPool:%username:~8%=%username%!"
    )
)

for /f "tokens=2" %%i in ('appcmd list vdir /state:Started /text:applicationPool /value') do (
    set "vdirAppPool=%%i"
    set "vdirAppPoolUsername=!vdirAppPool:%username:~8%=%username%!"
    if /i "!vdirAppPoolUsername!"=="%username%" (
        appcmd set vdir /vdir.name:"%%~i" /applicationPool:"!vdirAppPool:%username:~8%=%username%!"
    )
)

net stop w3svc
net start w3svc

net user %username% %newPassword%
____________________________________________________________

@echo off
setlocal

set "username=DOMAIN\USERNAME"
set "newPassword=NEW_PASSWORD"

net user %username% %newPassword%

for /f "tokens=2" %%i in ('appcmd list apppool /state:Started /text:ProcessModel.UserName /value') do (
    if /i "%%i"=="%username%" (
        appcmd set apppool /apppool.name:"%%~i" /processmodel.password:"%newPassword%"
    )
)

for /f "tokens=2" %%i in ('appcmd list site /state:Started /text:applicationPool /value') do (
    set "siteAppPool=%%i"
    set "siteAppPoolUsername=!siteAppPool:%username:~8%=%username%!"
    if /i "!siteAppPoolUsername!"=="%username%" (
        appcmd set site /site.name:"%%~nxi" /applicationPool:"!siteAppPool:%username:~8%=%username%!"
    )
)

for /f "tokens=2" %%i in ('appcmd list vdir /state:Started /text:applicationPool /value') do (
    set "vdirAppPool=%%i"
    set "vdirAppPoolUsername=!vdirAppPool:%username:~8%=%username%!"
    if /i "!vdirAppPoolUsername!"=="%username%" (
        appcmd set vdir /vdir.name:"%%~i" /applicationPool:"!vdirAppPool:%username:~8%=%username%!"
    )
)

net stop w3svc
net start w3svc

_____________________________

@echo off
setlocal

set "username=DOMAIN\USERNAME"
set "newPassword=NEW_PASSWORD"

dsmod user %username% -pwd %newPassword%

for /f "tokens=2" %%i in ('appcmd list apppool /state:Started /text:ProcessModel.UserName /value') do (
    if /i "%%i"=="%username%" (
        appcmd set apppool /apppool.name:"%%~i" /processmodel.password:"%newPassword%"
    )
)

for /f "tokens=2" %%i in ('appcmd list site /state:Started /text:applicationPool /value') do (
    set "siteAppPool=%%i"
    set "siteAppPoolUsername=!siteAppPool:%username:~8%=%username%!"
    if /i "!siteAppPoolUsername!"=="%username%" (
        appcmd set site /site.name:"%%~nxi" /applicationPool:"!siteAppPool:%username:~8%=%username%!"
    )
)

for /f "tokens=2" %%i in ('appcmd list vdir /state:Started /text:applicationPool /value') do (
    set "vdirAppPool=%%i"
    set "vdirAppPoolUsername=!vdirAppPool:%username:~8%=%username%!"
    if /i "!vdirAppPoolUsername!"=="%username%" (
        appcmd set vdir /vdir.name:"%%~i" /applicationPool:"!vdirAppPool:%username:~8%=%username%!"
    )
)

net stop w3svc
net start w3svc
