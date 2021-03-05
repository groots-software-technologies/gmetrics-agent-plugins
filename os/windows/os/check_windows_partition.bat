@ECHO OFF
SETLOCAL

REM ####### ensure all required info is present --UNIX Var--######
@Echo %1%2%3%4|find "ARG"
IF NOT ERRORLEVEL 1 GOTO help

REM ####### ensure all required info is present --Win Var--######
IF "%1"=="" goto help
IF "%2"=="" goto help
IF "%3"=="" goto help
IF "%4"=="" goto help

@SETLOCAL ENABLEEXTENSIONS
@SETLOCAL ENABLEDELAYEDEXPANSION

REM ####### assign each to a variable to reference it later..######
SET HOSTNAME=%1
SET DRIVE=%2
SET WARNING=%3
SET CRITICAL=%4

REM ####### Compare input threshol.
IF %WARNING% GEQ %CRITICAL% goto help

@FOR /F "tokens=1-3" %%n IN ('"WMIC /node:"%HOSTNAME%" LOGICALDISK GET Name,Size,FreeSpace | find /i "%DRIVE%""') DO @SET FreeBytes=%%n & @SET TotalBytes=%%p

SET TotalGB=0
SET FreeGB=0

REM Parameter value used to convert in GB
set num1=1074

REM Parameter value used to convert in MB or KB
REM set num1 = 1049

REM @ECHO Total space: !TotalBytes!

SET /a TotalSpace=!TotalBytes:~0,-6! / !NUM1!
SET /a FreeSpace=!FreeBytes:~0,-7! / !NUM1!

SET TotalGB=!TotalSpace!
SET FreeGB=!FreeSpace!

SET PERNUM=100

SET /A TotalUsed=!TotalSpace! - !FreeSpace!
SET /A MULTIUSED=!TotalUsed!*!PERNUM!
SET /A PERCENTUSED=!MULTIUSED!/!TotalGB!

REM ######## Now the fun stuff,  compare the Warning, Critical values..####

if %PERCENTUSED% GEQ %CRITICAL% goto CRITI-2
if %PERCENTUSED% GEQ %WARNING% goto WARN-1
goto OK-0

:CRITI-2
echo CRITICAL - Drive %DRIVE%, Total space: !TotalGB!GB, Free space : !FreeGB!GB, Percent Used : %PERCENTUSED%^%%^| DriveUsed=%PERCENTUSED%^%%;%WARNING%;%CRITICAL%
@Exit /b 2

:WARN-1
echo WARNING - Drive %DRIVE%, Total space: !TotalGB!GB, Free space : !FreeGB!GB, Percent Used : %PERCENTUSED%^%%^| DriveUsed=%PERCENTUSED%^%%;%WARNING%;%CRITICAL%
@Exit /b 1

:OK-0
echo OK - Drive %DRIVE%, Total space: !TotalGB!GB, Free space : !FreeGB!GB, Percent Used : %PERCENTUSED%^%%^| DriveUsed=%PERCENTUSED%^%%;%WARNING%;%CRITICAL%
@Exit /b 0

:help
@echo Usage : %0 localhost ^<PARTITION NAME^> ^<WARNING THRESHOLD^> ^<CRITICAL THRESHOLD^>
echo Example: %0 localhost c: 80 90
@echo example:  /groots/monitoring/config_files/libexec/check_metrics -H 172.19.48.139 -t 600 -c check_disk -a 'localhost c: 80 90' (From Gmetrics SVR.)
@Exit /b 3
:eof
