@echo OFF
SETLOCAL
REM ####### ensure all required info is present --UNIX Var--######
@Echo %1%2%3%4%5%6|find "ARG"
IF NOT ERRORLEVEL 1 GOTO mseof

REM ####### ensure all required info is present --Win Var--######
IF "%1"=="" goto mseof
IF "%2"=="" goto mseof
IF "%3"=="" goto mseof
IF "%4"=="" goto mseof
IF "%5"=="" goto mseof
IF "%6"=="" goto mseof

@echo %4 |find "%%%"
IF not ERRORLEVEL 1 GOTO mseof
@echo %6 |find "%%%"
IF not ERRORLEVEL 1 GOTO mseof



REM ####### assign each to a variable to reference it later..######
SET ip=%1
SET pkt=%2
SET wrta=%3
SET wpl=%4
SET crta=%5
SET cpl=%6

REM ########  capture fresh data to a File #######
@echo ->%1

ping %ip% -n %pkt% >>%1

REM ########  pickout the data we need from the File #######
FOR /F "tokens=11 delims= " %%k in ('findstr /c:"Lost" %1') do set LST=%%k

IF ERRORLEVEL 1 GOTO timeout
FOR /F "tokens=9 delims= " %%k in ('findstr /c:"Average" %1') do set AVG=%%k

REM ########  trim the variables...####
set AVG=%AVG:m=%
set AVG=%AVG:s=%

:timeout
set LST=%LST:(=%
set LST=%LST:~0,-1%


REM ######## Now the fun stuff,  compare the Warning, Critical values..####

if %LST% GEQ %cpl% goto CPL-2
if %AVG% GEQ %crta% goto Crta-2
if %LST% GEQ %wpl% goto WPL-1
if %AVG% GEQ %wrta% goto Wrta-1

Goto OK-0

:CPL-2
@echo CRITICAL: PKT-LS=%LST%%%^|rta=%crta%;%wrta% pl=%LST%%%;%wpl%;%cpl%
rem GOTO EOF
@exit 2

:Crta-2
@echo CRITICAL: PKT-LS=%LST%%%, RT-AV=%AVG%ms^|rta=%AVG%ms;%wrta%;%crta% pl=%LST%%%;%wpl%;%cpl%
rem GOTO EOF
@exit 2

:WPL-1
@echo WARNING: PKT-LS=%LST%%%, RT-AV=%AVG%ms^|rta=%wrta%;%crta% pl=%LST%%%;%wpl%;%cpl%
rem GOTO EOF
@exit 1

:Wrta-1
@echo WARNING: PKT-LS=%LST%%%, RT-AV=%AVG%ms^|rta=%AVG%ms;%wrta%;%crta% pl=%LST%%%;%wpl%;%cpl%
rem GOTO EOF
@exit 1

:OK-0
@ECHO OK: - PKT-LS=%LST%%%, RT-AV=%AVG%ms^|rta=%AVG%ms;%wrta%;%crta% pl=%LST%%%;%wpl%;%cpl%
rem GOTO EOF
@Exit 0


:mseof
@echo Usage:check_host ^<host_address^> ^<Packets^> ^<wrta^>,^<wpl^> ^<crta^>,^<cpl^>
@echo Usage:check_ping ^<host_address^> ^<Packets^> ^<wrta^>,^<wpl^> ^<crta^>,^<cpl^>
@echo example:  /groots/monitoring/config_files/libexec/check_metrics -2 -H 192.168.137.1 -t 600 -c check_ping -a "127.0.0.1 5 3000,70 4000,80" (From Gmetrics SVR.)
@echo        : check_ping 192.168.0.1 5 200,1 400,10 (From a local win wks where check_ping.bat resides)
@echo        : (wpl\cpl are in percent, without the "%%%" symbol!!)

rem GOTO EOF
@exit 0

:eof