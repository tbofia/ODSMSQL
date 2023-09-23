@echo off
setlocal enabledelayedexpansion

REM determine if they are using NT authentication or not
if "%2"=="nt" goto USING_NT_AUTH
if "%2"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparm_=/T
set pwdparm_=
goto SET_DB

:USING_SQL_AUTH
set unameparm_=/U%2
set pwdparm_=/P%3

:SET_DB
set database_=%4

FOR /F "tokens=1,2 delims= " %%A IN ('sqlcmd -S %1 -h -1 %unameparam_% %pwdparam_% -d %database_% -Q "SET NOCOUNT ON; SELECT ProcessId,TargetTableName FROM adm.Process WHERE ProductKey = 'SmartAdvisor';"') DO (

SET processid_=%%A
SET targettablename_=%%B
REM ECHO !processid_! !targettablename_!

sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i idxdynsrc.sql -o Dynamic\src.!targettablename_!.sql -h -1

)
GOTO End

:End