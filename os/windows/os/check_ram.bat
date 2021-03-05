@ECHO OFF

rem Note: KB = KiB, MB = MiB and GB = GiB in this batch file, see
rem       https://en.wikipedia.org/wiki/Gibibyte for details on GiB.

SETLOCAL

REM ####### ensure all required info is present --UNIX Var--######
@Echo %1%2|find "ARG"
IF NOT ERRORLEVEL 1 GOTO help

REM ####### ensure all required info is present --Win Var--######
IF "%1"=="" goto help
IF "%2"=="" goto help

@SETLOCAL ENABLEEXTENSIONS
@SETLOCAL ENABLEDELAYEDEXPANSION

REM ####### assign each to a variable to reference it later..######
SET WARNING=%1
SET CRITICAL=%2

REM ####### Compare input threshol.
IF %WARNING% GEQ %CRITICAL% goto help

REM ####### Gather memory size and used size.

:GetTotalMemory
for /F "skip=1" %%M in ('%SystemRoot%\System32\wbem\wmic.exe ComputerSystem get TotalPhysicalMemory') do set "TotalMemory=%%M" & goto GetAvailableMemory

:GetAvailableMemory
for /F "skip=1" %%M in ('%SystemRoot%\System32\wbem\wmic.exe OS get FreePhysicalMemory') do set "AvailableMemory=%%M" & goto ProcessValues

rem Total physical memory is in bytes which can be greater 2^31 (= 2 GB)
rem Windows command processor performs arithmetic operations always with
rem 32-bit signed integer. Therefore more than 2 GB installed physical
rem memory exceeds the bit width of a 32-bit signed integer and arithmetic
rem calculations are wrong on more than 2 GB installed memory. To avoid
rem the integer overflow, the last 6 characters are removed from bytes
rem value and the remaining characters are divided by 1073 to get the
rem number of GB. This workaround works only for physical RAM being
rem an exact multiple of 1 GB, i.e. for 1 GB, 2 GB, 4 GB, 8 GB, ...

rem  1 GB =  1.073.741.824 bytes = 2^30
rem  2 GB =  2.147.483.648 bytes = 2^31
rem  4 GB =  4.294.967.296 bytes = 2^32
rem  8 GB =  8.589.934.592 bytes = 2^33
rem 16 GB = 17.179.869.184 bytes = 2^34
rem 32 GB = 34.359.738.368 bytes = 2^35

:ProcessValues
set "TotalMemory=%TotalMemory:~0,-6%"
set /A TotalMemory+=50
set /A TotalMemory/=1073

set /A TotalMemory*=1024

set /A AvailableMemory/=1024

set /A UsedMemory=TotalMemory - AvailableMemory

set /A UsedPercent=(UsedMemory * 100) / TotalMemory

REM ######## Now the fun stuff,  compare the Warning, Critical values..####

if %UsedPercent% GEQ %CRITICAL% goto CRITI-2
if %UsedPercent% GEQ %WARNING% goto WARN-1
goto OK-0

:CRITI-2
echo CRITICAL - Total memory: %TotalMemory% MB, Used memory: %UsedMemory% MB, Free memory: %AvailableMemory% MB^| Totalmemory=%TotalMemory%MB Usedmemory=%UsedMemory%MB Freememory=%AvailableMemory%MB
@Exit /b 2

:WARN-1
echo WARNING - Total memory: %TotalMemory% MB, Used memory: %UsedMemory% MB, Free memory: %AvailableMemory% MB^| Totalmemory=%TotalMemory%MB Usedmemory=%UsedMemory%MB Freememory=%AvailableMemory%MB
@Exit /b 1

:OK-0
echo OK - Total memory: %TotalMemory% MB, Used memory: %UsedMemory% MB, Free memory: %AvailableMemory% MB^| Totalmemory=%TotalMemory%MB Usedmemory=%UsedMemory%MB Freememory=%AvailableMemory%MB
@Exit /b 0

:help
@echo Usage : %0 ^<WARNING THRESHOLD^> ^<CRITICAL THRESHOLD^>
echo Example: %0 80 90
@echo example: /groots/monitoring/config_files/libexec/check_metrics -H 172.19.48.139 -c check_ram -a "80 90" (From Gmetrics SVR.)
@Exit /b 3

ENDLOCAL